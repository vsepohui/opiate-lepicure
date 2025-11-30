package Opiate::Controller::User;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;


sub get_user {
	my $self  = shift;
	my $alias = shift;
	
	my ($user) = Opiate::Model::User->new->select_all(alias => $alias);
	 
	return $user;
}

sub feed {
	my $self = shift;
	my $alias = $self->stash('alias');
	
	my $user = $self->get_user($alias) or return $self->page_404();
	
	return $self->render(
		user => $user,
	);
}


1;
