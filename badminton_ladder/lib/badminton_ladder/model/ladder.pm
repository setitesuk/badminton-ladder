
package badminton_ladder::model::ladder;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(team ladder_type )]);
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder
	    id_team id_ladder_type 
	    last_played position );
}

1;
 
