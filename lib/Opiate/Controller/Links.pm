package Opiate::Controller::Links;

use 5.022;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Link;
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

sub links {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();
	
	my @links = Opiate::Model::Link->select(user_id => $owner->{id});

	return $self->render(
		owner => $owner,
		links => \@links,
	);
}

sub add {
	my $self = shift;
	my $user = $self->user;
	
	return $self->error('Ошибка доступа!') unless $self->is_allowed();
	my $owner = $self->owner();

	my $url         = $self->param('url') or return $self->error('Вы не ввели ссылку!');
	my $description = $self->param('description') or return $self->error('Вы не ввели описание ссылки!');
	
	return $self->error('Вы ввели некорректную ссылку!') unless $url =~ /^https?:\/\/[\d\w\-\.]+/;

	Opiate::Model::Link->insert(
		user_id     => $owner->{id},
		url         => $url, 
		description => $description,
	);
	
	return $self->redirect_to('/' . $owner->{alias} . '/links');
}


1;

