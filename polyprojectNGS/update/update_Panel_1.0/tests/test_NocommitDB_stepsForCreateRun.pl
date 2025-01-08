#!/usr/bin/perl
########################################################################
###### test_NocommitDB_stepsForCreateRun.pl
#./test_NocommitDB_stepsForCreateRun.pl -in=infile_ForCreateRun
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
#use DateTime;
#use DateTime::Duration;
use File::Basename;
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
use Cwd qw(getcwd);

my $in;

GetOptions(
 	'in=s' => \$in,
); 
unless ($in eq "infile_ForCreateRun")
 {
	confess ("Usage :"."\n".
			"$0 -in=infile_ForCreateRun"."\n".
			"\n"
			);
}

my $filename=getcwd."/".$in;
warn Dumper $filename;
open( my $FH, '<', $filename ) or die("Can't read this file: $filename\n");

my $cmdPlt=0;
my $cmdMac=0;
my $cmdMseq=0;
my $cmdMaln=0;
my $cmdMsnp=0;
my $cmdCap=0;
my $cmdPan=0;
my $cmdBun=0;
my $cmdTrans=0;
my $cmdProj=0;
my $cmdRun=0;
my $cmdPat=0;

while ( my $Line = <$FH> ) {
	chop($Line);
	next if ($Line =~ /\*/);
	my @data = split( /:/, $Line );
#	warn Dumper @data;
	print $data[0]."\n";
	if ($data[0] eq "plateform") {
		$cmdPlt=$data[1];
	}	
	if ($data[0] eq "machine") {
		$cmdMac=$data[1];
	}	
	if ($data[0] eq "methseq") {
		$cmdMseq=$data[1];
	}	
	if ($data[0] eq "methaln") {
		$cmdMaln=$data[1];
	}	
	if ($data[0] eq "methsnp") {
		$cmdMsnp=$data[1];
	}	
	if ($data[0] eq "capture") {
		$cmdCap=$data[1];
	}	
	if ($data[0] eq "panel") {
		$cmdPan=$data[1];
	}	
	if ($data[0] eq "bundle") {
		$cmdBun=$data[1];
	}	
	if ($data[0] eq "transcript") {
		$cmdTrans=$data[1];
	}	
	if ($data[0] eq "project") {
		$cmdProj=$data[1];
	}	
	if ($data[0] eq "run") {
		$cmdRun=$data[1];
	}	
	if ($data[0] eq "patient") {
		$cmdPat=$data[1];
	}	
}

use Test::More "no_plan";
my $cgi = new CGI;
my $buffer = GBuffer->new;
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
print "========================================\n";
print "Tests for Creation Run: enter parameters\n";
print "========================================\n";
print "+---------------------------------------\n";

pass("\nControl Parameters");
my ($paramPlt, $pvaluePlt) =ctrlParam($cmdPlt, 'Plateform parameters');
my ($paramMac, $pvalueMac) =ctrlParam($cmdMac, 'Machine parameters');
my ($paramMseq, $pvalueMseq) =ctrlParam($cmdMseq, 'Method Seq parameters');
my ($paramMaln, $pvalueMaln) =ctrlParam($cmdMaln, 'Method ALN parameters');
my ($paramMsnp, $pvalueMsnp) =ctrlParam($cmdMsnp, 'Method SNP parameters');
my ($paramCap, $pvalueCap) =ctrlParam($cmdCap, 'Capture parameters');
my ($paramPan, $pvaluePan) =ctrlParam($cmdPan, 'Panel parameters');
my ($paramBun, $pvalueBun) =ctrlParam($cmdBun, 'Bundle parameters');
my ($paramTrans, $pvalueTrans) =ctrlParam($cmdTrans, 'Transcript parameters');
my ($paramProj, $pvalueProj) =ctrlParam($cmdProj, 'Project parameters');
my ($paramRun, $pvalueRun) =ctrlParam($cmdRun, 'Run parameters');
my ($paramPat, $pvaluePat) =ctrlParam($cmdPat, 'Patient parameters');
pass("\nEnd Control Parameters");


