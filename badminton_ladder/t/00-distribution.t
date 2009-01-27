#########
# Author:        rmp
# Last Modified: $Date: 2009-01-09 15:23:14 +0000 (Fri, 09 Jan 2009) $
# Id:            $Id: 00-distribution.t 3909 2009-01-09 15:23:14Z ajb $
# Source:        $Source$
# $HeadURL: svn+ssh://svn.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/sra/branches/prerelease-8.0/t/00-distribution.t $
#
package distribution;
use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

our $VERSION = do { my @r = (q$LastChangedRevision: 3909 $ =~ /\d+/mxg); sprintf '%d.'.'%03d' x $#r, @r };

eval {
  require Test::Distribution;
};

if($EVAL_ERROR) {
  plan skip_all => 'Test::Distribution not installed';
} else {
  Test::Distribution->import('not' => 'prereq'); # Having issues with Test::Dist seeing my PREREQ_PM :(
}

1;
