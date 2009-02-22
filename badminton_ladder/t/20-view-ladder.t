use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 3;
use lib qw{t};
use t::util;
use DateTime;
use badminton_ladder::model::ladder;

use_ok('badminton_ladder::view::ladder');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::ladder->new({
    util => $util,
  });
  my $view = badminton_ladder::view::ladder->new({
    util => $util, model => $model, action => q{list},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render list');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/ladder/list.html}), 'rendered list is correct');
}