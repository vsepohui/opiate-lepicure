package Opiate::Config;

use 5.022;
use warnings;

use FindBin qw($Bin);

sub new {
	my $class = shift;
	
	state $self;
	
	unless ($self) {
		my $fi;
		
		my $f = $Bin . '/../opiate.conf';
		open $fi, $f;
		my $s = join '', <$fi>;
		close $fi;
		
		$self = eval $s;

		$self = bless $self, $class;
	}
	
	return $self;
}



1;
