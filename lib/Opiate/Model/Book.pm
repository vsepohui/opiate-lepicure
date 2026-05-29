package Opiate::Model::Book;

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
		INSERT INTO books (user_id, name, year, alias)
		VALUES (?, ?, ?, ?)
	], $opts{user_id}, $opts{name}, $opts{year}, $opts{alias});
	
	my $id = $self->_db->last_insert_id('books');

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
		FROM books
		WHERE id = ?
	], $opts{id});
	
	return $class->new(%$obj);
}

sub inc_visit_counter {
	my $self = shift;
	
	$self->{visit_count} ++;
	
	$self->_db->do(q[
		UPDATE books 
		SET visit_count = ?
		WHERE id = ?
	], $self->{visit_count}, $self->{id});
	
	return;
}

1;
