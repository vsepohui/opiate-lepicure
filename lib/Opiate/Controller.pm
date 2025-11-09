package Opiate::Controller;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Opiate::DB;
use Opiate::Redis;


sub ip {
	my $self = shift;
	return $self->tx->remote_address;
}

sub db {
	my $self = shift;
	return new Opiate::DB;
}

sub redis {
	my $self = shift;
	return Opiate::Redis->redis;
}


sub back {
	my $self = shift;

	if (my $back = $self->param('back')) {
		return $self->redirect_to($back);
	}	

	my $key = 'back';
	if ($self->flash($key)) {
		$self->redirect_to('/');
	} else {
		$self->flash($key => 1);
		$self->redirect_to($self->req->headers->referrer // '/');
	}
}


sub error {
	my $self = shift;
	my $text  = shift;
	$self->noty('error' => $text);
	return $self->back;
}

sub noty {
	my $self = shift;
	my ($type, $msg) = @_;
	my $noty = $self->flash('noty') || [];
	Encode::encode_utf8($type);
	Encode::encode_utf8($msg);
	push @$noty, [$type, $msg];

	$self->flash('noty' => $noty);
	$self->stash('noty' => $noty);
}



1;
