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


print "Create panel\n";

$buffer->dbh->do("CREATE  TABLE `PolyprojectNGS`.`panel` (
  `panel_id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `validation_db` VARCHAR(45) NOT NULL ,
  `creation_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP , 
#  `updated_date` TIMESTAMP NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`panel_id`) ,
  INDEX `index2` (`panel_id` ASC, `name` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1");

print "Create bundle_panel\n";
$buffer->dbh->do("CREATE  TABLE `PolyprojectNGS`.`bundle_panel` (
  `bundle_id` INT(11) NOT NULL ,
  `panel_id` INT(11) NOT NULL ,
  PRIMARY KEY (`bundle_id`, `panel_id`) ,
  INDEX `fk_bundle_panel_1` (`bundle_id` ASC) ,
  INDEX `fk_bundle_panel_2` (`panel_id` ASC) ,
  CONSTRAINT `fk_bundle_panel_1`
    FOREIGN KEY (`bundle_id` )
    REFERENCES `PolyprojectNGS`.`bundle` (`bundle_id` )
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_bundle_panel_2`
    FOREIGN KEY (`panel_id` )
    REFERENCES `PolyprojectNGS`.`panel` (`panel_id` )
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1");

print "Create panel_capture\n";
$buffer->dbh->do("CREATE  TABLE `PolyprojectNGS`.`panel_capture` (
  `panel_id` INT(11) NOT NULL ,
  `capture_id` INT(11) NOT NULL ,
  PRIMARY KEY (`panel_id`, `capture_id`) ,
  INDEX `fk_panel_capture_1` (`panel_id` ASC) ,
  INDEX `fk_panel_capture_2` (`capture_id` ASC) ,
  CONSTRAINT `fk_panel_capture_1`
    FOREIGN KEY (`panel_id` )
    REFERENCES `PolyprojectNGS`.`panel` (`panel_id` )
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_panel_capture_2`
    FOREIGN KEY (`capture_id` )
    REFERENCES `PolyprojectNGS`.`capture_systems` (`capture_id` )
    ON DELETE CASCADE
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1");

=mod
#print "Drop column panel_id to patient\n";
#$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` DROP COLUMN `panel_id`");
print "Add column panel_id to patient\n";
$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` ADD COLUMN `panel_id` INT(11) NULL DEFAULT '0'  AFTER `capture_id`");
=cut