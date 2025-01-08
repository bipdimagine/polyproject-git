#!/usr/bin/perl
########################################################################
###### ./createDB_Panel.pl
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/..";
use lib "$Bin/../GenBo";
use lib "$Bin/../GenBo/lib/GenBoDB";
use lib "$Bin/../GenBo/lib/obj-nodb";
use lib "$Bin/../GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/../GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/../packages"; 
use lib "$Bin/../../../polymorphism-cgi/packages/export";

use util_file qw(readXmlVariations);
use insert;
use Time::Local;

use connect;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
use JSON;
use Carp;
use Getopt::Long;


my $cgi    = new CGI;
my $buffer = GBuffer->new;

print "drop panel\n";
$buffer->dbh->do("DROP TABLE IF EXISTS PolyprojectNGS.panel");
print "drop bundle_panel\n";
$buffer->dbh->do("DROP TABLE IF EXISTS PolyprojectNGS.bundle_panel");
print "drop panel_capture\n";
$buffer->dbh->do("DROP TABLE IF EXISTS PolyprojectNGS.panel_capture");
