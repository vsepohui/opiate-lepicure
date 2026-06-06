package Opiate::Model::Link;

use 5.022;
use warnings;

use Opiate::Magic;

use base 'Opiate::Model';


sub insert {
	my $self = shift;
	my %args = @_;
	
	$self->_db->do(q[
		INSERT INTO links (user_id, url, description)
		VALUES (?, ?, ?)
	], $args{user_id}, $args{url}, $args{description});
	
	return;
}

sub select {
	my $class = shift;
	my %opts  = (
		user_id => undef,
		@_,
	);
	
	my @links = $class->_db->select_all(q[
		SELECT *
		FROM links
		WHERE user_id = ?
		ORDER BY id
	], $opts{user_id}) or return;
	
	return map {$class->new(%$_)} @links;
}

1;
