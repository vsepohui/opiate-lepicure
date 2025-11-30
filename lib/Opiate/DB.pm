package Opiate::DB;

use strict;
use warnings;
use 5.028;

use DBI;
use DBD::Pg;

sub _dbh {
	my $class = shift;
	state $dbh = DBI->connect("dbi:Pg:dbname=opiate", 'opiate', '', {AutoCommit => 1});
	return $dbh;
}


sub new {
	my $class = shift;
	
	my $self = {
		dbh => $class->_dbh(),
	};
	$self = bless $self, $class;
	
	return $self;
}

sub dbh {
	my $self = shift;
	return $self->{dbh};
}

sub do {
	my $self  = shift;
	my $sql	  = shift;
	my @binds = @_;
	
	my $dbh = $self->dbh;
	my $sth = $dbh->prepare($sql);
	return $sth->execute(@binds);
}

sub select_all {
	my $self  = shift;
	my $sql	  = shift;
	my @binds = @_;
	
	my $dbh = $self->dbh;
	my $sth = $dbh->prepare($sql);

	$sth->execute(@binds);
	
	my @result = ();
	while (my $row = $sth->fetchrow_hashref) {
		push @result, $row;
	}

	return wantarray ? @result : \@result;
}

1;
