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
