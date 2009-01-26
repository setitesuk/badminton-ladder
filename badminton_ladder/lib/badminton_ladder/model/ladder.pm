
package badminton_ladder::model::ladder;
use strict;
use warnings;
use base qw(badminton_ladder::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(team ladder_type )]);
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder id_team id_ladder_type last_played position);
}

sub get_ladders {
  my ($self, $ladder_description) = @_;
  my $q = q{SELECT t.name AS name, l.last_played AS last_played, l.position AS position, t.id_team AS id_team, t.challenged_by AS challenged_by
            FROM team t, ladder l, ladder_type lt
            WHERE lt.description = ?
            AND   lt.id_ladder_type = l.id_ladder_type
            AND   l.id_team = t.id_team
            ORDER BY l.position
            };
  my $dbh = $self->util->dbh();
  my $sth = $dbh->prepare($q);
  $sth->execute($ladder_description);
  my $return = [];
  while (my $row = $sth->fetchrow_hashref()) {
    push @{$return}, $row;
  }
  return $return;
}

sub main_ladder {
  my ($self) = @_;
  if (!$self->{main_ladder}) {
    $self->{main_ladder} = $self->get_ladders('Main');
  }
  return $self->{main_ladder};
}
sub challenging_ladder {
  my ($self) = @_;
  if (!$self->{challenging_ladder}) {
    $self->{challenging_ladder} = $self->get_ladders('Challenging');
  }
  return $self->{challenging_ladder};
}
sub out_of_ladder {
  my ($self) = @_;
  if (!$self->{out_of_ladder}) {
    $self->{out_of_ladder} = $self->get_ladders('Out of Ladder');
  }
  return $self->{out_of_ladder};
}

sub challenger {
  my ($self, $id_team) = @_;
  return badminton_ladder::model::team->new({util => $self->util})->challenger($id_team);
}

1;
 