my $r_plateformid=test_createPlateform($dbh,$paramPlt,$pvaluePlt, 'Test Creation Plateform');
my $r_machineid=test_createMachine($dbh,$paramMac,$pvalueMac, 'Test Creation Machine');
my $r_methseqid=test_createMethSeq($dbh,$paramMseq,$pvalueMseq, 'Test Creation Method Seq');
my $r_methalnid=test_createMethAln($dbh,$paramMaln, $pvalueMaln, 'Test Creation Method Aln');
my $r_methsnpid=test_createMethSnp($dbh,$paramMsnp, $pvalueMsnp, 'Test Creation Method Snp');
my ($r_captureid,$r_analyse)=test_createCapture($dbh,$paramCap, $pvalueCap, 'Test Creation Capture');

my $r_panelid;
my $r_bundleid;
my $r_bundlename;
my $r_transid;

if(length($paramPan)){
	$r_panelid=test_createPanel($dbh,$paramPan, $pvaluePan,$r_captureid, 'Test Creation Panel');
	($r_bundleid,$r_bundlename)=test_createBundle($dbh,$paramBun, $pvalueBun,$r_captureid,$r_panelid, 'Test Creation Bundle');
	$r_transid=test_createTranscript($dbh,$paramTrans, $pvalueTrans,$r_bundleid,$r_bundlename, 'Test Creation Transcript');

} elsif ($r_analyse eq "target") {
 	$r_panelid=test_createPanel($dbh,$paramPan, $pvaluePan,$r_captureid, 'Test Creation Panel');	
	($r_bundleid,$r_bundlename)=test_createBundle($dbh,$paramBun, $pvalueBun,$r_captureid,$r_panelid, 'Test Creation Bundle');
	$r_transid=test_createTranscript($dbh,$paramTrans, $pvalueTrans,$r_bundleid, 'Test Creation Transcript');
}
#test_createBundlePanel($dbh,$r_bundleid,$r_bundlename,$r_panelid);
my ($r_projectid,$r_projectname)=test_createProject($dbh,$paramProj, $pvalueProj, 'Test Creation Project');
my ($r_runid,$r_run_nbpat)=test_createRun($dbh,$paramRun,$pvalueRun,$r_plateformid,$r_machineid,$r_methseqid,'Test Creation Run');
test_createPatient($dbh,$paramPat,$pvaluePat,$r_run_nbpat,$r_runid,$r_projectid,$r_projectname,$r_captureid,$r_panelid,$r_methalnid,$r_methsnpid, 'Test Creation Patient');

=mod
if(length($paramPan)){
	warn "AQQQQQQQQQQQqqqqq";
	$r_panelid=test_createPanel($dbh,$paramPan, $pvaluePan,$r_captureid, 'Test Creation Panel');
} else {
	warn "BQQQQQQQQQQQqqqqq";
 	if($r_analyse eq "target"){
 		warn "CQQQQQQQQQQQqqqqq";
 		$r_panelid=test_createPanel($dbh,$paramPan, $pvaluePan,$r_captureid, 'Test Creation Panel');	
 	}
}
=cut

sub test_createPlateform {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my $plateform;
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "plateform") {
			$plateform=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 1, "\n".$test_name.": 1 parameter");
	ok(scalar @ipvalue eq 1, $test_name.': 1 value');
	my $plateform_inf = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	ok(!exists $plateform_inf->{id},'Not existing Plateform') or done_testing,exit;
	my $myplateformid = queryPolyproject::newPlateformData($buffer->dbh,$plateform);
	my $plateform_inf = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	ok($plateform_inf ->{name},"Plateform created:".$plateform.' '.$plateform_inf ->{id}) or done_testing,exit;
	return ($plateform_inf ->{id});
}

