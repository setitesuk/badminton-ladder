use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 19;
use lib qw{t};
use t::util;
use DateTime;

use_ok('badminton_ladder::model::ladder');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::ladder->new({
    util => $util,
  });

  my @fields = $model->fields();
  is(scalar@fields, 5, '5 fields found');
  my $main_ladder = $model->main_ladder();
  isa_ok($main_ladder, 'ARRAY', '$model->main_ladder()');
  is(scalar@{$main_ladder}, 4, '4 teams in main ladder');
  my $challenging_ladder = $model->challenging_ladder();
  isa_ok($challenging_ladder, 'ARRAY', '$model->challenging_ladder()');
  is($model->challenging_ladder(), $challenging_ladder, 'cache worked ok');
  is(scalar@{$challenging_ladder}, 0, '0 teams in main ladder');
  my $out_of_ladder = $model->out_of_ladder();
  isa_ok($out_of_ladder, 'ARRAY', '$model->out_of_ladder()');
  is($model->out_of_ladder(), $out_of_ladder, 'cache worked ok');
  is(scalar@{$out_of_ladder}, 0, '0 teams in out_of_ladder ladder');
  is($model->challenger(4), 'Fourth of July', '$model->challenger(4) is ok');

  $model->{datetime_object_for_now} = DateTime->new({ year => 2008, month => 2, day => 1, time_zone => 'UTC'});
  eval { $model->assess_positions(); };
  is($EVAL_ERROR, q{}, 'no croak on $model->assess_positions()');
  is($model->{out_of_ladder}, undef, 'cache of out of ladder reset');
  is(scalar@{$model->main_ladder()}, 4, 'all teams have are still in main ladder');
  is(scalar@{$model->out_of_ladder()}, 0, 'no teams have been put in out of ladder');
  
  $model->{datetime_object_for_now} = undef;

  eval { $model->assess_positions(); };
  is($EVAL_ERROR, q{}, 'no croak on $model->assess_positions()');
  is($model->{out_of_ladder}, undef, 'cache of out of ladder reset');
  is(scalar@{$model->main_ladder()}, 0, 'all teams have dropped out of main ladder');
  is(scalar@{$model->out_of_ladder()}, 4, 'all teams have been put in out of ladder');
}