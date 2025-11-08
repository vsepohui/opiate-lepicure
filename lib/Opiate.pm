package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

use Digest::CRC qw(crc32);

sub startup {
	my $self = shift;
	
	my $rr = time() . $$;
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

	$self->hook(before_dispatch => sub {
		my $c = shift;
		my $i = hex (crc32 ($$ . time() . $c->req->request_id())) . substr($$, -3) . substr(time(), -3);
		srand($i);
	});


	my $r = $self->routes;
	$r->get('/')->to('Welcome#welcome');
}

1;