sub test_createMachine {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my $machine;
	my $type;
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "machine") {
			$machine=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "type") {
			$type=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 2, "\n".$test_name.': 2 parameters');
	ok(scalar @ipvalue eq 2, $test_name.': 2 values');
	my $machineid = queryPolyproject::getMachineFromName($buffer->dbh,$machine);
	ok(!exists $machineid->{machineId},'Not Existing Machine') or done_testing,exit;
	my $mymachineid = queryPolyproject::newMachineData($buffer->dbh,$machine,$type);
	my $machine_inf = queryPolyproject::getMachineFromName($buffer->dbh,$machine);	
	ok($machine_inf->{macName},"Sequencing Machine created: ".$machine.' '.$machine_inf->{machineId}) or done_testing,exit;
	return ($machine_inf->{machineId});
}

sub test_createMethSeq {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my $methseq;
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "methseq") {
			$methseq=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 1, "\n".$test_name.': 1 parameter');
	ok(scalar @ipvalue eq 1, $test_name.': 1 value');
	my $methseq_inf = queryPolyproject::getMethSeqFromName($buffer->dbh,$methseq);
	ok(!exists $methseq_inf ->{methodSeqId},'Not Existing Method Seq') or done_testing,exit;
	my $mymethodseqid = queryPolyproject::newMethSeqData($buffer->dbh,$methseq);
	my $methseq_inf = queryPolyproject::getMethSeqFromName($buffer->dbh,$methseq);
	ok($methseq_inf->{methSeqName},"Method Seq Created: ".$methseq.' '.$methseq_inf->{methodSeqId}) or done_testing,exit;
	return ($methseq_inf->{methodSeqId});
}

sub test_createMethAln {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my $methaln;
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "methaln") {
			$methaln=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 1, "\n".$test_name.': 1 parameter');
	ok(scalar @ipvalue eq 1, $test_name.': 1 value');
	my $methaln_inf = queryPolyproject::getMethodFromName($buffer->dbh,$methaln);
	ok(!exists $methaln_inf->{methodId},'Not Existing Method Aln') or done_testing,exit;
	my $type='ALIGN';
	my $mymethalnid = queryPolyproject::newMethodData($buffer->dbh,$methaln,$type);
	my $methaln_inf = queryPolyproject::getMethodFromName($buffer->dbh,$methaln);
	ok($methaln_inf->{methName},"Method Aln Created: ".$methaln.' '.$methaln_inf ->{methodId}) or done_testing,exit;
	return ($methaln_inf ->{methodId});
}

sub test_createMethSnp {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my $methsnp;
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "methsnp") {
			$methsnp=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 1, "\n".$test_name.': 1 parameter');
	ok(scalar @ipvalue eq 1, $test_name.': 1 value');
	my $methsnp_inf = queryPolyproject::getMethodFromName($buffer->dbh,$methsnp);
	ok(!exists $methsnp_inf->{methodId},'Not Existing Method Snp') or done_testing,exit;
	my $type='SNP';
	my $mymethsnpid = queryPolyproject::newMethodData($buffer->dbh,$methsnp,$type);
	my $methsnp_inf = queryPolyproject::getMethodFromName($buffer->dbh,$methsnp);
	ok($methsnp_inf->{methName},"Method Snp Created: ".$methsnp.' '.$methsnp_inf ->{methodId}) or done_testing,exit;
	return ($methsnp_inf ->{methodId});
}

sub test_createCapture {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($capture,$capVs,$capDes,$capType,$capMeth,$golden_path,$capAnalyse,$capFile,$capFilePrimers);	
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "capture") {
			$capture=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "capVs") {
			$capVs=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "capDes") {
			$capDes=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "capType") {
			$capType=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "capMeth") {
			$capMeth=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "golden_path") {
			$golden_path=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "capAnalyse") {
			$capAnalyse=$ipvalue[$i];			
		}
	}

	ok(scalar @iparam eq 7, "\n".$test_name.': 7 parameters');
	ok(scalar @ipvalue eq 7, $test_name.': 7 values');
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
	ok($releaseid,'Existing release in Capture') or done_testing,exit;
	my $capture_inf = queryPanel::getCaptureFromName($buffer->dbh,$capture);
	ok(!exists $capture_inf->{captureId},'Not Existing Capture') or done_testing,exit;
	my $last_captureid = queryPanel::newCaptureData($buffer->dbh,$capture,$capVs,$capDes,$capFile,$capFilePrimers,$capType,$capMeth,$releaseid,$capAnalyse);
	my $capture_inf = queryPanel::getCaptureFromName($buffer->dbh,$capture);
	ok($capture_inf->{capName},$test_name.': '.$capture.' '.$capture_inf->{captureId}.' Analyse: '.$capture_inf->{capAnalyse}) or done_testing,exit;
