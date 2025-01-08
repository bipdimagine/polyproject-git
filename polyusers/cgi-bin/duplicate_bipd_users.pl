#!/usr/bin/perl
########################################################################
###### ./duplicate_bipd_users.pl
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/../../GenBo";
use lib "$Bin/../../GenBo/lib/GenBoDB";
use lib "$Bin/../../GenBo/lib/obj-lite";
use Time::Local;
#use queryPolyproject;
use connect;
use export_data;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
use JSON;
use Carp;
use Getopt::Long;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

# Delete Tables
$buffer->dbh->do("DROP TABLE IF EXISTS bipd_users2.UNITE");
$buffer->dbh->do("DROP TABLE IF EXISTS bipd_users2.EQUIPE");
$buffer->dbh->do("DROP TABLE IF EXISTS bipd_users2.USER");

# Backup table's structures -> Like
$buffer->dbh->do("CREATE TABLE bipd_users2.UNITE like bipd_users.UNITE");
$buffer->dbh->do("CREATE TABLE bipd_users2.EQUIPE like bipd_users.EQUIPE");
$buffer->dbh->do("CREATE TABLE bipd_users2.USER like bipd_users.USER");

#insert
$buffer->dbh->do("INSERT INTO bipd_users2.UNITE SELECT * FROM bipd_users.UNITE");
$buffer->dbh->do("INSERT INTO bipd_users2.EQUIPE SELECT * FROM bipd_users.EQUIPE");
$buffer->dbh->do("INSERT INTO bipd_users2.USER SELECT * FROM bipd_users.USER");

############################################## 

 


