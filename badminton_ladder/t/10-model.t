use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 10;
use lib qw{t};
use t::util;
use DateTime;

use_ok('badminton_ladder::model');

my $util = t::util->new({ fixtures => 1 });
my $model = badminton_ladder::model->new({
  util => $util,
});
my @fields = $model->fields();
is(scalar@fields, 1, '1 field found');
is($fields[0], 'id', 'field is correct');
isa_ok($model, 'badminton_ladder::model', '$model');
my $dt = $model->datetime_object_for_now();
isa_ok($dt, 'DateTime', '$model->datetime_object_for_now()');
is($model->datetime_object_for_now(), $dt, '$model->datetime_object_for_now() cache works ok');

$model->{datetime_object_for_now} = DateTime->new({ year => 2008, month => 4, day => 26 });

is($model->human_date({}), '26 Apr 2008', 'Human date is ok using $model->datetime_object_for_now()');
is($model->human_date({mysql_date => '2008-12-25'}), '25 Dec 2008', 'Human date is ok when give a mysql format date');

is($model->date_today({type => q{}}), '26 Apr 2008', 'Default returned date ok from $model->date_today()');
is($model->date_today({type => q{mysql}}), '2008-04-26', 'mysql format returned date ok from $model->date_today()');

 