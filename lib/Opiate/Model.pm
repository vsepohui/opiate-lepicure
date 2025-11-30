package Opiate::Model;

use 5.022;
use warnings;

use Opiate::DB;


sub new {
	my $class = shift;
	my %init  = @_;
	
	my $self  = {
		_db => new Opiate::DB,
		%init,
	};
	return bless $self, $class;
}

sub db {
	my $self = shift;
	return $self->{_db};
}

sub table {
	...
}

sub select_all {
	my $self = shift;
	my %args = @_;
	
	my $sql = q[SELECT * FROM ] . $self->table . q[ WHERE ];
	
	my @where = ();
	my @binds = ();
	
	my @list = keys %args;
	
	for (@list) {
		push @where, qq[ $_ = ? ];
		push @binds, $args{$_};
	}
	
	$sql .= join 'AND', @where;
	
	my $class = ref $self;
	my @result = map {$class->new($_)} $self->db->select_all($sql, @binds);
	return wantarray ? @result : \@result;
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

1;
