use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 14;
use lib qw{t};
use t::util;

use_ok('badminton_ladder::model::ladder_type');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::ladder_type->new({
    util => $util,
  });

  isa_ok($model, 'badminton_ladder::model::ladder_type', '$model');
  my @fields = $model->fields();
  is(scalar@fields, 2, 'two fields');
  is($fields[0], 'id_ladder_type', '$fields[0] is id_ladder_type');
  is($fields[1], 'description', '$fields[1] is description');
  is(scalar@{$model->ladder_types()}, 3, '3 ladder types found')
}
{
  my $model = badminton_ladder::model::ladder_type->new({
    util => $util,
    id_ladder_type => 3,
  });
  is($model->description(), 'Main', '$model->description() is correct');
}
{
  my $model = badminton_ladder::model::ladder_type->new({
    util => $util,
    description => 'Out of Ladder',
  });
  is($model->id_ladder_type(), 1, '$model->id_ladder_type() is correct');
}
{
  my $model = badminton_ladder::model::ladder_type->new({
    util => $util,
    description => 'test',
  });
  is($model->id_ladder_type(), undef, '$model->id_ladder_type() is undef');
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_ladder_type(), 4, '$model->id_ladder_type() is 4');
  eval {
    $model->description('new_test');
    $model->save();
  };
  is($EVAL_ERROR, q{}, 'no croak on save');
  is($model->id_ladder_type, 4, '$model->id_ladder_type() is still 4 - as update');
  is(scalar@{$model->ladder_types()}, 4, 'now 4 ladder types found')
}