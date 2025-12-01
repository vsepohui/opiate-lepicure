package Opiate::Model::User;

use 5.022;
use warnings;

use base 'Opiate::Model';

use Opiate::Magic;

use constant table => 'users';


sub crypt_password {
	my $self = shift;
	my $password = shift;
	return Opiate::Magic->crypt_password($password);
}

sub check_password {
	my $self = shift;
	my $password = shift;
	return Opiate::Magic->check_password($self->{password}, $password);
}

sub set {
	my $self = shift;
	my %args = shift;
	if (my $p = $args{password}) {
		$args{password} = $self->crypt_password($p);
	}
	
	return $self->SUPER::set(%args);
}

sub insert {
	my $self = shift;
	my %args = @_;
	
	$args{password} = $self->crypt_password($args{password}) if $args{password};
	
	return $self->SUPER::insert(%args);
}

1;
