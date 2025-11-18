package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

use Opiate::Magic;
use Digest::CRC qw(crc32);


sub startup {
	my $self = shift;
	
	my $rr = time() . $$;
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

	$self->hook(before_dispatch => sub {
		my $c = shift;
		my $i = crc32 ($$ . time() . $c->req->request_id()) . substr($$, -3) . substr(time(), -3);
		srand($i);
	});


	my $r = $self->routes;
	$r->any('/')->to('Welcome#welcome');
	$r->any('/invite')->to('Welcome#invite');
	$r->any('/trunaev')->to('Welcome#trunaev');
	
	$self->helper(
		'json' => sub {
			my $self = shift;
			my $str  = shift;
			return Opiate::Magic->json_encode($str);
		},
	);
}

1;
