use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 15;
use lib qw{t};
use t::util;

use_ok('badminton_ladder::model::player');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::player->new({
    util => $util,
  });

  isa_ok($model, 'badminton_ladder::model::player', '$model');
  my @fields = $model->fields();
  is(scalar@fields, 4, '4 fields');
  is($fields[0], 'id_player', '$fields[0] is id_player');
  is($fields[1], 'email', '$fields[1] is email');
  is($fields[2], 'forename', '$fields[2] is forename');
  is($fields[3], 'surname', '$fields[3] is surname');
  my $players = $model->players();
  is(scalar@{$players}, 8, '8 players found');
}
{
  my $model = badminton_ladder::model::player->new({
    util => $util,
    id_player => 3,
  });
  is($model->full_name(), 'third player', '$model->full_name() is correct');
}
{
  my $model = badminton_ladder::model::player->new({
    util => $util,
    email => 'ninth.player',
    forename => 'ninth',
    surname => 'player',
  });
  is($model->id_player(), undef, '$model->id_player() is undef');
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_player(), 9, '$model->id_player() is 9');
  eval {
    $model->forename('neuf');
    $model->save();
  };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_player, 9, '$model->id_player() is still 9 - as update');
  my $players = $model->players();
  is(scalar@{$players}, 9, '9 players now found');
}
