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

1;
