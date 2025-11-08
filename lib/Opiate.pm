package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

use Math::Random::Secure qw(irand);


sub startup {
	my $self = shift;
	
	my $rr = time() ^ $$;
	
	srand($rr);
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

	my $r = $self->routes;

	$r->get('/')->to('Welcome#welcome');
	
	$self->helper(irand => sub {
		my $c = shift;
		return irand($_);
	});
}

1;
