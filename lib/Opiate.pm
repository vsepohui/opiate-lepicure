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
		
		$c->stash('is_admin' => 0);
		
		my $user;
		
		# Check cookie
		if (my $sip = $c->session('ip')) {
			if ($sip eq $c->ip) {
				if ($user = Opiate::Model::User->get_by_alias(alias => $c->session('alias'))) {
					$c->stash('user' => $user);
					$c->stash('is_admin' => ($user->{alias} eq $self->config->{admin}));				
				} else {
					return $c->page_404;
				}
			} else {
				 $self->session(expires => 1);
			}
		} else {
			 $self->session(expires => 1);
		}

		my $code = Opiate::Magic->generate_random_string(32).':'.($user ? $user->{id} : 0).':'.time();
		my $token = Opiate::Magic->sign_with_secret($code, $c->config->{secrets}->[0]);

		$c->stash(magic => '<input type="hidden" name="magic" value="' . $code . ':' . $token . '"/>');	


		if ($c->req->method() eq 'POST') {
			my $magic = $c->param('magic') or return $c->page_404;
			my ($rnd, $user_id, $time, $sign) = split /:/, $magic;
			
			die "Wrong magic" if ($user_id != ($user ? $user->{id} : 0));
			
			my $code = $rnd . ':' . $user_id . ':' . $time;
			return $c->error('Попробуйте еще раз') if (Opiate::Magic->sign_with_secret($code, $c->config->{secrets}->[0]) ne $sign || time() > $time + 60);
		}
		
		
		return 1;
	});

	
	my $r = $self->routes;
	$r->any('/')->to('Welcome#welcome');
	$r->any('/welcome')->to('Welcome#welcome');
	$r->any('/invite')->to('Welcome#invite');
	$r->post('/logout')->to('Welcome#logout');
	$r->any('/ajax/update_magic')->to('Welcome#update_magic');
	
	$r->any('/admin')->to('Admin#admin');
	$r->any('/admin/users')->to('Admin#users');
	$r->any('/admin/users/edit')->to('Admin#users_edit');
	$r->any('/admin/invites')->to('Admin#invites');
	
	$r->any('/#alias')->to('User#feed');
	$r->any('/#alias/profile')->to('User#profile');
	$r->any('/#alias/feed.rss')->to('User#feed', rss => 1);
	$r->any('/#alias/feed/#post')->to('User#post');
	$r->any('/#alias/ajax/update')->to('User#ajax_feed_update');
	
	$r->any('/#alias/books')->to('Books#books');
	$r->any('/#alias/books/#book_id/#book_alias')->to('Books#show');
	$r->post('/#alias/books/#book_id/#book_alias/add_list')->to('Books#add_list');
	$r->any('/#alias/books/#book_id/#book_alias/index')->to('Books#index');
	$r->any('/#alias/books/#book_id/#book_alias/#page_id')->to('Books#show');
	
	$r->post('/#alias/books/add')->to('Books#add');
	
	$r->any('/#alias/music')->to('Music#music');
	$r->post('/#alias/music/add')->to('Music#add');
	
	$r->any('/#alias/photos')->to('Photos#photos');
	$r->post('/#alias/photos/upload')->to('Photos#upload');
	
	$r->any('/#alias/links')->to('Links#links');
	$r->post('/#alias/links/add')->to('Links#add');
	
	
	
	$self->helper(
		'json' => sub {
			my $self = shift;
			my $str  = shift;
			return Opiate::Magic->json_encode($str);
		}
	);
	
	$self->helper(
		'format_postgres_timestamp' => sub {
			my $self = shift;
			my $str  = shift;
			$str =~ s/\..+//;
			return $str;
		},
	);
	
	$self->helper(
		'html_escape' => sub {
			my $self = shift;
			my $str  = shift;
			
			$str =~ s/&/&amp;/g;   # Ampersand must be first
			$str =~ s/</&lt;/g;    # Less than
			$str =~ s/>/&gt;/g;    # Greater than
			$str =~ s/"/&quot;/g;  # Double quote
			$str =~ s/'/&#39;/g;   # Single quote

			return $str;
		},
	);
	
	$self->helper(
		'magic' => sub {
			my $self = shift;
			return $self->stash('magic');
		}
	);
}

1;
