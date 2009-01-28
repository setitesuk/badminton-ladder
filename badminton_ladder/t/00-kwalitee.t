#########
# Author:        zerojinx
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
use Test::More;
use strict;
use warnings;
use English qw(-no_match_vars);

eval {
  require Test::Kwalitee;
};

if($EVAL_ERROR) {
  plan( skip_all => 'Test::Kwalitee not installed; skipping' );
}

Test::Kwalitee->import(tests => [qw(-no_symlinks -has_meta_yml)]);
