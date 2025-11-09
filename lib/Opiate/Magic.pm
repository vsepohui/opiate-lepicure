package Opiate::Magic;

use 5.022;
use warnings;

use Data::Validate::Email qw(is_email);
use JSON::XS;
use Mojo::Home;
use utf8;


sub new {
	my $class = shift;
	state $self = bless {}, $class;
	return $self;
}

sub dir {
	my $self = shift;
	
	state $dir;
	unless ($dir) {
		my $home = Mojo::Home->new;
		$home->detect;
		$dir = "$home";
	}
	return $dir;
}


sub json {
	my $class = shift;
	state $json = JSON::XS->new->utf8;
	return $json->latin1;
}

sub json_decode {
	my $class = shift;
	my $text = shift;
	return eval {$class->json->decode($text)};
}

sub json_encode {
	my $class = shift;
	my $perl = shift;
	my $text = $class->json->encode($perl);
	return $text;
}

1;
