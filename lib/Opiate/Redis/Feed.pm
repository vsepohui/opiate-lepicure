package Opiate::Redis::Feed;

use 5.022;
use warnings;

use base 'Opiate::Redis';

use utf8;

use Opiate::Magic;



sub prefix {
	my $self = shift;
	return ($self->SUPER::prefix(), 'f');
}

sub push {
	my $self   = shift;
	my $alias  = shift;
	my $object = shift;
	
	my $key = $self->build_key($alias);
	my $obj = Opiate::Magic->json_encode($object);
	
	return $self->redis->rpush($key, $obj);
}

sub length {
	my $self   = shift;
	my $alias  = shift;
	
	my $key = $self->build_key($alias);
	
	return $self->redis->llen($key);
}

sub part {
	my $self    = shift;
	my $alias   = shift;
	my ($x, $y) = @_;
	
	my $key = $self->build_key($alias);
	
	return $self->redis->lrange($key, $x, $y);	
}

1;
