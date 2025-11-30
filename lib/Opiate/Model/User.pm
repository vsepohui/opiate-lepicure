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

1;
