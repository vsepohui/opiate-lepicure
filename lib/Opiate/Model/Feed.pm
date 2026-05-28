package Opiate::Model::Feed;

use 5.022;
use warnings;

use utf8;

use Opiate::Redis;
use Opiate::Magic;
use Carp;


sub new {
	my $class = shift;
	my %opts  = @_;
	
	my $self = {
		alias   => $opts{alias},
		subject => $opts{subject},
		message => $opts{message},
		ip 		=> $opts{ip},
		ctime   => scalar localtime(),
	};
	
	bless $self, $class;
	
	$self->{id} = $class->_get_last_id($self->{alias}) + 1;
	
	$self->push();
	
	return $self;
}

sub get {
	my $class = shift;
	my $alias = shift;
	my ($x, $y) = @_;
	
	my @list =  map {bless $_, $class} map {Opiate::Magic->json_decode($_)} $class->_range($alias, $x, $y);
	return @list;
}

sub set {
	my $self = shift;;
	my $num  = shift;
	my $obj = Opiate::Magic->json_encode({%$self});
	$self->_db->lset($self->build_key(), $num, $obj);
}

sub _prefix {
	my $self = shift;
	return '0', 'f';
}

sub _db {
	my $self = shift;
	state $db = new Opiate::Redis;
	return $db;
}

sub _get_last_id {
	my $class = shift;
	my $alias = shift;
	my ($last) = $class->get($alias, -1, -1);
	return $last->{id} || 0;
}


sub length {
	my $self = shift;
	my $key  = $self->build_key(@_);
	return $self->_db->llen($key);
}


sub build_key {
	my $self = shift;
	my $alias = shift || $self->{alias};
	
	my @key = ($self->_prefix);
	push @key, ref $alias ?  @$alias : $alias;
	
	return join '::', @key;
}

sub _range {
	my $self  = shift;
	my $alias = shift;
	my ($x, $y) = @_;
	
	my $key = $self->build_key($alias);
	
	return $self->_db->lrange($key, $x, $y);	
}

sub push {
	my $self   = shift;

	my $key = $self->build_key();
	my $obj = Opiate::Magic->json_encode({%$self});
	return $self->_db->rpush($key, $obj);
}

1;
