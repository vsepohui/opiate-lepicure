package Opiate::Controller::Welcome;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub welcome {
	my $self = shift;
	return $self->render;
}

1;
