package Opiate::Model::BookList;

use 5.022;
use warnings;

use utf8;

use Opiate::DB;
use Opiate::Magic;

use base 'Opiate::Model';


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

sub insert {
	my $self = shift;
	my %opts = @_;
	
	$self->_db->do(q[
		INSERT INTO book_lists (book_id, title, text)
		VALUES (?, ?, ?)
	], $opts{book_id}, $opts{title}, $opts{text});
	
	return;
}

sub select {
	my $class = shift;
	my %opts  = (
		book_id => undef,
		limit	=> undef,
		offset  => undef,
		@_,
	);
	
	my @list = $class->_db->select_all(q[
		SELECT * 
		FROM book_lists
		WHERE book_id = ?
		ORDER BY id
		LIMIT ?
		OFFSET ?
	], $opts{book_id}, $opts{limit}, $opts{offset});
	
	return map {$class->new(%$_)} @list;
}


sub count {
	my $class = shift;
	my %opts  = (
		book_id => undef,
		@_,
	);
	
	my ($data) = $class->_db->select_all(q[
		SELECT COUNT(id) AS count
		FROM book_lists
		WHERE book_id = ?
	], $opts{book_id});
	
	return $data->{count};
}


sub inc_visit_counter {
	my $self = shift;
	
	$self->{visit_count} ++;
	
	$self->_db->do(q[
		UPDATE book_lists 
		SET visit_count = ?
		WHERE id = ?
	], $self->{visit_count}, $self->{id});
	
	return;
}

1;
