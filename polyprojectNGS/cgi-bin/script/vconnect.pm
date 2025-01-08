package vconnect;

use strict;
use FindBin qw($Bin);
use lib "$Bin/";
use DBI;
use DBD::mysql;
use Data::Dumper;
use Carp;
use FindBin qw($Bin);



sub getdbh{
	my $config = shift;
	my $ip = $config->{polyprod}->{ip};
	my $db_user_name = $config->{polyprod}->{user};
	my $db_password = $config->{polyprod}->{pw};
	my $dsn = "DBI:mysql::$ip\n";
	my $dbh = DBI->connect($dsn, $db_user_name, $db_password)|| die "Database connection not made: $DBI::errstr";
	return $dbh;
}  


1;
