#!/usr/bin/perl
#############################################################################
# new_polyproject.pl ##from GenBo/script/ngs_exome/last_script/new_project.pl
#############################################################################
#./new_polyproject.pl opt=newPoly golden_path=HG19  description=qsSQ disease=4 database=Polyexome
#./new_polyproject.pl opt=newRun plateform=INTEGRAGEN machine=SOLEXA method_align=crossmatch method_call=ensembl mseq=mate-paired type=ngs capture=agilent_v50 patient=d1,d2
#./new_polyproject.pl opt=addProjPat project= patient=
#./new_polyproject.pl opt=newPat project= run= capture= patient=

use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use Carp;
use strict;
use Set::IntSpan::Fast::XS ;
use Data::Dumper;
use GBuffer;
use Getopt::Long;
#use GenBoWrite;
use GenBoWriteNgs;
use GenBoQuery;
use GenBoQueryNgs;
use GenBoTrace;
use GenBoRelationWrite;
use GenBoProjectWriteNgs;
use util_file qw(readXmlVariations);
use insert;

use CGI;
use connect;
use JSON::XS;
use queryPolyproject;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;

#paramètre passés au cgi
my $opt = $cgi->param('opt');

#print $cgi->header();
if ( $opt eq "newPoly" ) {
	ProjectSection();
} elsif ( $opt eq "newRun" ) {
	RunSection();
} elsif ( $opt eq "addProjPat" ) {
	ProjectPatientSection();
} elsif ( $opt eq "newPat" ) {
	PatSection();
}

###### Add Project  ###################################################################
sub ProjectSection {
	my $project_name;
#my $project_type = $cgi->param('type');
# All projects are ngs: type=3
	my $golden_path = $cgi->param('golden_path');
	my $description = $cgi->param('description');
	my $groupdisease_id = $cgi->param('disease');
	my $database = $cgi->param('database');

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################

#warn $ENV{'LOGNAME'};
	my $username = $ENV{'LOGNAME'};

	my %config;
	$config{type_db} = $database;

	my $dbid = GenBoProjectQueryNgs::getDbId($buffer->dbh,$config{type_db});
	die("$database unknown") unless $dbid;
	sendError( "undefined database " . $dbid ) unless ($dbid);
	my $releaseid = GenBoProjectQueryNgs::getReleaseId($buffer->dbh,$golden_path);
	die("release $golden_path  unknown") unless $releaseid;
	sendError( "undefined release " . $releaseid) unless ($releaseid);
# No project_type but run_type and all run_type=3 for ngs
	my $type={"id"=>3};
=pod
=cut
	my $validDisease="";
	if ($groupdisease_id) {
		my @ListDisease = split(/,/,$groupdisease_id);
		foreach my $u (@ListDisease) {
			my $resId = queryPolyproject::ctrlDiseaseId($buffer->dbh, $u);
			$validDisease.=$resId->{diseaseId}."," if ($resId);
		}
		chop($validDisease);
		sendError("Disease number: " . $groupdisease_id . " not in Disease DB: ") unless $validDisease;
	}
#warn "validDisease :$validDisease\n";

	my $prefix;
	if($database eq "polydev"){
		$prefix= "DEV";
	}
	elsif($database eq "Polyexome"){
		$prefix = "NGS";
#	$prefix = "TES";
	}
	elsif($database eq "Polyrock"){
		$prefix = "ROCK";
#	$prefix = "TES";
	}
	else {
		sendError("No project created for database Polyprod");
		die;
	}
#call => renvoit id et nom
	my $query = qq{CALL PolyprojectNGS.new_project("$prefix",$type->{id},"$description");};
	my $sth = $buffer->dbh()->prepare( $query );
	$sth->execute();

	my $res = $sth->fetchall_arrayref({});
	sendError("No project created") if ( scalar(@$res) == 0 );

	my $pid = $res->[0]->{project_id};
	sendError("No project created") unless ($pid);

=pod
=cut
#GenBoProjectWriteNgs::addMethods($buffer->dbh,$pid,$method_align->{id});
#GenBoProjectWriteNgs::addMethods($buffer->dbh,$pid,$method_call->{id});
	if ($groupdisease_id) {
		my @listDisease = split(/,/,$validDisease);
		foreach my $u (@listDisease) {
			my $diseaseid = queryPolyproject::addDisease2project($buffer->dbh, $u, $pid);
		}
	}
	GenBoProjectWriteNgs::addDb($buffer->dbh,$pid,$dbid);
	GenBoProjectWriteNgs::addRelease($buffer->dbh,$pid,$releaseid);

### End Autocommit dbh ###########
	$dbh->commit();

	my $typeId=$type->{id};
	my $name = $res->[0]->{name};
	$ENV{'DATABASE'} = "";
	my $buffer = GBuffer->new();
	my $projectG = $buffer->newProject(-name=>$name);
	#TODO: decommenté"
	$projectG->makePath();
# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
	my $dbh = $buffer->dbh;
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
	#TODO: decommenté"
	my $query1 =qq{INSERT INTO $database.ORIGIN(NAME,TYPE_ORIGIN_ID,DESCRIPTION) values ("$name",$typeId,"$description");};
	$dbh->do($query1) ;
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for project name: " . $name);	
} # End of project section



