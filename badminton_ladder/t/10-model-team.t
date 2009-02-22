use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 65;
use lib qw{t};
use t::util;

use_ok('badminton_ladder::model::team');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
  });

  isa_ok($model, 'badminton_ladder::model::team', '$model');
  my @fields = $model->fields();
  is(scalar@fields, 5, '5 fields');
  is($fields[0], 'id_team', '$fields[0] is id_team');
  is($fields[1], 'loss', '$fields[1] is loss');
  is($fields[2], 'name', '$fields[2] is name');
  is($fields[3], 'win', '$fields[3] is win');
  is($fields[4], 'challenged_by', '$fields[4] is challenged_by');
  my $teams = $model->teams();
  is(scalar@{$teams}, 4, '4 teams found');
  eval { $model->non_challenged_teams(); };
  like($EVAL_ERROR, qr/No\ team\ is\ about\ to\ be\ challenged/, 'croak $model->non_challenged_teams() as no team is being challenged');
  my $non_challenged_teams;
  eval { $non_challenged_teams = $model->non_challenged_teams(3); };
  is($EVAL_ERROR, q{}, 'no croak on $model->non_challenged_teams(3)');
  is(scalar@{$non_challenged_teams}, 3, '3 non_challenged_teams');
  foreach my $t (@{$non_challenged_teams}) {
    isnt($t->{name}, 'Third Base', qq{$t->{name} isn't Third Base});
    isnt($t->{id_team}, 3, qq{$t->{id_team} isn't 3});
  }
  is($model->challenger(3), 'Third Base', '$model->challenger(3) returns name of team with id_team of 3');
  $model->{challenger} = undef;
  is($model->challenger() , q{}, 'no challenger returned');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    name => 'Five Element',
  });
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_team(), 5, 'id_team is 5');
  eval {
    $model->name('Fifth Element');
    $model->save();
  };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_team(), 5, 'id_team is still 5, as update');
  my $arg_refs = {
    player_1 => { email => 'ninth.player', forename => 'ninth', surname => 'player' },
    player_2 => { email => 'tenth.player', forename => 'tenth', surname => 'player' },
  };
  eval { $model->generate_team($arg_refs); };
  is($EVAL_ERROR, q{}, 'no croak on generate team');
  my $non_challenged_teams;
  eval { $non_challenged_teams = $model->non_challenged_teams(); };
  isa_ok($non_challenged_teams, 'ARRAY', '$model->non_challenged_teams()');
  is(scalar@{$non_challenged_teams}, 4, '4 teams');
  foreach my $t (@{$non_challenged_teams}) {
    isnt($t->{name}, $model->name(), qq{$t->{name} isnt Fifth Element});
    isnt($t->{id_team}, $model->id_team(), qq{$t->{id_team} isnt 5});
  }
  ok($model->eligible_challenge(1), 'Top Dogs can challenge Fifth Element');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    id_team => 1,
  });
  is($model->name(), 'Top Dogs', '$model->name() is correct');
  is($model->win(), 3, '3 wins');
  is($model->loss(), 0, 'no losses');
  is($model->played(), 3, '3 matches played');
  ok($model->eligible_challenge(4), 'Fourth of July can challenge Top Dogs');
  ok(!$model->eligible_challenge(1), 'Top Dogs cannot challenge Top Dogs');
  ok(!$model->eligible_challenge(5), 'Fifth Element cannot challenge Top Dogs');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    name => 'Fourth of July',
  });
  is($model->id_team(), 4, '$model->id_team() is correct');
  is($model->win(), 0, '0 wins');
  is($model->loss(), 3, '3 losses');
  is($model->played(), 3, '3 matches played');
  ok($model->eligible_challenge(1), 'Top Dogs can challenge Fourth of July');
  ok($model->eligible_challenge(5), 'Fifth Element can challenge Fourth of July');
  
  eval {
    $model->challenged_by(5);
    $model->save();
    $model->save_challenge();
  };
  is($EVAL_ERROR, q{}, 'challenge saved ok');
  my $challenger = $model->challenger();
  is($challenger, 'Fifth Element', 'Fifth Element is the challenger');
  my $challenger_model = badminton_ladder::model::team->new({ util => $util, name => $challenger });
  my $challengers_losses = $challenger_model->loss() || 0;
  $model->{challenger} = 'test';
  is($model->challenger(), 'test', 'cache works ok for $model->challenger()');
  my $challenged_teams = $model->challenged_teams();
  isa_ok($challenged_teams, 'ARRAY', '$model->challenged_teams() - array of teams returned');
  is($model->challenged_teams(), $challenged_teams, 'cache works ok for $model->challenged_teams()');
  is(scalar@{$challenged_teams}, 1, '1 team returned, as 2 are currently challenging each other');
  eval { $model->update_result(4); };
  is($EVAL_ERROR, q{}, 'no croak on update result');
  is($model->challenged_by(), undef, 'challenge has completed');
  is($model->win(), 1, '$model->win() has incremented by 1'); 
  $challenger_model = badminton_ladder::model::team->new({ util => $util, name => $challenger });
  is($challenger_model->loss(), $challengers_losses + 1, '$challenger_model->loss() has incremented by 1');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    name => 'Fourth of July',
  });
  my $losses = $model->loss();
  eval {
    $model->challenged_by(5);
    $model->save();
    $model->save_challenge();
    $model->update_result(5);
  };
  is($EVAL_ERROR, q{}, 'no croak on on going through the challenge and update motions');
  is($model->loss(), $losses + 1, '$model->loss() has incremented by 1');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    name => 'Fourth of July',
  });
  $util->catch_email($model);
  eval { $model->email_a_challenge(3); };
  is($EVAL_ERROR, q{}, 'no croak on email creation');
  my $parsed_email = $util->parse_email($model->{emails}[0]);
  my $expected_body = q{Fourth of July

You have been challenged by Third Base to a badminton match.
If you wish to decline, this will be entered up by the other team as a win to them, and you will lose your placing if you are currently above this team.

Thanks - badminton ladder};
  is($parsed_email->{body}, $expected_body, 'email body is correct');
  is($parsed_email->{to}, qq{fifth.player,sixth.player,seventh.player,eighth.player\n}, 'email to is correct');
  is($parsed_email->{from}, qq{fifth.player\n}, 'email from is correct');
}