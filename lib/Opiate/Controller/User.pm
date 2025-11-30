package Opiate::Controller::User;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Redis::Feed;


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

	
	if ($self->req->method eq 'POST') {
		die "HAXOR GET OFF!" unless $self->check_attack;
		my $info = $self->param('info');
		$user->set(info => $info);
		return $self->redirect_to('/');
	}
	
	my $feed_key = $owner->{alias};
	
	my $handler = new Opiate::Redis::Feed;
	my $size = $handler->llen($feed_key);

	
	
	return $self->render(
		owner => $owner,
		alias => $self->stash('alias'),
	);
}


sub post {
	my $self = shift;
	my $user = $self->user;
	die 'A';
	my $owner = $self->owner() or return $self->page_404();
	die '22@';
	
	die "HAXOR GET OFF!" if ($self->req->method ne 'POST');
	die "r00t killed ruut" unless $self->check_attack;
	
	my $subject = $self->param('subject');
	my $message = $self->param('message');

	my $handler = new Opiate::Redis::Feed;
	$handler->push($owner->{alias}, {
		subject => $subject,
		message => $message,
		ip 		=> $self->ip,
		ctime   => scalar localtime(),
	});
	
	return $self->back;
	
}


1;
