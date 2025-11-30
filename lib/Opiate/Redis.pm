package Opiate::Redis;

use 5.022;
use warnings;

use utf8;
use Redis::Fast;


sub new {
	my $class = shift;
	my $self  = {};
	return bless $self, $class;
}

sub redis {
	state $redis = Redis::Fast->new(server => '127.0.0.1:6379', encoding => undef);
	return $redis;
}

sub prefix {
	my $self = shift;
	return '0';
}

sub build_key {
	my $self = shift;
	my $alias = shift;
	my @key = ($self->prefix);
	push @key, ref $alias ?  @$alias : $alias;
	
	return join '::', @key;
}

sub rpush {
	my $class = shift;
	return $class->redis->rpush(@_);
}

sub llen {
	my $class = shift;
	return $class->redis->llen(@_);
}

sub lrange {
	my $class = shift;
	return $class->redis->lrange(@_);
}



1;
