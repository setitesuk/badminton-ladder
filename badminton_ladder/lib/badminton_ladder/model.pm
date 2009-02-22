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
use DateTime;
use Readonly;

our $VERSION = 1;

Readonly::Scalar our $MONTHS => [qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)];

__PACKAGE__->mk_accessors(__PACKAGE__->fields());

sub fields {
  return qw(id);
}

sub date_today {
  my ($self, $arg_ref) = @_;
  my $type = $arg_ref->{type};
  my $dt = $self->datetime_object_for_now();
  my $mon = $dt->month() - 1;
  my $mday = $dt->day();
  my $year = $dt->year();
  my $human_month = $MONTHS->[$mon];
  $mon++;
  $mon = sprintf '%02d', $mon;
  $mday = sprintf '%02d', $mday;
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
    my $dt = $self->datetime_object_for_now();
    $mon = $dt->month() - 1;
    $mday = sprintf '%02d', $dt->day();
    $year = $dt->year();
    $human_month = $MONTHS->[$mon];
  }
  return "$mday $human_month $year";
}

sub datetime_object_for_now {
  my ($self) = @_;
  if (!$self->{datetime_object_for_now}) {
    $self->{datetime_object_for_now} = DateTime->now();
    $self->{datetime_object_for_now}->set_time_zone('UTC');
  }
  return $self->{datetime_object_for_now};
}

1;
__END__

=head1 NAME

badminton_ladder::model

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oDerivedClass = DerivedClass->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - field descriptors

=head2 date_today - returns a date string. May be reuested as mysql for yyyy-mm-dd, else returns a human readable date dd mon yyyy

  my $sDate = $oDerivedClass->date_today({type => 'mysql|human'});

=head2 human_date - returns a string dd mon yyyy from a given date string

  my $sDate = $oDerivedClass->human_date({mysql_date => 'yyyy-mm-dd'});

=head2 datetime_object_for_now - returns (and caches) a datetime object that is of now

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item ClearPress::model

=item DateTime

=item Readonly

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Andy Brown, E<lt>setitesuk@gmail.com<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
