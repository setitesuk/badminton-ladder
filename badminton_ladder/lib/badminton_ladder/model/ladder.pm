
package badminton_ladder::model::ladder;
use strict;
use warnings;
use base qw(badminton_ladder::model);
use DateTime;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(team ladder_type )]);
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_ladder id_team id_ladder_type last_played position);
}

sub get_ladders {
  my ($self, $ladder_description) = @_;
  my $q = q{SELECT l.id_ladder AS id_ladder, t.name AS name, l.last_played AS last_played, l.position AS position, t.id_team AS id_team, t.challenged_by AS challenged_by
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
  return $self->get_ladders('Main');
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

sub assess_positions {
  my ($self) = @_;
  my $ladders = $self->main_ladder();
  my $dt = DateTime->now();
  $dt->set_time_zone('UTC');
  $dt->subtract( days => 42 );
  warn$dt;
  my $drop_outs = [];
  my $out_of_ladder_type_id = badminton_ladder::model::ladder_type->new({
    util => $self->util(),
    description => 'Out of Ladder',
  })->id_ladder_type();
  my $next_position = 1;
  my $number_dropped = 0;
  my $pkg = ref$self;
  foreach my $l (@{$ladders}) {
    my ($y, $m, $d) = $l->{last_played} =~ /(\d{4})-(\d{2})-(\d{2})/xms;
    my $l_dt = DateTime->new({
      year => $y, month => $m, day => $d, time_zone => 'UTC',
    });
    my $l_obj = $pkg->new({
      util => $self->util(),
      id_ladder => $l->{id_ladder},
    });
    $l_obj->read();
    my $diff = $dt->subtract_datetime_absolute( $l_dt );
    if ($diff->is_positive()) {
      $next_position = $l->{position} - $number_dropped;
      $number_dropped++;
      $l_obj->position(0);
      $l_obj->id_ladder_type($out_of_ladder_type_id);
    } else {
      $l_obj->position($next_position);
      $next_position++;
    }
    $l_obj->update();
  }
  return 1;
}

1;
 
