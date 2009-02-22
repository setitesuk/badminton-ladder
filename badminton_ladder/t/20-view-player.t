use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 5;
use lib qw{t};
use t::util;
use DateTime;
use badminton_ladder::model::player;

use_ok('badminton_ladder::view::player');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::player->new({
    util => $util,
  });
  my $view = badminton_ladder::view::player->new({
    util => $util, model => $model, action => q{list},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render list');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/player/list.html}), 'rendered list is correct');
}
{
  my $model = badminton_ladder::model::player->new({
    util => $util, id_player => 1,
  });
  my $view = badminton_ladder::view::player->new({
    util => $util, model => $model, action => q{read},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render read');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/player/read.html}), 'rendered read is correct');
}