# a faire :
	if ($capture_inf->{capAnalyse} =~ m/(exome)|(genome)/) {
			my $CapPan = queryPanel::getPanelsfromCapture($buffer->dbh);
			my %seenP;
			my %seenB;
			
			foreach my $c (sort {$a->{panId} <=> $b->{panId}}@$CapPan){
				next if exists $seenP{$c->{panId}};
				$seenP{$c->{panId}}++;
				queryPanel::addPanel2Capture($buffer->dbh,$c->{panId},$capture_inf->{captureId});
			}
			my $nb_panels = keys(%seenP);
			ok($nb_panels, $test_name.' for Exome or Genome: '.$nb_panels." panels are added to the Capture");
		
	}
	
	return ($capture_inf->{captureId},$capture_inf->{capAnalyse});
}
=mod
		if ($capAnalyse =~ m/(exome)|(genome)/) { 
			my $CapPan = queryPanel::getPanelsfromCapture($buffer->dbh);
			my %seenP;
			my %seenB;
			
			foreach my $c (sort {$a->{panId} <=> $b->{panId}}@$CapPan){
				next if exists $seenP{$c->{panId}};
				$seenP{$c->{panId}}++;
				queryPanel::addPanel2Capture($buffer->dbh,$c->{panId},$new_capid);
			}
			my $nb_panels = keys(%seenP);
			$message_AllPans="<br><b>For Exome or Genome Analysis</b>, All Panels <b>($nb_panels)</b> are added to this Exons Capture";
		}				
=cut	

