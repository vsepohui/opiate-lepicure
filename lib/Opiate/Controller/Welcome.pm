package Opiate::Controller::Welcome;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';


sub welcome {
	my $self = shift;
	return $self->render;
}

sub invite {
	my $self = shift;
	
	if ($self->req->method eq 'POST') {
		my $name  = $self->param('name') or return $self->error('Вы не ввесли свое имя');
		my $email = $self->param('email') or return $self->error('Вы не ввели свой email');
		my $ask   = $self->param('ask') or return $self->error('Вы не указали причину заявки на приглашение');
		
		my $ip = $self->ip;
		my $k = "invite:limit:$ip";
		if ($self->redis->get($k)) {
			return $self->error('Вы не можете просить приглашение чаще чем раз в 1 час!');
		}
		$self->redis->setex($k, 60*60, 1);
		
		$self->db->do(q[
			INSERT INTO invites (name, email, ask) VALUES (?, ?, ?)
		], $name, $email, $ask);
	}
	
	return $self->render;
}

sub trunaev {
	my $self = shift;
	return $self->render;
}


1;
