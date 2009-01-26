
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
  return qw(id_team loss name win challenged_by);
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

sub non_challenged_teams {
  my ($self) = @_;
  if (!$self->{non_challenged_teams}) {
    my $q = q{SELECT id_team, name FROM team WHERE challenged_by IS NULL};
    my $dbh = $self->util->dbh();
    my $sth = $dbh->prepare($q);
    $sth->execute();
    while (my $r = $sth->fetchrow_hashref()) {
      push @{$self->{non_challenged_teams}}, $r;
    }
  }
  return $self->{non_challenged_teams};
}

sub save_challenge {
  my ($self) = @_;
  my $util = $self->util();
  my $pkg = ref$self;
  my $challenger = $pkg->new({
    util => $util,
    id_team => $self->challenged_by(),
    challenged_by => $self->id_team(),
  });
  $challenger->save();
  return 1;
}


sub challenger {
  my ($self, $id_team) = @_;
  if (!$self->{challenger}) {
    $id_team ||= $self->challenged_by();

    if (!$id_team) {
      return q{};
    }
    my $pkg = ref$self;
    $self->{challenger} = $pkg->new({ util => $self->util(), id_team => $id_team})->name();
  }
  return $self->{challenger};
}

sub challenged_teams {
  my ($self) = @_;
  if (!$self->{challenged_teams}) {
    my $seen = {};
    foreach my $team ( @{$self->teams()} ) {
      if ($team->challenged_by()) {
        if (!$seen->{$team->challenged_by()}) {
          $seen->{$team->id_team()}++;
          push @{$self->{challenged_teams}}, $team;
        }
      }
    }
  }
  return $self->{challenged_teams};
}

sub update_challenge {
  my ($self, $winner) = @_;
  my $pkg = ref$self;
  my $challenger = $pkg->new({ util => $self->util(), id_team => $self->challenged_by() });

  my $s_ladder = $self->ladder();
  my $s_position = $s_ladder->position();
  my $s_ladder_type = $s_ladder->ladder_type->description();

  my $c_ladder = $challenger->ladder();
  my $c_position = $c_ladder->position();
  my $c_ladder_type = $c_ladder->ladder_type->description();


  if ($s_ladder_type eq 'Main' && $c_ladder_type eq 'Main') {
    if ($self->id_team() == $winner) {
      if ($s_position > $c_position) {
        
      } else {
        $s_ladder->position($c_position);
        $c_ladder->position($s_position);
      }
    } else {
      if ($s_position > $c_position) {
        $s_ladder->position($c_position);
        $c_ladder->position($s_position);
      } else {

      }
    }
  } else {

    my $main_ladder_count = scalar@{$s_ladder->main_ladder()};
    my $main_ladder_type_id = badminton_ladder::model::ladder_type->new({
      util => $self->util,
      description => 'Main',
    })->id_ladder_type();

    if ($s_ladder_type eq 'Main') {
      $c_position = $main_ladder_count + 1;
      if ($self->id_team() == $winner) {
        if ($s_position < $c_position) {
        
        } else {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        }
      } else {
        if ($s_position < $c_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {

        }
      
      }
      $c_ladder->id_ladder_type($main_ladder_type_id);
    } elsif ($c_ladder_type eq 'Main') {
      $s_position = $main_ladder_count + 1;
      if ($challenger->id_team() == $winner) {
        if ($c_position < $s_position) {
        
        } else {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        }
      } else {
        if ($c_position < $s_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {

        }
      
      }
      $s_ladder->id_ladder_type($main_ladder_type_id);
      $s_ladder->save();
    } else {
      $s_ladder->id_ladder_type($main_ladder_type_id);
      $c_ladder->id_ladder_type($main_ladder_type_id);
      if ($self->id_team() == $winner) {
        $s_ladder->position($main_ladder_count + 1);
        $c_ladder->position($main_ladder_count + 2);
      } else {
        $c_ladder->position($main_ladder_count + 1);
        $s_ladder->position($main_ladder_count + 2);
      }
    }
  }

  my $date = $self->date_today({type => 'mysql'});
  $c_ladder->last_played($date);
  $s_ladder->last_played($date);

  $self->challenged_by(undef);
  $challenger->challenged_by(undef);
  $s_ladder->save();
  $c_ladder->save();
  return 1;
}


1;
 
