#!/usr/bin/perl
########################################################################
#./step1_PanelFromCapture_CreatePanel.pl
########################################################################
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


#use GenBoRelationWrite;
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
print "step1_PanelFromCapture_CreatePanel.pl: Create Panel & Schemas Validation , Add to Capture\n";
print "except Analyse in exome, genome, rnaseq, chipseq\n";
print "=========================================================================================\n";
my $query = qq{
	select  C.capture_id as captureId,C.name as capName,
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

# A Faire  voir si schema validation déjà créer ne pas le créer ...
#Exome 
#diagnostique

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
#my @res_sorted=sort { $a->{capture_id} <=> $b->{capture_id}} @res;
my @res_sorted=sort { $a->{captureId} <=> $b->{captureId}} @res;
my $nb=0;
my $line=1;
foreach my $u (@res_sorted) {
	next if ($u->{capAnalyse} =~ m/(exome)|(genome)|(rnaseq)|(chipseq)/);
	my @validationList;	
	@validationList = queryPanel::getSchemasValidation($buffer->dbh,"validation_".$u->{capAnalyse});
	my @val_name;
	foreach my $r (@validationList) {
		my %s;
		next unless scalar @$r;
		push(@val_name,values %{$r->[0]}) if values %{$r->[0]} ne "";
	}
	my $res_pC;	
	if(!scalar @val_name && scalar @validationList) {
		print "==========A======> Create Panel: $u->{capAnalyse} Schemas: validation_$u->{capAnalyse} Panel_CaptureId: $u->{captureId}\n";
		f_utils::createValidationDB($buffer,"validation_".$u->{capAnalyse});
		my $name_pan=$u->{capAnalyse};
		my $panelId=f_utils::new_panel($buffer,$name_pan,$u->{capAnalyse});
		if (defined $panelId ) {		
			queryPanel::addPanel2Capture($buffer->dbh,$panelId,$u->{captureId});
			$res_pC=f_utils::searchIn_panelCapture($buffer,$u->{captureId},1);
		}		
		
	}
	$res_pC=f_utils::searchIn_panelCapture($buffer,$u->{captureId},1);
	if (! scalar @$res_pC ) {
		my $capList=queryPanel::getCaptureFromAnalyse($buffer->dbh,$u->{capAnalyse});
		my @capIdList =split(/,/,join ',', keys %{{map{$_->{captureId}=>1}@$capList}});
		my @panelFound;
		my %seenM=();
		foreach my $r (@capIdList) {
			$res_pC=f_utils::searchIn_panelCapture($buffer,$r,1);
			if (scalar @$res_pC && $res_pC->[0]->{panel_id}) {
				push(@panelFound,$res_pC->[0]->{panel_id}) unless $seenM{$res_pC->[0]->{panel_id}}++;
			}			
		}
		if (scalar @panelFound) {
			if (scalar @panelFound==1) {
				print "=========> add Panel_CaptureId: Panel $panelFound[0] Capture $u->{captureId} \n";				
				queryPanel::addPanel2Capture($buffer->dbh,$panelFound[0],$u->{captureId});
			}
		} else {			
				print "=====B====> Create Panel: $u->{capAnalyse}  Panel_CaptureId: $u->{captureId}\n";
				my $name_pan=$u->{capAnalyse};
				my $panelId=f_utils::new_panel($buffer,$name_pan,$u->{capAnalyse});
				if (defined $panelId ) {		
					queryPanel::addPanel2Capture($buffer->dbh,$panelId,$u->{captureId});
				}		
		}
	}
	$res_pC=f_utils::searchIn_panelCapture($buffer,$u->{captureId},1);
	my $res_PanId =join ',', keys %{{map{$_->{panel_id}=>1}@$res_pC}};
	my $panName = queryPanel::getPanel($buffer->dbh,$res_PanId) if $res_PanId ;
	my $pan_Id;
	my $pan_Name;
	$pan_Id=$res_PanId if $res_PanId;
	$pan_Name=$panName->[0]->{panName} if $res_PanId;
	printf("%3d Capture: %3d %35s # Analyse: %20s # Panel %3d %30s\n",$line,$u->{captureId},$u->{capName},
	$u->{capAnalyse},$pan_Id, $pan_Name);
	$nb++;
	$line++;
}
#### End Autocommit dbh ###########
$dbh->commit();
print "Print End Program\n";



exit(0);

