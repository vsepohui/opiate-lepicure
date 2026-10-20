package Opiate::Controller::Temple;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Invite;
use Opiate::Model::HistoryLog;

use POSIX qw(ceil);


sub acl {
	my $self = shift;
	die $self->error('Ошибка доступа') unless $self->stash('is_god');
}


sub temple {
	my $self = shift;
	$self->acl;
	
	return $self->render;
}

sub users {
	my $self = shift;
	$self->acl;
	
	my @users = Opiate::Model::User->select_all;
	
	return $self->render(
		users => \@users,
	);
}

sub history_log {
	my $self = shift;
	$self->acl;
	
	my $page = $self->param('page') || 1;
	
	my $count = Opiate::Model::HistoryLog->count();
	my @log = Opiate::Model::HistoryLog->select(limit => 10, offset => ($page - 1) * 10);
	
	return $self->render(
		log		=> \@log,
		page	=> $page,
		count	=> $count,
		page_count => ceil ($count / 10),
	);
}

sub user_sudo {
	my $self = shift;
	$self->acl;
	
	my ($user) = Opiate::Model::User->get_by_alias(alias => $self->param('alias')) or die "User not found";
	
	$self->session('sudo' => $user->{alias});
	
	return $self->redirect_to('/' . $user->{alias});
}

sub user_sudo_off {
	my $self = shift;
	if ($self->session->{sudo}) {
		delete $self->session->{sudo};
	} else {
		return $self->page_404;
	}
	
	return $self->redirect_to('/temple/users');
}

sub users_edit {
	my $self = shift;
	
	$self->acl;
	
	my ($user) = Opiate::Model::User->get_by_alias(alias => $self->param('alias')) or die "User not found";
	
	if ($self->req->method eq 'POST') {
		my $name = $self->param('name') or die "Name not specified";
		my $email = $self->param('email') or die "Email not specified";
		
		$user->update_admin(
			name  => $name,
			email => $email,
		);
	}
	
	return $self->render(
		admin_user => $user,
	);
}

sub invites {
	my $self = shift;
	$self->acl;
	
	my @invites = Opiate::Model::Invite->select_all;
	
	return $self->render(
		invites => \@invites,
	);
}


1;
