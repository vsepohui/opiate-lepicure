package Opiate::Memcached;

use 5.022;
use warnings;

use JSON::XS;
use Cache::Memcached::Fast;

use utf8;


sub new {
	my $class = shift;
	my $self  = {};
	return bless $self, $class;
}

sub memd {
	state $memd = Cache::Memcached::Fast->new({
		servers => [ { address => '127.0.0.1:11211' } ],
		namespace => 'opiate:',
		connect_timeout => 0.2,
		io_timeout => 0.5,
		close_on_error => 1,
		compress_threshold => 100_000,
		compress_ratio => 0.9,
		max_failures => 3,
		failure_timeout => 2,
		ketama_points => 150,
		nowait => 1,
		hash_namespace => 1,
		serialize_methods => [ \&Storable::freeze, \&Storable::thaw ],
		utf8 => 1,
		max_size => 512 * 1024,
	});
	return $memd;
}

sub get {
	my $self = shift;
	my $key  = shift;
	
	return $self->memd->get($key);
}

sub set {
	my $self = shift;
	my $key  = shift;
	my $val  = shift;
	
	return $self->memd->set($key => $val);
}

sub delete {
	my $self = shift;
	my $key  = shift;
	
	return $self->memd->delete($key);
}




1;
