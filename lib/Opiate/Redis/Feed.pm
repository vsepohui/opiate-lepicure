package Opiate::Redis::Feed;

use 5.022;
use warnings;

use base 'Opiate::Redis';

use utf8;

use Opiate::Magic;


sub get_last_id {
	my $self = shift;
	my $alias  = shift;

	my $l = $self->length($alias) or return 0;
	
	my ($last) = $self->part($alias, $l - 1, $l - 1);

	my $hash = Opiate::Magic->json_decode($last);
	
	return $hash->{id} || 0;
}

sub watch_counter_inc {
	my $self = shift;
	my $alias = shift;
	my $num   = shift;
	
	my $key = $self->build_key($alias);
	
	my ($obj) = $self->part($alias, $num, $num);
	
	my $hash = Opiate::Magic->json_decode($obj);

	$hash->{watch_counter} = ($hash->{watch_counter} // 0) + 1;
	
	$obj = Opiate::Magic->json_encode($hash);
	
	$self->redis->lset($key, $num, $obj);
	
	return 1;
}

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
