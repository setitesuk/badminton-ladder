#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#

package badminton_ladder::model::ladder_type;
use strict;
use warnings;
use base qw(badminton_ladder::model);

our $VERSION = 1;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(ladder )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder_type description);
}

sub init {
  my ($self) = @_;
  if ($self->{description} && !$self->{id_ladder_type}) {
    my $q = q{SELECT id_ladder_type FROM ladder_type WHERE description = ?};
    my $dbh = $self->util->dbh();
    my $ref = $dbh->selectall_arrayref($q, {}, $self->description());
    if ($ref) {
      $self->{id_ladder_type} = $ref->[0]->[0];
    }
  }
  return 1;
}

1;
