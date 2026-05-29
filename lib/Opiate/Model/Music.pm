package Opiate::Model::Music;

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
		INSERT INTO music (user_id, bandcamp_id)
		VALUES (?, ?)
	], $opts{user_id}, $opts{bandcamp_id});
	
	my $id = $self->_db->last_insert_id('music');

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
		FROM music
		WHERE id = ?
	], $opts{id});
	
	return $class->new(%$obj);
}

sub inc_visit_counter {
	my $self = shift;
	
	$self->{visit_count} ++;
	
	$self->_db->do(q[
		UPDATE music 
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
		FROM music
		WHERE user_id = ?
		ORDER BY id
	], $opts{user_id});
	
	return map {$class->new(%$_)} @list;
}

1;
