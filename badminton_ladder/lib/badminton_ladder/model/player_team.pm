#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#

package badminton_ladder::model::player_team;
use strict;
use warnings;
use base qw(badminton_ladder::model);
use badminton_ladder::model::team;
use badminton_ladder::model::player;

our $VERSION = 1;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(player team)]);
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_player_team id_player id_team);
}

sub all_teams {
  my ($self) = @_;
  if (!$self->{all_teams}) {
    my $team = badminton_ladder::model::team->new({ util => $self->util() });
    $self->{all_teams} = $team->teams();
  }
  return $self->{all_teams};
}

sub all_players {
  my ($self) = @_;
  if (!$self->{all_players}) {
    my $player = badminton_ladder::model::player->new({ util => $self->util() });
    $self->{all_players} = $player->players();
  }
  return $self->{all_players};
}

1;
__END__

=head1 NAME

badminton_ladder::model::player_team

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oPlayerTeam = badminton_ladder::model::player_team->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - field descriptors

=head2 date_today - returns a date string. May be reuested as mysql for yyyy-mm-dd, else returns a human readable date dd mon yyyy

  my $sDate = $oPlayerTeam->date_today({type => 'mysql|human'});

=head2 human_date - returns a string dd mon yyyy from a given date string

  my $sDate = $oPlayerTeam->human_date({mysql_date => 'yyyy-mm-dd'});

=head2 all_teams - obtain an arrayref of all teams

  my $aAllTeams = $oPlayerTeam->all_teams();

=head2 all_players - obtain an arrayref of all players

  my $aAllPlayers = $oPlayerTeam->all_players();

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item badminton_ladder::model

=item badminton_ladder::model::player

=item badminton_ladder::model::team

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
