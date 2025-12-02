package Opiate;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

use Opiate::Controller;
use Opiate::Model::User;
use Opiate::Magic;
use Digest::CRC qw(crc32);


sub startup {
	my $self = shift;

        
   	my $rr = time() . $$;
	my $config = $self->plugin('NotYAMLConfig');
	$self->secrets($config->{secrets});

    $self->routes->namespaces(['Opiate::Controller']);
    $self->controller_class('Opiate::Controller');

	$self->hook(before_dispatch => sub {
		my $c = shift;
		my $i = crc32 ($$ . time() . $c->req->request_id()) . substr($$, -3) . substr(time(), -3);
		srand($i);
		
		# Check cookie
		if (my $sip = $c->session('ip')) {
			if ($sip eq $c->ip) {
				my $user;
				if ($user = Opiate::Model::User->new->get(alias => $c->session('alias'))) {
					$c->stash('user' => $user);
				} else {
					return 0;
				}
			} else {
				 $self->session(expires => 1);
			}
		} else {
			 $self->session(expires => 1);
		}
		
		return 1;
	});

	
	my $r = $self->routes;
	$r->any('/')->to('Welcome#welcome');
	$r->any('/invite')->to('Welcome#invite');
	$r->any('/logout')->to('Welcome#logout');
	$r->any('/#alias')->to('User#feed');
	
	
	$self->helper(
		'json' => sub {
			my $self = shift;
			my $str  = shift;
			return Opiate::Magic->json_encode($str);
		},
	);
}

1;
