package Opiate::Model::Photo;

use 5.022;
use warnings;

use utf8;

use Opiate::DB;
use Opiate::Magic;

use base 'Opiate::Model';


sub insert {
	my $self = shift;
	my %opts = @_;
	
	$self->_db->do(q[
		INSERT INTO photo (user_id, path)
		VALUES (?, ?)
	], $opts{user_id}, $opts{path});
	
	my $id = $self->_db->last_insert_id('path');

	return $self->select_by_id(id => $id);
}

sub select_by_id {
	my $class = shift;
	my %opts  = (
		id	=> undef,
		@_,
	);
	
	my ($obj) = $class->_db->select_all(q[
		SELECT * 
		FROM photo
		WHERE id = ?
	], $opts{id});
	
	return $class->new(%$obj);
}

sub inc_visit_counter {
	my $self = shift;
	
	$self->{visit_count} ++;
	
	$self->_db->do(q[
		UPDATE photo 
		SET visit_count = ?
		WHERE id = ?
	], $self->{visit_count}, $self->{id});
	
	return;
}

sub select {
	my $class = shift;
	my %opts  = (
		user_id => undef,
		@_,
	);
	
	my @list = $class->_db->select_all(q[
		SELECT * 
		FROM photo
		WHERE user_id = ?
		ORDER BY id
	], $opts{user_id});
	
	return map {$class->new(%$_)} @list;
}

1;
