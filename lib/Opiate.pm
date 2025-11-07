package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';


sub startup {
	my $self = shift;
	
	srand();
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

	my $r = $self->routes;

	$r->get('/')->to('Welcome#welcome');
}

1;
