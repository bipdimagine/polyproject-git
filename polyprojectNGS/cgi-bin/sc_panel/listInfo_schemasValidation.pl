#!/usr/bin/perl
########################################################################
#./step1_PanelFromCapture_CreatePanel.pl
########################################################################
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


use GenBoRelationWrite;
use util_file qw(readXmlVariations);
use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use queryValidationDB;
use queryPanel;
use f_utils;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

print "=========================================================================================\n";
print "List Schemas Validation\n";
print "=========================================================================================\n";

my $count=1;
my $validationList = queryPolyproject::getSchemasValidation($buffer->dbh);
foreach my $c (@$validationList){
	my %s;
	my $name = $c->{'Database (%validation%)'};
	my $nb_exons = queryPanel::countIn_TablesValidation($buffer->dbh,$name,"exons");
	my $nb_reports = queryPanel::countIn_TablesValidation($buffer->dbh,$name,"reports");
	my $nb_validations = queryPanel::countIn_TablesValidation($buffer->dbh,$name,"validations");
	my $nb_variations = queryPanel::countIn_TablesValidation($buffer->dbh,$name,"variations");
	printf ("%-3d %-60s Exons: %-3d Reports: %-3d Validations: %-3d Variations: %-3d\n",$count,$name,$nb_exons->{'NB'},$nb_reports->{'NB'},$nb_validations->{'NB'},$nb_variations->{'NB'}) ;
	$count ++;
}
print "=========================================================================================\n";
print "End List\n";
print "=========================================================================================\n";



exit(0);

