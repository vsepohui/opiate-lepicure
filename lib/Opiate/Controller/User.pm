package Opiate::Controller::User;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Feed;
use Opiate::Magic;

use constant POSTS_PER_PAGE => 10; 


sub owner {
	my $self  = shift;
	my $alias = $self->stash('alias');
	return Opiate::Model::User->get_by_alias(alias => $alias);
}

sub check_attack {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub feed {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner() or return $self->page_404();
	
	my $marker = $self->param('marker') // Opiate::Model::Feed->get_max_id();
	
	my $alias = $owner->{alias};
	
	if ($self->req->method eq 'POST') {
		return $self->error('Ошибка доступа!') unless $self->check_attack;
		
		my $subject = $self->param('subject') or return $self->error('Вы не ввели тему сообщения!');
		my $message = $self->param('message') or return $self->error('Вы не ввели текст сообщения!');

		my $feed = Opiate::Model::Feed->insert( 
			user_id	=> $owner->{id},
			subject => $subject,
			message	=> $message,
		);
		return $self->back;
	}

	
	my @feed = Opiate::Model::Feed->select(
		user_id => $owner->{id},
		case_id => $marker,
		limit   => 10,
	);
	
	for (@feed) {
		$_->inc_visit_counter();
	}
	

	return $self->render(
		$self->stash('rss') ? (template => 'user/feed', format => 'rss') : (),
		owner  => $owner,
		alias  => $self->stash('alias'),
		feed   => \@feed,
		marker => $marker,
	);
}

sub profile {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner() or return $self->page_404();
	
	my $marker = $self->param('marker') // Opiate::Model::Feed->get_max_id();
	
	my $alias = $owner->{alias};
	
	if ($self->req->method eq 'POST') {
		return $self->error('Ошибка доступа!') unless $self->check_attack;
		if ($self->param('avatar_upload')) {
			for my $file (@{$self->req->uploads('upload')}) {
				my $size = $file->size;
				my $name = $file->filename;
				
				return $self->error('Файл слишком большой!') if ($size >= 300_000);
				
				my $path = $self->upload_image($owner->{alias}, $file);
				
				$owner->set_avatar(avatar => $path);
				
				return $self->redirect_to('/' . $alias);
			}
		} elsif (my $info = $self->param('info')) {
			$user->set_info(info => $info);
			return $self->back;
		}
	}
	
	return $self->render(
		owner  => $owner,
		alias  => $self->stash('alias'),
	);	
}

sub ajax_feed_update {
	my $self = shift;
	my $owner = $self->owner;
	
	my $case_id = $self->param('case_id') or die "No case_id";
	die "Wrong param" if $case_id =~ /\D/;
	
	my @feed;
	
	if ($self->param('last')) {
		@feed = Opiate::Model::Feed->select_last(
			user_id => $owner->{id},
			case_id => $case_id,
			limit   => 10,
		);
	} else {
		@feed = Opiate::Model::Feed->select_new(
			user_id => $owner->{id},
			case_id => $case_id,
			limit   => 10,
		);
	}
	
	return $self->render(
		template => 'user/ajax_feed',
		owner   => $owner,
		alias   => $self->stash('alias'),		
		feed    => \@feed,
		is_last => ($self->param('last') ? 1 : 0),
	);
}




sub post {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner() or return $self->page_404();
	my $alias = $owner->{alias};
	
	my $feed_id = $self->stash('post');
	die "Page not found" if $feed_id =~/\D/;

	my $feed = Opiate::Model::Feed->select_by_id(id => $feed_id);

	if ($self->req->method eq 'POST') {
		return $self->error('Ошибка доступа!') unless $self->check_attack;
		
		my $subject = $self->param('subject') or return $self->error('Вы не ввели тему сообщения!');
		my $message = $self->param('message') or return $self->error('Вы не ввели текст сообщения!');
		
		
		$feed->update(
			subject => $subject,
			message => $message,
		);
		
		return $self->redirect_to('/' . $alias . '/feed/' . $feed_id);
	}

	$feed->inc_visit_counter();
	
	return $self->render(
		owner => $owner,
		alias => $self->stash('alias'),
		feed  => $feed,
	);
}


1;
