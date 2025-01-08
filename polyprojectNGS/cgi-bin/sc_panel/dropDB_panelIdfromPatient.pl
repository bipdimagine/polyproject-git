#!/usr/bin/perl
########################################################################
###### ./addDB_panelIdToPatient.pl
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
#UPDATE `PolyprojectNGS`.`patient` SET `update_date` = `creation_date`;


my $cgi    = new CGI;
my $buffer = GBuffer->new;



print "Drop column panel_id In patient\n";
$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` DROP COLUMN `panel_id`");

