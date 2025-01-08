#!/usr/bin/perl
########################################################################
###### manageData.pl
########################################################################
#use CGI;
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#ce script est utilisé pour inserer des données dans la BD à partir de l'interface.
use GenBoWrite;
use GenBoQuery;
use GenBoTrace;
use GenBoRelationWrite;
use GenBoProjectWrite;
use util_file qw(readXmlVariations);
use insert;
use Time::Local;

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
#use Encode::Encoding;
#use Encode::Alias;
#use Encode;

use export_data;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $option = $cgi->param('option');

#print $cgi->header();
if ( $option eq "plateform" ) {
	PlateformSection();
} elsif ( $option eq "Newplateform" ) {
	newPlateformSection();
} elsif ( $option eq "Addplateform" ) {
	addPlateformSection();
} elsif ( $option eq "machine" ) {
	MachineSection();
} elsif ( $option eq "Newmachine" ) {
	newMachineSection();
} elsif ( $option eq "database" ) {
	DatabaseSection();
} elsif ( $option eq "release" ) {
	ReleaseSection();
} elsif ( $option eq "disease" ) {
        DiseaseSection();
} elsif ( $option eq "projDisease" ) {
        DiseaseProjectSection();
} elsif ( $option eq "addDisease" ) {
        addDiseaseProjectSection();
} elsif ( $option eq "remDisease" ) {
        removeDiseaseProjectSection();
} elsif ( $option eq "Newdisease" ) {
        NewdiseaseSection();
} elsif ( $option eq "Deldisease" ) {
        DeldiseaseSection();
} elsif ( $option eq "method" ) {
	MethodSection();
} elsif ( $option eq "methodAln" ) {
	AlnMethodSection();
} elsif ( $option eq "methodCall" ) {
	CallMethodSection();
} elsif ( $option eq "methodSeq" ) {
	SeqMethodSection();
} elsif ( $option eq "chgMethSeq" ) {
	runSeqMethodSection();
} elsif ( $option eq "NewMethSeq" ) {
	newMethSeqSection();
} elsif ( $option eq "Newcalling" ) {
	newCallingSection();
} elsif ( $option eq "AddAlnCalling" ) {
	addAlnCallingSection();
} elsif ( $option eq "Newalignment" ) {
	newAlignmentSection();
} elsif ( $option eq "capture" ) {
	CaptureSection();
} elsif ( $option eq "Newcapture" ) {
	newCaptureSection();
} elsif ( $option eq "user" ) {
	UserSection();
} elsif ( $option eq "addUser" ) {
	addUserProjectSection();
} elsif ( $option eq "userProject" ) {
	UserProjectSection();
} elsif ( $option eq "runtype" ) {
	RunTypeSection();
} elsif ( $option eq "NewTypeSeq" ) {
	newRunTypeSection();
} elsif ( $option eq "patient" ) {
	RunPatientSection();
} elsif ( $option eq "patientProject" ) {
	PatientProjectSection();
} elsif ( $option eq "freeRun" ) {
	freeRunPatientSection();
}
# ./manageData.pl option=patientProject ProjSel=1180

