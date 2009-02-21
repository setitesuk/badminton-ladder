#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#

package badminton_ladder::model::ladder;
use strict;
use warnings;
use base qw(badminton_ladder::model);
use DateTime;
use Readonly;
use badminton_ladder::model::team;

our $VERSION = 1;

Readonly::Scalar our $DAYS_BEFORE_DROPPING_OUT_OF_LADDER => 42;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(team ladder_type )]);
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder id_team id_ladder_type last_played position);
}

sub get_ladders {
  my ($self, $ladder_description) = @_;
  my $q = q{SELECT l.id_ladder AS id_ladder, t.name AS name, l.last_played AS last_played, l.position AS position, t.id_team AS id_team, t.challenged_by AS challenged_by
            FROM team t, ladder l, ladder_type lt
            WHERE lt.description = ?
            AND   lt.id_ladder_type = l.id_ladder_type
            AND   l.id_team = t.id_team
            ORDER BY l.position
            };
  my $dbh = $self->util->dbh();
  my $sth = $dbh->prepare($q);
  $sth->execute($ladder_description);
  my $return = [];
  while (my $row = $sth->fetchrow_hashref()) {
    push @{$return}, $row;
  }
  return $return;
}

sub main_ladder {
  my ($self) = @_;
  return $self->get_ladders('Main');
}
sub challenging_ladder {
  my ($self) = @_;
  if (!$self->{challenging_ladder}) {
    $self->{challenging_ladder} = $self->get_ladders('Challenging');
  }
  return $self->{challenging_ladder};
}
sub out_of_ladder {
  my ($self) = @_;
  if (!$self->{out_of_ladder}) {
    $self->{out_of_ladder} = $self->get_ladders('Out of Ladder');
  }
  return $self->{out_of_ladder};
}

sub challenger {
  my ($self, $id_team) = @_;
  return badminton_ladder::model::team->new({util => $self->util})->challenger($id_team);
}

sub assess_positions {
  my ($self) = @_;
  my $ladders = $self->main_ladder();
  my $dt = $self->datetime_object_for_now;
  $dt->subtract( days => $DAYS_BEFORE_DROPPING_OUT_OF_LADDER );

  my $drop_outs = [];
  my $out_of_ladder_type_id = badminton_ladder::model::ladder_type->new({
    util => $self->util(),
    description => 'Out of Ladder',
  })->id_ladder_type();
  my $next_position = 1;
  my $number_dropped = 0;
  my $pkg = ref$self;
  foreach my $l (@{$ladders}) {
    my ($y, $m, $d) = $l->{last_played} =~ /(\d{4})-(\d{2})-(\d{2})/xms;
    my $l_dt = DateTime->new({
      year => $y, month => $m, day => $d, time_zone => 'UTC',
    });
    my $l_obj = $pkg->new({
      util => $self->util(),
      id_ladder => $l->{id_ladder},
    });
    $l_obj->read();
    my $diff = $dt->subtract_datetime_absolute( $l_dt );
    if ($diff->is_positive()) {
      $next_position = $l->{position} - $number_dropped;
      $number_dropped++;
      $l_obj->position(0);
      $l_obj->id_ladder_type($out_of_ladder_type_id);
    } else {
      $l_obj->position($next_position);
      $next_position++;
    }
    $l_obj->update();
  }
  $self->{out_of_ladder} = undef;
  return 1;
}

1;
__END__

=head1 NAME

badminton_ladder::model::ladder

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oLadder = badminton_ladder::model::ladder->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - field descriptors

=head2 date_today - returns a date string. May be reuested as mysql for yyyy-mm-dd, else returns a human readable date dd mon yyyy

  my $sDate = $oLadder>date_today({type => 'mysql|human'});

=head2 human_date - returns a string dd mon yyyy from a given date string

  my $sDate = $oLadder->human_date({mysql_date => 'yyyy-mm-dd'});

=head2 assess_positions
=head2 challenger
=head2 challenging_ladder
=head2 get_ladders
=head2 main_ladder
=head2 out_of_ladder

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item badminton_ladder::model

=item badminton_ladder::model::team

=item badminton_ladder::model::ladder_type

=item DateTime

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Andy Brown, E<lt>setitesuk@gmail.com<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
