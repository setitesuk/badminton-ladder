#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# $Id$
# $HeadURL$
#
package t::util;
use strict;
use warnings;
use base qw(npg::util Exporter);
use t::dbh;
use Carp;
use npg::model::user;
use DateTime;
use Website::Utilities::Profiler;
use CGI;
use English qw(-no_match_vars);
use Test::More;
use HTML::PullParser;
use YAML qw(LoadFile);
use MIME::Parser;
use MIME::Lite;
use GD;

our $VERSION = do { my ($r) = q$LastChangedRevision: 4043 $ =~ /(\d+)/mx; $r; };
our @EXPORT_OK = qw(is_colour);

$ENV{HTTP_HOST}     = 'test.badminton.com';
$ENV{DOCUMENT_ROOT} = './htdocs';
$ENV{SCRIPT_NAME}   = '/cgi-bin/badminton';
$ENV{dev}           = 'test';

sub dbh {
  my ($self, @args) = @_;

  if($self->{fixtures}) {
    return $self->SUPER::dbh(@args);
  }

  $self->{'dbh'} ||= t::dbh->new({'mock'=>$self->{'mock'}});
  return $self->{'dbh'};
}

sub driver {
  my $self = shift;

  if($self->{fixtures}) {
    return $self->SUPER::driver();
  }

  return $self;
}

sub create {
  my ($self, @args) = @_;

  if($self->{fixtures}) {
    return $self->driver->create(@args);
  }

  return $self->dbh->do(@args);
}

sub new {
  my ($class, @args) = @_;
  my $self = $class->SUPER::new(@args);

  if($self->{fixtures}) {
    $self->load_fixtures();
  }

  return $self;
}

sub load_fixtures {
  my $self = shift;

  if($self->dbsection() ne 'test') {
    croak "dbsection is set to @{[$self->dbsection()]} which is not the same as 'test'. Refusing to go ahead!";
  }

  #########
  # build table definitions
  #
  if(!-e "data/schema.txt") {
    croak "Could not find data/schema.txt";
  }

  $self->log('Loading data/schema.txt');
  my $cmd = sprintf q(cat data/schema.txt | mysql -u%s -P%s %s -h%s %s),
                    $self->dbuser(),
		    $self->dbport(),
		    $self->dbpass()?"-p@{[$self->dbpass()]}":q(),
		    $self->dbhost(),
		    $self->dbname();

  $self->log("Executing: $cmd");
  open my $fh, q(-|), $cmd or croak $ERRNO;
  while(<$fh>) {
    print;
  }
  close $fh or croak $ERRNO;

  #########
  # populate test data
  #
  opendir my $dh, q(t/data/fixtures) or croak "Could not open t/data/fixtures";
  my @fixtures = sort grep { /\d+\-[a-z\d_]+\.yml$/mix } readdir $dh;
  closedir $dh;

  $self->log('Loading fixtures: '. join q[ ], @fixtures);

  my $dbh = $self->dbh();
  for my $fx (@fixtures) {
    my $yml     = LoadFile("t/data/fixtures/$fx");
    my ($table) = $fx =~ /\-([a-z\d_]+)/mix;
#    $self->log("+- Loading $fx into $table");
    my $row1    = $yml->[0];
    my @fields  = keys %{$row1};
    my $query   = qq(INSERT INTO $table (@{[join q(, ), @fields]}) VALUES (@{[join q(,), map { q(?) } @fields]}));

    for my $row (@{$yml}) {
      $dbh->do($query, {}, map { $row->{$_} } @fields);
    }
    $dbh->commit();
  }

  return;
}


sub date_today {
  my ($self,$database) = @_;
  my $dt               = DateTime->now();
  if ($database && $database eq 'mysql') {
    $dt =~ s/T/ /gxms;
    return $dt;
  }
  return $dt;
}

sub prof {
  my $self = shift;
  $self->{'prof'} ||= Website::Utilities::Profiler->new();
  return $self->{'prof'};
}

sub profiler {
  my $self = shift;
  $self->{'prof'} ||= Website::Utilities::Profiler->new();
  return $self->{'prof'};
}

sub data_root {
  return './data';
}

sub cgi {
  my ($self, $cgi) = @_;

  if($cgi) {
    $self->{cgi} = $cgi;
  }

  $self->{cgi} ||= CGI->new();
  return $self->{cgi};
}

sub ora_dbname {
  return 'mock';
}

sub rendered {
  my ($self, $tt_name) = @_;
  local $RS = undef;
  open my $fh, q(<), $tt_name or croak "Error opening $tt_name: $ERRNO";
  my $content = <$fh>;
  close $fh or croak "Error closing $tt_name: $ERRNO";
  return $content;
}