sub test_createPanel {
	my ($dbh,$param,$pvalue,$captureid,$test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($name,$validation);	
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "name") {
			$name=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "validation") {
			$validation=$ipvalue[$i];			
		}
	}
	my $info_cap = queryPanel::getCaptureIdSingle($buffer->dbh,$captureid);
	my $pan=1;
	$pan=0 if $info_cap->{capAnalyse} ne "target";
	$pan=1 if scalar @iparam;
	ok(scalar @iparam eq 2, "\n".$test_name.': 2 parameters') if ($pan);
	ok(scalar @ipvalue eq 2, $test_name.': 2 values') if ($pan);
	my $panel_inf;
	if ($pan) {
		$panel_inf=queryPanel::getPanelIdFromName($buffer->dbh,$name);
		ok(!exists $panel_inf->{panel_id},'Panel not exist') or done_testing,exit;
   		my $last_panelid = queryPanel::newPanel($buffer->dbh,$name,$validation);
		$panel_inf = queryPanel::getPanelIdFromName($buffer->dbh,$name);
		ok($panel_inf->{panName},$test_name.': '.$name .' '.$panel_inf->{panel_id}) or done_testing,exit;
		queryPanel::addPanel2Capture($buffer->dbh,$panel_inf->{panel_id},$captureid);
		queryPolyproject::upCaptureValidation($buffer->dbh,$captureid,$validation);
		my $CapPan = queryPanel::getPanelsfromCapture($buffer->dbh,$captureid,$panel_inf->{panel_id});
		$test_name.=" with Capture";
		ok($CapPan->[0]->{capName},$test_name.': '.$CapPan->[0]->{panName}.' '.$CapPan->[0]->{capName}) or done_testing,exit;
		my $mode="add";
		addremPanel_forFilteringAnalyseCapture($buffer,$panel_inf->{panel_id},$mode);
		my $res_pC=f_utils::searchIn_panelCapture($buffer,$panel_inf->{panel_id},0);
		ok(scalar @$res_pC,$test_name.': '.scalar @$res_pC.' Exons Capture (Exome,Genome) contains this Panels') or done_testing,exit;
#A faire :create Bundle & and Transcript		
	} else {
		ok($info_cap->{capAnalyse} ne "target" ,$test_name.': not created , empty parameters for Analyse NOT Target');
	};
	return ($panel_inf->{panel_id}) if ($pan);
	return (0) unless ($pan);
}
sub test_createBundle {
	my ($dbh,$param,$pvalue,$captureid,$panelid,$test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($bundle,$bunVs,$bunDes);	
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "bundle") {
			$bundle=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "bunVs") {
			$bunVs=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "bunDes") {
			$bunDes=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 3, "\n".$test_name.': 3 parameters');
	ok(scalar @ipvalue eq 3, $test_name.': 3 values');
	my $bundle_inf = queryPolyproject::getBundleFromName($buffer->dbh,$bundle);
	ok(!exists $bundle_inf->{bundleId},'Bundle not exist') or done_testing,exit;
	my $last_bundleid = queryPolyproject::newBundle($buffer->dbh,$bundle,$bunVs,$bunDes);
	$bundle_inf = queryPolyproject::getBundleFromName($buffer->dbh,$bundle);
	ok($bundle_inf->{bunName},$test_name.': '.$bundle_inf->{bunName}.' '.$bundle_inf->{bundleId}) or done_testing,exit;
	queryPanel::addBundlePanel($buffer->dbh,$bundle_inf->{bundleId}, $panelid);
	my $resBP=queryPanel::getBundlePanel($buffer->dbh,$bundle_inf->{bundleId},$panelid);
	my $panel_inf = queryPanel::getPanel($buffer->dbh,$panelid);
	ok($resBP->{bundle_id},$test_name.': '.$bundle_inf->{bunName}.' added to Panel '.$panel_inf->[0]->{panName}.' '.$panelid) or done_testing,exit;
	return ($bundle_inf->{bundleId},$bundle_inf->{bunName});
}
sub test_createTranscript {
	my ($dbh,$param,$pvalue,$bundleid,$bundlename,$test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($transcript,$transmission,$tmod,$btmod);	
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "transcript") {
			$transcript=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "transmission") {
			$transmission=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "tmod") {
			$tmod=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "btmod") {
			$btmod=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 4,"\n".$test_name.': 4 parameters');
	ok(scalar @ipvalue eq 4, $test_name.': 4 values');
	my $transcriptid = queryPolyproject::getTranscriptId($buffer->dbh,$transcript);
	ok(!$transcriptid,'Transcript not exist') or done_testing,exit;
	
	my $transcript_id=queryPolyproject::newTranscriptData($buffer->dbh,$transcript,$transmission,$tmod);
	$transcriptid = queryPolyproject::getTranscriptId($buffer->dbh,$transcript);
	my $trans_inf = queryPolyproject::getTranscript($buffer->dbh,$transcriptid);
	ok($transcriptid,$test_name.': '.$transcript.' '.$transcriptid.' with transmission: '.$trans_inf->[0]->{transmission}) or done_testing,exit;
	queryPolyproject::newBundleTranscript($buffer->dbh,$transcriptid,$bundleid,$transmission,$btmod);
	my $Btr=queryPolyproject::getBundleTranscriptId($buffer->dbh,$bundleid,$transcriptid);
	$Btr=$Btr->[0];
	ok($Btr->{transcript_id},$test_name.' added to Bundle: Bundle '.$bundlename.' '.$bundleid. ' Transcript '. $transcript.' '.$Btr->{transcript_id}.' Transmission: '.$Btr->{transmission}) or done_testing,exit;
}

sub test_createProject {
	my ($dbh,$param,$pvalue, $test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($golden_path,$description);
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "golden_path") {
			$golden_path=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "description") {
			$description=$ipvalue[$i];			
		}
	}
	ok(scalar @iparam eq 2, "\n".$test_name.': 2 parameters');
	ok(scalar @ipvalue eq 2, $test_name.': 2 values');
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
	ok($releaseid,'Existing release in Projet') or done_testing,exit;

	my $database="Polyexome";
	my $type={"id"=>3};
	my $prefix= "NGS";
	my $query = qq{CALL PolyprojectNGS.new_project("$prefix",$type->{id},"$description");};
	my $sth = $buffer->dbh()->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	my $pid = $res->[0]->{project_id};
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$pid);
	my $project = $buffer->newProject(-name=>$projectname);
	ok($projectname,$test_name.': '.$projectname.' '.$pid) or done_testing,exit;
	return ($pid,$projectname);
}

