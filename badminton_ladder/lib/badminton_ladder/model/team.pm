
package badminton_ladder::model::team;
use strict;
use warnings;
use base qw(badminton_ladder::model);
use Carp qw(carp cluck croak confess);
use English qw{-no_match_vars};
use badminton_ladder::model::player;
use badminton_ladder::model::player_team;
use badminton_ladder::model::ladder;
use badminton_ladder::model::ladder_type;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(player_team ladder )]);
__PACKAGE__->has_all();
__PACKAGE__->has_many_through('player|player_team');

sub fields {
  return qw(id_team loss name win);
}

sub played {
  my ($self) = @_;
  if (!$self->{played}) {
    my $loss = $self->loss || 0;
    my $win = $self->win || 0;
    $self->{played} = $loss + $win;
  }
  return $self->{played};
}

sub generate_team {
  my ($self, $arg_ref) = @_;
  my $util = $self->util();
  eval {
    my $player_1 = badminton_ladder::model::player->new({
      util => $util,
      forename => $arg_ref->{player_1}->{forename},
      surname => $arg_ref->{player_1}->{surname},
      email => $arg_ref->{player_1}->{email},
    });
    $player_1->create();
    $player_1->read();
    my $player_2 = badminton_ladder::model::player->new({
      util => $util,
      forename => $arg_ref->{player_2}->{forename},
      surname => $arg_ref->{player_2}->{surname},
      email => $arg_ref->{player_2}->{email},
    });
    $player_2->create();
    $player_2->read();
    my $player_1_team = badminton_ladder::model::player_team->new({
      util => $util,
      id_player => $player_1->id_player(),
      id_team => $self->id_team(),
    });
    my $player_2_team = badminton_ladder::model::player_team->new({
      util => $util,
      id_player => $player_2->id_player(),
      id_team => $self->id_team(),
    });
    $player_1_team->save();
    $player_2_team->save();
    my $ladder_type = badminton_ladder::model::ladder_type->new({
      util => $util,
      description => 'Challenging',
    });
    my $date = $self->date_today({type => 'mysql'});
    my $ladder = badminton_ladder::model::ladder->new({
      util => $util,
      id_team => $self->id_team(),
      id_ladder_type => $ladder_type->id_ladder_type(), 
	    last_played => $date,
	    position => 0,
    });
    $ladder->create();
    1;
  } or do {
    croak $EVAL_ERROR;
  };
  return 1;
}

1;
 
