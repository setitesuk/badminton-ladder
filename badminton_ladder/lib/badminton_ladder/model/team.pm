#########
# Author:        setitesuk
# Maintainer:    $Author$
# Last Modified: $Date$
# Id:            $Id$
# $HeadURL$
#
package badminton_ladder::model::team;
use strict;
use warnings;
use base qw(badminton_ladder::model);
use Carp qw(carp cluck croak confess);
use English qw{-no_match_vars};
use badminton_ladder::model::player;
use badminton_ladder::model::player_team;
use badminton_ladder::model::ladder;
use badminton_ladder::model::ladder_type;
use Readonly;

our $VERSION = 1;

Readonly::Scalar our $CHALLENGE_PLACES_ABOVE_YOU => 3;
Readonly::Scalar our $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST => 1;
Readonly::Scalar our $OUT_OF_MAIN_LADDER_POSITION => 0;
Readonly::Scalar our $DEFAULT_NO_OF_LOSSES => 0;
Readonly::Scalar our $DEFAULT_NO_OF_WINS => 0;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(player_team ladder )]);
__PACKAGE__->has_all();
__PACKAGE__->has_many_through('player|player_team');

sub fields {
  return qw(id_team loss name win challenged_by);
}

sub init {
  my ($self) = @_;
  if ($self->{name} && !$self->{id_team}) {
    my $q = q{SELECT id_team FROM team WHERE name = ?};
    my $dbh = $self->util->dbh();
    my $ref = $dbh->selectall_arrayref($q, {}, $self->name());
    if ($ref) {
      $self->{id_team} = $ref->[0]->[0];
    }
  }
  return 1;
}

sub played {
  my ($self) = @_;
  if (!$self->{played}) {
    my $loss = $self->loss || $DEFAULT_NO_OF_LOSSES;
    my $win = $self->win || $DEFAULT_NO_OF_WINS;
    $self->{played} = $loss + $win;
  }
  return $self->{played};
}

sub generate_team {
  my ($self, $arg_ref) = @_;
  my $util = $self->util();
  eval {
    my $player_1 = badminton_ladder::model::player->new({
      util => $util,
      forename => $arg_ref->{player_1}->{forename},
      surname => $arg_ref->{player_1}->{surname},
      email => $arg_ref->{player_1}->{email},
    });
    $player_1->create();
    $player_1->read();
    my $player_2 = badminton_ladder::model::player->new({
      util => $util,
      forename => $arg_ref->{player_2}->{forename},
      surname => $arg_ref->{player_2}->{surname},
      email => $arg_ref->{player_2}->{email},
    });
    $player_2->create();
    $player_2->read();
    my $player_1_team = badminton_ladder::model::player_team->new({
      util => $util,
      id_player => $player_1->id_player(),
      id_team => $self->id_team(),
    });
    my $player_2_team = badminton_ladder::model::player_team->new({
      util => $util,
      id_player => $player_2->id_player(),
      id_team => $self->id_team(),
    });
    $player_1_team->save();
    $player_2_team->save();
    my $ladder_type = badminton_ladder::model::ladder_type->new({
      util => $util,
      description => 'Challenging',
    });
    my $date = $self->date_today({type => 'mysql'});
    my $ladder = badminton_ladder::model::ladder->new({
      util => $util,
      id_team => $self->id_team(),
      id_ladder_type => $ladder_type->id_ladder_type(),
	    last_played => $date,
	    position => $OUT_OF_MAIN_LADDER_POSITION,
    });
    $ladder->create();
    1;
  } or do {
    croak $EVAL_ERROR;
  };
  return 1;
}

sub non_challenged_teams {
  my ($self, $id_challenged_team) = @_;
  $id_challenged_team ||= $self->id_team();
  
  if (!$id_challenged_team) {
    croak 'No team is about to be challenged';
  }
  
  my $q = q{SELECT id_team, name FROM team WHERE challenged_by IS NULL};
  my $dbh = $self->util->dbh();
  my $sth = $dbh->prepare($q);
  $sth->execute();
  my $return = [];
  while (my $r = $sth->fetchrow_hashref()) {
    push @{$return}, $r;
  }
  return $return;
}

sub eligible_challenge {
  my ($self, $id_challenger) = @_;
  my $id_team = $self->id_team();

  if ($id_challenger == $id_team) {
    return 0;
  }

  my $q = q{SELECT position FROM ladder WHERE id_team = ?};
  my $dbh = $self->util->dbh();
  my $ref = $dbh->selectall_arrayref($q, {}, $id_team);
  my ($challengee_position, $challenger_position);
  if ($ref && scalar@{$ref}) {
    $challengee_position = $ref->[0]->[0];
  }
  $ref = $dbh->selectall_arrayref($q, {}, $id_challenger);
  if ($ref && scalar@{$ref}) {
    $challenger_position = $ref->[0]->[0];
  }

  if ($challengee_position == $OUT_OF_MAIN_LADDER_POSITION
        ||
      ($challenger_position && $challengee_position > $challenger_position)
        ||
      ($challenger_position > $OUT_OF_MAIN_LADDER_POSITION && ($challengee_position >= ($challenger_position - $CHALLENGE_PLACES_ABOVE_YOU)))
     ) {
    return 1;
  }
  
  if ($challenger_position == $OUT_OF_MAIN_LADDER_POSITION) {
    my $main_ladder = badminton_ladder::model::ladder->new({ util => $self->util() })->main_ladder();
    my $number_of_teams = scalar@{$main_ladder} + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST;
    my $challenge_upto = $number_of_teams - $CHALLENGE_PLACES_ABOVE_YOU;
    if ($challengee_position >= $challenge_upto) {
      return 1;
    }
  }
  return 0;
}

