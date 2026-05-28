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
	return Opiate::Model::User->new->get(alias => $alias);
}

sub check_attack {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub feed {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner() or return $self->page_404();
	
	my $alias = $owner->{alias};
	
	if ($self->req->method eq 'POST') {
		die "HAXOR GET OFF!" unless $self->check_attack;
		if ($self->param('avatar_upload')) {
			for my $file (@{$self->req->uploads('upload')}) {
				my $size = $file->size;
				my $name = $file->filename;
				
				return $self->error('Файл слишком большой!') if ($size >= 300_000);
				
				my $path = $self->upload_image($file);
				
				$owner->set(avatar => $path);
				
				return $self->redirect_to('/' . $alias);
			}
		} elsif (my $info = $self->param('info')) {
			$user->set(info => $info);
			return $self->back;
		} else {
			my $subject = $self->param('subject') or return $self->error('Вы не ввели тему сообщения!');
			my $message = $self->param('message') or return $self->error('Вы не ввели текст сообщения!');

			my $feed = Opiate::Model::Feed->new( 
				alias   => $alias,
				subject => $subject,
				message => $message,
				ip 		=> $self->ip,
				ctime   => scalar localtime(),
			);
			return $self->back;		
		}
	}

	
	#my $size = Opiate::Model::Feed->length($alias);
	
	my @feed = reverse Opiate::Model::Feed->get($alias, -1 * POSTS_PER_PAGE(), -1);
	
	my $num = 0;
	for (@feed) {
		$_->{watch_counter} ++;
		$_->update($num);
		$num ++;
	}
	
	return $self->render(
		owner => $owner,
		alias => $self->stash('alias'),
		feed  => \@feed,
	);
}




1;
