#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package badminton_ladder::model;
use strict;
use warnings;
use base qw(ClearPress::model);
use Readonly;

our $VERSION = 1;

Readonly::Scalar our $CORRECT_THE_YEAR     => 1900;
Readonly::Scalar our $MONTHS               => [qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)];

__PACKAGE__->mk_accessors(__PACKAGE__->fields());

sub fields {
  return qw(id);
}

sub date_today {
  my ($self, $arg_ref) = @_;
  my $type = $arg_ref->{type};
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $human_month = $MONTHS->[$mon];
  $mon++;
  $mon = sprintf '%02d', $mon;
  $mday = sprintf '%02d', $mday;
  $year += $CORRECT_THE_YEAR;
  my $return_date = $type eq 'mysql' ? "$year-$mon-$mday"
                  :                    "$mday $human_month $year"
                  ;
  return $return_date;
}

sub human_date {
  my ($self, $arg_ref) = @_;
  my ($year, $mon, $mday, $human_month);
  if ($arg_ref->{mysql_date}) {
    ($year, $mon, $mday) = split /-/xms, $arg_ref->{mysql_date};
    $mon--;
    $mday = sprintf '%02d', $mday;
    $human_month = $MONTHS->[$mon];
  } else {
  }
  return "$mday $human_month $year";
}

1;
