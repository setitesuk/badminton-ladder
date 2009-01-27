#########
# Author:        rmp
# Maintainer:    $Author: ajb $
# Created:       2007-10
# Last Modified: $Date: 2009-01-09 15:23:14 +0000 (Fri, 09 Jan 2009) $
# Id:            $Id: 00-pod.t 3909 2009-01-09 15:23:14Z ajb $
# $HeadURL: svn+ssh://svn.internal.sanger.ac.uk/repos/svn/new-pipeline-dev/sra/branches/prerelease-8.0/t/00-pod.t $
#
use strict;
use warnings;
use Test::More;

our $VERSION = do { my @r = (q$LastChangedRevision: 3909 $ =~ /\d+/mxg); sprintf '%d.'.'%03d' x $#r, @r };

eval "use Test::Pod 1.00"; ## no critic
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