sub test_rendered {
  my ($self, $chunk1, $chunk2) = @_;
  my $fn = $chunk2 || q[];

  if(!$chunk1) {
    diag q(No chunk1 in test_rendered);
  }

  if(!$chunk2) {
    diag q(No chunk2 in test_rendered);
  }

  if($chunk2 =~ m{^t/}mx) {
    $chunk2 = $self->rendered($chunk2);

    if(!length $chunk2) {
      diag("Zero-sized $chunk2. Expected something like\n$chunk1");
    }
  }

  my $chunk1els = $self->parse_html_to_get_expected($chunk1);
  my $chunk2els = $self->parse_html_to_get_expected($chunk2);
  my $pass      = $self->match_tags($chunk2els, $chunk1els);

  if($pass) {
    return 1;

  } else {
    if($fn =~ m{^t/}mx) {
      ($fn) = $fn =~ m{([^/]+)$}mx;
    }
    if(!$fn) {
      $fn = q[blob];
    }

    my $rx = "/tmp/${fn}-chunk-received";
    my $ex = "/tmp/${fn}-chunk-expected";
    open my $fh1, q(>), $rx or croak "Error opening $ex";
    open my $fh2, q(>), $ex or croak "Error opening $rx";
    print $fh1 $chunk1;
    print $fh2 $chunk2;
    close $fh1 or croak "Error closing $ex";
    close $fh2 or croak "Error closing $rx";
    diag("diff $ex $rx");
  }

  return;
}

sub parse_html_to_get_expected {
  my ($self, $html) = @_;
  my $p;
  my $array = [];

  if ($html =~ m{^t/}xms) {
    $p = HTML::PullParser->new(
			       file  => $html,
			       start => '"S", tagname, @attr',
			       end   => '"E", tagname',
			      );
  } else {
    $p = HTML::PullParser->new(
			       doc   => $html,
			       start => '"S", tagname, @attr',
			       end   => '"E", tagname',
			      );
  }

  my $count = 1;
  while (my $token = $p->get_token()) {
    my $tag = q{};
    for (@{$token}) {
      $_ =~ s/\d{4}-\d{2}-\d{2}/date/xms;
      $_ =~ s/\d{2}:\d{2}:\d{2}/time/xms;
      $tag .= " $_";
    }
    push @{$array}, [$count, $tag];
    $count++;
  }

  return $array;
}

sub match_tags {
  my ($self, $expected, $rendered) = @_;
  my $fail = 0;
  my $a;

  for my $tag (@{$expected}) {
    my @temp = @{$rendered};
    my $match = 0;
    for ($a= 0; $a < @temp;) {
      my $rendered_tag = shift @{$rendered};
      if ($tag->[1] eq $rendered_tag->[1]) {
        $match++;
        $a = scalar @temp;
      } else {
        $a++;
      }
    }

    if (!$match) {
      diag("Failed to match '$tag->[1]'");
      return 0;
    }
  }

  return 1;
}

###########
# for catching emails, so firstly they don't get sent from within a test
# and secondly you could then parse the caught email
#

sub catch_email {
  my ($self, $model) = @_;
  $model->{emails} ||= [];
  my $sub = sub {
		my $msg = shift;
    push @{$model->{emails}}, $msg->as_string;
		return;
	};
  MIME::Lite->send('sub', $sub);
  return;
}

##########
# for parsing emails to get information from them, probably caught emails
#

sub parse_email {
  my ($self, $email) = @_;
  my $parser = MIME::Parser->new();
  $parser->output_to_core(1);
  my $entity = $parser->parse_data($email);
  my $ref    = {
		annotation => $entity->bodyhandle->as_string(),
		subject    => $entity->head->get('Subject', 0),
		to         => $entity->head->get('To',0)   || undef,
		cc         => $entity->head->get('Cc',0)   || undef,
		bcc        => $entity->head->get('Bcc',0)  || undef,
		from       => $entity->head->get('From',0) || undef,
	};
  return $ref;
}

#sub cleanup {
##  carp q[t::util skipping cleanup];
#}
sub is_colour {
  my ($png_response, @args) = @_;

  #########
  # strip HTTP response header
  #
  $png_response =~ s/.*?\n\n//smx;

  #########
  # convert blob to GD
  #
  my $gd = GD::Image->newFromPngData($png_response);

  #########
  # status coloured box extends to the bottom-right of the instrument image
  # so pull the bottom-right pixel and check its colour
  #
  my ($width, $height) = $gd->getBounds();
  my $rgb_index        = $gd->getPixel($width-1, $height-1);
  my @rgb              = $gd->rgb($rgb_index);
  diag("status colour is (@rgb)");
  return is_deeply(\@rgb, @args);
}

1;
