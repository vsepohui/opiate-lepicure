package Opiate::Model::Feed;

use 5.022;
use warnings;

use utf8;

use Opiate::DB;
use Opiate::Magic;


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
		INSERT INTO feed (user_id, subject, message)
		VALUES (?, ?, ?)
	], $opts{user_id}, $opts{subject}, $opts{message});
	
	return;
}

sub select {
	my $class = shift;
	my %opts  = (
		user_id => undef,
		limit	=> undef,
		case_id	=> undef,
		@_,
	);
	
	my @list = $class->_db->select_all(q[
		SELECT * 
		FROM feed
		WHERE user_id = ?
		AND id > ?
		ORDER BY id DESC
		LIMIT ?
	], $opts{user_id}, $opts{case_id}, $opts{limit});
	
	return map {$class->new(%$_)} @list;
}

sub select_by_id {
	my $class = shift;
	my %opts  = (
		id	=> undef,
		@_,
	);
	
	my ($obj) = $class->_db->select_all(q[
		SELECT * 
		FROM feed
		WHERE id = ?
	], $opts{id});
	
	return $class->new(%$obj);
}

sub inc_visit_counter {
	my $self = shift;
	
	$self->{visit_count} ++;
	
	$self->_db->do(q[
		UPDATE feed 
		SET visit_count = ?
		WHERE id = ?
	], $self->{visit_count}, $self->{id});
	
	return;
}

1;
