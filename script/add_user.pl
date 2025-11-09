#!/usr/bin/perl

use strict;
use 5.022;

BEGIN {use FindBin qw($Bin); require "$Bin/_init.pl"};

use Opiate::DB;
use Opiate::Magic;

my $db = new Opiate::DB;

print "Enter username: ";
my $name = <>; chomp $name;
die unless $name;

print "Enter email: ";
my $email = <>; chomp $email;
die unless $email;

print "Enter password: ";
my $password = <>; chomp $password;
die unless $password;

my $salt;

my $password_crypted = Opiate::Magic->crypt_password($password);

$db->do(q[INSERT INTO users (name, email, password) VALUES (?, ?, ?)], $name, $email, $password_crypted);

1;