sub test_createRun {
	my ($dbh,$param,$pvalue,$plateformid,$machineid,$methseqid,$test_name) = @_;	
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($name,$description,$pltname,$nbpat);
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "name") {
			$name=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "description") {
			$description=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "pltname") {
			$pltname=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "nbpat") {
			$nbpat=$ipvalue[$i];			
		}
	}

	ok(scalar @iparam eq 4, "\n".$test_name.': 4 parameters');
	ok(scalar @ipvalue eq 4, $test_name.': 4 values');
	my $type = "ngs";
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	
	my $last_run_id=queryPanel::newRun($buffer->dbh,$rtype->{id},$description,$name,$pltname,$nbpat);
	my $runid=$last_run_id->{'LAST_INSERT_ID()'};
	my $run_inf = queryPanel::getRunDataInfo($buffer->dbh,$runid);
	
	ok($run_inf->{run_id},$test_name.': '.$run_inf->{run_id}) or done_testing,exit;
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid,$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$machineid,$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$methseqid,$runid);
	return ($run_inf->{run_id},$run_inf->{nbpatient});
}

sub test_createPatient {
	my ($dbh,$param,$pvalue,$nbpat,$runid,$projectid,$projectname,$captureid,$panelid,$methaln,$methsnp,$test_name) = @_;
	my @iparam = split(/ /,$param);
	my @ipvalue = split(/ /,$pvalue);
	my ($patient,$family,$father,$mother,$sex,$status,$fc,$bc);
	for (my $i = 0; $i< scalar(@iparam); $i++) {
		if ($iparam[$i] eq "patient") {
			$patient=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "family") {
			$family=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "father") {
			$father=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "mother") {
			$mother=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "sex") {
			$sex=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "status") {
			$status=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "fc") {
			$fc=$ipvalue[$i];			
		}
		if ($iparam[$i] eq "bc") {
			$bc=$ipvalue[$i];			
		}
	}

	ok(scalar @iparam eq 8, "\n".$test_name.': 8 parameters');
	ok(scalar @ipvalue eq 8, $test_name.': 8 values');

	my @pat=split(/,/,blk($patient));
	ok($nbpat ==  scalar(@pat), $test_name.': Number of Patients:'.$nbpat);
		
	my @fam=split(/,/,blk($family));
	my @lfathers=split(/,/,blk($father));
	my @lmothers=split(/,/,blk($mother));
	my @lsexs=split(/,/,blk($sex));
	my @lstatuss=split(/,/,blk($status));
	my @bcs=split(/,/,blk($bc));
	my $i;
	my $List_patid="";
	for my $p (@pat) {
		my $j;
		for my $f (@fam) {
			if ($i==$j) {
				my $patid=queryPolyproject::ctrlProjectPatientName($buffer->dbh,$projectid,$p);
				ok(!$patid,$test_name.': '.$p.' Not Existing in Project Id: '.$projectid) or done_testing,exit;

				my $last_patient_id=queryPanel::newPatientRun($buffer->dbh,$p,$p,$runid,$captureid,$panelid,$f,$fc,@bcs[$i],@lfathers[$i],@lmothers[$i],@lsexs[$i],@lstatuss[$i]);
				my $patient_inf=queryPanel::getPatientFromName($buffer->dbh,$p,$runid);
				ok($patient_inf->{patient_id},$test_name.': Patient Created '.$patient_inf->{name}.' '. $patient_inf->{patient_id}
				.' family: '.$patient_inf->{family}.' father: '.$patient_inf->{father}.' mother: '.$patient_inf->{mother}
				.' sex: '.$patient_inf->{sex}.' status: '.$patient_inf->{status}
				.' bc: '.$patient_inf->{bar_code}.' flowcell: '.$patient_inf->{flowcell}) or done_testing,exit;
				queryPolyproject::upPatientProject($buffer->dbh,$patient_inf->{patient_id},$projectid);
				my $patientproj_inf=queryPanel::getPatientFromName($buffer->dbh,$p,$runid,$projectid);
				ok($patientproj_inf->{project_id},$test_name.': Patient '.$patient_inf->{name}.' added to Project '. $projectname.' '.$patientproj_inf->{project_id}) or done_testing,exit;

				queryPolyproject::addMeth2pat($buffer->dbh,$patient_inf->{patient_id},$methaln);
				my $pataln_inf = queryPolyproject::getnewAlnMethodName($buffer->dbh,$runid,$projectid,$patient_inf->{patient_id});
				ok($pataln_inf->[0]->{methAln},$test_name.': Patient '.$patient_inf->{name}.' added to Method Aln '.$pataln_inf->[0]->{methAln}) or done_testing,exit;
					
				queryPolyproject::addMeth2pat($buffer->dbh,$patient_inf->{patient_id},$methsnp);
				my $patsnp_inf = queryPolyproject::getnewCallMethodName($buffer->dbh,$runid,$projectid,$patient_inf->{patient_id});
				ok($patsnp_inf->[0]->{methCall},$test_name.': Patient '.$patient_inf->{name}.' added to Method Call '.$pataln_inf->[0]->{methCall}) or done_testing,exit;
			}
			$j++;
		}
		$i++;
	}
	my $runListId = queryPanel::getPatientsInfoFromRun($buffer->dbh,$runid,$projectid);
	my $info_run = queryPanel::getRunInfo($buffer->dbh,$runid);
	my $end=$info_run->[0];
	ok($end->{run_id},"Run Summary:".
	"\nRun ".$end->{run_id}." Name: ".$end->{name}." PltName: ".$end->{pltRun}." Description: ".$end->{description}." Date: ".$end->{cDate}.
	"\nPlateform: ".$end->{plateformName}.
	"\nSequencing Machine: ".$end->{macName}.
	"\nSequencing Method: ".$end->{methSeqName}.
	"\nAlignment & Calling Method: ".$end->{methAln}." ".$end->{methCall}.
	"\nCapture: ".$end->{capName}." ".$end->{capId}." Analyse:".$end->{capAnalyse}.
	"\nPanel: ".$end->{panName}.
	"\nProject: ".$end->{ProjectName}." ".$end->{ProjectId}.
	"\nPatient: ".$end->{patName}." nb: ".$end->{nbpatRun}
	) or done_testing,exit;
}

