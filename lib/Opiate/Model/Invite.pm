package Opiate::Model::Invite;

use 5.022;
use warnings;

use Opiate::Magic;

use base 'Opiate::Model';


sub select_all {
	my $class   = shift;
	
	my @invites = $class->_db->select_all(q[
		SELECT *
		FROM invites
		ORDER BY id
	]) or return;
	
	return map {$class->new(%$_)} @invites;}

1;
