
package badminton_ladder::model::ladder_type;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(ladder )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder_type
	    
	    description );
}

1;
 
