package Opiate::Model;

use 5.022;
use warnings;

use Opiate::DB;

sub new {
	my $class = shift;
	my %opts  = @_;
	
	my $self = {
		%opts
	};
	
	bless $self, $class;
	
	return $self;
}

sub _db {
	my $class = shift;
	state $db = new Opiate::DB;
	return $db;
}


1;
