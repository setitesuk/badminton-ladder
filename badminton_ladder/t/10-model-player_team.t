use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 6;
use lib qw{t};
use t::util;
use DateTime;

use_ok('badminton_ladder::model::player_team');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::player_team->new({
    util => $util,
  });

  my @fields = $model->fields();
  is(scalar@fields, 3, '3 fields found');
  my $all_teams = $model->all_teams();
  isa_ok($all_teams, 'ARRAY', '$model->all_teams()');
  is($model->all_teams(), $all_teams, 'all_teams cached ok');
  my $all_players = $model->all_players();
  isa_ok($all_players, 'ARRAY', '$model->all_players()');
  is($model->all_players(), $all_players, 'all_players cached ok');
}