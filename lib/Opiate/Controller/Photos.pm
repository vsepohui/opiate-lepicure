package Opiate::Controller::Photos;

use 5.022;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Magic;

use utf8;

sub owner {
	my $self  = shift;
	my $alias = $self->stash('alias');
	return Opiate::Model::User->get_by_alias(alias => $alias);
}

sub is_allowed {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub photos {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();

	return $self->render(owner => $owner);
}

sub upload {
	my $self = shift;
	my $user = $self->user;
	
	return $self->error('Ошибка доступа!') unless $self->is_allowed();
	my $owner = $self->owner();
	
	...
}


1;
