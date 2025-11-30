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

sub generate_random_string {
	my $self   = shift;
    my $length = shift;
    
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9'); # Define your character set
    my $random_string = '';
    
    for (1..$length) {
        $random_string .= $chars[rand @chars];
    }
    return $random_string;
}

sub crypt_password {
	my $self = shift;
	my $pass = shift;
	my $salt = $self->generate_random_string(8);
	return crypt($pass, $salt) . $salt;
}

sub check_password {
	my $self = shift;
	my $hash = shift;
	my $pass = shift;
	my $salt = substr($hash, length($hash) - 8);
	return $hash eq (crypt($pass, $salt) . $salt);
}


1;
