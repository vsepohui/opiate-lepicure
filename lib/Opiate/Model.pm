package Opiate::Model;

use 5.022;
use warnings;

use Opiate::DB;


sub new {
	my $class = shift;
	my %init  = @_;
	
	my $self  = {
		%init,
	};
	return bless $self, $class;
}

sub db {
	my $self = shift;
	return new Opiate::DB;
}

sub table {
	...
}

sub select_all {
	my $self = shift;
	my @args = @_;
	my %doom = ();
	my %args = ();
	
	if (ref $args[-1]) {
		my $last = pop @args;
		%doom = (%$last);
	}
	%args = (@args);
	
	my $sql = q[SELECT * FROM ] . $self->table . q[ WHERE ];
	
	my @where = ();
	my @binds = ();
	
	my @list = keys %args;
	
	for (@list) {
		push @where, qq[ $_ = ? ];
		push @binds, $args{$_};
	}
	
	$sql .= join 'AND', @where;
	
	if ($doom{limit}) {
		$sql .= " LIMIT ?";
		push @binds, $doom{limit};
	}
	
	my $class = ref $self;
	@list = $self->db->select_all($sql, @binds);
	my @buffer = ();
	for my $hash (@list) {
		push @buffer, bless $hash, $class;
	}
	return wantarray ? @buffer : \@buffer;
}

sub insert {
	my $self = shift;
	my %args = @_;
	
	my $sql = q[INSERT INTO ] . $self->table;
	
	my @fields = ();
	my @binds = ();
	
	my @list = keys %args;
	
	for (@list) {
		push @fields, q[ ? ];
		push @binds, $args{$_};
	}
	
	$sql .= '(' . (join ',', @list) . ') ';
	$sql .= 'VALUES (' . (join ',', map { '?' } @binds) . '); ';
	
	return $self->db->do($sql, @binds);
}

sub set {
	my $self = shift;
	my %args = @_;
	
	my $sql = q[UPDATE ] . $self->table . ' SET ';
	
	my @fields = ();
	my @binds = ();
	
	my @list = keys %args;
	
	my @buffer;
	for (@list) {
		push @binds, $args{$_};
		push @buffer, $_ . ' =  ?';
	}
	
	$sql .= join ', ', @buffer;
	
	return $self->db->do($sql, @binds);
}

sub get {
	my $self   = shift;
	my %family = @_;
	
	my ($hash) = $self->select_all(%family, {'limit' => 1});
	
	return !keys %$hash ? undef : $hash;
}

1;
