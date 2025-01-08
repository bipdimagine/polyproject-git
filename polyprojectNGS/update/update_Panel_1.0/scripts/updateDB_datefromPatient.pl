#!/usr/bin/perl
########################################################################
###### ./addDB_panelIdToPatient.pl
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../../..";
use lib "$Bin/../../../../GenBo";
use lib "$Bin/../../../../GenBo/lib/GenBoDB";
use lib "$Bin/../../../../GenBo/lib/obj-nodb";
use lib "$Bin/../../../../GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/../../../../packages"; 
use lib "$Bin/../../../cgi-bin";
use lib "$Bin/../../../../polymorphism-cgi/packages/export";

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

############### creation_date ##########################################
#print "Modified  creation_date  NOT NULL DEFAULT CURRENT_TIMESTAMP In patient\n";
print "Modified  creation_date  TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' In patient\n";
#$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` CHANGE COLUMN `creation_date` `creation_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  ;");
$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` CHANGE COLUMN `creation_date` `creation_date` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00';");

############### update_date ##########################################
print "Duplicate  creation_date to update_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP In patient\n";
$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` ADD COLUMN `update_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `creation_date`");
#$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` ADD COLUMN `update_date` DATETIME NOT NULL  AFTER `creation_date`");
$buffer->dbh->do("UPDATE `PolyprojectNGS`.`patient` SET `update_date` = `creation_date`");
#ALTER TABLE `PolyprojectNGS`.`patient` CHANGE COLUMN `update_date` `update_date` DATETIME NOT NULL  AFTER `project_id_dest` ;
#ALTER TABLE `PolyprojectNGS`.`patient` ADD COLUMN `update_date` DATETIME NOT NULL  AFTER `project_id_dest` ;