=mod

=cut

#########################################################################
sub addremPanel_forFilteringAnalyseCapture {
	my ($buffer,$panelId,$mode) = @_;
	my $captureList= queryPolyproject::getCaptureId($buffer->dbh);
#	warn Dumper $captureList;
	foreach my $c (@$captureList){
		next unless ($c->{capAnalyse} =~ m/(exome)|(genome)/);
		if ($mode eq "add") {
				my $resPC=queryPanel::getPanelCapture($buffer->dbh,$panelId,$c->{captureId});
				queryPanel::addPanel2Capture($buffer->dbh,$panelId,$c->{captureId}) unless $resPC->{capture_id};				
		} elsif ($mode eq "rem") {
			queryPanel::removePanel2Capture($buffer->dbh,$panelId,$c->{captureId});				
		}
	}
}

sub ctrlParam {
	my ($cmd, $test_name) = @_;
	my @param;
	my @pvalue;
	my @inline = split(/ /,$cmd);
	ok(scalar @inline, $test_name.': no empty inline');
	foreach my $a (@inline) {
		next unless $a;
		my @opt = split(/=/,$a);
		$opt[0]=~ s/^-+//;
		push(@param,$opt[0]);
		push(@pvalue,$opt[1]);
	}
	ok(scalar @param, $test_name.': no empty parameters');
	ok(scalar @pvalue, $test_name.': no empty value parameters');
	return (join(' ',@param),join(' ',@pvalue));
}

sub blk{
	my ($field) = @_;
	$field=~ s/ //g;
#	$field=~ s/\n//g;
	return $field;
}
