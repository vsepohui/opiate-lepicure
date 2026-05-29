package Opiate::Model::User;

use 5.022;
use warnings;

use Opiate::Magic;


sub new {
	my $class = shift;
	my %opts  = @_;
	
	my $self  = {
		%opts,
	};
	
	return bless $self, $class;
}

sub _db {
	my $class = shift;
	state $db = new Opiate::DB;
	return $db;
}

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
#	my %args = @_;
	#if (my $p = $args{password}) {
	#	$args{password} = $self->crypt_password($p);
	#}
	
	#return $self->SUPER::set(%args);
	...
}

sub insert {
	my $self = shift;
	my %args = @_;
	
	$args{password} = $self->crypt_password($args{password}) if $args{password};
	...

}

sub get_by_alias {
	my $class   = shift;
	my %opts = (
		alias => undef,
		@_,
	);
	
	my ($user) = $class->_db->select_all(q[
		SELECT *
		FROM users
		WHERE alias = ?
	], $opts{alias}) or return;
	
	return $class->new(%$user);
}

sub get_by_email {
	my $class   = shift;
	my %opts = (
		email => undef,
		@_,
	);
	
	my ($user) = $class->_db->select_all(q[
		SELECT *
		FROM users
		WHERE email = ?
	], $opts{email}) or return;
	
	return $class->new(%$user);
}

1;
