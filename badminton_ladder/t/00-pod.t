#########
# Author:        zerojinx
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
use strict;
use warnings;
use Test::More;

our $VERSION = do { my @r = (q$LastChangedRevision: 3909 $ =~ /\d+/mxg); sprintf '%d.'.'%03d' x $#r, @r };

eval "use Test::Pod 1.00"; ## no critic
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
