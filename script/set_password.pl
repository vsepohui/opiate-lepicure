#!/usr/bin/perl

use strict;
use 5.022;
use utf8;

BEGIN {use FindBin qw($Bin); require "$Bin/_init.pl"};

use Opiate::Model::User;
use Opiate::Magic;

my $db = new Opiate::DB;

print "Enter alias: ";
my $alias = <>; chomp $alias;
die unless $alias;

print "Enter password: ";
my $password = <>; chomp $password;
die unless $password;


my $user = new Opiate::Model::User;
$user->get(alias => $alias);
$user->set(password => $password);

1;