###### Patient Run ###################################################################
sub RunPatientSection {
	my $runid = $cgi->param('RunSel');
	#warn Dumper $runid;
	my $runListId = queryPolyproject::getPatientsInfoFromRun($buffer->dbh,$runid);
	warn Dumper $runListId;
	my @data;
	my %hdata;
	$hdata{identifier}="PatId";
	$hdata{label}="PatId";
	foreach my $c (@$runListId){
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{PatId} = $c->{patient_id};
		$s{PatId} += 0;
		$s{ProjectId} = $c->{project_id};
		$s{ProjectId} += 0;
		$s{CaptureId} = $c->{capture_id};
		$s{CaptureId} += 0;
		$s{patientName} = $c->{name};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub freeRunPatientSection {
#	my $runid = $cgi->param('RunSel');
	#warn Dumper $runid;
#	my $runListId = queryPolyproject::getFreePatientsRun($buffer->dbh);
#	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$projid);
	my $runListId = queryPolyproject::getPatientProjectInfo($buffer->dbh,0);
	
#	warn Dumper $runListId;
	my @data;
	my %hdata;
	#$hdata{identifier}="RunId";
	$hdata{label}="RunId";
	foreach my $c (@$runListId){
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{PatId} = $c->{patient_id};
		$s{PatId} += 0;		
		$s{patientName} = $c->{name};		
		$s{macName} = $c->{macName};
		$s{plateformName} = $c->{plateformName};
		my $methaln = queryPolyproject::getAlnMethodName($buffer->dbh,$s{RunId});
		$s{methAln}=join(" ",map{$_->{methAln}}@$methaln);
		my $methsnp = queryPolyproject::getCallMethodName($buffer->dbh,$s{RunId});
		$s{methSnp}=join(" ",map{$_->{methCall}}@$methsnp);
		$s{methSeqName} = $c->{methSeqName};
		$s{capName} = $c->{capName};
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);

}
#	foreach my $c (@$patientList){
#		my %s;
#		$s{Row} = $row++;
#		$s{Name} = $c->{name};
#		$s{RunId} = $c->{run_id};
#		$s{macName} = $c->{macName};
#		$s{plateformName} = $c->{plateformName};
#		my $methaln = queryPolyproject::getAlnMethodName($buffer->dbh,$s{RunId});
#		$s{methAln}=join(" ",map{$_->{methAln}}@$methaln);
##		my $methsnp = queryPolyproject::getCallMethodName($buffer->dbh,$s{RunId});
#		$s{methSnp}=join(" ",map{$_->{methCall}}@$methsnp);
#		$s{methSeqName} = $c->{methSeqName};
#		$s{capName} = $c->{capName};
#		my @datec = split(/ /,$c->{cDate});
#		my ($YY, $MM, $DD) = split("-", $datec[0]);
#		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
#		$s{cDate} = $mydate;
#		push(@data,\%s);
#	}
	
###### Plateform ###################################################################
sub PlateformSection {
	my $plateformListId = queryPolyproject::getPlateformId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="plateformName";
	$hdata{label}="plateformName";
	foreach my $c (@$plateformListId){
		my %s;
		$s{plateformId} = $c->{plateformId};
		$s{plateformId} += 0;
		$s{plateformName} = $c->{plateformName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newPlateformSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $plateform = $cgi->param('plateform');
        my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
		if (exists $plateformid ->{id}) {
			sendError("Plateform Name: " . $plateform ."...". " already in Plateform database");
		} else 	{
### End Autocommit dbh ###########
			my $myplateformid = queryPolyproject::newPlateformData($buffer->dbh,$plateform);
			$dbh->commit();
			sendOK("Successful validation for Plateform : ". $plateform);	
		}
		exit(0);
}

sub addPlateformSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPlateform = $cgi->param('Fcall');
	my @field = split(/,/,$listPlateform);
	my $allPlateform="";
	foreach my $u (@field) {
		my $plateformid = queryPolyproject::addPlateform2run($buffer->dbh, $u, $runid);
		$allPlateform.=$plateformid;	
	}
	if ($allPlateform =="") {
		sendError("Plateform number: " . $listPlateform . " already linked to run ID: " . $runid);
	}else 	{
#### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Successful validation for run ID: ". $runid);	
	}
	exit(0);
}

###### Machine #####################################################################
sub MachineSection {
	my $machineListId = queryPolyproject::getMachineId($buffer->dbh);
#	warn Dumper $plateformListId;
	my @data;
	my %hdata;
	$hdata{identifier}="macName";
	$hdata{label}="macName";
	foreach my $c (@$machineListId){
		my %s;
		$s{machineId} = $c->{machineId};
		$s{machineId} += 0;
		$s{macName} = $c->{macName};
		$s{macType} = $c->{macType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newMachineSection {
### Autocommit dbh ###########id="stateInput"
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
		my $machine = $cgi->param('machine');
		my $mactype = $cgi->param('mactype');
        my $machineid = queryPolyproject::getMachineFromName($buffer->dbh,$machine);
		if (exists $machineid ->{machineId}) {
			sendError("Machine Name: " . $machine ."...". " already in Machine database");
		} else 	{
### End Autocommit dbh ###########
			my $mymachineid = queryPolyproject::newMachineData($buffer->dbh,$machine,$mactype);
			$dbh->commit();
			sendOK("Successful validation for Machine : ". $machine);	
		}
		exit(0);
}
###### Database ###################################################################
sub DatabaseSection {
	my $dbListId = queryPolyproject::getDatabaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="dbName";
	$hdata{label}="dbName";
        	foreach my $c (@$dbListId){
		my %s;
		$s{dbId} = $c->{dbId};
		$s{dbId} += 0;
		$s{dbName} = $c->{dbName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
###### Release ####################################################################
sub ReleaseSection {
	my $relListId = queryPolyproject::getReleaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="relName";
	$hdata{label}="relName";
        	foreach my $c (@$relListId){
		my %s;
		$s{releaseId} = $c->{releaseId};
		$s{releaseId} += 0;
		$s{relName} = $c->{relName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###### Disease ####################################################################
sub DiseaseSection {
	my $typeListId = queryPolyproject::getDiseaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="diseaseId";
	$hdata{label}="diseaseId";
        	foreach my $c (@$typeListId){
		my %s;
		$s{diseaseId} = $c->{diseaseId};
		$s{diseaseId} += 0;
		$s{diseaseName} = $c->{diseaseName};
		$s{diseaseAbb} = $c->{diseaseAbb};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub DiseaseProjectSection {
	my $projectId = $cgi->param('ProjSel');
	my $typeListId = queryPolyproject::getDiseasesFromProject($buffer->dbh,$projectId);
	my @data;
	my %hdata;
	$hdata{identifier}="diseaseId";
	$hdata{label}="diseaseId";
	foreach my $c (@$typeListId){
		my %s;
		$s{diseaseId} = $c->{diseaseId};
		$s{diseaseId} += 0;
		$s{diseaseName} = $c->{description};
		$s{diseaseAbb} = $c->{diseaseAbb};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
sub addDiseaseProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $projname = $cgi->param('ProjSel');
        my $listDisease = $cgi->param('Disease');
        my @field = split(/,/,$listDisease);
		my $projid = queryPolyproject::getProjectFromName($buffer->dbh,$projname);
		my $allDisease="";
		foreach my $u (@field) {
			#warn Dumper $projid->{projectId};
			my $projectId = $projid->{projectId};
			my $diseaseid = queryPolyproject::addDisease2project($buffer->dbh, $u, $projectId);
#			die;
			$allDisease.=$diseaseid;
		}
		if ($allDisease =="") {
			sendError("Disease number: " . $listDisease . " already linked to project ID: " . $projid->{projectId});
		}else 	{
### End Autocommit dbh ###########
			$dbh->commit();
			sendOK("Successful validation for project ID: ". $projid->{projectId});	
		}
		exit(0);
}

sub removeDiseaseProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listDisease = $cgi->param('Disease');
	my @field = split(/,/,$listDisease);
	if($listDisease) {
		foreach my $u (@field) {
			my $diseaseid = queryPolyproject::delDisease2project($buffer->dbh, $u, $projid);
		}
	}
	if($listDisease) {
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Diseases removed from project ID: ". $projid);	
	} else {
		sendError("Diseases Not removed from project ID: ". $projid);
	}
	exit(0);
}

sub NewdiseaseSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $disease = $cgi->param('disease');
	my $abb = $cgi->param('abb');
	$abb="" unless defined $abb;
	$disease=~ s/'/ /g;
	my $diseaseid = queryPolyproject::getDiseaseFromName($buffer->dbh,$disease);
	if (exists $diseaseid ->{diseaseId}) {
		sendError("Disease Name: " . $disease ."...". " already in Disease database");
	} else 	{
### End Autocommit dbh ###########
		my $mydiseaseid = queryPolyproject::newDiseaseData($buffer->dbh,$disease,$abb);
		$dbh->commit();
		sendOK("Successful validation for Disease : ". $disease);	
	}
	exit(0);
}


sub DeldiseaseSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $ListdiseaseId = $cgi->param('diseaseId');
	my @field = split(/,/,$ListdiseaseId);
	if($ListdiseaseId) {
		my $notvalid="";
		foreach my $u (@field) {
			my $DisProj = queryPolyproject::ctrlDiseaseIdProject($buffer->dbh, $u);
			if(scalar @$DisProj>0) {
				my $ListProj=join(" ",map{$_->{projectId}}@$DisProj);
				$notvalid.=" Disease id:".$u." was found in Project id: ".$ListProj."," if ($ListProj);
			}
		}
		chop($notvalid);
		if($notvalid) {
			sendError($notvalid);			
		} else {
			foreach my $d (@field) {
				queryPolyproject::delDiseaseData($buffer->dbh, $d);
			}
			$dbh->commit();
			sendOK("Successful Deletion for Disease Id: ". $ListdiseaseId);				
		}
	}
}

###### Method #####################################################################
sub MethodSection {
	my $metListId = queryPolyproject::getMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="methName";
	$hdata{label}="methName";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{methName} = $c->{methName};
		$s{methType} = $c->{methType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub AlnMethodSection {
	my $metListId = queryPolyproject::getAlnMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="methName";
	$hdata{label}="methName";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{methName} = $c->{methName};
		$s{methType} = $c->{methType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub CallMethodSection {
	my $metListId = queryPolyproject::getCallMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="methName";
	$hdata{label}="methName";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{methName} = $c->{methName};
		$s{methType} = $c->{methType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newCallingSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $method = $cgi->param('method');
	my $methodid = queryPolyproject::getMethodFromName($buffer->dbh,$method);
	if (exists $methodid ->{methodId}) {
			sendError("Method Name: " . $method ."...". " already in Method database");
	} else 	{
### End Autocommit dbh ###########
		my $type='SNP';
		my $mymethodid = queryPolyproject::newMethodData($buffer->dbh,$method,$type);
		$dbh->commit();
		sendOK("Successful validation for Method : ". $method);	
	}
	exit(0);
}

sub addAlnCallingSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $runid = $cgi->param('RunSel');
	my $listMeth = $cgi->param('Mcall');
	my $projectName = queryPolyproject::getProjectName($buffer->dbh,$projid);
	#warn Dumper $projid;
	my @field = split(/,/,$listMeth);
	my $allMeth="";
	foreach my $u (@field) {
		my $methid = queryPolyproject::addMeth2run($buffer->dbh, $u, $runid);
		
		$allMeth.=$methid;	
	}
	if ($allMeth =="") {
		sendError("Method number: " . $listMeth . " already linked to run ID: " . $runid);
	}else 	{
### End Autocommit dbh ###########
		$dbh->commit();
		my $buffer = GBuffer->new();
		my $projectG = $buffer->newProject(-name=>$projectName);
		# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
		$projectG->makePath_v2();
		sendOK("Successful validation of project ID: ". $projid." for the run ID :".$runid);	
	}
	exit(0);
}


sub newAlignmentSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $method = $cgi->param('method');
    my $methodid = queryPolyproject::getMethodFromName($buffer->dbh,$method);
	if (exists $methodid ->{methodId}) {
		sendError("Method Name: " . $method ."...". " already in Method database");
	} else 	{
### End Autocommit dbh ###########
		my $type='ALIGN';
		my $mymethodid = queryPolyproject::newMethodData($buffer->dbh,$method,$type);
		$dbh->commit();
		sendOK("Successful validation for Method : ". $method);	
	}
	exit(0);
}
###### Method Seq #################################################################
sub SeqMethodSection {
	my $mseqListId = queryPolyproject::getSeqMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="methSeqName";
	$hdata{label}="methSeqName";
	foreach my $c (@$mseqListId){
		my %s;
		$s{methodSeqId} = $c->{methodSeqId};
		$s{methodSeqId} += 0;
		$s{methSeqName} = $c->{methSeqName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub runSeqMethodSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listMethSeq = $cgi->param('Scall');
	my @field = split(/,/,$listMethSeq);
	my $allMethSeq="";
	foreach my $u (@field) {
		my $mid = queryPolyproject::upMethSeq2run($buffer->dbh, $u, $runid);
		$allMethSeq.=$mid;	
	}
	if ($allMethSeq =="") {
		sendError("MethSeq number: " . $listMethSeq . " already linked to run ID: " . $runid);
	}else 	{
#### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Successful validation for run ID: ". $runid);	
	}
	exit(0);
}

sub newMethSeqSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $methseq = $cgi->param('methseq');
	my $methseqid = queryPolyproject::getMethSeqFromName($buffer->dbh,$methseq);
	if (exists $methseqid ->{methodSeqId}) {
			sendError("Sequencing Method Name: " . $methseq ."...". " already in Method Seq database");
	} else 	{
### End Autocommit dbh ###########
		my $mymethseqdid = queryPolyproject::newMethSeqData($buffer->dbh,$methseq);
		$dbh->commit();
		sendOK("Successful validation for Sequencing Method : ". $methseq);	
	}
	exit(0);
}

###### Capture ####################################################################

sub CaptureSection {
	my $captureListId = queryPolyproject::getCaptureId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="capName";
	$hdata{label}="capName";
	foreach my $c (@$captureListId){
		my %s;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{capName} = $c->{capName};
		$s{capDes} =  $c->{capDes};
		$s{capFile} = $c->{capFile};
		$s{capType} = $c->{capType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
 sub newCaptureSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $capture = $cgi->param('capture');
	my $capDes = $cgi->param('capDes');
	my $capVs = $cgi->param('capVs');
	my $capFile = $cgi->param('capFile');
	my $capType = $cgi->param('capType');
	my $captureid = queryPolyproject::getCaptureFromName($buffer->dbh,$capture);
	if (exists $captureid ->{captureId}) {
		sendError("Capture Name: " . $capture ."...". " already in Capture database");
	} else 	{
### End Autocommit dbh ###########
		my $mycaptureid = queryPolyproject::newCaptureData($buffer->dbh,$capture,$capVs,$capDes,$capFile,$capType);
		$dbh->commit();
		sendOK("Successful validation for Capture : ". $capture);	
	}
	exit(0);
}

###### User ########################################################################
sub UserSection {
	my $userList = queryPolyproject::getUserInfo($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="UserId";
	$hdata{label}="Name";
        	foreach my $c (@$userList){
		my %s;
		$s{UserId} = $c->{UserId};
		$s{UserId} += 0;
		$s{Name} = $c->{Name};
		$s{Firstname} = $c->{Firstname};
		$s{Code} = $c->{Code};
		$s{Team} = $c->{Team};
		$s{Site} = $c->{Site};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub UserProjectSection {
	my $projid = $cgi->param('ProjSel');
	my $userList = queryPolyproject::getUsersAllInfoFromProject($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$userList){
		my %s;
		$s{Row} = $row++;
		$s{Name} = $c->{name};
		$s{Firstname} = $c->{Firstname};
		$s{Email} = $c->{Email};
		$s{Code} = $c->{unit};
		$s{Organisme} = $c->{organisme};
		$s{Site} = $c->{site};
		$s{Director} = $c->{Director};
		$s{Team} = $c->{Team};
		$s{Responsable} = $c->{Responsable};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub addUserProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listUser = $cgi->param('User');
	my @field = split(/,/,$listUser);
	my $allUser="";
	foreach my $u (@field) {
		my $userid = queryPolyproject::addUser2project($buffer->dbh, $u, $projid);
		$allUser.=$userid;
	}
	if ($allUser =="") {
		sendError("User number: " . $listUser . " already linked to project ID: " . $projid);
	}else 	{
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Successful validation for project ID: ". $projid);	
	}
	exit(0);
}

###### Run Type ###################################################################
sub RunTypeSection {
	my $runtypeListId = queryPolyproject::getRunType($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="runTypeName";
	$hdata{label}="runTypeName";
	foreach my $c (@$runtypeListId){
		my %s;
		$s{runTypeId} = $c->{runTypeId};
		$s{runTypeId} += 0;
		$s{runTypeName} = $c->{runTypeName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
 
 sub newRunTypeSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $type = $cgi->param('type');
	my $typeid = queryPolyproject::getRunTypeFromName($buffer->dbh,$type);
	if (exists $typeid ->{runTypeId}) {
			sendError("Run Type Name: " . $type ."...". " already in Run Type database");
	} else 	{
### End Autocommit dbh ###########
		my $mytypeid = queryPolyproject::newRunTypeData($buffer->dbh,$type);
		$dbh->commit();
		sendOK("Successful validation for Run Type Name : ". $type);	
	}
	exit(0);
 }
 
sub PatientProjectSection {
	my $projid = $cgi->param('ProjSel');
#	warn Dumper $projid;
	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$projid);
#	warn Dumper $patientList;
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$patientList){
		my %s;
		$s{Row} = $row++;
		$s{Name} = $c->{name};
		$s{RunId} = $c->{run_id};
		$s{macName} = $c->{macName};
		$s{plateformName} = $c->{plateformName};
		my $methaln = queryPolyproject::getAlnMethodName($buffer->dbh,$s{RunId});
		$s{methAln}=join(" ",map{$_->{methAln}}@$methaln);
		my $methsnp = queryPolyproject::getCallMethodName($buffer->dbh,$s{RunId});
		$s{methSnp}=join(" ",map{$_->{methCall}}@$methsnp);
		$s{methSeqName} = $c->{methSeqName};
		$s{capName} = $c->{capName};
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

 
 
####################################################################################
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


sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}


exit(0);



