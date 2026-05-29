package Opiate::Controller::Music;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Book;
use Opiate::Model::BookList;
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
	
	$self->render(owner => $owner);
}


1;
