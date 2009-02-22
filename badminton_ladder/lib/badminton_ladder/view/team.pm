#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package badminton_ladder::view::team;
use strict;
use warnings;
use base qw(ClearPress::view);
use Carp;
use English qw{-no_match_vars};

our $VERSION = 1;

sub create {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $name = $cgi->param('name');
  my $forename_1 = $cgi->param('forename_1');
  my $surname_1 = $cgi->param('surname_1');
  my $email_1 = $cgi->param('email_1');
  my $forename_2 = $cgi->param('forename_2');
  my $surname_2 = $cgi->param('surname_2');
  my $email_2 = $cgi->param('email_2');
  my $model = $self->model();
  $name ||= $surname_1.q{/}.$surname_2;
  $model->name($name);
  $model->win(0);
  $model->loss(0);
  eval {
    $model->create();
    $model->generate_team({
      player_1 => { forename => $forename_1, surname => $surname_1, email => $email_1 },
      player_2 => { forename => $forename_2, surname => $surname_2, email => $email_2 },
    });
  } or do {
    croak $EVAL_ERROR;
  };
  return 1;
}

sub read_challenge {
  my ($self) = @_;
  return 1;
}

sub update_challenge {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $model = $self->model();
  my $challenger = $cgi->param('id_challenger');
  if (!$model->eligible_challenge($challenger)) {
    croak 'You cannot make this challenge. You can only challenge someone upto 3 places above you in the main ladder, or anyone who is not in the ladder';
  }
  $model->challenged_by($challenger);
  $model->save();
  $model->save_challenge();
  $model->email_a_challenge($challenger);
  return 1;
}

sub update_result {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $model = $self->model();
  my $winner = $cgi->param('winner');
  $model->update_result($winner);
  return 1;
}

sub list_challenges {
  my ($self) = @_;
  return 1;
}

1;
__END__

=head1 NAME

badminton_ladder::view::team

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $o = badminton_ladder::view::team->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 create - handler for creating a new team

=head2 read_challenge - handler for reading a challenge

=head2 update_challenge - handler for setting a challenge up

=head2 update_result - handler for updating the results of a challenge

=head2 list_challenges - handler for displaying all the challenges

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item ClearPress::view

=item Carp

=item English

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

