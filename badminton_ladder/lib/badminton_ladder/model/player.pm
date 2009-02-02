#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#

package badminton_ladder::model::player;
use strict;
use warnings;
use base qw(badminton_ladder::model);

our $VERSION = 1;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(player_team )]);
__PACKAGE__->has_all();
__PACKAGE__->has_many_through('team|player_team');

sub fields {
  return qw(id_player email forename surname);
}

sub full_name {
  my ($self) = @_;
  return $self->forename().q{ }.$self->surname();
}

1;
__END__

=head1 NAME

badminton_ladder::model::player

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oPlayer = badminton_ladder::model::player->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - field descriptors

=head2 date_today - returns a date string. May be reuested as mysql for yyyy-mm-dd, else returns a human readable date dd mon yyyy

  my $sDate = $oPlayer->date_today({type => 'mysql|human'});

=head2 human_date - returns a string dd mon yyyy from a given date string

  my $sDate = $oPlayer->human_date({mysql_date => 'yyyy-mm-dd'});

=head2 full_name - returns a string with the forename and surname concatenated together

  my $sFullName = $oPlayer->full_name();

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item badminton_ladder::model

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