###### Add Run   ###################################################################
sub RunSection {
#	my $projectId=$cgi->param('project');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $method_seq = $cgi->param('mseq');
	my $type = $cgi->param('type');
	my $capture = $cgi->param('capture');
	my $patients = $cgi->param('patient');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
	
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
#warn $ENV{'LOGNAME'};
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = GenBoQueryNgs::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);	
	my $captureId = GenBoProjectQueryNgs::getCaptureId($buffer->dbh,$capture);
	sendError( "undefined capture " . $capture ) unless ($captureId);

	my $validAln="";
	if ($group_method_align_name) {
		my @ListAln = split(/,/,$group_method_align_name);
		foreach my $u (@ListAln) {
			my $method_align = GenBoProjectQueryNgs::getMethodsFromName($buffer->dbh,$u,"ALIGN");
			$validAln.=$method_align->{id}."," if ($method_align);
		}
		chop($validAln);
		sendError("undefined method_align: " . $group_method_align_name ) unless $validAln;	
	}

	my $validMeth="";
	if ($group_method_calling_name) {
		my @ListMeth = split(/,/,$group_method_calling_name);
		foreach my $u (@ListMeth) {
			my $method_call = GenBoProjectQueryNgs::getMethodsFromName($buffer->dbh,$u,"SNP");
			$validMeth.=$method_call->{id}."," if ($method_call);
		}
		chop($validMeth);
		sendError("undefined method_call: " . $group_method_calling_name ) unless $validMeth;	
	}
# create runid
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id});
	my $runid=$last_run_id->{'LAST_INSERT_ID()'};

# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
	
# 	
	if ($group_method_align_name) {
		my @ListAln = split(/,/,$validAln);	
		foreach my $u (@ListAln) {
			GenBoProjectWriteNgs::addMethods($buffer->dbh,$runid,$u);
		}	
	}
	if ($group_method_calling_name) {
		my @ListMeth = split(/,/,$validMeth);	
		foreach my $u (@ListMeth) {
			GenBoProjectWriteNgs::addMethods($buffer->dbh,$runid,$u);
		}	
	}
# new patient
	for my $u (@pat) {
		my $last_patient_id=queryPolyproject::addPatientRun_v2($buffer->dbh,$u,$runid, $captureId);
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);	
}

###### Add Project Patient  ###################################################################
#./new_polyproject.pl opt=addProjPat project=1248 patient=1920

sub ProjectPatientSection {
	my $projectId=$cgi->param('project');
	my $patients = $cgi->param('patient');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$projectId);
	my $project = $buffer->newProject(-name=>$projectname);
	die ("unknown project ".$projectname ) unless $project;
	my $username = $ENV{'LOGNAME'};
	my $allPat="";
	my $failedPat="";
	#######JM
	my $typeGenbo=$buffer->getType("patient");
	for my $u (@pat) {
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$u);
		
		my $patientGenbo_id = GenBoWriteNgs::createGenBo($buffer->dbh,$patname,$typeGenbo,$projectId);
		my $patid=queryPolyproject::upPatientProject($buffer->dbh,$u,$projectId,$patientGenbo_id);
		$allPat.=$patid;
		if ($allPat == "") {
			$failedPat.=$u.",";
		}	
	}
### End Autocommit dbh ###########
	$dbh->commit();
	if ($allPat =="") {
		chop($failedPat);
		sendError("Patient number: " . $failedPat . " already linked to project ID: " . $projectId);
	} else 	{
		$ENV{'DATABASE'} = "";
		my $name = $projectname;
		my $buffer = GBuffer->new();
		my $projectG = $buffer->newProject(-name=>$name);
		$projectG->makePath();
		sendOK("Successful validation for project: " . $projectId);	
	}
	
}

###### Add Patient  ###############################################################
#./new_polyproject.pl opt=newPat project=1248 run=212 capture=2 patient="DJM4"
sub PatSection {
	my $projectId=$cgi->param('project');
	my $runId = $cgi->param('run');
	my $captureId = $cgi->param('capture');
	my $patients = $cgi->param('patient');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
#warn $ENV{'LOGNAME'};
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$projectId);
	my $project = $buffer->newProject(-name=>$projectname);
	die ("unknown project ".$projectname ) unless $project;
	my $username = $ENV{'LOGNAME'};
	my $typeGenbo=$buffer->getType("patient");

# new patient
	for my $u (@pat) {
		my $patientGenbo_id = GenBoWriteNgs::createGenBo($buffer->dbh,$u,$typeGenbo,$projectId);
		my $last_patient_id=queryPolyproject::addPatientRun($buffer->dbh,$u,$projectId,$runId, $captureId,$patientGenbo_id);
		#my $patientid=$last_patient_id->{'LAST_INSERT_ID()'};
		#queryPolyproject::upPatientGenbo($buffer->dbh,$patientid);
		#my ($patient_id) = GenBoWrite::createGenBo($buffer->dbh,$u,$type,$project->id);	
	}
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for run: " . $runId);	
}


sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub sendError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub response {
	my ($rep) = @_;
	print qq{<textarea>};
	print to_json($rep);
	print qq{</textarea>};
	exit(0);
}

exit(0);
