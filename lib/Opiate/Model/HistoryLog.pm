package Opiate::Model::HistoryLog;

use 5.022;
use warnings;

use Opiate::Magic;

use base 'Opiate::Model';


sub insert {
	my $self = shift;
	my %args = (
		user_id 		=> undef,
		sudo_id 		=> undef,
		object_table	=> undef,
		object_id 		=> undef,
		log 			=> undef,
		@_,
	);
	
	$self->_db->do(q[
		INSERT INTO history_log (user_id, sudo_id, object_table, object_id, log)
		VALUES (?, ?, ?, ?, ?)
	], $args{user_id}, $args{sudo_id}, $args{object_table}, $args{object_id}, $args{log});
	
	return;
}


sub count {
	my $class = shift;
	
	my ($row) = $class->_db->select_all(q[
		SELECT COUNT(1) AS count
		FROM history_log
	]);
	
	return $row->{count};
}

sub select {
	my $class = shift;
	my %opts  = (
		limit  => undef,
		offset => undef,
		@_,
	);
		
	
	my @users = $class->_db->select_all(q[
		SELECT *
		FROM history_log
		ORDER BY id DESC
		LIMIT ?
		OFFSET ?
	], $opts{limit}, $opts{offset}) or return;
	
	return map {$class->new(%$_)} @users;
}

1;
