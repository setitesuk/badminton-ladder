
package badminton_ladder::view::team;
use strict;
use warnings;
use base qw(ClearPress::view);
use Carp;
use English qw{-no_match_vars};

sub create {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $name = $cgi->param('name');
  my $forename_1 = $cgi->param('forename_1');
  my $surname_1 = $cgi->param('surname_1');
  my $email_1 = $cgi->param('email_1');
  my $forename_2 = $cgi->param('forename_2');
  my $surname_2 = $cgi->param('surname_2');
  my $email_2 = $cgi->param('email_2');
  my $model = $self->model();
  $name ||= $surname_1.q{/}.$surname_2;
  $model->name($name);
  $model->win(0);
  $model->loss(0);
  eval {
    $model->create();
    $model->generate_team({
      player_1 => { forename => $forename_1, surname => $surname_1, email => $email_1 },
      player_2 => { forename => $forename_2, surname => $surname_2, email => $email_2 },
    });
  } or do {
    croak $EVAL_ERROR;
  };
  return 1;
}

sub read_challenge {
  my ($self) = @_;
  return 1;
}

sub update_challenge {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $model = $self->model();
  my $challenger = $cgi->param('id_challenger');
  if ($model->id_team() == $challenger) {
    croak 'You cannot challenge yourself! Click back to continue.';
  }
  $model->challenged_by($challenger);
  $model->save();
  $model->save_challenge();
  return 1;
}

sub update_result {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $model = $self->model();
  my $winner = $cgi->param('winner');
  $model->update_challenge($winner);
  return 1;
}

sub list_challenges {
  my ($self) = @_;
  return 1;
}

1;
 
