package Opiate::Controller::Music;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Music;
use Opiate::Magic;

use utf8;

use constant LIMIT => 400; 


sub owner {
	my $self  = shift;
	my $alias = $self->stash('alias');
	return Opiate::Model::User->get_by_alias(alias => $alias);
}

sub is_allowed {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub music {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();
	
	my @music = Opiate::Model::Music->select(user_id => $owner->{id});

	$self->render(
		owner => $owner,
		music => \@music,
	);
}

sub add {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();
	return $self->error('Ошибка доступа') unless $self->is_allowed;
	
	my $html = $self->param('html');
	my ($id) = $html =~ /https:\/\/bandcamp.com\/EmbeddedPlayer\/album=(\d+)/;

	Opiate::Model::Music->insert(user_id => $owner->{id}, bandcamp_id => $id);
	
	return $self->redirect_to('/' . $owner->{alias} . '/music');
}



1;
