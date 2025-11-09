package Opiate::Redis;

use 5.022;
use warnings;

use utf8;
use Redis::Fast;


sub redis {
	state $redis = Redis::Fast->new(server => '127.0.0.1:6379', encoding => undef);
	return $redis;
}


1;
