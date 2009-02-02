#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package t::dbh;
use strict;
use warnings;
use Carp;

sub new {
  my ($class, $ref) = @_;
  $ref ||= {};
  $ref->{stack} = [];
  bless $ref, $class;

  for my $m (keys %{$ref->{mock}}) {
    my $v = $ref->{mock}->{$m};
    $m =~ s/\s+/ /smxg;
    $ref->{mock}->{$m} = $v;
  }

  return $ref;
}

sub prepare {
  my ($self, $stmt) = @_;
  $self->{ptr} = 0;
  push @{$self->{stack}}, $stmt;
  return $self;
}

sub prepare_cached {
  my $self = shift;
  return $self->prepare(@_);
}

sub execute {
  my $self = shift;
  push @{$self->{stack}}, \@_;
  return;
}

sub rollback {
}

sub commit {
}

sub finish {
  my $self = shift;
  pop @{$self->{'stack'}};
  pop @{$self->{'stack'}};
  $self->{'ptr'} = 0;
  return;
}

sub disconnect {
}

sub do {
  my ($self, $dummy, @args) = @_;
  if(ref $dummy ne 'HASH') {
    unshift @args, $dummy;
  }
  return $self->mockfetch(@args);
}

sub fetchrow_hashref {
  my $self = shift;
  my $args = $self->{stack}->[-1];
  my $stmt = $self->{stack}->[-2];
  my $data = $self->mockfetch($stmt, @{$args});
  if($self->{ptr}+1 > scalar @{$data}) {
    return;
  }

  my $v = $data->[$self->{ptr}];
  $self->{ptr}++;
  $self->{rows} = $self->{ptr};
  return $v;
}

sub selectall_arrayref {
  my $self = shift;
  return $self->mockfetch(@_);
}

sub mockfetch {
  my ($self, $query, @params) = @_;
  my $merge = $query . ':' . join q(,), map { (defined $_)?$_:q(NULL) } @params;
  $merge    =~ s/(ARRAY|HASH|GLOB)\(0x[\da-z]+\)//smxg;
  $merge    =~ s/\s+/ /smxg;

  if(!$self->{mock}->{$merge}) {
    croak "No mock data for q($merge)";
  }

  if(ref $self->{mock}->{$merge}) {
    $self->{rows} = scalar @{$self->{mock}->{$merge}};
  } else {
    $self->{rows} = 0;
  }

  return $self->{mock}->{$merge};
}

sub rows {
  my $self = shift;
  return $self->{rows} || -1;
}

1;
