package Opiate::Controller;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Opiate::DB;
use Opiate::Redis;



sub user {
	my $self  = shift;
	return $self->stash('user');
}


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

sub page_404 {
	my $self = shift;
	return $self->reply->not_found;
}

sub upload_image {
	my $self = shift;
	my $file = shift;

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
		
	my @path = (qw(i up), $year, $mon, $mday);
	
	my $pref = 'public';
	my @buff = ();
	for my $p (@path) {
		push @buff, $p;
		my @pp = ($pref, @buff);
		my $dir = join '/', @pp;
		mkdir $dir unless (-d $dir);
	}
	my $dir = join '/', ($pref, @buff);
	
	my $ext = $file->filename;
	$ext =~ s/^.+?\.(...)$/$1/;
	
	my $full_path;
	while (1) {
		my $new_filename = Opiate::Magic->generate_random_string(16);
		$full_path = $dir . '/' . $new_filename . '.' . $ext;
		last unless -f $full_path;
	}
	
	$file->move_to($full_path);
	
	my $result = $full_path;
	$result =~ s/^public//;
	
	return $result;
}

1;
