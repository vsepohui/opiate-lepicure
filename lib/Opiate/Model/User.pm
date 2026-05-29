package Opiate::Model::User;

use 5.022;
use warnings;

use Opiate::Magic;

use base 'Opiate::Model';


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

sub set_info {
	my $self = shift;
	my %args = @_;
	
	$self->{info} = $args{info};

	$self->_db->do(q[
		UPDATE users
		SET info = ?
		WHERE id = ?
	], $self->{info}, $self->{id});
}

sub set_avatar {
	my $self = shift;
	my %args = @_;
	
	$self->{avatar} = $args{avatar};

	$self->_db->do(q[
		UPDATE users
		SET avatar = ?
		WHERE id = ?
	], $self->{avatar}, $self->{id});
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
