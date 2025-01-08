#!/usr/bin/perl
########################################################################
#./step3_PanelFromPatient_UpPatient.pl
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

use util_file qw(readXmlVariations);
use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
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
print "=====================================================================\n";
print "step3_PanelFromPatient_UpPatient: update Patient for Panel\n";
print "=====================================================================\n";

my $query = qq{
	select a.patient_id,a.name,a.run_id,a.capture_id,a.panel_id
	from PolyprojectNGS.patient a;
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
my @res_sorted=sort { $a->{run_id} <=> $b->{run_id} ||  $a->{capture_id} <=> $b->{capture_id}} @res;
foreach my $u (@res_sorted) {
	next unless $u->{run_id};
	next unless $u->{capture_id};
	my $res_pC=f_utils::searchIn_panelCapture($buffer,$u->{capture_id},1);
	my $pat_panId=$u->{panel_id};
	if ($pat_panId==0) {
		$pat_panId=$res_pC->[0]->{panel_id};
		queryPanel::upPatientPanel($buffer->dbh, $u->{patient_id}, $pat_panId, $u->{run_id});
		printf("%70s --> Run: %4d # ==> Update Patient %4d with Panel: %4d\n","",,$u->{run_id},$u->{patient_id},$res_pC->[0]->{panel_id}) if $res_pC->[0]->{panel_id};
	}	
	my $res_c=f_utils::searchIn_capture($buffer,$u->{capture_id},1);
	if ($res_c->[0]->{capAnalyse} =~ "target") {
		my (undef,$a_analyse)= split(/:/,$res_c->[0]->{capAnalyse});
		my @validationList;
		if ($a_analyse) {
			@validationList = queryPanel::getSchemasValidation($buffer->dbh,"validation_".$a_analyse);			
		}
		my @val_name;
		foreach my $r (@validationList) {
			my %s;
			next unless scalar @$r;
			push(@val_name,values %{$r->[0]}) if values %{$r->[0]} ne "";
		}
		if(!scalar @val_name && $a_analyse) {
			print "======================> Create schemas Validation: validation_$a_analyse\n";
			f_utils::createValidationDB($buffer,"validation_".$a_analyse);
			@val_name="validation_".$a_analyse;
		} 
		if (! scalar @$res_pC ) {
			my (undef,$a_validation)= split(/validation_/,join("",@val_name));
			if(scalar @val_name && $pat_panId==0 ){
				my $panelId;
				my $panelId=f_utils::new_panel($buffer,$a_validation);
				$pat_panId=$panelId;
				print "===========> Create Panel: $a_validation + Panel_CaptureId: $u->{capture_id} Bundle_Panel:$panelId\n";
				queryPanel::addPanel2Capture($buffer->dbh,$panelId,$u->{capture_id});	
				f_utils::add_bundlepanelWithCapture($buffer,$u->{capture_id},$panelId);		
				queryPanel::upPatientPanel($buffer->dbh, $u->{patient_id}, $panelId, $u->{run_id});
			}		
		}
	}

	printf("Run: %4d # Patient:%15s %4d # Capture:%4d # Panel:%4d\n",$u->{run_id},$u->{name},$u->{patient_id},$u->{capture_id},$pat_panId);			
}
#### End Autocommit dbh ###########
$dbh->commit();

print "Print End Program\n";


=mod
=cut
exit(0);

