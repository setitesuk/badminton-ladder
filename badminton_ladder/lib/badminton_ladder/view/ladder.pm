#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#

package badminton_ladder::view::ladder;
use strict;
use warnings;
use base qw(ClearPress::view);

our $VERSION = 1;

sub list {
  my ($self) = @_;
  $self->model->assess_positions();
  return 1;
}

1;
