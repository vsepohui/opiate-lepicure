package Opiate::Controller::Admin;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;


sub acl {
	my $self = shift;
	die $self->error('Ошибка доступа') unless $self->stash('is_admin');
}


sub admin {
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
	
	return $self->render;
}

1;
