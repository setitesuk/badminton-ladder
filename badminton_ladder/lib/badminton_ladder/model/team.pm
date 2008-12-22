
package badminton_ladder::model::team;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(player_team ladder )]);
__PACKAGE__->has_all();
__PACKAGE__->has_many_through('player|player_team');

sub fields {
  return qw(id_team
	    
	    loss name win );
}

sub played {
  my ($self) = @_;
  if (!$self->{played}) {
    $self->{played} = $self->loss() + $self->win();
  }
  return $self->{played};
}

1;
 
