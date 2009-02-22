use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More 'no_plan';#tests => 9;
use lib qw{t};
use t::util;
use DateTime;
use badminton_ladder::model::team;

use_ok('badminton_ladder::view::team');

my $util = t::util->new({ fixtures => 1 });
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{list},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render list');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/list.html}), 'rendered list is correct');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util, id_team => 1,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{read},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render read');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/read.html}), 'rendered read is correct');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{list}, aspect => q{list_challenges},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render list_challenges');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/list_challenges_none.html}), 'rendered list_challenges is correct');
}
{
  my $model = badminton_ladder::model::team->new({
    util => $util,
    id_team => 1,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{read}, aspect => q{read_challenge},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render read_challenge');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/read_challenge.html}), 'rendered read_challenge is correct');

  my $cgi = $util->cgi();
  $cgi->param('id_challenger','2');
  $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{update}, aspect => q{update_challenge},
  });
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render update_challenge');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/update_challenge.html}), 'rendered update_challenge is correct');
}
