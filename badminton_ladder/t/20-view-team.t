use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 20;
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
  $util->catch_email($model);
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render update_challenge');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/update_challenge.html}), 'rendered update_challenge is correct');
  my $parsed_email = $util->parse_email($model->{emails}[0]);
  my $expected_body = q{Top Dogs

You have been challenged by Second Best to a badminton match.
If you wish to decline, this will be entered up by the other team as a win to them, and you will lose your placing if you are currently above this team.

Thanks - badminton ladder};
  is($parsed_email->{body}, $expected_body, 'email body is correct');
  is($parsed_email->{to}, qq{third.player,fourth.player,first.player,second.player\n}, 'email to is correct');
  is($parsed_email->{from}, qq{third.player\n}, 'email from is correct');

  $cgi->param('winner','2');
  $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{update}, aspect => q{update_result},
  });
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render update_result');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/update_result.html}), 'rendered update_result is correct');
}
{
  my $cgi = $util->cgi();
  $cgi->param('forename_1', 'Bruce');
  $cgi->param('surname_1', 'Willis');
  $cgi->param('email_1', 'bruce.willis@fith.element');
  $cgi->param('forename_2', 'Gary');
  $cgi->param('surname_2', 'Oldman');
  $cgi->param('email_2', 'gary.oldman@fith.element');
  my $model = badminton_ladder::model::team->new({
    util => $util,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{create},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render create - no team name given');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/create.html}), 'rendered create is correct');
}
{
  my $cgi = $util->cgi();
  $cgi->param('name', 'Fifth Element');

  my $model = badminton_ladder::model::team->new({
    util => $util,
  });
  my $view = badminton_ladder::view::team->new({
    util => $util, model => $model, action => q{create},
  });

  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render create - team name given');
  ok($util->test_rendered($render, q{t/data/rendered/badminton_ladder/team/create.html}), 'rendered create is correct');
}
