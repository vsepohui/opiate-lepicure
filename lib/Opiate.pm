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
		
		# Check cookie
		if (my $sip = $c->session('ip')) {
			if ($sip eq $c->ip) {
				my $user;
				if ($user = Opiate::Model::User->get_by_alias(alias => $c->session('alias'))) {
					$c->stash('user' => $user);
					$c->stash('is_admin' => ($user->{alias} eq $self->config->{admin}));
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
	$r->any('/welcome')->to('Welcome#welcome');
	$r->any('/invite')->to('Welcome#invite');
	$r->any('/logout')->to('Welcome#logout');
	
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
	$r->any('/#alias/books/#book_id/#book_alias/add_list')->to('Books#add_list');
	$r->any('/#alias/books/#book_id/#book_alias/index')->to('Books#index');
	$r->any('/#alias/books/#book_id/#book_alias/#page_id')->to('Books#show');
	
	$r->any('/#alias/books/add')->to('Books#add');
	
	$r->any('/#alias/music')->to('Music#music');
	$r->any('/#alias/music/add')->to('Music#add');
	
	$r->any('/#alias/photos')->to('Photos#photos');
	$r->any('/#alias/photos/upload')->to('Photos#upload');
	
	$r->any('/#alias/links')->to('Links#links');
	$r->any('/#alias/links/add')->to('Links#add');
	
	
	
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
}

1;
