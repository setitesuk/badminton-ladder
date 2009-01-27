
package badminton_ladder::view::ladder;
use strict;
use warnings;
use base qw(ClearPress::view);

sub list {
  my ($self) = @_;
  $self->model->assess_positions();
  return 1;
}

1;
 
