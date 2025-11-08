package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

sub startup {
	my $self = shift;
	
	my $rr = time() . $$;
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

	$self->hook(before_dispatch => sub {
		my $c = shift;
		my $i = $$ . $c->req->request_id() . time();
		die $i;
	#	srand($i);
	});


	my $r = $self->routes;
	$r->get('/')->to('Welcome#welcome');
}

1;
