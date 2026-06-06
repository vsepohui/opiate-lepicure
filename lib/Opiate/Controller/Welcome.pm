package Opiate::Controller::Welcome;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;


sub welcome {
	my $self = shift;
	
	if (my $alias = $self->session('alias')) {
		return $self->redirect_to('/' . $alias);
	}
	
	if ($self->req->method eq 'POST') {
		my $email    = lc $self->param('email') or return $self->error('Вы не ввели свой email');
		my $password = $self->param('password') or return $self->error('Вы не ввели свой пароль');
		my ($user) = Opiate::Model::User->get_by_email(email => $email) or return $self->error('Не верный пароль');
		return $self->error('Не верный пароль') unless $user->check_password($password);
		$self->session(alias => $user->{alias});
		$self->session(ip => $self->ip);
		if ($self->param('remember')) {
			$self->session(expiration => 4233600);
		} else {
			$self->session(expiration => 86400);
		}
		return $self->redirect_to('/' . $user->{alias});
	}
	return $self->render;
}

sub invite {
	my $self = shift;
	
	if ($self->req->method eq 'POST') {
		my $name  = $self->param('name') or return $self->error('Вы не ввесли свое имя');
		my $alias  = $self->param('alias') or return $self->error('Вы не ввесли свой логин');
		my $email = $self->param('email') or return $self->error('Вы не ввели свой email');
		my $ask   = $self->param('ask') or return $self->error('Вы не указали причину заявки на приглашение');
		
		my $ip = $self->ip;
		my $k = "invite:limit:$ip";
		if ($self->redis->get($k)) {
			return $self->error('Вы не можете просить приглашение чаще чем раз в 1 час!');
		}
		$self->redis->setex($k, 60*60, 1);
		
		$self->db->do(q[
			INSERT INTO invites (alias, name, email, ask) VALUES (?, ?, ?, ?)
		], $alias, $name, $email, $ask);
		
		$self->stash(is_submit => 1);
	}
	
	return $self->render;
}

sub logout {
	my $self = shift;
    $self->session(expires => 1);
	return $self->redirect_to('/');
}

sub update_magic {
	my $self = shift;
	my $magic = $self->stash('magic');
	my ($val) = $magic =~ / value="([^"]+)"/;
	return $self->render(text => $val);
}

1;
