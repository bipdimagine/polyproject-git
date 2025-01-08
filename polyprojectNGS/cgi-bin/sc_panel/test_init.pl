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
#use warnings;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

print "=========================================================================================\n";
print "Test Capture & Validation\n";
print "=========================================================================================\n";
my $query = qq{
	select  C.capture_id as captureId,C.name as capName,
	C.validation_db as capValidation,
	C.version as capVs, C.description as capDes,	
	C.filename as capFile, C.type as capType,
	C.analyse as capAnalyse,
	C.method as capMeth,
	C.primers_filename as capFilePrimers
	from PolyprojectNGS.capture_systems C
	;
};

my @res;
my $sth = $buffer->dbh->prepare($query) || die();
$sth->execute();
while (my $id = $sth->fetchrow_hashref ) {
	push(@res,$id);
}


### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
#my @res_sorted=sort { $a->{capture_id} <=> $b->{capture_id}} @res;
my @res_sorted=sort { $a->{captureId} <=> $b->{captureId}} @res;
my $nb=0;
my $line=1;
foreach my $u (@res_sorted) {
	my @validationList;	
	@validationList = queryPanel::getSchemasValidation($buffer->dbh,"validation_".$u->{capValidation});
	my @val_name;
	foreach my $r (@validationList) {
		my %s;
		next unless scalar @$r;
		push(@val_name,values %{$r->[0]}) if values %{$r->[0]} ne "";
	}
	print "Capture $u->{captureId} $u->{capName} // Analyse:$u->{capAnalyse} // Validation: @val_name\n";
}
#### End Autocommit dbh ###########
$dbh->commit();
print "Print End Program\n";



exit(0);

