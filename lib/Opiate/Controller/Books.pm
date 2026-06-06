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
	
	
	my @books = Opiate::Model::Book->select_by_user_id(user_id => $owner->{id});
	
	return $self->render(
		owner => $owner, 
		books => \@books,
	);
}


sub show {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();
	
	
	my ($book) = Opiate::Model::Book->select_by_id(id => $self->stash('book_id')) or  return $self->error('Книга не найдена!');
	return $self->error('Книга не найдена!') if(($book->{user_id} != $owner->{id}) || ($book->{alias} ne $self->stash('book_alias')));
	
	my $offset = $self->stash('page_id') || 1;
	
	my ($list) = Opiate::Model::BookList->select(
		book_id => $book->{id},
		limit   => 1,
		offset  => $offset - 1,
	);
	
	my $lists_count = Opiate::Model::BookList->count(book_id => $book->{id});
	
	return $self->render(
		owner       => $owner, 
		book        => $book,
		list        => $list,
		lists_count => $lists_count,
		page_id		=> $offset,
	);
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

	return $self->redirect_to('/' . $owner->{alias} . '/books');
}

sub add_list {
	my $self = shift;
	my $user = $self->user;
	
	return $self->error('Ошибка доступа!') unless $self->is_allowed();
	my $owner = $self->owner();
	
	if ($self->req->method eq 'POST') {
		my ($book) = Opiate::Model::Book->select_by_id(id => $self->stash('book_id')) or  return $self->error('Книга не найдена!');
		return $self->error('Книга не найдена!') if(($book->{user_id} != $owner->{id}) || ($book->{alias} ne $self->stash('book_alias')));
		
		my $offset = $self->stash('page_id') || 0;

		my $title = $self->param('title') or return $self->error('Вы не заголовок!');
		my $text = $self->param('text') or return $self->error('Вы не ввели текст!');		
			
		my ($list) = Opiate::Model::BookList->insert(
			book_id => $book->{id},
			title   => $title,
			text    => $text,
		);
		
		return $self->redirect_to('/' . $owner->{alias} . '/books/' . $book->{id} . '/' . $book->{alias});
	}

	return $self->redirect_to('/' . $owner->{alias} . '/books');
}


1;
