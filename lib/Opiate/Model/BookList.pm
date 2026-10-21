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
	
	my $ckey = 'book_lists:'.$opts{book_id};
	$self->_cache->delete($ckey);
	
	$self->_db->do(q[
		INSERT INTO book_lists (book_id, title, text)
		VALUES (?, ?, ?)
	], $opts{book_id}, $opts{title}, $opts{text});
	
	
	my $id = $self->_db->last_insert_id('book_lists');

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
		FROM book_lists
		WHERE id = ?
	], $opts{id});
	
	return $class->new(%$obj);
}


sub select_all_by_book_id {
	my $class = shift;
	my $book_id = shift;
	
	my $c = $class->_cache;
	my $ckey = 'book_lists:'.$book_id;
	
	my @list;
	
	if (my $list = $c->get($ckey)) {
		@list = @$list;
	} else {
		@list = $class->select(
			book_id => $book_id,
			limit   => 1000,
			offset  => 0,
		);
		
		$c->set($ckey => \@list);
	}
	
	return @list;
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

sub select_desc {
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
		ORDER BY id DESC
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

sub update {
	my $self = shift;
	my %opts = @_;
	
	my $ckey = 'book_lists:'.$self->{book_id};
	$self->_cache->delete($ckey);	
	
	$self->{title} = $opts{title};
	$self->{text} = $opts{text};
	
	$self->_db->do(q[
		UPDATE book_lists 
		SET 
			title = ?,
			text = ?
		WHERE id = ?
	], $self->{title}, $self->{text}, $self->{id});
	
	return;

}

1;
