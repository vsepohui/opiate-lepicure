package Opiate::Controller::Books;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Book;
use Opiate::Model::BookList;
use Opiate::Magic;

use utf8;

use constant LISTS_PER_PAGE => 10; 


sub owner {
	my $self  = shift;
	my $alias = $self->stash('alias');
	return Opiate::Model::User->get_by_alias(alias => $alias);
}

sub is_allowed {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub books {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();

	return $self->render(owner => $owner);
}

sub add {
	my $self = shift;
	my $user = $self->user;
	
	return $self->error('Ошибка доступа!') unless $self->is_allowed();
	my $owner = $self->owner();
	
	if ($self->req->method eq 'POST') {
		my $name = $self->param('name') or return $self->error('Вы не ввели название книги!');
		my $year = $self->param('year') or return $self->error('Вы не ввели год написания книги!');
		my $alias = lc Opiate::Magic::rus_to_translit($name);
		$alias =~ s/[^\w\d]/\-/g;
		
		my $book = Opiate::Model::Book->insert( 
			user_id	=> $owner->{id},
			name    => $name,
			alias	=> $alias,
			year    => $year,
		);
		
		return $self->redirect_to('/' . $owner->{alias} . '/books/' . $book->{id} . '/' . $alias);
	}
	
	return $self->render(owner => $owner);
}


1;