sub save_challenge {
  my ($self) = @_;
  my $util = $self->util();
  my $pkg = ref$self;
  my $challenger = $pkg->new({
    util => $util,
    id_team => $self->challenged_by(),
    challenged_by => $self->id_team(),
  });
  $challenger->save();
  return 1;
}


sub challenger {
  my ($self, $id_team) = @_;
  if (!$self->{challenger}) {
    $id_team ||= $self->challenged_by();

    if (!$id_team) {
      return q{};
    }
    my $pkg = ref$self;
    $self->{challenger} = $pkg->new({ util => $self->util(), id_team => $id_team})->name();
  }
  return $self->{challenger};
}

sub challenged_teams {
  my ($self) = @_;
  if (!$self->{challenged_teams}) {
    my $seen = {};
    foreach my $team ( @{$self->teams()} ) {
      if ($team->challenged_by()) {
        if (!$seen->{$team->challenged_by()}) {
          $seen->{$team->id_team()}++;
          push @{$self->{challenged_teams}}, $team;
        }
      }
    }
  }
  return $self->{challenged_teams};
}

sub update_result { ## no critic (Subroutines::ProhibitExcessComplexity)
  my ($self, $winner) = @_;
  my $pkg = ref$self;

  my $challenger = $pkg->new({ util => $self->util(), id_team => $self->challenged_by() });
  my $s_ladder = $self->ladders()->[0];
  my $s_position = $s_ladder->position();
  my $s_ladder_type = $s_ladder->ladder_type->description();

  my $c_ladder = $challenger->ladders()->[0];
  my $c_position = $c_ladder->position();
  my $c_ladder_type = $c_ladder->ladder_type->description();


  if ($s_ladder_type eq 'Main' && $c_ladder_type eq 'Main') {

    if ($self->id_team() == $winner) {
      if ($s_position > $c_position) {
        $s_ladder->position($c_position);
        $c_ladder->position($s_position);
      }
    } else {
      if ($s_position < $c_position) {
        $s_ladder->position($c_position);
        $c_ladder->position($s_position);
      }
    }

  } else {

    my $main_ladder_count = scalar@{$s_ladder->main_ladder()};
    if ($s_ladder_type eq 'Main') {

      $c_position = $main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST;

      if ($self->id_team() == $winner) {
        if ($s_position > $c_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {
          $c_ladder->position($c_position);
        }
      } else {
        if ($s_position < $c_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {
          $c_ladder->position($c_position);
        }
      }

    } elsif ($c_ladder_type eq 'Main') {

      $s_position = $main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST;

      if ($challenger->id_team() == $winner) {
        if ($c_position > $s_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {
          $s_ladder->position($s_position);
        }
      } else {
        if ($c_position < $s_position) {
          $s_ladder->position($c_position);
          $c_ladder->position($s_position);
        } else {
          $s_ladder->position($s_position);
        }
      }

    } else {

      if ($self->id_team() == $winner) {
        $s_ladder->position($main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST);
        $c_ladder->position($main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST);
      } else {
        $c_ladder->position($main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST);
        $s_ladder->position($main_ladder_count + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST + $ACCOUNT_FOR_ALL_NON_MAIN_TEAMS_ARE_LAST);
      }

    }
  }

  my $date = $self->date_today({type => 'mysql'});
  $c_ladder->last_played($date);
  $s_ladder->last_played($date);

  my $main_ladder_type_id = badminton_ladder::model::ladder_type->new({
    util => $self->util,
    description => 'Main',
  })->id_ladder_type();

  $s_ladder->id_ladder_type($main_ladder_type_id);
  $c_ladder->id_ladder_type($main_ladder_type_id);

  if ($self->id_team() == $winner) {
    $self->increment_wins();
    $challenger->increment_losses();
  } else {
    $self->increment_losses();
    $challenger->increment_wins();
  }

  $self->challenged_by(undef);
  $challenger->challenged_by(undef);

  $self->update();
  $challenger->update();

  $s_ladder->save();
  $c_ladder->save();

  return 1;
}

sub increment_wins {
  my ($self) = @_;
  $self->read();
  $self->{win}++;
  return 1;
}

sub increment_losses {
  my ($self) = @_;
  $self->read();
  $self->{loss}++;
  return 1;
}

1;
__END__

=head1 NAME

badminton_ladder::model::team

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oTeam = badminton_ladder::model::team->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - field descriptors

=head2 date_today - returns a date string. May be reuested as mysql for yyyy-mm-dd, else returns a human readable date dd mon yyyy

  my $sDate = $o>date_today({type => 'mysql|human'});

=head2 human_date - returns a string dd mon yyyy from a given date string

  my $sDate = $o->human_date({mysql_date => 'yyyy-mm-dd'});

=head2 challenged_teams
=head2 challenger
=head2 eligible_challenge
=head2 generate_team
=head2 increment_losses
=head2 increment_wins
=head2 init
=head2 non_challenged_teams
=head2 played
=head2 save_challenge
=head2 update_result

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item ClearPress::model

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
