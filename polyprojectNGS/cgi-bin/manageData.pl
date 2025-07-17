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
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";
use Time::Local;
#use DateTime;
#use DateTime::Duration;
use File::Basename;
use GBuffer;
use connect;
use queryPolyproject;
use queryPerson;
use queryValidationDB;
use Data::Dumper;
use Carp;
use JSON;
use List::Util qw/ max min /;

use export_data;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $option = $cgi->param('option');

#print $cgi->header();
if ( $option eq "schemas" ) {
	SchemasSection();
} elsif ( $option eq "newValidationDB" ) {
	newValidationDBSection();
} elsif ( $option eq "schemasName" ) {
	SchemasNameSection();
} elsif ( $option eq "upDataDefault" ) {
	upDataDefaultSection();
} elsif ( $option eq "upExtractDef" ) {
	upExtractDefSection();
} elsif ( $option eq "plateform" ) {
	PlateformSection();
} elsif ( $option eq "plateformName" ) {
	PlateformNameSection();
} elsif ( $option eq "Newplateform" ) {
	newPlateformSection();
} elsif ( $option eq "Addplateform" ) {
	addPlateformSection();
} elsif ( $option eq "machine" ) {
	MachineSection();
} elsif ( $option eq "machineName" ) {
	MachineNameSection();
} elsif ( $option eq "Newmachine" ) {
	newMachineSection();
} elsif ( $option eq "database" ) {
	DatabaseSection();
} elsif ( $option eq "release" ) {
	ReleaseSection();
} elsif ( $option eq "releaseRef" ) {
	ReleaseRefSection();
} elsif ( $option eq "method" ) {
	MethodSection();
} elsif ( $option eq "methodAln" ) {
	AlnMethodSection();
} elsif ( $option eq "AlnName" ) {
	AlnNameSection();
} elsif ( $option eq "methodCall" ) {
	CallMethodSection();
} elsif ( $option eq "CallName" ) {
	CallNameSection();
} elsif ( $option eq "methodOther" ) {
	OtherMethodSection();
} elsif ( $option eq "OtherName" ) {
	OtherNameSection();
} elsif ( $option eq "methodSeq" ) {
	SeqMethodSection();
} elsif ( $option eq "methSeqName" ) {
	SeqMethodNameSection();
} elsif ( $option eq "chgMethSeq" ) {
	runSeqMethodSection();
} elsif ( $option eq "NewMethSeq" ) {
	newMethSeqSection();
} elsif ( $option eq "groupName" ) {
	groupNameSection();
} elsif ( $option eq "Newcalling" ) {
	newCallingSection();
} elsif ( $option eq "AddNewAlnCalling" ) {
	addNewAlnCallingSection();
} elsif ( $option eq "Newalignment" ) {
	newAlignmentSection();
} elsif ( $option eq "analyse" ) {
	CaptureAnalyseSection();
} elsif ( $option eq "valanalyse" ) {
	CaptureValAnalyseSection();
} elsif ( $option eq "captureName" ) {
	CaptureNameSection();
} elsif ( $option eq "captureByAnalyse" ) {
	captureByAnalyseSection();
} elsif ( $option eq "captureInfo" ) {
	#not used
	CaptureInfoSection();
} elsif ( $option eq "captureNameRef" ) {
	#not used
	CaptureNameRefSection();
} elsif ( $option eq "captureMeth" ) {
	CaptureMethSection();
} elsif ( $option eq "captureMethName" ) {
	CaptureMethNameSection();
} elsif ( $option eq "captureType" ) {
	CaptureTypeSection();
} elsif ( $option eq "captureProject" ) {
	captureProjectSection();
} elsif ( $option eq "lastCapture" ) {
	lastCaptureSection();
} elsif ( $option eq "umi" ) {
	UmiSection();
} elsif ( $option eq "umiName" ) {
	umiNameSection();
} elsif ( $option eq "newUmi" ) {
	newUmiSection();
} elsif ( $option eq "perspective" ) {
	PerspectiveSection();
} elsif ( $option eq "Newperspective" ) {
	newPerspectiveSection();
} elsif ( $option eq "technology" ) {
	TechnologySection();
} elsif ( $option eq "Newtechnology" ) {
	newTechnologySection();
} elsif ( $option eq "preparation" ) {
	PreparationSection();
} elsif ( $option eq "Newpreparation" ) {
	newPreparationSection();
} elsif ( $option eq "profile" ) {
	ProfileSection();
} elsif ( $option eq "NewUpdateprofile" ) {
	newupdateProfileSection();
} elsif ( $option eq "bundle" ) {
	BundleSection();
} elsif ( $option eq "lastBundle" ) {
	lastBundleSection();	
} elsif ( $option eq "bundleCap" ) {
	BundleCapSection();
} elsif ( $option eq "Newbundle2Capture" ) {
	newBundle2CaptureSection();
} elsif ( $option eq "upBundle" ) {
	upBundleSection();
} elsif ( $option eq "AddCapturebundle" ) {
	AddCapturebundleSection();
} elsif ( $option eq "RemCapturebundle" ) {
	RemCapturebundleSection();
} elsif ( $option eq "relGeneName" ) {
	relGeneNameSection();
} elsif ( $option eq "bundleTranscripts" ) {
	BundleTranscriptsSection();
} elsif ( $option eq "addTranscripts" ) {
	addTranscriptsSection();
} elsif ( $option eq "upTranscripts" ) {
	upTranscriptsSection();
} elsif ( $option eq "delTranscripts" ) {
	delTranscriptsSection();
} elsif ( $option eq "user" ) {
	UserSection();
} elsif ( $option eq "addUser" ) {
	addUserProjectSection();
} elsif ( $option eq "remUser" ) {
	removeUserProjectSection();
} elsif ( $option eq "remUserAllProjects" ) {
	removeUserForAllProjectsSection();
} elsif ( $option eq "DirectorName" ) {
	DirectorNameSection();	
} elsif ( $option eq "unitName" ) {
	UnitNameSection();	
} elsif ( $option eq "userProject" ) {
	UserProjectSection();
} elsif ( $option eq "userList" ) {
	UserListSection();
} elsif ( $option eq "userId" ) {
	UserIdProjectSection();
} elsif ( $option eq "usergroupProject" ) {
	UserGroupProjectSection();
} elsif ( $option eq "ugroup" ) {
	ugroupSection();
} elsif ( $option eq "userGroup" ) {
	userGroupSection();
} elsif ( $option eq "addUserGroup" ) {
	# a suprimer 
	addUserGroupProjectSection();
} elsif ( $option eq "addProject2Group" ) {
	addProject2GroupSection();
} elsif ( $option eq "remUserGroup" ) {
	#  a suprimer
	remUserGroupProjectSection();
} elsif ( $option eq "remProject2Group" ) {
	remProject2GroupSection();
} elsif ( $option eq "runtype" ) {
	RunTypeSection();
} elsif ( $option eq "NewTypeSeq" ) {
	newRunTypeSection();
} elsif ( $option eq "patient" ) {
	RunPatientSection();
} elsif ( $option eq "gpatient" ) {
	genomicRunPatientSection();
} elsif ( $option eq "patientProject" ) {
	PatientProjectSection();
} elsif ( $option eq "gpatientProjectDest" ) {
	genomicPatientProjectDestSection();
} elsif ( $option eq "findPatient" ) {
	FindPatientSection();
} elsif ( $option eq "delPatient" ) {
	DelPatientSection();
} elsif ( $option eq "upPatient" ) {
	UpPatientSection();
} elsif ( $option eq "addPatientRun" ) {
	addPatientRunSection();
} elsif ( $option eq "addMethodsToPatient" ) {
	addMethodsToPatientSection();
} elsif ( $option eq "updatePatientRun" ) {
	updatePatientRunSection();
} elsif ( $option eq "upPatientProj" ) {
	UpPatientProjSection();
} elsif ( $option eq "upPatientIV" ) {
	upPatientIVSection();
} elsif ( $option eq "upPatientControl" ) {
	upPatientControlSection();
} elsif ( $option eq "upPatientProfile" ) {
	upPatientProfileSection();
} elsif ( $option eq "upPatientSpecies" ) {
	upPatientSpeciesSection();
} elsif ( $option eq "upPatientCapture" ) {
	upPatientCaptureSection();
} elsif ( $option eq "removePatientProj" ) {
	removePatientProjSection();
} elsif ( $option eq "Project" ) {
	ProjectSection();
} elsif ( $option eq "saveProject" ) {
	saveProjectSection();
} elsif ( $option eq "delProject" ) {
	delProjectSection();
} elsif ( $option eq "lastProject" ) {
	lastProjectSection();
} elsif ( $option eq "lastDesProject" ) {
	lastDesProjectSection();
} elsif ( $option eq "ProjectDest" ) {
	ProjectDestSection();
} elsif ( $option eq "runProject" ) {
	RunProjectSection();
} elsif ( $option eq "freeRun" ) {
	freeRunPatientSection();
} elsif ( $option eq "selfreeRun" ) {
	selfreeRunPatientSection();
} elsif ( $option eq "allRun" ) { #old
	allRunSection();
} elsif ( $option eq "allqRun" ) { #version pour Plt
	allqRunSection();
} elsif ( $option eq "allqRunDev" ) { #old
	allqRunDevSection();
} elsif ( $option eq "lastRun" ) {
	lastRunSection();
} elsif ( $option eq "chgCapPat" ) {
	chgCapPatSection();
} elsif ( $option eq "validRun" ) { #not used
	validRunSection();
} elsif ( $option eq "upRun" ) {
	UpRunSection();
} elsif ( $option eq "phenotype" ) {
	phenotypeSection();
} elsif ( $option eq "phenotypeName" ) {
	phenotypeNameSection();
} elsif ( $option eq "addPhenotype" ) {
	addPhenotypeSection();
}  elsif ( $option eq "speciesName" ) {
	speciesNameSection();
} elsif ( $option eq "profileName" ) {
	profileNameSection();
} elsif ( $option eq "pipelineName" ) {
	pipelineNameSection();
} elsif ( $option eq "pipelineMeth" ) {
	pipelineMethSection();
} elsif ( $option eq "newPipeline" ) {
	newPipelineSection();
} elsif ( $option eq "upPipeline" ) {
	upPipelineSection();
} elsif ($option eq "years") {
	yearsSection();
}

######################################################################################
# Not Used
sub SchemasNameSection {
	my $validationList = queryPolyproject::getSchemasValidation($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="name";
	my $ind=1;
	foreach my $c (@$validationList){
		my %s;
		my $name = $c->{'Database (%validation%)'};
		my @nameSP = split(/validation_/,$name);
		#my @nameSP = split(/_/,$name);
		$s{name} = $nameSP[1];
		$s{value} = $s{name};		
		$ind++;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub SchemasSection {
	my $validationList = queryPolyproject::getSchemasValidation($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="Name";
	foreach my $c (@$validationList){
		my %s;
		my $name = $c->{'Database (%validation%)'};
		my @nameSP = split(/validation_/,$name);
		#my @nameSP = split(/_/,$name);
		$s{Name} = $nameSP[1];
		push(@data,\%s);
	}
	my @result_sorted=sort {lc $a->{Name} cmp lc $b->{Name}} @data;
	$hdata{items}=\@result_sorted;
#	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newValidationDBSection {
	my $schemas = $cgi->param('name');
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $validationList = queryPolyproject::getSchemasValidation($buffer->dbh,"validation_".$schemas);
	createValidationDB("validation_".$schemas) unless  scalar @$validationList;
	$dbh->commit();
	sendOK("OK:Shemas ValidationDB created: ". "validation_".$schemas);	
}

###### Patient Run ###################################################################
#not used
sub validRunSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	queryPolyproject::upStep2run($buffer->dbh, $runid, 0);
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);	
}

sub chgCapPatSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $patients = $cgi->param('PatSel');
	my $capid = $cgi->param('CapSel');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);	
	for my $u (@pat) {
		queryPolyproject::upPatientCapture($buffer->dbh, $u, $runid, $capid);
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);	
}

sub UpRunSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('run');
	my $name = $cgi->param('name');
	my $description = $cgi->param('description');
	my $pltrun = $cgi->param('pltrun');
	queryPolyproject::upRunDesName($buffer->dbh,$runid,$name,$description,$pltrun);
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);				
}

sub UpPatientSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $partial = $cgi->param('partial');
	
	my $runId = $cgi->param('run');
		my @fieldR = split(/,/,$runId);	
#	my $projectId = $cgi->param('project');
	my $listChoice = $cgi->param('choice');
		my @fieldCh = split(/,/,$listChoice);
	my $listProject = $cgi->param('projname');
		my @fieldG = split(/,/,$listProject);
	my @fieldGI;
	for (my $i = 0; $i< scalar(@fieldG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,$fieldG[$i]);
		$res->{projectId} += 0;
		$fieldGI[$i] = $res->{projectId};
	}
	my $listCurrentProject = $cgi->param('currentprojname');
		my @fieldCG = split(/,/,$listCurrentProject);
	my @fieldCGI;
	for (my $i = 0; $i< scalar(@fieldCG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,$fieldCG[$i]);
		$res->{projectId} += 0;
		$fieldCGI[$i] = $res->{projectId};
	}
#
	my $listPatientId = $cgi->param('PatIdSel');
		my @fieldI = split(/,/,$listPatientId);
	my $listPatientName = $cgi->param('PatNameSel');
		my @fieldN = split(/,/,$listPatientName);
#
	my $listSex = $cgi->param('sex');
		my @fieldS = split(/,/,$listSex);
	my $listStatus = $cgi->param('status');
		my @fieldT = split(/,/,$listStatus);
	my $listDesPat = $cgi->param('desPat');
		my @fieldD = split(/,/,$listDesPat);
	my $listBC = $cgi->param('bc');
		my @fieldB = split(/,/,$listBC);	
	my $listBC2= $cgi->param('bc2');
		my @fieldB2 = split(/,/,$listBC2);	
	my $listBCG = $cgi->param('iv');
		my @fieldBG = split(/,/,$listBCG);	
	my $listFlowcell = $cgi->param('flowcell');
		my @fieldO = split(/,/,$listFlowcell);
	my $listFamily = $cgi->param('family');
		my @fieldF = split(/,/,$listFamily);
	my $listFather = $cgi->param('father');
		my @fieldA = split(/,/,$listFather);
	my $listMother = $cgi->param('mother');
		my @fieldM = split(/,/,$listMother);
	my $listType = $cgi->param('type');
		my @fieldTY = split(/,/,$listType);
		
#Person
	my $pperson=0;
	my $listPersonName = $cgi->param('personSel');
#	warn Dumper $listPersonName;
	if ($listPersonName) {$pperson=1};		
		my @fieldPN = split(/,/,$listPersonName);
# Extended	options
	my $extended=0;
	my $s_personsearch = $cgi->param('s_personsearch');
	$s_personsearch=~ s/ //g;
	$s_personsearch=~ s/\n/;/g;	# warn Dumper $s_personsearch;
	$extended= 1 if $s_personsearch;
	my @s_personsearch=split(/,/,$s_personsearch);
	
	my $s_person = $cgi->param('s_person');
	$s_person=~ s/ //g;
	$s_person=~ s/\n/;/g;
	my @s_person=split(/,/,$s_person);
	
	my $s_personid = $cgi->param('s_person_id');
	$s_personid=~ s/ //g;
	$s_personid=~ s/\n/;/g;
	my @s_personid=split(/,/,$s_personid);
	my $hash_pers;		
	for (my $i = 0; $i< scalar(@s_personsearch); $i++) {
		$hash_pers->{$s_personsearch[$i]} = $s_person[$i].",".$s_personid[$i];
	}

	if (! $extended) {		
		my @identical;
		my %hdata;
		$hdata{identifier}="Row";
		$hdata{label}="Row";
		my $ident=0;
		my $row=1;
		my %seen=();
		my %seenPers=();
		my @existPers;
		my $ln=0;
		foreach my $s (@fieldPN) {
#			my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$v);			
			my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$fieldI[$ln]);
			$ln++ unless $s;
			next unless $s;
			$ln++ if $s eq $res_pat->{person};
			next if $s eq $res_pat->{person};
			my $personList=[];
			#$personList= queryPerson::getPatientPersonInfo_Startwith_PersonName($buffer->dbh,$s);# Pas de extend....
			if (scalar @$personList) {
				$ident=1;
				my @newPersonName=new_PersonName($row,$s,$personList);
				@existPers=map{$_->{person}}@newPersonName;
				push(@identical,@newPersonName) unless $seenPers{@existPers." ".$s};
				$seenPers{@existPers." ".$s}++;
				$row++;			
				for my $y (@$personList) {
					next if $seen{$y->{person_id}}++;
					my %si;
					$si{Row} = $row++;
					$si{imax} = 0;
					$si{person_s} = $s;
					$si{person} = $y->{person};
					$si{person_id} = $y->{person_id};				
					$si{patient} = $y->{name};
					$si{patient_id} = $y->{patient_id};
					$si{run} = $y->{run_id};
					$si{projectId} = $y->{project_id};
					$si{project} = $y->{project};
					$si{capAnalyse} = $y->{capAnalyse};
					$si{sex} = $y->{sex};
					$si{family} = $y->{family};
					$si{status} = $y->{status};
					$si{iv_vcf} = $y->{identity_vigilance_vcf};
					push(@identical,\%si);
				}				
			}
			$ln++;			
		}		
		$hdata{items}=\@identical;
		if ($ident) {
			my $extend;
			$extend=\%hdata;
			sendExtended("Extend",$extend);
		}
	}
	my @fieldII;
	my @fieldPI;#person_id
#	my @fieldPN;# person name
	my @fieldPNO;# person name
	my @fieldPFI;#family_id
	my @fieldPAI;#father_id
	my @fieldPMI;#mother_id
	my @fieldPS;#sex
	my @fieldPT;#status

	my $listCapture = $cgi->param('capture');
		my @fieldC = split(/,/,$listCapture);
	my @fieldCI;
	for (my $i = 0; $i< scalar(@fieldC); $i++) {
		my $res = queryPolyproject::getCaptureFromName($buffer->dbh,$fieldC[$i]);
		$res->{captureId} += 0;
		@fieldCI[$i] = $res->{captureId};
		my $relcProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$fieldCGI[$i]);
		
		my $relProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$fieldGI[$i]);
		my $relCap = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$fieldCI[$i]);
		my $relCapj=join(" ",map{$_->{name}}@$relCap) if defined $relCap ;
		if ($relcProj=~ /^HG19/) {$relcProj="HG19"}
		if ($relCapj=~ /^HG19/) {$relCapj="HG19"}
		if ($relcProj=~ /^HG38/) {$relcProj="HG38"}
		if ($relCapj=~ /^HG38/) {$relCapj="HG38"}
		
		if (($relcProj ne $relCapj) && $relcProj) {
		### End Autocommit dbh ###########
		# Pas Bon
			$dbh->commit();
			sendError("<b>Failure</b>: Release between Capture ($relCapj) and Project ($relcProj) are different...");
		}
	}
	my $seq_machine = $cgi->param('machine');
	my $plateform = $cgi->param('plateform');
	my $method_seq = $cgi->param('methseq');
	my $listAln = $cgi->param('aln');
		my @fieldAl = split(/,/,$listAln);
	my @fieldAln;
	for (my $i = 0; $i< scalar(@fieldAl); $i++) {
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,$fieldAl[$i],"ALIGN");
		$res->{id} += 0;
		@fieldAln[$i] = $res->{id};
	}	
		
	my $listCall = $cgi->param('call');
		my @fieldCa = split(/,/,$listCall);
	my @fieldCall;
	for (my $i = 0; $i< scalar(@fieldCa); $i++) {
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,$fieldCa[$i],"SNP");
		$res->{id} += 0;
		@fieldCall[$i] = $res->{id};
	}
	
	my $listOthers = $cgi->param('others');
		my @fieldOt = split(/,/,$listOthers);	
	my @fieldOthers;
	for (my $i = 0; $i< scalar(@fieldOt); $i++) {
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,$fieldOt[$i],"other");
		$res->{id} += 0;
		@fieldOthers[$i] = $res->{id};
	}

	my $listGroup = $cgi->param('GroupNameSel');
		my @fieldGN = my @fieldGNname= split(/,/,$listGroup,-1);
		
	for (my $i = 0; $i< scalar(@fieldGN); $i++) {
		my $res = queryPolyproject::getGroupIdFromName($buffer->dbh,$fieldGN[$i]);
		$res->{group_id} += 0;
		@fieldGN[$i] = $res->{group_id} if $res->{group_id};
		@fieldGN[$i] = 0 unless $res->{group_id};
	}
	my $machineid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	queryPolyproject::upMachine2run($buffer->dbh,$runId,$machineid->{machineId}) unless $partial;
	
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	queryPolyproject::upPlateform2run($buffer->dbh,$runId,$plateformid->{id}) unless $partial;	
	
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	queryPolyproject::upMethSeq2run($buffer->dbh,$runId,$meth_seq->{methodSeqId}) unless $partial;	
	my $validR="";
	my $validP="";
	my $validNew= "";

	my %seen;
	for (my $i = 0; $i< scalar(@fieldI); $i++) {
		my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,$fieldN[$i]);
		for my $p (@$pname) {
			if ($p->{run_id} != $fieldR[$i]) {
				$validR.=$p->{name}.":".$p->{run_id}."," ;
			}
			my $proj=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,$fieldN[$i]);
			if (defined $proj) {
				if ($p->{run_id} != $fieldR[$i]) {
					my $nameproj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$p->{run_id},$proj->[0]->{project_id});
					$validP.=$p->{name}.":". $nameproj->{name}."," if $nameproj->{name};
				}
			}
		}
#	if ($fieldCh[$i] eq "U") {
			#Person			
		my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$fieldI[$i]);
#		warn Dumper $res_pat;
		my $l_species=queryPerson::getSpecies_FromId($buffer->dbh,$res_pat->{species_id});
		$fieldII[$i] = $res_pat->{patient_id};
			
		$fieldPI[$i]=$res_pat->{person_id};
#		$fieldPN[$i]=$fieldN[$i] unless $fieldPN[$i];
		$fieldPS[$i]=$fieldS[$i];
		$fieldPT[$i]=$fieldT[$i];
		$fieldPFI[$i]=0;
		$fieldPAI[$i]=0;
		$fieldPMI[$i]=0;
		$fieldPNO[$i] = $res_pat->{person};
		
#		warn Dumper $fieldPNO[$i];
			
		my $fam;
		my $familyId;
		$fam=queryPerson::getFamily_FromName($buffer->dbh,$fieldF[$i]);
		unless ($fam->{name}) {
			my $last_family_id=queryPerson::insertFamily($buffer->dbh,$fieldF[$i]);
			$familyId=$last_family_id->{'LAST_INSERT_ID()'};
		} else {
			$familyId=$fam->{family_id};
		}			
		$fieldPFI[$i]=$familyId if $familyId;
		if ($fieldA[$i]) {
			my $fatherId=0;
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldA[$i],$fieldR[$i]);
 			if ($patientList->[0]->{person_id}) {					
            	$fatherId=$patientList->[0]->{person_id};
 			} else {
 				my $patientListProj = queryPerson::getPatientPersonInfo_byPatientName_byProjectId($buffer->dbh,$fieldA[$i],$fieldGI[$i]);
  				if (scalar @$patientListProj>1) {
 					$fatherId=0;
 				} else {
 					$fatherId=$patientListProj->[0]->{person_id};
 				}					
 			}
			$fieldPAI[$i]=$fatherId;
		}
		if ($fieldM[$i]) {
			my $motherId=0;
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldM[$i],$fieldR[$i]);
 			if ($patientList->[0]->{person_id}) {					
            	$motherId=$patientList->[0]->{person_id};
 			 } else {
 				my $patientListProj = queryPerson::getPatientPersonInfo_byPatientName_byProjectId($buffer->dbh,$fieldM[$i],$fieldGI[$i]);
 				if (scalar @$patientListProj>1) {
 					$motherId=0;
 				} else {
 					$motherId=$patientListProj->[0]->{person_id};
 				}					
 			}
			$fieldPMI[$i]=$motherId;
		}
		$fieldI[$i]+= 0;			
  		queryPolyproject::upPatientInfo($buffer->dbh,$fieldI[$i],$fieldN[$i],$fieldS[$i],$fieldT[$i],$fieldD[$i],$fieldB[$i],$fieldB2[$i],$fieldBG[$i],$fieldO[$i],$fieldF[$i],$fieldA[$i],$fieldM[$i],$fieldCI[$i],$fieldTY[$i]);
		$fieldPI[$i]+= 0;
		unless ($partial) {
			if ($fieldAln[$i]) {
				my $is_pm1=queryPolyproject::isPatientMethod($buffer->dbh,$fieldI[$i],$fieldAln[$i]);
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldI[$i],$fieldAln[$i]) unless $is_pm1->{method_id};				
			}
			if ($fieldCall[$i]) {
				my $is_pm2=queryPolyproject::isPatientMethod($buffer->dbh,$fieldI[$i],$fieldCall[$i]);
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldI[$i],$fieldCall[$i]) unless $is_pm2->{method_id};					
			}
			if ($fieldOthers[$i]) {
				my $is_pm3=queryPolyproject::isPatientMethod($buffer->dbh,$fieldI[$i],$fieldOthers[$i]);
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldI[$i],$fieldOthers[$i]) unless $is_pm3->{method_id};					
			}
		}
		my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$fieldI[$i]);
		if ($groupid->[0]->{group_id}) {
			queryPolyproject::removeGroup2patient($buffer->dbh,$fieldI[$i]) if $fieldGNname[$i] eq "";
  			next if $fieldGNname[$i] eq "";
			if ($fieldGN[$i]) {
   				queryPolyproject::removeGroup2patient($buffer->dbh,$fieldI[$i]);
   				queryPolyproject::addGroup2patient($buffer->dbh,$fieldI[$i],$fieldGN[$i]);
			}			
   			##queryPolyproject::upPatientGroup($buffer->dbh,$fieldI[$i],$fieldGN[$i]) if ($fieldGN[$i]);
   			##queryPolyproject::removeGroup2patient($buffer->dbh,$fieldI[$i]) unless ($fieldGN[$i]);
 			unless ($fieldGN[$i]) {					
   				queryPolyproject::removeGroup2patient($buffer->dbh,$fieldI[$i]);
				my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$fieldGNname[$i]);
				$fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 				queryPolyproject::addGroup2patient($buffer->dbh,$fieldI[$i],$fieldGN[$i]) if ($fieldGN[$i]);
 			}

 		} else {			
 			unless ($fieldGN[$i] ) {
				queryPolyproject::removeGroup2patient($buffer->dbh,$fieldI[$i]) if $fieldGNname[$i] eq "";
  				#next if $fieldGNname[$i] eq ""; #?????????
				my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$fieldGNname[$i]) unless $fieldGNname[$i] eq "" ;
				$fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 			} 				
  			if ($fieldGN[$i] ) { 					
				my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$fieldGNname[$i]) unless $fieldGNname[$i] eq "" ;
				$fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 			}
  			queryPolyproject::addGroup2patient($buffer->dbh,$fieldI[$i],$fieldGN[$i]) if ($fieldGN[$i]);
 		}
 		my $person_id;
		if ($pperson) {
			if ($hash_pers->{$fieldPN[$i]})	{
				queryPerson::delPatientPerson($buffer->dbh,$fieldII[$i],$fieldPI[$i]);
				if ((split ',',$hash_pers->{$fieldPN[$i]})[1]) {
					$person_id=(split ',',$hash_pers->{$fieldPN[$i]})[1];
				} else {
					my $person_name=(split ',',$hash_pers->{$fieldPN[$i]})[0];
					my $last_person_id;
					my ($lsexs,$lstatuss,$familyids,$lfathers,$lmothers)=(1,2,0,0,0);
					$lsexs=$fieldS[$i] if $fieldS[$i];
					$lstatuss=$fieldT[$i] if $fieldT[$i];
					$familyids=$fieldPFI[$i] if $fieldPFI[$i];
					$lfathers=$fieldPAI[$i] if $fieldPAI[$i];
					$lmothers=$fieldPMI[$i] if $fieldPMI[$i];
					my $exist_person_name;
					$exist_person_name=queryPerson::getPersonName_fromName($buffer->dbh,$person_name);
					if ($exist_person_name) {
						$person_id=$exist_person_name->{person_id};						
					} else {					
						$last_person_id=queryPerson::insertPerson($buffer->dbh,$person_name,$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) if $fieldPN[$i];
						$person_id=$last_person_id->{'LAST_INSERT_ID()'} if $fieldPN[$i];
						$hash_pers->{$fieldPN[$i]}.= $person_id if $fieldPN[$i]; # a tester												
					}
				}
				queryPerson::insertPatientPerson($buffer->dbh,$fieldII[$i],$person_id);
			} else {	
				my $last_person_id;
				my ($lsexs,$lstatuss,$familyids,$lfathers,$lmothers)=(1,2,0,0,0);
				$lsexs=$fieldS[$i] if $fieldS[$i];
				$lstatuss=$fieldT[$i] if $fieldT[$i];
				$familyids=$fieldPFI[$i] if $fieldPFI[$i];
				$lfathers=$fieldPAI[$i] if $fieldPAI[$i];
				$lmothers=$fieldPMI[$i] if $fieldPMI[$i];
				if ($fieldPNO[$i] =~ /^($l_species->{code})[0-9]+/ && ! $fieldPN[$i]) {
					next;
				} else {	
					queryPerson::delPatientPerson($buffer->dbh,$fieldI[$i],$fieldPI[$i]);
				}
				my $persname;
				$last_person_id=queryPerson::insertPerson($buffer->dbh,$fieldPN[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) if $fieldPN[$i];
				$last_person_id=queryPerson::insertPerson($buffer->dbh,'tempo_'.$fieldN[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) unless $fieldPN[$i];							
				$person_id=$last_person_id->{'LAST_INSERT_ID()'};
				unless ($fieldPN[$i]) {
					$persname=$l_species->{code}.sprintf("%010d", $person_id);
					queryPerson::upPersonName($buffer->dbh,$person_id,$persname);								
				}
				queryPerson::insertPatientPerson($buffer->dbh,$fieldI[$i],$person_id);
			}					
		} else {
			# not pperson
				my $last_person_id;
				my ($lsexs,$lstatuss,$familyids,$lfathers,$lmothers)=(1,2,0,0,0);
				$lsexs=$fieldS[$i] if $fieldS[$i];
				$lstatuss=$fieldT[$i] if $fieldT[$i];
				$familyids=$fieldPFI[$i] if $fieldPFI[$i];
				$lfathers=$fieldPAI[$i] if $fieldPAI[$i];
				$lmothers=$fieldPMI[$i] if $fieldPMI[$i];
				if ($fieldPNO[$i] =~ /^($l_species->{code})[0-9]+/ && ! $fieldPN[$i]) {
					next;
				} else {	
					queryPerson::delPatientPerson($buffer->dbh,$fieldI[$i],$fieldPI[$i]);
				}
				my $persname;
				$last_person_id=queryPerson::insertPerson($buffer->dbh,$fieldPN[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) if $fieldPN[$i];
				$last_person_id=queryPerson::insertPerson($buffer->dbh,'tempo_'.$fieldN[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) unless $fieldPN[$i];							
				$person_id=$last_person_id->{'LAST_INSERT_ID()'};
				unless ($fieldPN[$i]) {
					$persname=$l_species->{code}.sprintf("%010d", $person_id);
					queryPerson::upPersonName($buffer->dbh,$person_id,$persname);								
				}
				queryPerson::insertPatientPerson($buffer->dbh,$fieldI[$i],$person_id);
#			die;
		}
	}
#	die;
	my $resEmptyGrp=queryPolyproject::searchEmptyGroup($buffer->dbh);
	if ($resEmptyGrp->{group_id}) {
		my $resPatGrp=queryPolyproject::searchPatientGroup($buffer->dbh);
		#print "===============================================================\n";
		#print "Empty Name : Purge table group from groupid of patient_groups\n";
		#print "===============================================================\n";
		foreach my $u (@$resPatGrp) {
			my $grpid=queryPolyproject::getGroupId($buffer->dbh,$u->{group_id});
			queryPolyproject::delGroup($buffer->dbh,$grpid->[0]->{group_id}) unless $grpid->[0]->{groupName};	
			queryPolyproject::delPatGroup($buffer->dbh,$u->{group_id}) unless $grpid->[0]->{group_id};	
		}
		#print "\n";
		#print "===============================================================\n";
		#print "Empty Name : Purge table group and patient_groups:\n";
		#print "===============================================================\n";
		my $resGrp=queryPolyproject::searchGroup($buffer->dbh);
		foreach my $u (@$resGrp) {
			my $patientid="";
			$patientid=queryPolyproject::getPatientIdFromPatientGroups($buffer->dbh,$u->{group_id}) unless $u->{name}; 
			if (defined $patientid) {
				queryPolyproject::delPatGroup($buffer->dbh,$u->{group_id}, $patientid->{patient_id}) unless $u->{name};			
			}
			queryPolyproject::delGroup($buffer->dbh,$u->{group_id}) unless $u->{name};	
		}
		#print "===============================================================\n";
		#print "============================= END =============================\n";
		#print "===============================================================\n";	
	}
	
	# Add pat
	if ($validNew) {
		my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runId);
		queryPolyproject::upNbPat2run($buffer->dbh,$runId,scalar(@$listPatRun));
	}
	
	chop($validP,$validR,$validNew);
#	
	#### End Autocommit dbh ###########
	$dbh->commit();
	if ($partial) {
		my @runidList=split(/ /,join(" ",map{$_}@fieldR));
		$runId=join ',', sort{$a <=> $b} keys %{{map{$_=>1}@runidList}};
	}

	if ($validP)	{
		sendOK("Successful validation for patient: <B>". $listPatientName."</B> in Run: <B>".$runId.
		"</B><BR><B>New patient are : </B>".$validNew.
		"<BR><B>WARNING:</B> Patient already exist in Run (patient:run): ".$validR.
		"<BR><B>WARNING:</B> Patient already exist in Project (patient:project): ".$validP)
	} elsif ($validR)	{
		sendOK("Successful validation for patient: <B>". $listPatientName."</B> in Run: <B>".$runId.
		"</B><BR><B>New patient are : </B>".$validNew.		
		"<BR><B>WARNING:</B> Patient already exist in Run (patient:run): ".$validR)
	} else {
		sendOK("Successful validation for patient: <B>". $listPatientName."</B> in Run: <B>".$runId.
		"</B><BR><B>New patient are : </B>".$validNew)
	}
}

=mod
=cut
sub addPatientRunSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $selplt = $cgi->param('SelPlt');
	my $runid = $cgi->param('RunSel');

	my $method_pipeline = $cgi->param('method_pipeline');
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $group_method_other_name = $cgi->param('method_other');

	my $captureId = $cgi->param('capture');
	my $nbpat = $cgi->param('nbpat');
	my $fc = $cgi->param('fc');
	my $typepat = $cgi->param('typePatient');
	my $speciesid = $cgi->param('species');
	my $profileid = $cgi->param('profileId');
		
# group
	my $groups = $cgi->param('group');
	$groups=~ s/ //g;
	$groups=~ s/\n/;/g;
	my @grp=split(/,/,$groups);

	my $patients = $cgi->param('patient');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
	
	my $families = $cgi->param('family');
	$families=~ s/ //g;
	$families=~ s/\n/;/g;
	my @fam=split(/,/,$families);

	my $fathers = $cgi->param('father');
	$fathers=~ s/ //g;
	$fathers=~ s/\n/;/g;
	my @lfathers=split(/,/,$fathers);

	my $mothers = $cgi->param('mother');
	$mothers=~ s/ //g;
	$mothers=~ s/\n/;/g;
	my @lmothers=split(/,/,$mothers);

	my $sexs = $cgi->param('sex');
	$sexs=~ s/ //g;
	$sexs=~ s/\n/;/g;
	my @lsexs=split(/,/,$sexs);

	my $statuss = $cgi->param('status');
	$statuss=~ s/ //g;
	$statuss=~ s/\n/;/g;
	my @lstatuss=split(/,/,$statuss);

	my $barcode = $cgi->param('bc');
	$barcode=~ s/ //g;
	$barcode=~ s/\n/;/g;
	my @bc=split(/,/,$barcode);
		
	my $barcode2 = $cgi->param('bc2');
	$barcode2=~ s/ //g;
	$barcode2=~ s/\n/;/g;
	my @bc2=split(/,/,$barcode2);

	my $gbarcode = $cgi->param('iv');
	$gbarcode=~ s/ //g;
	$gbarcode=~ s/\n/;/g;
	my @bcg=split(/,/,$gbarcode);

	my $p_person = $cgi->param('person');
	$p_person=~ s/ //g;
	$p_person=~ s/\n/;/g;
	my @person=split(/,/,$p_person);
# Extended	options
	my $extended=0;
	my $s_personsearch = $cgi->param('s_personsearch');
	$s_personsearch=~ s/ //g;
	$s_personsearch=~ s/\n/;/g;
	$extended= 1 if $s_personsearch;
	my @s_personsearch=split(/,/,$s_personsearch);
	
	my $s_person = $cgi->param('s_person');
	$s_person=~ s/ //g;
	$s_person=~ s/\n/;/g;
	my @s_person=split(/,/,$s_person);
	
	my $s_personid = $cgi->param('s_person_id');
	$s_personid=~ s/ //g;
	$s_personid=~ s/\n/;/g;
	my @s_personid=split(/,/,$s_personid);
	my $hash_pers;		
	for (my $i = 0; $i< scalar(@s_personsearch); $i++) {
		$hash_pers->{$s_personsearch[$i]} = $s_person[$i].",".$s_personid[$i];
	}
# Error Patients 
	my $novalidPatient = isUniqPatient($buffer->dbh,@pat);
	sendError( "<b>Error Patient:<b> Duplicated Patients $novalidPatient in this current Run..." ) if ($novalidPatient);
# Warning Genotype Bar Code
	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @bcg;

	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code : $messageduplicateB" if scalar @duplicateB;


# method pipeline
	my $validPipe="";
	if ($method_pipeline) {
		my $meth_pipe = queryPolyproject::getPipelineMethods_byId($buffer->dbh,$method_pipeline);
		my @ListPipe = split(/ /,$meth_pipe->[0]->{content});	
		foreach my $m (@ListPipe) {
				my $method_p= queryPolyproject::getMethodsFromName($buffer->dbh,$m);
				$validPipe.=$method_p->{id}."," if ($method_p);
		}
		chop($validPipe);
		sendError("Error undefined method in Pipeline Methods: " . $method_pipeline ) unless $validPipe;	
	}

# method aln
	my $validAln="";
	my $validCall="";
	my $validOther="";
	unless ($selplt) {
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$group_method_align_name);
			foreach my $u (@ListAln) {
				my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
				$validAln.=$method_align->{id}."," if ($method_align);
			}
			chop($validAln);
			sendError("Error undefined method_align: " . $group_method_align_name ) unless $validAln;	
		}
# method call
		if ($group_method_calling_name) {
			my @ListCall = split(/,/,$group_method_calling_name);
			foreach my $u (@ListCall) {
				my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validCall.=$method_call->{id}."," if ($method_call);
			}
			chop($validCall);
			sendError("Error undefined method_call: " . $group_method_calling_name ) unless $validCall;	
		}
# method other
		if ($group_method_other_name) {
			my @ListOther = split(/,/,$group_method_other_name);
			foreach my $u (@ListOther) {
				my $method_other = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"other");
				$validOther.=$method_other->{id}."," if ($method_other);
			}
			chop($validOther);
			sendError("Error undefined method_other: " . $group_method_other_name ) unless $validOther;	
		}
	}

	if (! $extended) {		
		my @identical;
		my %hdata;
		$hdata{identifier}="Row";
		$hdata{label}="Row";
		my $ident=0;
		my $row=1;
		my %seen=();
		my %seenPers=();
		my @existPers;
		foreach my $s (@person) {
			next unless $s;
			my $personList= queryPerson::getPatientPersonInfo_Startwith_PersonName($buffer->dbh,$s);
			if (scalar @$personList) {
				$ident=1;
				my @newPersonName=new_PersonName($row,$s,$personList);
				@existPers=map{$_->{person}}@newPersonName;
				push(@identical,@newPersonName) unless $seenPers{@existPers." ".$s};
				$seenPers{@existPers." ".$s}++;
				$row++;			
				for my $y (@$personList) {
					next if $seen{$y->{person_id}}++;
					my %si;
					$si{Row} = $row++;
					$si{imax} = 0;
					$si{person_s} = $s;
					$si{person} = $y->{person};
					$si{person_id} = $y->{person_id};				
					$si{patient} = $y->{name};
					$si{patient_id} = $y->{patient_id};
					$si{run} = $y->{run_id};
					$si{projectId} = $y->{project_id};
					$si{project} = $y->{project};
					$si{capAnalyse} = $y->{capAnalyse};
					$si{family} = $y->{family};
					$si{sex} = $y->{sex};
					$si{status} = $y->{status};
					$si{iv_vcf} = $y->{identity_vigilance_vcf};
					push(@identical,\%si);
				}				
			}
		}
		$hdata{items}=\@identical;
		if ($ident) {
			my $extend;
			$extend=\%hdata;
			sendExtended("Extend",$extend);
		}
	}	
# new patient & family 
	my $i;
	my $validR="";
	my $validP="";
	my %seen;
	my %seen2;
	my @patientpersonId;
	foreach my $p (@pat) {
		my $j;
		foreach my $f (@fam) {
			if ($i==$j) {
				my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,$p);
				for my $pc (@$pname) {
					$validR.=$pc->{name}.":".$pc->{run_id}."," unless $seen{$pc->{name}}++;
					my $proj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$pc->{run_id},$pc->{project_id}) if $pc->{project_id};
					if (defined $proj) {
						$validP.=$pc->{name}.":". $proj->{name}."," unless $seen2{$pc->{name}}++;
					};
				}
				$profileid=0 unless defined $profileid;
				$profileid=0 unless $profileid;
				my $last_patient_id=queryPolyproject::newPatientRun($buffer->dbh,$p,$p,$runid,$captureId,$f,$fc,$bc[$i],$bc2[$i],$bcg[$i],$lfathers[$i],$lmothers[$i],$lsexs[$i],$lstatuss[$i],$typepat,$speciesid,$profileid);
				my $patient_id=$last_patient_id->{'LAST_INSERT_ID()'};
				my $personRunList= queryPerson::getPatientPersonInfo_byPersonName_Run($buffer->dbh,$person[$i]);
				my @existPers=map{$_->{person_id}}@$personRunList;

				my $person_id;
				my $l_species=queryPerson::getSpecies_FromId($buffer->dbh,$speciesid);
				unless (scalar(@existPers)) {
					my $last_person_id;
					$last_person_id=queryPerson::insertPerson($buffer->dbh,$person[$i],$lsexs[$i],$lstatuss[$i],0,0,0,0) if $person[$i];
					$last_person_id=queryPerson::insertPerson($buffer->dbh,$p,$lsexs[$i],$lstatuss[$i],0,0,0,0) unless $person[$i];
					$person_id=$last_person_id->{'LAST_INSERT_ID()'};				
				} else {
					if ($hash_pers->{$person[$i]})	{
						if ((split ',',$hash_pers->{$person[$i]})[1]) {
							$person_id=(split ',',$hash_pers->{$person[$i]})[1];
						} else {
							my $person_name=(split ',',$hash_pers->{$person[$i]})[0];
							my $last_person_id=queryPerson::insertPerson($buffer->dbh,$person_name,$lsexs[$i],$lstatuss[$i],0,0,0,0);
							$person_id=$last_person_id->{'LAST_INSERT_ID()'};				
							$hash_pers->{$person[$i]}.=	$person_id;
						}						
					} else {
						my $e_person=queryPerson::getPersonName_fromName($buffer->dbh,$person[$i]);
						$person_id=$e_person->{person_id};
					}	
				}	
				#die;	
				queryPerson::insertPatientPerson($buffer->dbh,$patient_id,$person_id);
				push(@patientpersonId,$patient_id.",".$person_id);
				my $persname;
				#$persname=$l_species->{code}.sprintf("%010d", $person_id) if ($person[$i] eq $p || !$person[$i]);
				#queryPerson::upPersonName($buffer->dbh,$person_id,$persname) if ($person[$i] eq $p || !$person[$i]);
				$persname=$l_species->{code}.sprintf("%010d", $person_id) unless $person[$i];				
				queryPerson::upPersonName($buffer->dbh,$person_id,$persname) unless $person[$i];

				#Group (new/old)
				if (defined $grp[$i] && $grp[$i]) {
					my $groupid;
					# test si group exist
					my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,$grp[$i]) if (defined $grp[$i] && $grp[$i]);
					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$grp[$i]) unless defined $group;
					$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
					$groupid = $group->{group_id} unless defined $last_groupid;
					my $patient_id=$last_patient_id->{'LAST_INSERT_ID()'};
				#Patient Group
					queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$groupid) if ($groupid);
				}
			}
			$j++;
		}
		$i++;
	}	
	chop($validR);
	chop($validP);
	
	# phase 2
	# update person for familyId fatherId motherId
	for my $l (@patientpersonId) {
		my $l_patid=(split(/,/,$l))[0];
		my $l_persid=(split(/,/,$l))[1];
		my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$l_patid);
		#warn Dumper $res_pat;
		
		my $fam;
		my $familyId;
		if ($res_pat->{family}) {
			$fam=queryPerson::getFamily_FromName($buffer->dbh,$res_pat->{family});
			unless ($fam->{name}) {
				my $last_family_id=queryPerson::insertFamily($buffer->dbh,$res_pat->{family});
				$familyId=$last_family_id->{'LAST_INSERT_ID()'};
			} else {
				$familyId=$fam->{family_id};
			}			
		}
		queryPerson::upPerson_inFamilyId($buffer->dbh,$res_pat->{person_id},$familyId) if $familyId;		
		if ($res_pat->{father}) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$res_pat->{father},$res_pat->{run_id});
			queryPerson::upPerson_inFatherId($buffer->dbh,$res_pat->{person_id},$patientList->[0]->{person_id});			
		}
		if ($res_pat->{mother}) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$res_pat->{mother},$res_pat->{run_id});
			queryPerson::upPerson_inMotherId($buffer->dbh,$res_pat->{person_id},$patientList->[0]->{person_id});
		}		
	}	

	my $listPatRun=queryPolyproject::getRunIdfromPatient($buffer->dbh,$runid);
	queryPolyproject::upNbPat2run($buffer->dbh,$runid,scalar(@$listPatRun));
#  add Meth call & aln to patient
	unless ($selplt) {
		for my $u (@pat) {
			# add Method in patient_methods
			if ($group_method_align_name) {
				my @ListAln = split(/,/,$validAln);	
				foreach my $m (@ListAln) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($group_method_calling_name) {
				my @ListCall = split(/,/,$validCall);	
				foreach my $m (@ListCall) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($group_method_other_name) {
				my @ListOther = split(/,/,$validOther);	
				foreach my $m (@ListOther) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($method_pipeline) {
				my @ListMethPipe = split(/,/,$validPipe);	
				foreach my $m (@ListMethPipe) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}					
		}
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	if ($validP)	{
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR."<BR>and Project: ".$validP.$messageduplicateB)
	} elsif ($validR)	{
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR.$messageduplicateB)
	} else {
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid."</B>".$messageduplicateB)
	}		
}

sub addMethodsToPatientSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $selplt = $cgi->param('SelPlt');
	my $runid = $cgi->param('RunSel');
	my $listPatname= $cgi->param('patient');
		my @fieldPN = split(/,/,$listPatname);
	my $listPatId= $cgi->param('patientid');
		my @fieldPI = split(/,/,$listPatId);

	my $method_pipeline = $cgi->param('method_pipeline');
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $group_method_other_name = $cgi->param('method_other');
	
	# method pipeline
	my $validPipe="";
	if ($method_pipeline) {
		my $meth_pipe = queryPolyproject::getPipelineMethods_byId($buffer->dbh,$method_pipeline);
		my @ListPipe = split(/ /,$meth_pipe->[0]->{content});	
		foreach my $m (@ListPipe) {
				my $method_p= queryPolyproject::getMethodsFromName($buffer->dbh,$m);
				$validPipe.=$method_p->{id}."," if ($method_p);
		}
		chop($validPipe);
		sendError("Error undefined method in Pipeline Methods: " . $method_pipeline ) unless $validPipe;	
	}	
# method aln
	my $validAln="";
	my $validCall="";
	my $validOther="";
	unless ($selplt) {
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$group_method_align_name);
			foreach my $u (@ListAln) {
				my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
				$validAln.=$method_align->{id}."," if ($method_align);
			}
			chop($validAln);
			sendError("Error undefined method_align: " . $group_method_align_name ) unless $validAln;	
		}
# method call
		if ($group_method_calling_name) {
			my @ListCall = split(/,/,$group_method_calling_name);
			foreach my $u (@ListCall) {
				my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validCall.=$method_call->{id}."," if ($method_call);
			}
			chop($validCall);
			sendError("Error undefined method_call: " . $group_method_calling_name ) unless $validCall;	
		}
# method other
		if ($group_method_other_name) {
			my @ListOther = split(/,/,$group_method_other_name);
			foreach my $u (@ListOther) {
				my $method_other = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"other");
				$validOther.=$method_other->{id}."," if ($method_other);
			}
			chop($validOther);
			sendError("Error undefined method_other: " . $group_method_other_name ) unless $validOther;	
		}
	}

	for (my $i = 0; $i< scalar(@fieldPI); $i++) {
		# add Method in patient_methods
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$validAln);	
			foreach my $m (@ListAln) {
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldPI[$i],$m);
			}	
		}
		if ($group_method_calling_name) {
			my @ListCall = split(/,/,$validCall);	
			foreach my $m (@ListCall) {
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldPI[$i],$m);
			}	
		}
		if ($group_method_other_name) {
			my @ListOther = split(/,/,$validOther);	
			foreach my $m (@ListOther) {
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldPI[$i],$m);
			}	
		}
		if ($method_pipeline) {
			my @ListMethPipe = split(/,/,$validPipe);	
			foreach my $m (@ListMethPipe) {
				queryPolyproject::addMeth2pat($buffer->dbh,$fieldPI[$i],$m);
			}	
		}					
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("<b>Medthods added for Patients:</b> ".$listPatname);	
}

sub new_PersonName {
	my ($row,$person,$List) = @_;
	my @simPers=split('__',join(',',map{$_->{person}}@$List));
	my @indice;
	push(@indice,'0');
	foreach my $m (@$List) {
		if ($m->{person} =~ /__/) {
			my $t=(split('__',$m->{person}))[1];
			push(@indice,(split('__',$m->{person}))[1]);			
		}
	}
	my $indice2=max @indice;
	$indice2++;
	my $new_name=$person."__".$indice2;
	my @newPerson;
	my %si;
	$si{Row} = $row;
	$si{person_s} = $person;
	$si{imax} = $indice2;
	#$si{person} = $new_name;
	$si{person} = 'New Person/'.$new_name;
	$si{person_id} = "";				
	$si{patient} = "";
	$si{patient_id} = "";
	$si{run} = "";
	$si{projectId} = "";
	$si{project} = "";
	$si{capAnalyse} = "";
	$si{family} = "";
	$si{sex} = "";
	$si{status} = "";
	$si{iv_vcf} = "";
	push(@newPerson,\%si);
	return @newPerson;
}

sub isUniqPatient {
	my ($dbh,@patient) = @_;
	my $novalidP="";
	my %seen;
	for my $p (@patient) {
		$novalidP.=$p."," if $seen{$p}++;
	}
	chop($novalidP);
	return $novalidP
}

sub updatePatientRunSection {
### Autocommit dbh ###########toto
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $speciesid = $cgi->param('species');
	my $l_species=queryPerson::getSpecies_FromId($buffer->dbh,$speciesid);
	
	my $listPatname= $cgi->param('name');
		my @PatName = split(/,/,$listPatname);
	my $pfamily=0;
	my $pfather=0;
	my $pmother=0;
	my $pbc=0;
	my $pbc2=0;
	my $piv=0;
	my $pperson=0;
	
	my $listFamily = $cgi->param('family');
		my @fieldF = split(/,/,$listFamily);
	if ($listFamily) {$pfamily=1};
	my $listFather = $cgi->param('father');
		my @fieldA = split(/,/,$listFather);
	if ($listFather) {$pfather=1};
	my $listMother = $cgi->param('mother');
		my @fieldM = split(/,/,$listMother);		
	if ($listMother) {$pmother=1};		
	my $listSex = $cgi->param('sex');
		my @fieldS = split(/,/,$listSex);
	my $listStatus = $cgi->param('status');
		my @fieldT = split(/,/,$listStatus);		
	my $listBC = $cgi->param('bc');
	if ($listBC) {$pbc=1};	
		my @fieldB = split(/,/,$listBC);			
	my $listBC2 = $cgi->param('bc2');
	if ($listBC2) {$pbc2=1};	
		my @fieldB2 = split(/,/,$listBC2);			
	my $listBCG = $cgi->param('iv');
	if ($listBCG) {$piv=1};		
		my @fieldBG = split(/,/,$listBCG);	
	my $listPerson = $cgi->param('person');
	if ($listPerson) {$pperson=1};		
		my @fieldPN = split(/,/,$listPerson);	
	
	my $listGroup = $cgi->param('group');
		my @fieldGNname= split(/,/,$listGroup,-1);#-1 for not empty element
		
# Extended	options
	my $extended=0;
	my $s_personsearch = $cgi->param('s_personsearch');
	$s_personsearch=~ s/ //g;
	$s_personsearch=~ s/\n/;/g;	# warn Dumper $s_personsearch;
	$extended= 1 if $s_personsearch;
	my @s_personsearch=split(/,/,$s_personsearch);
	
	my $s_person = $cgi->param('s_person');
	$s_person=~ s/ //g;
	$s_person=~ s/\n/;/g;
	my @s_person=split(/,/,$s_person);
	
	my $s_personid = $cgi->param('s_person_id');
	$s_personid=~ s/ //g;
	$s_personid=~ s/\n/;/g;
	my @s_personid=split(/,/,$s_personid);
	my $hash_pers;		
	for (my $i = 0; $i< scalar(@s_personsearch); $i++) {
		$hash_pers->{$s_personsearch[$i]} = $s_person[$i].",".$s_personid[$i];
	}
	if (! $extended) {		
		my @identical;
		my %hdata;
		$hdata{identifier}="Row";
		$hdata{label}="Row";
		my $ident=0;
		my $row=1;
		my %seen=();
		my %seenPers=();
		my @existPers;
		foreach my $s (@fieldPN) {
			next unless $s;
			my $personList= queryPerson::getPatientPersonInfo_Startwith_PersonName($buffer->dbh,$s);
			if (scalar @$personList) {
				$ident=1;
				my @newPersonName=new_PersonName($row,$s,$personList);
				@existPers=map{$_->{person}}@newPersonName;
				push(@identical,@newPersonName) unless $seenPers{@existPers." ".$s};
				$seenPers{@existPers." ".$s}++;
				$row++;			
				for my $y (@$personList) {
					next if $seen{$y->{person_id}}++;
					my %si;
					$si{Row} = $row++;
					$si{imax} = 0;
					$si{person_s} = $s;
					$si{person} = $y->{person};
					$si{person_id} = $y->{person_id};				
					$si{patient} = $y->{name};
					$si{patient_id} = $y->{patient_id};
					$si{run} = $y->{run_id};
					$si{projectId} = $y->{project_id};
					$si{project} = $y->{project};
					$si{capAnalyse} = $y->{capAnalyse};
					$si{family} = $y->{family};
					$si{sex} = $y->{sex};
					$si{status} = $y->{status};
					$si{iv_vcf} = $y->{identity_vigilance_vcf};
					push(@identical,\%si);
				}				
			}
		}		
		$hdata{items}=\@identical;
		if ($ident) {
			my $extend;
			$extend=\%hdata;
			sendExtended("Extend",$extend);
		}
	}
	my @fieldI;
	#person
	my @fieldPI;
	my @fieldPFI;
	my @fieldPNO;
	my @fieldPAI;
	my @fieldPMI;
	
	for (my $i = 0; $i< scalar(@PatName); $i++) {		
		my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$PatName[$i],$runid);
		$fieldI[$i] = $patientList->[0]->{patient_id};
		$fieldPI[$i] = $patientList->[0]->{person_id};
		$fieldPFI[$i] = $patientList->[0]->{family_id};
		$fieldPNO[$i] = $patientList->[0]->{person};		
		
		unless  ($patientList->[0]->{patient_id}) {
			$dbh->commit();
			sendError("Error: <B>Unknown Patient: </B>$PatName[$i] in Run: $runid");
		}
	}
####### Control Father/Mother Sex  ###########################	
	my $f;
	for (my $i = 0; $i< scalar(@PatName); $i++) {
		$f->{$fieldA[$i]}=1 if $fieldA[$i];
		$f->{$fieldM[$i]}=2 if $fieldM[$i] ;	
	}
	my $error_message="";
	for (my $i = 0; $i< scalar(@PatName); $i++) {
		$error_message.= "Error <b>Father</b> $PatName[$i] <b>Sex:</b> $fieldS[$i]"."<br>" if ($fieldS[$i]==2 && $f->{$PatName[$i]}==1);
		$error_message.= "Error <b>Mother</b> $PatName[$i] <b>Sex:</b> $fieldS[$i]"."<br>" if ($fieldS[$i]==1 && $f->{$PatName[$i]}==2);
	}
	if  ($error_message) {
		$dbh->commit();
		sendError($error_message);
	}
	
####### Group  ###########################	
	my @fieldGN;
	if (@fieldGNname) {
		for (my $i = 0; $i< scalar(@fieldGNname); $i++) {
			my $res = queryPolyproject::getGroupIdFromName($buffer->dbh,$fieldGNname[$i]);
			$res->{group_id} += 0;
			$fieldGN[$i] = $res->{group_id} if $res->{group_id};
			$fieldGN[$i] = 0 unless  $res->{group_id};
		}		
	}
	# Only for table Patient
#######  ###########################	
	for (my $i = 0; $i< scalar(@fieldI); $i++) {		
		my $param="";
		my $paramp="";		
		if ($fieldA[$i]) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldA[$i],$runid);
			
			unless  ($patientList->[0]->{patient_id}) {			
			#unless  ($res) {
				$dbh->commit();
				sendError("Error: <B>Unknown Patient: </B>$fieldA[$i] in Run: $runid");
			}
		}
		if ($fieldM[$i]) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldM[$i],$runid);
			#unless  ($res) {
			unless  ($patientList->[0]->{patient_id}) {			
				$dbh->commit();
				sendError("Error: <B>Unknown Patient: </B>$fieldM[$i] in Run: $runid");
			}
		}
		$param.="family=".$fieldF[$i]." " if ($fieldF[$i]);
		$param.="family=".$PatName[$i]." " if ($pfamily && !$fieldF[$i]);
		
		$param.="father=".$fieldA[$i]." " if ($fieldA[$i]);
		$param.="father=".""." " if ($pfather && !$fieldA[$i]);
		
		$param.="mother=".$fieldM[$i]." " if ($fieldM[$i]);
		$param.="mother=".""." " if ($pmother && !$fieldM[$i]);
		
		$param.="sex=".$fieldS[$i]." " if ($fieldS[$i]);
		$param.="status=".$fieldT[$i]." " if ($fieldT[$i]);
		$param.="bar_code=".$fieldB[$i]." " if ($fieldB[$i]);
		$param.="bar_code=".""." " if ($pbc && !$fieldB[$i]);

		$param.="bar_code2=".$fieldB2[$i]." " if ($fieldB2[$i]);
		$param.="bar_code2=".""." " if ($pbc2 && !$fieldB2[$i]);		
		
		$param.="identity_vigilance=".$fieldBG[$i]." " if ($fieldBG[$i]);
		$param.="identity_vigilance=".""." " if ($piv && !$fieldBG[$i]);
		chop($param);
		if ($fieldF[$i]) {
			#warn Dumper $fieldF[$i];
			my $fam;
			my $familyId;
			$fam=queryPerson::getFamily_FromName($buffer->dbh,$fieldF[$i]);
			unless ($fam->{name}) {
				my $last_family_id=queryPerson::insertFamily($buffer->dbh,$fieldF[$i]);
				$familyId=$last_family_id->{'LAST_INSERT_ID()'};
			} else {
				$familyId=$fam->{family_id};
			}			
			$fieldPFI[$i]=$familyId;
		}
		if ($pfamily && !$fieldF[$i]) {
			my $fam;
			my $familyId;
			$fam=queryPerson::getFamily_FromName($buffer->dbh,$PatName[$i]);
			unless ($fam->{name}) {
				my $last_family_id=queryPerson::insertFamily($buffer->dbh,$PatName[$i]);
				$familyId=$last_family_id->{'LAST_INSERT_ID()'};
			} else {
				$familyId=$fam->{family_id};
			}			
			$fieldPFI[$i]=$familyId;
		}
		#father
		if ($fieldA[$i]) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldA[$i],$runid);
			$fieldPAI[$i] = $patientList->[0]->{person_id};
		}		
		#mother
		if ($fieldM[$i]) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$fieldM[$i],$runid);
			$fieldPMI[$i] = $patientList->[0]->{person_id};
		}
		$paramp.="name=".$fieldPN[$i]." " if ($fieldPN[$i]);# person name
		$paramp.="name=".$fieldPNO[$i]." " if ($pperson && !$fieldPN[$i]);# person name
		$paramp.="family_id=".$fieldPFI[$i]." " if ($fieldPFI[$i]);		
		$paramp.="father_id=".$fieldPAI[$i]." " if ($fieldPAI[$i]);
		$paramp.="father_id="."0"." " if ($pfather && !$fieldPAI[$i]);
		$paramp.="mother_id=".$fieldPMI[$i]." " if ($fieldPMI[$i]);
		$paramp.="mother_id="."0"." " if ($pmother && !$fieldPMI[$i]);		
		$paramp.="sex=".$fieldS[$i]." " if ($fieldS[$i]);
		$paramp.="status=".$fieldT[$i]." " if ($fieldT[$i]);
		chop($paramp);		
		queryPolyproject::upPatientRun($buffer->dbh,$runid,$fieldI[$i],$param);
		my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$fieldI[$i]);
		if (@fieldGNname) {
			if ($fieldGN[$i]) {
				if ($groupid->[0]->{group_id}) {
					my $res_grp=queryPolyproject::isPatientGroup($buffer->dbh,$fieldI[$i],$fieldGN[$i]);				
					unless (scalar(@$res_grp)) {
						queryPolyproject::upPatientGroup($buffer->dbh,$fieldI[$i],$fieldGN[$i]);
					} 
 				} else {
  					queryPolyproject::addGroup2patient($buffer->dbh,$fieldI[$i],$fieldGN[$i]);
 				}			
			} else {
  				if ($groupid->[0]->{group_id}) {
 					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$fieldGNname[$i]) unless $fieldGNname[$i] eq "" ;
 					$fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
  					queryPolyproject::upPatientGroup($buffer->dbh,$fieldI[$i],$fieldGN[$i]);
  				
  				} else {
 					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$fieldGNname[$i]) unless $fieldGNname[$i] eq "" ;
 					$fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 					queryPolyproject::addGroup2patient($buffer->dbh,$fieldI[$i],$fieldGN[$i]); 				
  				}
			}
		}

		my $person_id;
		if ($pperson)	{
			if ($hash_pers->{$fieldPN[$i]})	{
				queryPerson::delPatientPerson($buffer->dbh,$fieldI[$i],$fieldPI[$i]);
				if ((split ',',$hash_pers->{$fieldPN[$i]})[1]) {
					$person_id=(split ',',$hash_pers->{$fieldPN[$i]})[1];
				} else {
					my $person_name=(split ',',$hash_pers->{$fieldPN[$i]})[0];
					my $last_person_id;
					my ($lsexs,$lstatuss,$familyids,$lfathers,$lmothers)=(1,2,0,0,0);
					$lsexs=$fieldS[$i] if $fieldS[$i];
					$lstatuss=$fieldT[$i] if $fieldT[$i];
					$familyids=$fieldPFI[$i] if $fieldPFI[$i];
					$lfathers=$fieldPAI[$i] if $fieldPAI[$i];
					$lmothers=$fieldPMI[$i] if $fieldPMI[$i];
					$last_person_id=queryPerson::insertPerson($buffer->dbh,$person_name,$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) if $fieldPN[$i];
					$person_id=$last_person_id->{'LAST_INSERT_ID()'};
					$hash_pers->{$fieldPN[$i]}.=	$person_id;
								
				}
				queryPerson::insertPatientPerson($buffer->dbh,$fieldI[$i],$person_id);								
			} else {	
				my $last_person_id;
				my ($lsexs,$lstatuss,$familyids,$lfathers,$lmothers)=(1,2,0,0,0);
				$lsexs=$fieldS[$i] if $fieldS[$i];
				$lstatuss=$fieldT[$i] if $fieldT[$i];
				$familyids=$fieldPFI[$i] if $fieldPFI[$i];
				$lfathers=$fieldPAI[$i] if $fieldPAI[$i];
				$lmothers=$fieldPMI[$i] if $fieldPMI[$i];
				if ($fieldPNO[$i] =~ /^($l_species->{code})[0-9]+/ && ! $fieldPN[$i]) {
					next;
				} else {								
					queryPerson::delPatientPerson($buffer->dbh,$fieldI[$i],$fieldPI[$i]);
				}
				my $persname;
				$last_person_id=queryPerson::insertPerson($buffer->dbh,$fieldPN[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) if $fieldPN[$i];
				$last_person_id=queryPerson::insertPerson($buffer->dbh,'tempo_'.$PatName[$i],$lsexs,$lstatuss,$familyids,$lfathers,$lmothers,0) unless $fieldPN[$i];							
				$person_id=$last_person_id->{'LAST_INSERT_ID()'};
				unless ($fieldPN[$i]) {
					$persname=$l_species->{code}.sprintf("%010d", $person_id);
					queryPerson::upPersonName($buffer->dbh,$person_id,$persname);								
				}
				queryPerson::insertPatientPerson($buffer->dbh,$fieldI[$i],$person_id);
			}
		}
	}	
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("<b>Patient updated:</b> ".$listPatname);
}

sub UpPatientProjSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('run');
	my $pid = $cgi->param('project');
	my $projname = $cgi->param('projname');
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	
	my $listPatname= $cgi->param('PatNameSel');
	my @PatName = split(/,/,$listPatname);
	my $listChoice = $cgi->param('choice');
	my @fieldCh = split(/,/,$listChoice);
	my $notValid;
	my $Valid;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		my $res=test_patientProject($buffer,$PatName[$i],$projname);
		$notValid.="$PatName[$i]"."," if $res;
		$Valid.="$PatName[$i]"."," unless $res;
		
		if (@fieldCh[$i] eq "U") {
			queryPolyproject::upPatientProjectDest($buffer->dbh,@PatId[$i],$pid) unless $res;
		} elsif (@fieldCh[$i] eq "A") {
			my $last_patient_id=queryPolyproject::addPatientProjectDest($buffer->dbh,@PatName[$i],@PatName[$i],$runid,$pid) unless $res;
		}
	}
	chop($notValid);	
	chop($Valid);	
#### End Autocommit dbh ###########
	$dbh->commit();
	
	my $errorMessage="";
	$errorMessage="<br><b>Error Patients:</b> ".$notValid." already in ".$projname if $notValid;
	if 	($Valid) {
		sendOK("Target Project ".$projname." contains now Patients: ".$Valid.$errorMessage);
	} else {
		sendError($errorMessage);
	}
}

sub test_patientProject {
	my ($buffer,$patname,$projname) = @_;
	my $patInfoList = queryPolyproject::getPatNameInfo($buffer->dbh,$patname);
	foreach my $b (@$patInfoList){
		return 1 if $projname eq $b->{ProjName};
	}
}

sub upPatientIVSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatname= $cgi->param('name');
	my $listBCG= $cgi->param('iv');	
	
	my @PatName = split(/,/,$listPatname);
	my @BCG = split(/,/,$listBCG);

	my %seenP = ();
	my @duplicateP = map { 1==$seenP{$_}++ ? $_ : () } @PatName;
	if (scalar @duplicateP) {
		$dbh->commit();
		sendError("<B>Error Dulicated Patients:</B> @duplicateP");
	}

	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @BCG;

	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code : $messageduplicateB" if scalar @duplicateB;
	my $notValid;
	my $Valid;
	for (my $i = 0; $i< scalar(@PatName); $i++) {
		my $res=queryPolyproject::getPatIdfromName($buffer->dbh,@PatName[$i],$runid);
		$notValid.="@PatName[$i]"."," unless $res;
		$Valid.="@PatName[$i]"."," if $res;
		queryPolyproject::upPatientBCG($buffer->dbh,$res,@BCG[$i]) if $res;
	}
	chop($notValid);	
	chop($Valid);	
#### End Autocommit dbh ###########
	$dbh->commit();	
	my $errorMessage="";
	$errorMessage="<br><b>Error: Genotype Bar Code NOT updated for Patients:</b> ".$notValid." not in Run: ".$runid if $notValid;
	if 	($Valid) {
		sendOK("OK: Genotype Bar Code updated for Patients: ".$Valid. " in Run: ".$runid.$errorMessage.$messageduplicateB);
	} else {
		sendError($errorMessage);
	}
}

sub upPatientControlSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $control = $cgi->param('control');

	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;
		queryPolyproject::upPatientControl($buffer->dbh,$PatId[$i],$control);
	}
	chop $patname_chg;
#### End Autocommit dbh ###########
	my $mess;
	$mess="NOT " unless $control;
	$mess="" if $control;
	$dbh->commit();	
	sendOK("OK: Patients: ".$patname_chg. " are <b>$mess"."Patient Control</b>");
}

sub upPatientProfileSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $profileid = $cgi->param('profileid');
	my $profile;
	$profile = queryPolyproject::getProfile_byId($buffer->dbh,$profileid) if $profileid;
	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;
		queryPolyproject::upPatientProfile($buffer->dbh,$PatId[$i],$profileid);
	}
	chop $patname_chg;
#### End Autocommit dbh ###########
	$dbh->commit();
	my $f_profile="No Profile";
	$f_profile=$profile->[0]->{name} if $profile->[0]->{name};
	sendOK("OK: Patients: ".$patname_chg."<br> belong to Profile: <b>$f_profile</b>");
}

sub upPatientSpeciesSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $listPersid= $cgi->param('PersIdSel');
	my @PersId = split(/,/,$listPersid);
	my $species = $cgi->param('species');
	my $r_sp = queryPolyproject::getSpecies_FromName($buffer->dbh,$species);
	my $species_id= $r_sp->{species_id};
	my $code= $r_sp->{code};
	#warn Dumper $species_id;
	#warn Dumper $code;
	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		#warn Dumper $PatId[$i];
		#warn Dumper $PersId[$i];
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;
		queryPolyproject::upPatientSpecies($buffer->dbh,$PatId[$i],$species_id);
		my $r_pers = queryPerson::getPerson_fromId($buffer->dbh,$PersId[$i]);
		#warn Dumper $r_pers;
		#warn Dumper $r_pers->{name};
		if ($r_pers->{name} =~ m/^[A-Z]{2}[0-9]{10}$/) {
			#my (undef,$pid)=split(/[A-Z]{2}/,$r_pers->{name});
			my $persname=$code.sprintf("%010d", $PersId[$i]);		
			#warn Dumper $persname;			
			queryPerson::upPersonName($buffer->dbh,$PersId[$i],$persname);								
		}
	}
	chop $patname_chg;
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("OK: Patients: ".$patname_chg."<br> concern the species: <b>$species</b>");
}

sub upPatientCaptureSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $capName= $cgi->param('capture');
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $r_cap = queryPolyproject::getCaptureFromName($buffer->dbh,$capName);
	my $capid=$r_cap->{captureId};
	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;
		#warn Dumper $PatId[$i];
		queryPolyproject::upPatientCaptureOnly($buffer->dbh,$PatId[$i],$capid);
	}
	chop $patname_chg;
#### End Autocommit dbh ###########
	$dbh->commit();
#	sendOK("OK: Patients: ".$patname_chg);
	sendOK("OK: Patients: ".$patname_chg."<br> use the capture: <b>$capName</b>");
	
}


sub removePatientProjSection{
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $pid = $cgi->param('ProjSel');
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$pid);
	my $project = $buffer->newProject(-name => $projectname);
	die( "unknown project" . $pid ) unless $project->id();
	my $dir=$project->getProjectPath();
	my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$project->id());
	$dir =~ s/$rel\///;
#	$dir =~ s/HG[0-9]+\///;

	my $notDelPatname="";
	my $DelPatname="";
	
	for (my $i = 0; $i< scalar(@PatId); $i++) {
		my $patname = queryPolyproject::getPatientName($buffer->dbh,$PatId[$i]);
		my $resF=findFilesInProj($dir,$patname);
		queryPolyproject::remPatientProject($buffer->dbh,$PatId[$i]) unless $resF;
		$notDelPatname.=$patname."," if $resF;
		$DelPatname.=$patname."," unless $resF;
	}
	chop($notDelPatname);
	chop($DelPatname);
	if ($DelPatname) {
		$dbh->commit();
		if ($notDelPatname) {
			sendOK("<B>OK</B> Patients removed from project ".$projectname.": ".$DelPatname.
			       "<BR><B>But</B><BR>".
			       "<B>Error Patients:</B> ".$notDelPatname." not removed from project ".$projectname.
			       "<BR>Presence of Patient files in the project directory");	
			
		} else {
			sendOK("<B>OK</B> Patients removed from project ".$projectname.": ".$DelPatname);	
		}
	} else {
		$dbh->commit();
		sendError("<B>Error Patients:</B> ".$notDelPatname." not removed from project ".$projectname.
		"<BR>Presence of Patient files in the project directory");			
	}
}

sub findFilesInProj {
		my ($dir,$name) = @_;
		my $find_cmd =`find $dir -name '$name.*' -ls|grep -v tracking`;
		return 1 if $find_cmd;
		return 0 unless $find_cmd;
}

sub DelPatientSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatient = $cgi->param('PatSel');
	my @field = split(/,/,$listPatient);
	my $failedPat="";
	if($listPatient) {
		foreach my $u (@field) {
       		my $patientid = queryPolyproject::getFreePatientId($buffer->dbh,$runid, $u);
       		$failedPat.=$u."," unless exists $patientid->[0]->{patient_id};
		}
		chop($failedPat);
	}
	if($failedPat) {
### End Autocommit dbh ###########
		sendError("Patients Not deleted from run ID: ". $runid);
	} else {
		foreach my $v (@field) {
			my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$v);
			my $res_patpers=queryPerson::getPatientPerson_byPersonId($buffer->dbh,$res_pat->{person_id});	
			my $delpatientid = queryPolyproject::delFreePatientId($buffer->dbh,$runid, $v);			
			if (scalar(@$res_patpers)>1) {
				queryPerson::delPatientPerson($buffer->dbh,$v,$res_pat->{person_id});
			} else {
				my $delpersonid = queryPerson::delPersonId($buffer->dbh,$res_pat->{person_id});
				queryPerson::delPatientPerson($buffer->dbh,$v,$res_pat->{person_id});
				
			}
			queryPolyproject::delPatMeth($buffer->dbh, $v);
		}
		my $otherrunid = queryPolyproject::getRunIdfromPatient($buffer->dbh,$runid);		
		#Dans ce cas: Suppression en cascade dans run_method_seq, run_plateform,run_methods,run_machine
		queryPolyproject::delFreeRun($buffer->dbh,$runid) unless exists $otherrunid->[0]->{run_id};
		queryPolyproject::delFreeRunMethSeq($buffer->dbh,$runid) unless exists $otherrunid->[0]->{run_id};
		queryPolyproject::delFreeRunPlateform($buffer->dbh,$runid) unless exists $otherrunid->[0]->{run_id};
		queryPolyproject::delFreeRunMachine($buffer->dbh,$runid) unless exists $otherrunid->[0]->{run_id};

		my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runid);
		queryPolyproject::upNbPat2run($buffer->dbh,$runid,scalar(@$listPatRun));
		
#### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Patients deleted from run ID: ". $runid);	
	}
	exit(0);
}

sub RunPatientSection {
	my $runid = $cgi->param('RunSel');
    my $projid = $cgi->param('ProjSel');
 
	my $runListId = queryPolyproject::getPatientsInfoFromRun($buffer->dbh,$runid,$projid);
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
		$s{ProjectName} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id});
		$s{capName} = $c->{capName};
		$s{patientName} = $c->{name};
		$s{Sex} = $c->{sex};		
		$s{Status} = $c->{status};
		$s{desPat} = $c->{description};	
		$s{bc} = $c->{bar_code};		
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		$s{MethSnp}= queryPolyproject::getCallMethodNameFromPatient($buffer->dbh,$c->{patient_id});
		$s{MethAln}= queryPolyproject::getAlnMethodNameFromPatient($buffer->dbh,$c->{patient_id});
					
		if($s{ProjectId}==0 ) {
			$s{FreeRun}=1;
		} else {
			$s{FreeRun}=""
		}
		$s{FreeRun} = 3 unless ( $s{MethAln} );#blue => Plt Imagine
		$s{FreeRun} = 3 unless ( $s{MethSnp} );#blue => Plt Imagine
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub genomicRunPatientSection {
	my $runid = $cgi->param('RunSel');
	my $projid = $cgi->param('ProjSel');
	my $patid = $cgi->param('PatSel');
	my $selplt = $cgi->param('SelPlt');
# group "STAFF"
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	my $runListId = queryPerson::getPatientPersonInfoProjectDest($buffer->dbh,$runid,$projid);
	# In patient_person remove double patient_id for family_id=0
	my $res_dup=rem_dupPatientPerson($runListId);
	if ($res_dup) {
		$runListId = queryPerson::getPatientPersonInfoProjectDest($buffer->dbh,$runid,$projid);
	}
#	Not Used Here;
#	my $hash_pers;
	#foreach my $a (@$runListId){
	#	my %s;
	#	if (defined $patid) {
	#		next unless $patid==$a->{patient_id};
	#	}
	#	next if $a->{name} eq $a->{person};
	#	$hash_pers->{$a->{patient_id}." ".$a->{name}} = $a->{person} ;
	#}
	my $hash_opat;	
	foreach my $a (@$runListId){
		my %s;
		#warn Dumper "pat: $a->{name} $a->{patient_id} proj: $a->{project_id} run: $a->{run_id} --- $a->{origin_patient_id}" if $a->{origin_patient_id};# if $a->{patient_id};
		my $projectname = queryPolyproject::getProjectName($buffer->dbh,$a->{project_id}) if $a->{origin_patient_id};
		$hash_opat->{$a->{name}." ".$a->{run_id}} = $projectname  if $a->{origin_patient_id};
	}
	my @data;
	my %hdata;
	$hdata{identifier}="PatId";
	$hdata{label}="PatId";
	my $nbPatRun=0;
	foreach my $c (@$runListId){
		if (defined $patid) {
			next unless $patid==$c->{patient_id};
		}
		next if $c->{origin_patient_id};
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{PatId} = $c->{patient_id};
		$s{PatId} += 0;
		my $inf_species= queryPolyproject::getSpecies($buffer->dbh,$c->{species_id});
		$s{species}=join(" ",map{$_->{name}}@$inf_species) if defined $inf_species;		
		$s{sp}="";
		$s{sp}=join(" ",map{$_->{code}}@$inf_species) if defined $inf_species;		
		
		my $group= queryPolyproject::getPatientGroup($buffer->dbh,$c->{patient_id});
		$s{group} = $group->{name} if defined $group->{name};
		$s{group} = "" unless defined $group->{name};
		$s{ProjectCurrentId} = $c->{project_id};
		$s{ProjectId} = $c->{project_id_dest} if $c->{project_id_dest};
#		$s{ProjectId} = $c->{project_id} if (! $c->{project_id_dest} && $selplt);
		$s{ProjectId} = $c->{project_id} if (! $c->{project_id_dest});
		$s{ProjectId} += 0;
		$s{CaptureId} = $c->{capture_id};
		$s{CaptureId} += 0;
		$s{ProjectCurrentName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectCurrentId});
		$s{ProjectName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectId});
		
		$s{ProjectIdDest} = 0;
		$s{ProjectIdDest} = $c->{project_id_dest} if $c->{project_id_dest};
		$s{ProjectNameDest} = "";
		$s{ProjectNameDest} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id_dest}) if $c->{project_id_dest};
		my $cap = queryPolyproject::getCaptureName($buffer->dbh,$s{CaptureId});		
		$s{capName} = $cap->[0]->{capName};
		my $c_res = queryPolyproject::getCaptureId($buffer->dbh,$s{CaptureId});
		$s{capAnalyse}=$c_res->[0]->{capAnalyse};	
		my $caprel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$s{CaptureId});
		$s{capRel}=join(" ",map{$_->{name}}@$caprel) if defined $caprel ;
		$s{patientName} = $c->{name};
		$s{oproject} ="";
		$s{oproject} = $hash_opat->{$c->{name}." ".$c->{run_id}} if $hash_opat->{$c->{name}." ".$c->{run_id}};#copy patient in other project
		$s{family} = $c->{family};
		$s{father} = $c->{father};
		$s{mother} = $c->{mother};
		$s{type} = $c->{type};
		$s{Gproject} = "";
		$s{Gproject} = $c->{g_project} if $c->{g_project};
		my $super_unit = queryPolyproject::getCodeUnitFromTeamId($buffer->dbh,6);#BIP-D
		my $users = queryPolyproject::getUsersAllInfoFromProject($buffer->dbh,$s{ProjectCurrentId},$super_unit);		
		my $usergroupList = queryPolyproject::getUsersAndGroupsFromProject($buffer->dbh,$s{ProjectCurrentId},0,$super_grp);#0=>no groupid
		$s{UserGroups}="";
		$s{Users}="";
		my (@userAll,@usergroup,@user);
		@user=join(",",map{$_->{name}}@$users) if scalar(@$users);
		push(@userAll,@user);
		if (scalar(@$usergroupList)) {
			$s{UserGroups}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_->{group}=>1}@$usergroupList}};
			my @usercum;
			my %seenV;	
			foreach my $c (sort {lc $a->{name} cmp lc $b->{name}} @$usergroupList){
				push(@usercum,"$c->{name}:$c->{ugroup_id}") unless ($seenV{$c->{name}.":".$c->{ugroup_id}}++);
			}
			@usergroup=join ',',@usercum if scalar @usercum;
			push(@userAll,@usergroup);			
		}
		$s{Users}=join ',',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@userAll}};
		$s{Sex} = $c->{sex};		
		$s{Status} = $c->{status};
		$s{desPat} = $c->{description};	
		$s{bc} = $c->{bar_code};
		$s{bc2} = $c->{bar_code2};
		$s{iv} = "";	
		$s{iv} = $c->{identity_vigilance} if $c->{identity_vigilance};	
		$s{iv_vcf} = "";
		$s{iv_vcf} = $c->{identity_vigilance_vcf} if $c->{identity_vigilance_vcf};
		$s{control} = $c->{control};		
		#$s{control} += 0;
		$s{flowcell} = $c->{flowcell};
		# Machine
		$s{machine} = queryPolyproject::getSequencingMachines($buffer->dbh,$s{RunId});
		# Method seq
		$s{methseq} = queryPolyproject::getMethSeq($buffer->dbh,$s{RunId});
		my $plateformList = queryPolyproject::getPlateform($buffer->dbh,$s{RunId});	
		$s{Plateform}=join(" ",map{$_->{name}}@$plateformList);
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		$s{MethSnp}= queryPolyproject::getCallMethodNameFromPatient($buffer->dbh,$s{PatId});
		$s{MethAln}= queryPolyproject::getAlnMethodNameFromPatient($buffer->dbh,$s{PatId});

		# Other Methods from Pipeline Methods
		my $i_pipe = queryPolyproject::getOtherMethodsNameFromPatient($buffer->dbh,$s{PatId});
		$s{MethPipe} = $i_pipe->{meths};
		my $profiles;
		$s{profile}="";
		$profiles = queryPolyproject::getProfile_byId($buffer->dbh,$c->{profile_id}) if $c->{profile_id};
		$s{profile}=$profiles->[0]->{name} if $c->{profile_id};
		
		#Phenotype Patient
		my $patPhenotype = queryPolyproject::getPatientPhenotype($buffer->dbh,$s{PatId});
		$s{phenotype}="";		
		$s{phenotype}=join(",",map{$_->{name}}@$patPhenotype) if defined $patPhenotype;
		if(($s{ProjectId}==0) && ($s{ProjectCurrentId}==0)) {
			$s{FreeRun}=1;
		} else {
			$s{FreeRun}=""
		}
		$s{FreeRun} = 3 unless ( $s{MethAln} );#blue => Plt Imagine
		$s{FreeRun} = 3 unless ( $s{MethSnp} );#blue => Plt Imagine
		
		##### person ####
		$s{p_personId} = $c->{person_id};
		#warn Dumper $c->{person_id};
		$s{p_personId} += 0;
		$s{p_personName} = $c->{person};
		$s{p_familyId} = $c->{family_id};
		my $p_fam = queryPerson::getFamily($buffer->dbh,$c->{family_id});
		#warn Dumper $p_fam;
		$s{p_family} = $p_fam->{name};
		$s{p_fatherId} = $c->{father_id};
		#warn Dumper $c->{father_id};		
		my $p_fat = queryPerson::getPersonName_fromId($buffer->dbh,$c->{father_id});
		#warn Dumper $p_fat;
		$s{p_father} = $p_fat;
		
		$s{p_motherId} = $c->{mother_id};
		my $p_mot = queryPerson::getPersonName_fromId($buffer->dbh,$c->{mother_id});
		$s{p_mother} = $p_mot;
		$s{p_Sex} = $c->{esex};		
		$s{p_Status} = $c->{estatus};
		
		$s{major}="";
		my $mj = queryPerson::getMajorProject($buffer->dbh,$c->{major_project_id});
		$s{major}=$mj->{name} if $mj->{name};
		
		my @p_datec = split(/ /,$c->{eDate});
		my ($p_YY, $p_MM, $p_DD) = split("-", $p_datec[0]);
		my $p_mydate = sprintf("%02d/%02d/%4d",$p_DD, $p_MM, $p_YY);
		$s{p_Date} = $p_mydate;
		$nbPatRun++;
		push(@data,\%s);
	}
	queryPolyproject::upNbPat2run($buffer->dbh,$runid,$nbPatRun);
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub rem_dupPatientPerson {
	my ($runList) = @_;
	my $res=0;
	my %seen;
	my $hash_pid;
	foreach my $c (@$runList){
		$hash_pid->{$c->{patient_id}."-".$c->{person_id}."-".$c->{family_id}}=$c->{patient_id};
	}
	my %cpt;
	foreach my $val (values %$hash_pid) {
		$cpt{$val}++;
	}
	my %hash_dup;
	while (my ($cle, $valeur) = each %$hash_pid) {
		if ($cpt{$valeur} > 1) {
			$hash_dup{$cle} = $valeur;
		}
	}
	foreach my $key (sort{$a cmp $b} keys %hash_dup) {
		warn "Duplicate Patient_Person";
		my @sp_line = split(/-/,$key);
		#$sp_line[2]==0 => for family_id==0
		queryPerson::delPatientPerson($buffer->dbh,$sp_line[0],$sp_line[1]) if $sp_line[2]==0;
		$res=1 if $sp_line[2]==0;
	}
	return $res;
}

sub freeRunPatientSection {
	my $runid = $cgi->param('RunSel');
	my $runListId = queryPolyproject::getPatientProjectInfo($buffer->dbh,0,$runid);
	my @data;
	my %hdata;
	#$hdata{identifier}="RunId";
	$hdata{label}="RunId";
	foreach my $c (@$runListId){
		my $patid=$c->{patient_id};
		$patid += 0;
		my @methaln = queryPolyproject::getAlnMethodNameFromPatient($buffer->dbh,$patid);
		my $tmp_methaln=join(" ",map{$_}@methaln);
		next unless $tmp_methaln;
		
		my @methsnp = queryPolyproject::getCallMethodNameFromPatient($buffer->dbh,$patid);
		my $tmp_methsnp=join(" ",map{$_}@methsnp);
		next unless $tmp_methsnp;
		
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{PatId} = $c->{patient_id};
		$s{PatId} += 0;
		$s{family} = $c->{family};
		$s{desRun} = $c->{desRun};		
		$s{nameRun} = $c->{nameRun};		
		$s{patientName} = $c->{name};
		$s{projectid_dest} = $c->{project_id_dest};	
		$s{ProjectDestName}=queryPolyproject::getProjectName($buffer->dbh,$c->{project_id_dest});	
		$s{macName} = $c->{macName};
		$s{plateformName} = $c->{plateformName};
		$s{methAln}=$tmp_methaln;
		$s{methSnp}=$tmp_methsnp;
		$s{methSeqName} = $c->{methSeqName};
		$s{capName} = $c->{capName};
 		my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$s{PatId});
 		my $groupName = queryPolyproject::getGroupId($buffer->dbh,$groupid->[0]->{group_id}) if defined $groupid;
  		$s{group} =join(" ",map{$_->{groupName}}@$groupName);

		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		
		if($c->{project_id}==0 ) {
			$s{FreeRun}=1;
		} else {
			$s{FreeRun}=""
		}
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{RunId} <=> $a->{RunId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub selfreeRunPatientSection {
	my $runid = $cgi->param('RunSel');
	my $runListId = queryPolyproject::getPatientProjectRunInfo($buffer->dbh,0,$runid);
	my @data;
	my %hdata;
	$hdata{label}="RunId";
	foreach my $c (@$runListId){
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{desRun} = $c->{desRun};
		$s{nameRun}	 = $c->{name};
		$s{gMachine} = $c->{ident_seq};		
		$s{gRun} = $c->{nbrun_solid};		
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		my $patList = queryPolyproject::getPatientsInfoFromRun($buffer->dbh,$c->{run_id});
		my $pat = join(",",map{$_->{patient_id}}@$patList);
		my $nbpat = scalar (split(',',$pat));
		my $lnk = join(",",map{ if ($_->{project_id}!=0) {$_->{project_id}}}@$patList);
		$lnk =~ s/,,//g;
		$lnk =~ s/^,//;
		$lnk =~ s/,$//g;
		my $nblnk = scalar (split(',',$lnk));
		$s{Rapport}= "$nblnk"."/"."$nbpat";
		$s{FreeRun}= 1 if ( $nblnk == 0 );#red
		$s{FreeRun} = "" if ( $nblnk == $nbpat );#green
		$s{FreeRun} = 2 if ( $nblnk > 0 && $nblnk < $nbpat );#orange
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{RunId} <=> $a->{RunId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

###### Data Default ###################################################################
sub upDataDefaultSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $table = $cgi->param('table');
	my $idsel = $cgi->param('idSel');
		my @fieldId = split(/,/,$idsel);
	my $idval_p = $cgi->param('def_value');
	my $idval+= 0;
	$idval=1 if $idval_p eq "true";
	my $message_field="";
	for (my $i = 0; $i< scalar(@fieldId); $i++) {
			my $res="";
			if ($table eq "Plt") {
				$res = queryPolyproject::getPlateformId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{plateformName}.",";
				queryPolyproject::upPlateform_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "Mac") {
				$res = queryPolyproject::getMachineId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{macName}.",";
				queryPolyproject::upMachine_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "MSeq") {
				$res = queryPolyproject::getSeqMethodId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{methSeqName}.",";
				queryPolyproject::upMethSeq_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "MAln") {
				$res = queryPolyproject::getAlnMethodId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{methName}.",";
				queryPolyproject::upMethods_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "MCall") {
				$res = queryPolyproject::getCallMethodId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{methName}.",";
				queryPolyproject::upMethods_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "MCall") {
				$res = queryPolyproject::getCallMethodId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{methName}.",";
				queryPolyproject::upMethods_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "Rel") {
				$res = queryPolyproject::getReleaseId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{relName}.",";
				queryPolyproject::upRelease_default($buffer->dbh,$fieldId[$i],$idval);
			}			
			if ($table eq "Capd") {
				$res = queryPolyproject::getCaptureId($buffer->dbh,$fieldId[$i]);
				$message_field.=$res->[0]->{capName}.",";
				queryPolyproject::upCapture_default($buffer->dbh,$fieldId[$i],$idval);
			}			
	}
	chop $message_field;
### End Autocommit dbh ###########
	$dbh->commit();
	my $table_name="";
	$table_name="Plateform" if $table eq "Plt";
	$table_name="Sequencing Machine" if $table eq "Mac";
	$table_name="Method Seq" if $table eq "MSeq";
	$table_name="Methods" if $table eq "MAln";
	$table_name="Releases" if $table eq "Rel";
	$table_name="Capture System" if $table eq "Capd";
	my $message_def="";
	$message_def="seen as Default" if $idval_p eq "true";
	$message_def="Not seen as Default" if $idval_p eq "false";
	sendOK("OK: On table $table_name: $message_field $message_def");	
}


sub upExtractDefSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $year = $cgi->param('year');
	$year+=0;
	my $table = $cgi->param('table');
	my $analyse = $cgi->param('analyse');
	my $idsel = $cgi->param('idSel');
	my $idval_p = $cgi->param('def_value');
	my $idval+= 0;
	$idval=1 if $idval_p eq "true";
	my $numAnalyse;
	if ($analyse eq "target") {
		$numAnalyse=4;
	} elsif ($analyse eq "exome"){		
		$numAnalyse=2;
	}  elsif ($analyse eq "genome"){		
		$numAnalyse=3;
	}  elsif ($analyse eq "rnaseq"){		
		$numAnalyse=5;
	} elsif ($analyse eq "singlecell"){		
		$numAnalyse=6;
	} elsif ($analyse eq "amplicon"){		
		$numAnalyse=7;
	}
	if ($table eq "Plt") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_plt;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			my $numAnalyse = 1;
			my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
			next unless scalar @$patientList;
			my @plateformList= split(/ /, join(" ",map{$_->{plateformName}}@$patientList));
			foreach my $l (@plateformList){
				$hash_plt->{$l} = 1 unless $seen{$l}++;	
			}
		}
		my $relListAll = queryPolyproject::getPlateformId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_plt->{$c->{plateformName}}) {
				queryPolyproject::upPlateform_default($buffer->dbh,$c->{plateformId},$idval);
			}
		}			
	} elsif ($table eq "Mac") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_mac;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			my $numAnalyse = 1;
			my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
			next unless scalar @$patientList;
			my @macnameList= split(/ /, join(" ",map{$_->{macName}}@$patientList));
			foreach my $l (@macnameList){
				$hash_mac->{$l} = 1 unless $seen{$l}++;	
			}
		}
		my $relListAll = queryPolyproject::getMachineId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_mac->{$c->{macName}}) {
				queryPolyproject::upMachine_default($buffer->dbh,$c->{machineId},$idval);
			}
		}			
	} elsif ($table eq "MSeq") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_mseq;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			my $numAnalyse = 1;
			my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
			next unless scalar @$patientList;
			my @methseqList= split(/ /, join(" ",map{$_->{methSeqName}}@$patientList));
			foreach my $l (@methseqList){
				$hash_mseq->{$l} = 1 unless $seen{$l}++;	
			}
		}
		my $relListAll = queryPolyproject::getSeqMethodId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_mseq->{$c->{methSeqName}}) {
				queryPolyproject::upMethSeq_default($buffer->dbh,$c->{methodSeqId},$idval);
			}
		}			
	} elsif ($table eq "MAln") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_aln;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			my $numAnalyse = 1;
			my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
			next unless scalar @$patientList;
			my @alnList= split(/ /, join(" ",map{$_->{methAln}}@$patientList));
			foreach my $l (@alnList){
				$hash_aln->{$l} = 1 unless $seen{$l}++;	
			}
		}
		my $relListAll = queryPolyproject::getAlnMethodId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_aln->{$c->{methName}}) {
				queryPolyproject::upMethods_default($buffer->dbh,$c->{methodId},$idval);
			}
		}			
	}  elsif ($table eq "MCall") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_call;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			my $numAnalyse = 1;
			my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
			next unless scalar @$patientList;
			my @callList= split(/ /, join(" ",map{$_->{methCall}}@$patientList));
			foreach my $l (@callList){
				$hash_call->{$l} = 1 unless $seen{$l}++;	
			}
		}
		my $relListAll = queryPolyproject::getCallMethodId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_call->{$c->{methName}}) {
				queryPolyproject::upMethods_default($buffer->dbh,$c->{methodId},$idval);
			}
		}			
	} elsif ($table eq "Rel") {
		my $projList=queryPolyproject::getProjectAll($buffer->dbh);
		my %seen;
		my $hash_rel;		
		foreach my $c (@$projList){
			my $p_year= (split(/-/,$c->{cDate}))[0];
			$p_year+=0;
			next unless $p_year;
			next if ($p_year<$year);
			$hash_rel->{$c->{relname}} = 1 unless $seen{$c->{relname}}++;
		}
		my $relListAll = queryPolyproject::getReleaseId($buffer->dbh);
		foreach my $c (@$relListAll){
			if (! $hash_rel->{$c->{relName}}) {
				queryPolyproject::upRelease_default($buffer->dbh,$c->{releaseId},$idval);
			}
		}		
	} elsif ($table eq "Capd"){
		my @fieldId = split(/,/,$idsel);
		my $res="";
		for (my $i = 0; $i< scalar(@fieldId); $i++) {
			my $res = queryPolyproject::getCaptureId($buffer->dbh,$fieldId[$i]);
			queryPolyproject::upCapture_default($buffer->dbh,$fieldId[$i],$idval);
		}							
	}				
### End Autocommit dbh ###########
	$dbh->commit();
	my $table_name="";
	$table_name="Plateform" if $table eq "Plt";
	$table_name="Sequencing Machine" if $table eq "Mac";
	$table_name="Method Seq" if $table eq "MSeq";
	$table_name="Methods" if $table eq "MAln";
	$table_name="Methods" if $table eq "MCall";
	$table_name="Releases" if $table eq "Rel";
	$table_name="Capture System" if $table eq "Capd";
	my $message_def="";
	my $message_table="";
	
	$message_def="seen as Default" if $idval==1;
	$message_def="Not seen as Default" if $idval==0;
	$year="" unless $year;	
	$message_table="for $analyse analysis, Selected Exon Captures from Project" if $table eq "Capd";
	$message_table.=" after" if ($table eq "Capd" && $year);
	$message_table="Release from Project after" if $table eq "Rel";
	$message_table="Plateform from Project after" if $table eq "Plt";
	$message_table="Machine from Project after" if $table eq "Mac";
	$message_table="Sequencing Methods from Project after" if $table eq "MSeq";
	$message_table="Alignment Methods from Project after" if $table eq "MAln";
	$message_table="Calling Methods from Project after" if $table eq "MCall";
	sendOK("OK: On table $table_name, $message_table $year $message_def") if $year;
	sendOK("OK: On table $table_name, $message_table $message_def") unless $year;

}

###### Plateform ###################################################################
sub PlateformSection {
#	my $def = $cgi->param('default');
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub PlateformNameSection {
	my $plateformListId = queryPolyproject::getPlateformId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$plateformListId){
		my %s;
		$s{plateformId} = $c->{plateformId};
		$s{plateformId} += 0;
		$s{value} = $c->{plateformName};
		$s{name} = $c->{plateformName};
		push(@data,\%s);
	}
	my @result_sorted=sort { $a->{name} cmp $b->{name} } @data;
	$hdata{items}=\@result_sorted;
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	my @result_sorted=sort { lc($a->{macName}) cmp lc($b->{macName}) } @data;
#	$hdata{items}=\@data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub MachineNameSection {
	my $machineListId = queryPolyproject::getMachineId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="name";
	foreach my $c (@$machineListId){
		my %s;
		#next if $c->{macName}== "ROCHE";
		$s{machineId} = $c->{machineId};
		$s{machineId} += 0;
		$s{value} = $c->{macName};
		$s{macName} = $c->{macName};
		$s{macType} = $c->{macType};
		$s{name} = $c->{macName}." | type: ".$c->{macType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newMachineSection {
### Autocommit dbh ###########
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
sub ReleasedefSection {
	my $relListAll = queryPolyproject::getReleasedefId($buffer->dbh);	
	my @data;
	my %hdata;
	$hdata{identifier}="releaseId";
	$hdata{label}="relName";
#	$hdata{label}="releaseId";
	foreach my $c (@$relListAll){
		next if $c->{relName} eq "MM38-GFP-TOMATO";
		my %s;
		$s{releaseId} = $c->{releaseId};
		$s{releaseId} += 0;
		$s{relName} = $c->{relName};
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub ReleaseSection {
	my $hascapture = $cgi->param('hascapture');
	my $relListAll = queryPolyproject::getReleaseId($buffer->dbh);
	my @rel_19_38; 
	foreach my $c (@$relListAll){
		next unless ($c->{relName} =~ m/(HG18)|(HG19)|(HG38)/) ;
		push(@rel_19_38,$c);
	}
	my @relOther;
	foreach my $c (@$relListAll) {
		next unless ($c->{relName} !~ m/(HG18)|(HG19)|(HG38)/) ;
		push(@relOther,$c);
	}
	my @result_sortedOther=sort { $b->{releaseId} <=> $a->{releaseId}}@relOther;
	my @join_relList=@rel_19_38;
	push(@join_relList,@result_sortedOther);
	my @data;
	my %hdata;
	$hdata{identifier}="relName";
	$hdata{label}="relName";
	foreach my $c (@join_relList){
		my %s;
		if ($hascapture) {
			my $caprel=queryPolyproject::getCapture_fromReleaseId($buffer->dbh,$c->{releaseId});
			next unless $caprel->[0]->{capture_id};
		}
		$s{releaseId} = $c->{releaseId};
		$s{releaseId} += 0;
		$s{speciesId} = $c->{species_id};
		$s{speciesId} += 0;
		my $inf_species= queryPolyproject::getSpecies($buffer->dbh,$c->{species_id});
		$s{sp}="";
		$s{sp}=join(" ",map{$_->{code}}@$inf_species) if defined $inf_species;				
		$s{relName} = $c->{relName};
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub ReleaseRefSection {
	my $relListAll = queryPolyproject::getReleaseIdRef($buffer->dbh);
	my @rel_19_38; 
	foreach my $c (@$relListAll){
		next unless ($c->{relName} =~ m/(HG19)|(HG38)/) ;
		push(@rel_19_38,$c);
	}
	my @relOther;
	foreach my $c (@$relListAll) {
		next unless ($c->{relName} !~ m/(HG18)|(HG19)|(HG38)/) ;
		push(@relOther,$c);
	}
	my @result_sortedOther=sort { $b->{releaseId} <=> $a->{releaseId}}@relOther;
	my @join_relList=@rel_19_38;
	push(@join_relList,@result_sortedOther);
	
	my @data;
	my %hdata;
	$hdata{identifier}="relName";
	$hdata{label}="relName";
        	foreach my $c (@join_relList){
		my %s;
		$s{releaseId} = $c->{releaseId};
		$s{releaseId} += 0;
		$s{relName} = $c->{relName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub AlnNameSection {
	my $metListId = queryPolyproject::getAlnMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{value} = $c->{methName};
		$s{name} = $c->{methName};
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub CallNameSection {
	my $metListId = queryPolyproject::getCallMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{value} = $c->{methName};
		$s{name} = $c->{methName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub OtherMethodSection {
	my $metListId = queryPolyproject::getOtherMethodId($buffer->dbh);
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub OtherNameSection {
	my $metListId = queryPolyproject::getOtherMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{value} = $c->{methName};
		$s{name} = $c->{methName};
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

sub addNewAlnCallingSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $typeMeth=$cgi->param('Type');
	my $runid = $cgi->param('RunSel');
	my $gmachine = $cgi->param('gmachine');
	my $grun = $cgi->param('grun');	
	my $ListPat = $cgi->param('PatSel');	
	my $gMeth_name = $cgi->param('Mcall');
	my @fieldP = split(/,/,$ListPat);
	my $valid="";
	foreach my $u (@fieldP) {
		my $validMeth="";
		if ($gMeth_name) {
			my @ListMeth = split(/,/,$gMeth_name);
			foreach my $m (@ListMeth) {
				my $method_call;
				$method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$m,"SNP") if ($typeMeth eq "SNP");
				$method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$m,"ALIGN") if ($typeMeth eq "ALIGN");
				my $ctrl_call= queryPolyproject::ctrlPatMeth($buffer->dbh, $u, $method_call->{id});
				$validMeth.=$method_call->{id}."," if ($method_call && ! $ctrl_call);
			}
		}
		chop($validMeth);		
		if ($gMeth_name) {
			my @ListMeth = split(/,/,$validMeth);
			foreach my $m (@ListMeth) {
				queryPolyproject::addMeth2pat($buffer->dbh,$u,$m);
			}
		}
		$valid.=$validMeth.',';
	}
	$valid=~ s/,//g;
	sendError("No Method Added" ) unless $valid;	
	queryPolyproject::upgRun($buffer->dbh, $runid, $gmachine, $grun) unless ($gmachine eq 'undefined');;
	
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);	
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
		$s{def} = $c->{def};
		push(@data,\%s);
	}
	my @result_sorted=sort { lc($a->{methSeqName}) cmp lc($b->{methSeqName}) } @data;
#	$hdata{items}=\@data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub SeqMethodNameSection {
	my $mseqListId = queryPolyproject::getSeqMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$mseqListId){
		my %s;
		$s{methodSeqId} = $c->{methodSeqId};
		$s{methodSeqId} += 0;
		$s{value} = $c->{methSeqName};
		$s{name} = $c->{methSeqName};
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

########### Group #########################################################
sub groupNameSection {
	my $groupListId = queryPolyproject::getGroupId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$groupListId){
		my %s;
		$s{groupId} = $c->{group_id};
		$s{groupId} += 0;
		$s{value} = $c->{groupName};
		$s{name} = $c->{groupName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###### Capture ####################################################################

sub CaptureAnalyseSection {
	my $capid = $cgi->param('capid');
	my $captureListId = queryPolyproject::getCaptureId($buffer->dbh,$capid);
	my @data;
	my %hdata;
	$hdata{identifier}="capAnalyse";
	$hdata{label}="capAnalyse";
	my %seen;
	foreach my $c (@$captureListId){
		my %s;
		$s{capAnalyse} = $c->{capAnalyse};
		push(@data,\%s) unless $seen{$s{capAnalyse}}++;
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub CaptureValAnalyseSection {
	my $capid = $cgi->param('capid');
	my $captureListAllId = queryPolyproject::getCaptureId($buffer->dbh,$capid);
	my @capNoTargetListId;
	my %seenA;
	foreach my $c (@$captureListAllId){
		next unless $c->{capAnalyse};
		if ($c->{capAnalyse}  =~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/) {
			push(@capNoTargetListId,$c) unless $seenA{$c->{capAnalyse}}++;
		}
	}
	my @capTarget;# for target analysis
	my %htab=('capAnalyse' => 'target','capVs' => 1,'capDes' => '','capFile' => '','captureId' => 9999,'capMeth' => '','capFilePrimers' => '','capName' => '','capType' => '','capValidation' => '');
	push(@capTarget,\%htab);
	my @capTargetListId;
	my %seenB;
	foreach my $c (@$captureListAllId){
		next unless $c->{capAnalyse};
		if ($c->{capAnalyse}  !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/) {
			push(@capTargetListId,$c) unless $seenB{$c->{capAnalyse}}++;
		}
	}
	my @sorted_capTargetListId=sort { uc($a->{capAnalyse}) cmp uc($b->{capAnalyse}) } @capTargetListId;
	my @join_captureListId=@capNoTargetListId;
	push(@join_captureListId,@capTarget);
	push(@join_captureListId,@sorted_capTargetListId);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="label";
	foreach my $c (@join_captureListId){
		my %s;
		if ($c->{capAnalyse}  =~ m/(exome)/) {
			$s{label} = "<a style='background:#66CC00'>".$c->{capAnalyse}."</a>";
		} elsif ($c->{capAnalyse}  =~ m/(genome)/) {
			$s{label} = "<a style='background:#FFFF00'>".$c->{capAnalyse}."</a>";			
		} elsif ($c->{capAnalyse}  =~ m/(rnaseq)/) {
			$s{label} = "<a style='background:#6666FF'>".$c->{capAnalyse}."</a>";			
		} elsif ($c->{capAnalyse}  =~ m/(singlecell)/) {
			$s{label} = "<a style='background:#33CCFF'>".$c->{capAnalyse}."</a>";			
		} elsif ($c->{capAnalyse}  =~ m/(amplicon)/) {
			$s{label} = "<a style='background:#F18973'>".$c->{capAnalyse}."</a>";			
		} elsif ($c->{capAnalyse}  =~ m/(other)/) {
			$s{label} = "<a style='background:#618685'>".$c->{capAnalyse}."</a>";			
		} elsif ($c->{capAnalyse}  =~ m/(target)/) {
			$s{label} = "<a style='background:#009966'>".$c->{capAnalyse}."</a>";			
		} else {
			$s{label} = $c->{capAnalyse};
		}
		$s{value} = $c->{capAnalyse};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub CaptureNameSection {
	my $captureListId = queryPolyproject::getCaptureId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$captureListId){
		my %s;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{caprel}="";
		my $rel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$c->{captureId});
		$rel=join(" ",map{$_->{name}}@$rel) if defined $rel ;
		$s{caprel}=$rel if defined $rel;
		$s{value} = $c->{capName};
		$s{name} = $c->{capName}." | ".$s{caprel}." | vs:".$c->{capVs}." | ".$c->{capDes};
		$s{capVs} = $c->{capVs};
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{capVs} <=> $a->{capVs} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

#not used
sub CaptureInfoSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $caprel = $cgi->param('caprel');
	my $RelInfo= queryPolyproject::getReleaseFromName($buffer->dbh,$caprel);
	my $relids;
	$relids=$RelInfo->[0]->{release_id};
	if ($RelInfo->[0]->{name} =~ /^HG19/ && $RelInfo->[0]->{name} ne "HG19") {
		$RelInfo= queryPolyproject::getReleaseFromName($buffer->dbh,"HG19");
		$relids=$relids.",".$RelInfo->[0]->{release_id};
	} elsif ($RelInfo->[0]->{name} =~ /^HG38/ && $RelInfo->[0]->{name} ne "HG38") {
		$RelInfo= queryPolyproject::getReleaseFromName($buffer->dbh,"HG38");
		$relids=$relids.",".$RelInfo->[0]->{release_id};
	}
	my $r_cap;
	if (scalar(split(/,/,$relids))>1) {
		my $p_rel= (split(/,/,$relids))[0];
		my $p_cap = queryPolyproject::getCaptureFromRelease($buffer->dbh,$p_rel);	
		my $h_rel= (split(/,/,$relids))[1];
		my $h_cap = queryPolyproject::getCaptureFromRelease($buffer->dbh,$h_rel);
		#merge
		@$r_cap=(@$p_cap,@$h_cap);
	} else {
		$r_cap = queryPolyproject::getCaptureFromRelease($buffer->dbh,$relids);			
	}
	my @data;
	my %hdata;
	$hdata{identifier}="capName";
	$hdata{label}="capName";
	foreach my $c (@$r_cap){
		my %s;
		if ($numAnalyse ==1 ) {
#all #no filter
		} elsif ($numAnalyse ==2 ) {
#exome
			next unless $c->{analyse} eq "exome"
		} elsif ($numAnalyse ==3 ) {
#genome
			next unless $c->{analyse} eq "genome"
		} elsif ($numAnalyse ==4 ) {
#panel
			next unless $c->{analyse} !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/
		} elsif ($numAnalyse ==5 ) {
#rnaseq
			next unless $c->{analyse} eq "rnaseq"
		} elsif ($numAnalyse ==6 ) {
#singlecell
			next unless $c->{analyse} eq "singlecell"
		} elsif ($numAnalyse ==7 ) {
#amplicon
			next unless $c->{analyse} eq "amplicon"
		} elsif ($numAnalyse ==8 ) {
#other
			next unless $c->{analyse} eq "other"
		}				
		$s{captureId} = $c->{capture_id};
		$s{captureId} += 0;
		$s{capName} = $c->{name};
		my $r_rel=queryPolyproject::getReleaseId($buffer->dbh,$c->{release_id});
		$s{rel} =  $r_rel->[0]->{relName};
		$s{def} =  $c->{def};
		$s{capDes} =  $c->{description};
		$s{capAnalyse} = $c->{analyse};
		$s{capValidation} = $c->{validation_db};
		unless ($c->{capValidation}) {$s{capValidation} =""};
		$s{capFilePrimers} = $c->{primers_filename};
		$s{capPrimers} = $c->{filename};
		unless ($c->{capFilePrimers}) {$s{capFilePrimers} =""};
		$s{capVs} = $c->{version};
		$s{capType} = $c->{type};
#		$s{capD} = $c->{type};
		my @datec = split(/ /,$c->{creation_date});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = ""; 
		$s{cDate} = $mydate unless ($mydate =~ "00/00/   0");
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub captureByAnalyseSection {
	my $analyse = $cgi->param('analyse');
	my $species = $cgi->param('species');
	my $capList;
	my $def=1;
	$capList = queryPolyproject::get_Capture($buffer->dbh,$def,$analyse,$species);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$capList){
		my %s;
		$s{captureId} = $c->{capture_id};
		$s{captureId} += 0;
		$s{caprel}= $c->{capRel};
		$s{species}= $c->{Species};
		$s{umi}= "";
		$s{umi}= "UMI: ".$c->{UMI}." |" if $c->{UMI};
		$s{value} = $c->{capture_id};
#		$s{name} = $c->{Capture}." | ".$s{species}." | ".$s{caprel}." | ".$s{umi};
		$s{name} = $c->{capture_id}." | ".$c->{Capture}." | ".$s{species}." | ".$s{caprel}." | ".$s{umi};
		$s{hidename} = $c->{Capture};
		push(@data,\%s);
	}
	my @result_sorted=sort { "\L$a->{hidename}" cmp "\L$b->{hidename}"} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

#not used
sub CaptureNameRefSection {
	my $captureListId = queryPolyproject::getCaptureId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$captureListId){
		my %s;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{caprel}="";
		my $rel = queryPolyproject::getReleaseRefFromCapture($buffer->dbh,$c->{captureId});
		$rel=join(" ",map{$_->{reference}}@$rel) if defined $rel ;
		$s{caprel}=$rel if defined $rel;
		$s{value} = $c->{capName};
		$s{name} = $c->{capName}." | ".$s{caprel}." | vs:".$c->{capVs}." | ".$c->{capDes};
		$s{capVs} = $c->{capVs};
		$s{capVs} += 0;
		push(@data,\%s);
	}
	my @result_sorted=sort { "\L$a->{value}" cmp "\L$b->{value}" || $b->{capVs} <=> $a->{capVs}} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub CaptureTypeSection {
	my $captureTypeList = queryPolyproject::getAllCaptureType($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$captureTypeList){
		my %s;
		next unless $c->{capType};
		$s{value} = $c->{capType};
		$s{name} =  $c->{capType};
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{name} <=> $a->{name} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub CaptureMethSection {
	my $captureListMeth= queryPolyproject::getAllCaptureMethod($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="capmeth";
#	$hdata{identifier}="value";
	foreach my $c (@$captureListMeth){
		my %s;
		next unless $c->{capMeth};
		$s{capmeth} = $c->{capMeth};
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{capmeth} <=> $a->{capmeth} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub CaptureMethNameSection {
	my $captureListMeth= queryPolyproject::getAllCaptureMethod($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$captureListMeth){
		my %s;
		next unless $c->{capMeth};
		$s{name} = $c->{capMeth};
		$s{value} = $s{name};
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{name} <=> $a->{name} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub lastCaptureSection {
	my $lastCaptureId = queryPolyproject::getLastCapture($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="capture_id";
	$hdata{label}="capture_id";
	foreach my $c (@$lastCaptureId){
		my %s;
		$s{capture_id} = $c->{capture_id};
		$s{capture_id} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub captureProjectSection {
	my $year = $cgi->param('year');
	$year+=0;
	my $analyse = $cgi->param('analyse');
	my $numAnalyse;
	if ($analyse eq "target") {
		$numAnalyse=4;
	} elsif ($analyse eq "exome"){		
		$numAnalyse=2;
	}  elsif ($analyse eq "genome"){		
		$numAnalyse=3;
	}  elsif ($analyse eq "rnaseq"){		
		$numAnalyse=5;
	} elsif ($analyse eq "singlecell"){		
		$numAnalyse=6;
	} elsif ($analyse eq "amplicon"){		
		$numAnalyse=7;
	}
	my $projList=queryPolyproject::getProjectAll($buffer->dbh);
	my %seen;
	my $hash_cap;		
	foreach my $c (@$projList) {
		my $p_year= (split(/-/,$c->{cDate}))[0];
		$p_year+=0;
		if (defined $year) {
			next unless $p_year;
			next if ($p_year<$year);			
		}
		my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
		next unless scalar @$patientList;
		my @captureList= split(/ /, join(" ",map{$_->{capName}}@$patientList));
		foreach my $l (@captureList){
			$hash_cap->{$l} = 1 unless $seen{$l}++;	
		}
	}
	my $relListAll = queryPolyproject::getCaptureBundleInfo($buffer->dbh,$numAnalyse) if $numAnalyse;
	my @data;
	my %hdata;
	$hdata{identifier}="captureId";
	$hdata{label}="captureId";
	foreach my $c (@$relListAll){	
		if ( $hash_cap->{$c->{capName}}) {
			my $rel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$c->{captureId});
			$rel=join(" ",map{$_->{name}}@$rel) if defined $rel ;
			next unless $rel;		
			my %s;
			$s{captureId} = $c->{captureId};
			$s{captureId} += 0;
			$s{capName} = $c->{capName};
			$s{capAnalyse} = $c->{capAnalyse};
			$s{rel} = $rel;
			my @datec = split(/ /,$c->{cDate});
			my ($YY, $MM, $DD) = split("-", $datec[0]);
			my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
			$s{cDate} = ""; 
			$s{cDate} = $mydate unless ($mydate =~ "00/00/   0");
			push(@data,\%s);
		}
	}						
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###### Umi ####################################################################
sub UmiSection {
	my $umiListId = queryPolyproject::getUmiId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="umiName";
	$hdata{label}="umiName";
	foreach my $c (@$umiListId){
		my %s;
		$s{umiId} = $c->{umi_id};
		$s{umiId} += 0;
		$s{umiName} = $c->{name};
		$s{umiMask} = $c->{mask};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub umiNameSection {
	my $umiListId = queryPolyproject::getUmiId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$umiListId){
		my %s;
		$s{umiId} = $c->{umi_id};
		$s{umiId} += 0;
		$s{value} = $c->{name};
		$s{mask} = $c->{mask};
		$s{name} = $s{umiId}." | ".$c->{name}." | ".$c->{mask};				
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newUmiSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
		my $umi = $cgi->param('umi');
		my $mask = $cgi->param('mask');
		$mask =~ s/!/;/g;
        my $r_umi = queryPolyproject::getUmiFromName($buffer->dbh,$umi);
 		if (exists $r_umi ->{umi_id}) {
			sendError("UMI Name: " . $umi ."...". " already in UMI database");
		} else 	{
### End Autocommit dbh ###########
			queryPolyproject::newUMIData($buffer->dbh,$umi,$mask);
			$dbh->commit();
			sendOK("OK : UMI created: ". $umi);	
		}
}
###### Perspective ####################################################################
sub PerspectiveSection {
	my $persListId = queryPolyproject::getPerspectiveId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="persName";
	$hdata{label}="persName";
	foreach my $c (@$persListId){
		my %s;
		$s{persId} = $c->{perspective_id};
		$s{persId} += 0;
		$s{persName} = $c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newPerspectiveSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $perspective = $cgi->param('perspective');
        my $perspectiveid = queryPolyproject::getPerspectiveFromName($buffer->dbh,$perspective);
#        warn Dumper $perspectiveid;
		if (exists $perspectiveid ->{id}) {
			sendError("Perspective Name: " . $perspective ."...". " already in Perspective database");
		} else 	{
### End Autocommit dbh ###########
			my $myperspectiveid = queryPolyproject::newPerspectiveData($buffer->dbh,$perspective);
			$dbh->commit();
			sendOK("Persective created: ". $perspective);	
		}
		exit(0);
}
###### Technology ####################################################################
sub TechnologySection {
	my $techListId = queryPolyproject::getTechnologyId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="techName";
	$hdata{label}="techName";
	foreach my $c (@$techListId){
		my %s;
		$s{techId} = $c->{technology_id};
		$s{techId} += 0;
		$s{techName} = $c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newTechnologySection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $technology = $cgi->param('technology');
        my $technologyid = queryPolyproject::getPerspectiveFromName($buffer->dbh,$technology);
#        warn Dumper $perspectiveid;
		if (exists $technologyid ->{id}) {
			sendError("Technology Name: " . $technology ."...". " already in Technology database");
		} else 	{
### End Autocommit dbh ###########
			my $mytechnologyid = queryPolyproject::newTechnologyData($buffer->dbh,$technology);
			$dbh->commit();
			sendOK("Technology created: ". $technology);	
		}
		exit(0);
}
###### Preparation ####################################################################
sub PreparationSection {
	my $prepListId = queryPolyproject::getPreparationId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="prepName";
	$hdata{label}="prepName";
	foreach my $c (@$prepListId){
		my %s;
		$s{prepId} = $c->{preparation_id};
		$s{prepId} += 0;
		$s{prepName} = $c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newPreparationSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $preparation = $cgi->param('preparation');
        my $preparationid = queryPolyproject::getPreparationFromName($buffer->dbh,$preparation);
#        warn Dumper $perspectiveid;
		if (exists $preparationid ->{id}) {
			sendError("Preparation Name: " . $preparation ."...". " already in Preparation database");
		} else 	{
### End Autocommit dbh ###########
			my $mypreparationid = queryPolyproject::newPreparationData($buffer->dbh,$preparation);
			$dbh->commit();
			sendOK("Preparation created: ". $preparation);	
		}
		exit(0);
}

###### Validation ####################################################################

 sub dropValidationDB {
	my ($name_DB) = @_;
	queryValidationDB::dropSchemasValidation($buffer->dbh,$name_DB) or 
	die "SchemasValidation not dropped";
 }
 
 sub createValidationDB {
	my ($name_DB) = @_;
	queryValidationDB::createSchemasValidation($buffer->dbh,$name_DB) or 
	die "SchemasValidation not created";
	queryValidationDB::createExonValidation($buffer->dbh,$name_DB) or 
	die "ExonValidation not created";         
 }

###### Bundle ########################################################################
sub BundleSection {
	my $bunid = $cgi->param('BunSel');
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);
	my @data;
	my %hdata;
	$hdata{identifier}="bundleId";
	$hdata{label}="bunName";
	foreach my $c (@$bundleList){
		my %s;
		$s{bundleId} = $c->{bundleId};
		$s{bundleId} += 0;
		$s{bunName} = $c->{bunName};
		$s{bunDes} =  $c->{bunDes};
		$s{bunVs} = $c->{bunVs};
		$s{meshid} = $c->{meshid};
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		my $cap = queryPolyproject::getBundleCapture($buffer->dbh,$c->{bundleId});
		$s{capName}=join(" ",map{$_->{name}}@$cap);
		$s{capType}=join(" ",map{$_->{type}}@$cap);
		my %seenM =();
		my @uniqueM= grep { ! $seenM{$_->{method}}++ } @$cap;
		$s{capMeth}=join(" ",map{$_->{method}}@uniqueM);
		my %seen = ();
		my @unique= grep { ! $seen{$_->{validation_db}}++ } @$cap;
		$s{capValidation}=join(" ",map{$_->{validation_db}}@unique);
		$s{capValidation} =~ s/^\s+//;
		#flagCap 
		$s{flagCap}=1 unless ( scalar(@$cap)>0);#red
		$s{flagCap}=0 if ( scalar(@$cap)>0);#green
		# A faire flagTrans
		my $bundleTransIdList = queryPolyproject::getBundleTranscriptId($buffer->dbh,$s{bundleId});
		$s{nbTr}=scalar(@$bundleTransIdList);
		$s{flagTr}=1 unless (scalar(@$bundleTransIdList)>0);#red
		$s{flagTr}=0 if (scalar(@$bundleTransIdList)>0);#green
		$s{flagGn}=0;#green
		$s{flagGn}=1 unless $s{nbTr};#red
		if (scalar(@$bundleTransIdList)>0) {
			my $cpt=0;
			foreach my $t (@$bundleTransIdList){
				my $tr=queryPolyproject::getTranscript($buffer->dbh,$t->{transcript_id});
				if (exists $tr->[0]->{id}) {
					$s{flagGn}=1 unless $tr->[0]->{gene};#red
				}
				$cpt++;
				last if ($cpt > 5000);				
			}
		}
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{bundleId} <=> $a->{bundleId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub lastBundleSection {
	my $lastBundleId = queryPolyproject::getLastBundle($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="bundle_id";
	$hdata{label}="bundle_id";
	foreach my $c (@$lastBundleId){
		my %s;
		$s{bundle_id} = $c->{bundle_id};
		$s{bundle_id} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub BundleCapSection {
	my $capid = $cgi->param('CapSel');
	my $exclude= $cgi->param('exclude');
	my $bundleList = queryPolyproject::getBundleFromCapture($buffer->dbh,$capid,$exclude);
	my @data;
	my %hdata;
#	$hdata{identifier}="bunName";
	$hdata{identifier}="bundleId";
	$hdata{label}="bunName";
	foreach my $c (@$bundleList){
		my %s;
		$s{bundleId} = $c->{bundleId};
		$s{bundleId} += 0;
		$s{bunName} = $c->{bunName};
		$s{bunDes} =  $c->{bunDes};
		$s{bunVs} = $c->{bunVs};
		$s{meshid} = $c->{meshid};
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		$s{capName} = $c->{capName};
		$s{capType} = $c->{capType};
		$s{capMeth} = $c->{capMeth};
		$s{capValidation} = $c->{capValidation};
		my $val= $s{bundleId};
		my $valB=0;
		my $res_bunrelgen = queryPolyproject::searchBundleReleaseGene($buffer->dbh,$val,$valB);
		my @all_res=map{$_->{name}}@$res_bunrelgen if scalar @$res_bunrelgen;
		$s{relGene}="";
		$s{relGene}=max @all_res if scalar @$res_bunrelgen;
		$s{flagCap}=1 unless ($s{capName});#red
		$s{flagCap}=0 if ($s{capName});#green
		# 
		my $bundleTransIdList = queryPolyproject::getBundleTranscriptId($buffer->dbh,$s{bundleId});
		$s{nbTr}=scalar(@$bundleTransIdList);
		$s{flagTr}=1 unless (scalar(@$bundleTransIdList)>0);#red
		$s{flagTr}=0 if (scalar(@$bundleTransIdList)>0);#green
		$s{flagGn}=0;#green
		$s{flagGn}=1 unless $s{nbTr};#red
		if (scalar(@$bundleTransIdList)>0) {
			my $cpt=0;
			foreach my $t (@$bundleTransIdList){
				my $tr=queryPolyproject::getTranscript($buffer->dbh,$t->{transcript_id});
				if (exists $tr->[0]->{id}) {
					$s{flagGn}=1 unless $tr->[0]->{gene};#red
				}
				$cpt++;
				last if ($cpt > 5000);				
			}
		}
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{bundleId} <=> $a->{bundleId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub BundleTranscriptsSection {
	my $bunid = $cgi->param('BunSel');
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);
	my @data;
	my %hdata;
	$hdata{identifier}="transcriptId";
	foreach my $c (@$bundleList){
		my $bundleTransIdList = queryPolyproject::getBundleTranscriptId($buffer->dbh,$bunid);
		if (exists $bundleTransIdList->[0]->{transcript_id}) {
			foreach my $t (@$bundleTransIdList){
				my %s;
				my $TranscriptList = queryPolyproject::getTranscript($buffer->dbh,$t->{transcript_id});
				next unless exists $TranscriptList->[0]->{id};
				$s{bundleId} = $c->{bundleId};
				$s{bundleId} += 0;
				$s{bunName} = $c->{bunName};
				$s{transcriptId} = $TranscriptList->[0]->{id};
				$s{transcriptId} += 0;
				$s{ensemblId} = $TranscriptList->[0]->{ensembl_id};
				$s{gene} = $TranscriptList->[0]->{gene};
				$s{transmission} = $TranscriptList->[0]->{transmission};
				my $tr = queryPolyproject::getBundleTranscriptId($buffer->dbh,$bunid,$TranscriptList->[0]->{id});
				$s{buntransmission} = $tr->[0]->{transmission};
				$s{flagGn}=1 unless ($s{gene});#red
				$s{flagGn}=0 if ($s{gene});#green
				push(@data,\%s);
			}
		};
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub AddCapturebundleSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bunid = $cgi->param('BunSel');
	my @ListBunid = split(/,/,$bunid);
	my $captureid = $cgi->param('captureid');
	my @ListCapture = split(/,/,$captureid);
	my $allbundle="";
	my $allcapture="";
	foreach my $b (@ListBunid) {
			my $bundle = queryPolyproject::getBundle($buffer->dbh,$b);
			$allbundle.=$bundle->[0]->{bunName}.',';
			$allcapture="";
			foreach my $t (@ListCapture) {
				my $capture = queryPolyproject::getCaptureName($buffer->dbh,$t);
				$allcapture.=$capture->[0]->{capName}.',';
				queryPolyproject::newBundleCapture($buffer->dbh,$t,$b);				
			}
	}
	chop($allbundle);
	chop($allcapture);
	$dbh->commit();
	sendOK("Successful validation for Bundles : ". $allbundle. " with Capture: ".$allcapture);	
}

sub RemCapturebundleSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bunid = $cgi->param('BunSel');
	my @ListBunid = split(/,/,$bunid);
	my $captureid = $cgi->param('CapSel');
	my $capture = queryPolyproject::getCaptureName($buffer->dbh,$captureid);	
	my $bunList;
	for (my $i = 0; $i< scalar(@ListBunid); $i++) {
		my $bundle= queryPolyproject::getBundle($buffer->dbh,@ListBunid[$i]);
		$bunList.=$bundle->[0]->{bunName}.",";
		queryPolyproject::delBundleCapture($buffer->dbh,$captureid,@ListBunid[$i]);
	}
	chop($bunList);
	$dbh->commit();
	sendOK("Bundles: ". $bunList. " remove from Capture: ".$capture->[0]->{capName});	
}

sub newBundle2CaptureSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bundle = $cgi->param('bundle');
	my $bunDes = $cgi->param('bunDes');
	my $bunVs = $cgi->param('bunVs');
	my $meshid = $cgi->param('meshid');
	my $capid = $cgi->param('capid');
	my $bunrg = $cgi->param('bunRG');
	
	my $bundleid = queryPolyproject::getBundleFromName($buffer->dbh,$bundle);
	if (exists $bundleid ->{bundleId}) {
		sendError("Bundle Name: " . $bundle ."...". " already in Bundle database");
	} else 	{
### End Autocommit dbh ###########
		my $last_bundleid = queryPolyproject::newBundle($buffer->dbh,$bundle,$bunVs,$bunDes,$meshid);
		queryPolyproject::newBundleCapture($buffer->dbh,$capid,$last_bundleid->{'LAST_INSERT_ID()'}) if defined $last_bundleid;				
		my $relGene_id;
		$relGene_id=queryPolyproject::get_relGeneIdfromName($buffer->dbh,$bunrg) if $bunrg;
		queryPolyproject::addBundleReleaseGene($buffer->dbh,$last_bundleid->{'LAST_INSERT_ID()'},$relGene_id) if $bunrg;
		$dbh->commit();
		sendOK("Bundle : ". $bundle ." is created...");	
	}
	exit(0);
}

sub upBundleSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bunid = $cgi->param('BunSel');
	my $bundle = $cgi->param('bundle');
	my $bunDes = $cgi->param('bunDes');
	my $bunVs = $cgi->param('bunVs');
	my $meshid = $cgi->param('meshid');
	my $bunrg = $cgi->param('bunRG');

	my @fieldI = split(/,/,$bunid);
	my @fieldB = split(/,/,$bundle);
	my @fieldV = split(/,/,$bunVs);
	my @fieldD = split(/,/,$bunDes);
	my @fieldM = split(/,/,$meshid);
	my @fieldR = split(/,/,$bunrg);
	
### End Autocommit dbh ###########
	for (my $i = 0; $i< scalar(@fieldI); $i++) {
		queryPolyproject::upBundleData($buffer->dbh,@fieldI[$i],@fieldB[$i],@fieldV[$i],@fieldD[$i],@fieldM[$i]);
		my $relGene_id;
		$relGene_id=queryPolyproject::get_relGeneIdfromName($buffer->dbh,@fieldR[$i]) if @fieldR[$i];
		my $res_bunGene;
		$res_bunGene=queryPolyproject::isBundleReleaseGene($buffer->dbh,@fieldI[$i],$relGene_id);
		queryPolyproject::addBundleReleaseGene($buffer->dbh,@fieldI[$i],$relGene_id) unless $res_bunGene->{bundle_id};
	}
	$dbh->commit();
	sendOK("Bundle: ". $bundle. " is updated");	
	exit(0);
}

sub relGeneNameSection {
	my $relGeneList = queryPolyproject::getReleaseGeneId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$relGeneList){
		my %s;
		next unless $c->{rel_gene_id}>0;
		$s{relGeneId} = $c->{rel_gene_id};
		$s{relGeneId} += 0;
		$s{value} = $c->{relgeneName};
		$s{name} = $c->{relgeneName};
#		$s{name} = $c->{relgeneName}."|".$c->{rel_gene_id};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###### Transcripts  ########################################################################
sub addTranscriptsSection {
	# for newProject()
	my $buffer = GBuffer->new();
	
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $relgene = $cgi->param('relgene');
	my $bunid = $cgi->param('BunSel');
	my $transcript = $cgi->param('transcript');
	my $transmission = $cgi->param('transmission');
	my $tmod  = $cgi->param('Tmod');
	my $btmod  = $cgi->param('BTmod');
	my $upload  = $cgi->param('upload');
	my $invalidTranscript="";
	my @ListTranscript = split(/,/,$transcript);
	my @ListTransmission = split(/,/,$transmission);
	my @ListTrId;
	for (my $i = 0; $i< scalar(@ListTranscript); $i++) {
		my $transcriptid = queryPolyproject::getTranscriptId($buffer->dbh,@ListTranscript[$i]);
		unless ($transcriptid) {
			my $last_transcript_id=queryPolyproject::newTranscriptData($buffer->dbh,@ListTranscript[$i],@ListTransmission[$i],$tmod);
			$transcriptid = $last_transcript_id->{'LAST_INSERT_ID()'};
		}
		push(@ListTrId,$transcriptid);
		if ($transcriptid) {
			#queryPolyproject::upTranscriptTransmission($buffer->dbh,$transcriptid,$ListTransmission[$i]) if $tmod;
			my $Btr=queryPolyproject::getBundleTranscriptId($buffer->dbh,$bunid,$transcriptid);
			if (exists $Btr->[0]->{transcript_id}) {
				queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bunid,$transcriptid,$ListTransmission[$i]) if $btmod;
				queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bunid,$transcriptid,) unless $btmod;
				$invalidTranscript.= $ListTranscript[$i].",";
				next;
			}
		}
		queryPolyproject::newBundleTranscript($buffer->dbh,$transcriptid,$bunid,$ListTransmission[$i],$btmod);
	}
	my $ll=join(",",@ListTrId);
	my $sql1 = qq{SELECT ENSEMBL_ID FROM PolyprojectNGS.transcripts WHERE ID in ($ll)};
	my $prep = $dbh->prepare($sql1);
	$prep->execute();
	my @trs =keys %{$prep->fetchall_hashref('ENSEMBL_ID')};

	my $projectname;
	$projectname = lastProjectRelGene($relgene) if $relgene;
	$projectname = lastExomeProject() unless $projectname;
	my $project = $buffer->newProject(-name=>$projectname);
	$project->gencode_version($relgene) if $relgene;
	
	foreach my $tr_name (@trs){
		eval {
			my $tr1 = $project->newTranscript($tr_name);
			my $gname = $tr1->getGene()->external_name();
			my $sql = qq{update PolyprojectNGS.transcripts SET GENE='$gname' where ENSEMBL_ID='$tr_name'};
			$dbh->do($sql);
		}		
	} 
	my $sql2 = qq{SELECT ENSEMBL_ID FROM PolyprojectNGS.transcripts WHERE GENE="" OR GENE IS NULL;};
	my $prep2 = $dbh->prepare($sql2);
	$prep2->execute();
	my @trs2 =keys %{$prep2->fetchall_hashref('ENSEMBL_ID')};
	foreach my $tr_name (@trs2){
		eval {
			my $tr1 = $project->newTranscript($tr_name);
			my $gname = $tr1->getGene()->external_name();
			my $sql = qq{update PolyprojectNGS.transcripts SET GENE='$gname' where ENSEMBL_ID='$tr_name'};
			$dbh->do($sql);
		}		
	} 
### End Autocommit dbh ###########
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);
	my $noGeneTranscriptList = queryPolyproject::controleEmptyGeneFromBundleTranscript($buffer->dbh,$bunid);		
	$dbh->commit();
	if ($invalidTranscript) {
		chop($invalidTranscript);
		$invalidTranscript= "<br><b>But</b> Transcripts already seen: ".$invalidTranscript;
	}
	if ($noGeneTranscriptList->[0]->{trId}) {
		$noGeneTranscriptList= "<br><b>WARNING:</b> Transcripts ID list with no Gene annotated:<br>".$noGeneTranscriptList->[0]->{trId};
	} else {
		$noGeneTranscriptList= "";
	}
	sendOK("Successful validation for Transcripts of Bundle : ". $bundleList->[0]->{bunName}.$invalidTranscript.$noGeneTranscriptList) unless $upload;	
	sendFormOK("Successful validation for Transcripts of Bundle : ". $bundleList->[0]->{bunName}.$invalidTranscript.$noGeneTranscriptList) if $upload;	
	exit(0);
}

sub lastProjectRelGene {
	my ($relgene)=@_;
	my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
	my $last_pid=$lastProjectId->[0]->{project_id};
	$last_pid += 0;
	my $projectname;
	my $count=0;
	while (1) {
		$projectname = queryPolyproject::getProjectName($buffer->dbh,$last_pid);
		my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$last_pid);
		if ($rel =~ "HG19") {
			my @d_relGene=queryPolyproject::getReleaseGeneFromProjects($buffer->dbh,$last_pid);	
			if ($d_relGene[0]==$relgene) {
				my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$last_pid);
				return $projectname if $patientsP->[0]->{name};
			}
		}
		$last_pid--;
		if ($count>20) {last};
		$count++;
	}
}

sub lastExomeProject {
	my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
	my $last_pid=$lastProjectId->[0]->{project_id};
	#warn Dumper $last_pid;
	#$last_pid=4371;
	$last_pid += 0;
	my $projectname;
	my $count=0;
	while (1) {
		$projectname = queryPolyproject::getProjectName($buffer->dbh,$last_pid);
		my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$last_pid);
		if ($rel =~ "HG19") {
			my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$last_pid);
			return $projectname if $patientsP->[0]->{name};
		}
		$last_pid--;
		if ($count>20) {last};
		$count++;
	}
}

sub upTranscriptsSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bunid = $cgi->param('BunSel');
	my $transcriptid = $cgi->param('transcriptId');
	my $transmission = $cgi->param('transmission');
	my $btransmission = $cgi->param('btransmission');
	my @fieldI = split(/,/,$transcriptid);
	my @fieldT = split(/,/,$transmission);
	my @fieldB = split(/,/,$btransmission);
	for (my $i = 0; $i< scalar(@fieldI); $i++) {
		unless(defined @fieldT[$i]) {@fieldT[$i]=""};
		queryPolyproject::upTranscriptTransmission($buffer->dbh,@fieldI[$i],@fieldT[$i]);
		if(defined @fieldB[$i]) {
			queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bunid,@fieldI[$i],@fieldB[$i]);
		};
	}	
### End Autocommit dbh ###########
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);		
	$dbh->commit();
	sendOK("Successful validation for Transcripts of Bundle : ". $bundleList->[0]->{bunName});	
}

sub delTranscriptsSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $bunid = $cgi->param('BunSel');
	my $transcriptid = $cgi->param('transcriptId');
	my @fieldI = split(/,/,$transcriptid);
	my $ListDelTranscript="";
	for (my $i = 0; $i< scalar(@fieldI); $i++) {
		my $tr=queryPolyproject::getTranscript($buffer->dbh, @fieldI[$i]);
		$ListDelTranscript.=$tr->[0]->{ensembl_id}.',';
		queryPolyproject::removeBundleTranscript($buffer->dbh, $bunid,@fieldI[$i]);
		queryPolyproject::delTranscript($buffer->dbh,@fieldI[$i]) unless $tr->[0]->{gene};
	}	
### End Autocommit dbh ###########
	chop($ListDelTranscript);
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);		
	$dbh->commit();
	sendOK("Transcripts :<b>".$ListDelTranscript."</b> deleted from Bundle : ". $bundleList->[0]->{bunName});	
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
		$s{Group} = "";
		my $group_info = queryPolyproject::getGroupInfoFromUser($buffer->dbh,$c->{UserId});
		$s{Group} = join(" ",map{$_->{name}}@$group_info) if $group_info;
		$s{Code} = $c->{Code};
		$s{Team} = $c->{Team};
		$s{Site} = $c->{Site};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub UserListSection {
	my $usite = $cgi->param('uniqSite');
	my $uunit = $cgi->param('uniqUnit');
	
	my $userList = queryPolyproject::getUserInfo($buffer->dbh);
	my @data;
	my %hdata;
#	$hdata{identifier}="UserId";
	$hdata{label}="Name";
	my %seen;
	foreach my $c (@$userList){
		my %s;
		if (defined $usite) { 
			$s{Name} = $c->{Site} ;
			push(@data,\%s) unless $seen{$s{Name}}++
		};
		
		if (defined $uunit) { 
			$s{Name} = $c->{Code} ;
			push(@data,\%s) unless $seen{$s{Name}}++
		};
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub UserProjectSection {
	my $projid = $cgi->param('ProjSel');
	my $nogroup=$cgi->param('nogroup');
	my $super_unit = queryPolyproject::getCodeUnitFromTeamId($buffer->dbh,6);#bip-d
# group "STAFF"
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	my $row=0;
	my $userList = queryPolyproject::getUsersAllInfoFromProject($buffer->dbh,$projid,$super_unit);
	my @dataU=buildList($row,$userList);
	my $usergroupList = queryPolyproject::getUsersAndGroupsFromProject($buffer->dbh,$projid,0,$super_grp);#0=>no groupid
	my @dataG;
	@dataG=buildList($row,$usergroupList) unless $nogroup;
	
	my @dataA=(@dataU,@dataG);
	$row=1;
	my @dataF=buildList($row,\@dataA);

	my %hdata;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	$hdata{items}=\@dataF;
	printJson(\%hdata);
	
}

sub buildList {
	my ($row,$list)=@_;
	my @datas;
	foreach my $c (@$list){
		my %s;
		$s{Row} = $row++ if $row;
		$s{UserId} = $c->{UserId};
		$s{UserId} += 0;
		$s{name} = $c->{name};
		$s{Firstname} = $c->{Firstname};
		$s{Email} = $c->{Email};
		$s{unit} = $c->{unit};
		$s{organisme} = $c->{organisme};
		$s{site} = $c->{site};
		$s{Director} = $c->{Director};
		$s{Team} = $c->{Team};
		$s{Responsable} = $c->{Responsable};
		$s{group} ="";
		$s{group} = $c->{group} if $c->{group};	
		push(@datas,\%s);
	}
	return @datas;
}

sub UserIdProjectSection {
	my $projid = $cgi->param('project');
	my $userIdList = queryPolyproject::getUserIdFromProject($buffer->dbh,$projid);
	my @data;
	my %hdata;
	$hdata{identifier}="UserId";
	$hdata{label}="UserId";
	foreach my $c (@$userIdList){
		my %s;
		$s{UserId} = $c->{user_id};
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
	my @fieldP = split(/,/,$projid );	
	
	my @fieldG;
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	push(@fieldG,$super_grp) if $super_grp;
	
	my $allUser="";
	foreach my $p (@fieldP) {
		my $ctrlGP=queryPolyproject::isGroupProject($buffer->dbh,$super_grp,$p);
		queryPolyproject::addGroup2project($buffer->dbh,$super_grp,$p) unless  $ctrlGP->{ugroup_id};
		foreach my $u (@field) {
			my $userid = queryPolyproject::addUser2project($buffer->dbh, $u, $p);
			$allUser.=$userid;
		}		
	}
	if ($allUser =="") {
		
		sendError("Error: ID Projects : $projid already belong to User's number: $listUser");
#		sendError("User number: " . $listUser . " already linked to project ID: " . $projid);
	} else {
### End Autocommit dbh ###########
		$dbh->commit();
#		sendOK("ok: Projects $allProj belong to Group User $allGrp");			
		sendOK("ok: Id Projects $projid belong to User $listUser");			
#		sendOK("Successful validation for project ID: ". $projid);	
	}
	exit(0);
}

sub removeUserProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listUser = $cgi->param('User');
	my @field = split(/,/,$listUser);
	if($listUser) {
		foreach my $u (@field) {
			my $userid = queryPolyproject::delUser2project($buffer->dbh, $u, $projid);
		}
	}
	if($listUser) {
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Users removed from project ID: ". $projid);	
	} else {
		sendError("Users Not removed from project ID: ". $projid);
	}
	exit(0);
}

sub removeUserForAllProjectsSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $userId = $cgi->param('User');
	my $res_u = queryPolyproject::getUserInfoFromId($buffer->dbh,$userId);
	queryPolyproject::removeUserAllProjects($buffer->dbh,$userId);
	$dbh->commit();
	sendOK("User $userId $res_u->[0]->{Name} $res_u->[0]->{Firstname} removed from All projects");	
}

#################### ugroup user ##################
sub ugroupSection {
	my $groupList = queryPolyproject::getUgroupId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="groupId";
	$hdata{label}="groupId";
	foreach my $c (@$groupList){
		my %s;
		$s{groupId} = $c->{UGROUP_ID};
		$s{groupId} += 0;
		$s{group} = $c->{NAME};
		$s{bt} = $s{groupId}."#".$s{group};
		push(@data,\%s);
	}
	my @data_sorted=sort { $a->{group} cmp $b->{group}} @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);
	exit(0);
}

sub userGroupSection {
	my $ugroupId = $cgi->param('GrpSel');
	my $usergroupList = queryPolyproject::getUserGroupInfoFromUgroup($buffer->dbh,$ugroupId);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$usergroupList){
		my %s;
		$s{Row} = $row++;
		$s{UserId} = $c->{user_id};
		$s{UserId} += 0;
		$s{Name} = $c->{name};
		$s{Firstname} = $c->{Firstname};
		$s{Group} = $c->{group};
		$s{GroupId} = $c->{ugroup_id};
		$s{GroupId} += 0;
		$s{Code} = $c->{unit};
		$s{Organisme} = $c->{organisme};
		$s{Site} = $c->{site};
		$s{Team} = $c->{Team};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub UserGroupProjectSection {
	my $projid = $cgi->param('ProjSel');
	my $userList = queryPolyproject::getUsersGroupFromProject($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	my %seen=();
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$userList){
		my %s;
		next unless $c->{ugroup_id};
		$s{Row} = $row++;
		$s{GroupId} = $c->{ugroup_id};
		$s{GroupId} += 0;
		$s{Group} ="";
		$s{Group} = $c->{group} if $c->{group};
#		push(@data,\%s);
		push(@data,\%s) unless ($seen{$s{UserId}."_".$s{GroupId}}++);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

# a supprimer
sub addUserGroupProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listGroup = $cgi->param('GrpSel');

	my @field = split(/,/,$listGroup);
	my @fieldP = split(/,/,$projid );	
	my (%seenG);
	my $allProj="";
	my $allGrp="";
	my $ok;
	my $op="add"; # for add
	foreach my $p (@fieldP) {
		my $projectname = queryPolyproject::getProjectName($buffer->dbh,$p);
		foreach my $g (@field) {
			my $g_info = queryPolyproject::getUgroupId($buffer->dbh,$g);
			$allGrp.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
			$allProj.=$projectname.",";
			$ok=updateUserProjectFromGroup($g,$p,$op);
		}		
	}
	chop($allProj,$allGrp);
	unless ($ok) {
		sendError("Error: Projects : $allProj already belong to Group User $allGrp");
	} else {
 ### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("ok: Projects $allProj belong to Group User $allGrp");			
	}		
}

sub addProject2GroupSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listGroup = $cgi->param('GrpSel');

	my @field = split(/,/,$listGroup);
	my @fieldP = split(/,/,$projid );	
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	push(@field,$super_grp) if $super_grp;
	my (%seenG);
	my $allProj="";
	my $allGrp="";
	my $ok;
	my $op="add"; # for add
	foreach my $p (@fieldP) {
		my $projectname = queryPolyproject::getProjectName($buffer->dbh,$p);
		foreach my $g (@field) {
			my $g_info = queryPolyproject::getUgroupId($buffer->dbh,$g);
			$allGrp.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
			$allProj.=$projectname.",";
			$ok=updateProjectForGroup($g,$p,$op);
		}		
	}
	chop($allProj,$allGrp);
	unless ($ok) {
		sendError("Error: Projects : $allProj already belong to Group User $allGrp");
	} else {
 ### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("ok: Projects $allProj belong to Group User $allGrp");			
	}		
}

sub updateProjectForGroup {
	my ($groupid,$projectid,$op) = @_; 
	my $ok=0;
	my $g_info = queryPolyproject::getUgroupId($buffer->dbh,$groupid);
	my $isStaff=0;
	$isStaff=1 if $g_info->[0]->{'NAME'} eq "STAFF";	
	my $ctrlGP=queryPolyproject::isGroupProject($buffer->dbh,$groupid,$projectid);
	if ($op eq "add") {
		return $ok=1 if ($ctrlGP->{ugroup_id} && $isStaff);
		return $ok if ($ctrlGP->{ugroup_id});
		queryPolyproject::addGroup2project($buffer->dbh, $groupid,$projectid);
	}
	if ($op eq "rem") {
		return $ok unless $ctrlGP->{ugroup_id};
		queryPolyproject::delGroup2project($buffer->dbh, $groupid,$projectid);
	}
	return $ok=1;					
}

# a supprimer
sub updateUserProjectFromGroup {
	my ($groupid,$projectid,$op) = @_;
	my $r_user=queryPolyproject::getUserIdFromGroup($buffer->dbh,$groupid);	
	my $ok=0;
	foreach my $u (@$r_user) {
		my $ctrlUGP=queryPolyproject::isUserGroupProject($buffer->dbh,$u->{user_id},$groupid,$projectid);
		my $ctrlUP=queryPolyproject::isUserProject($buffer->dbh,$u->{user_id},$projectid);
		if ($op eq "add") {
			unless ($ctrlUGP->{ugroup_id}) {
				if ($ctrlUP->{user_id}) {
					queryPolyproject::upUserGroup2project($buffer->dbh, $u->{user_id},$groupid,$projectid)
				} else {
					queryPolyproject::addUserGroup2project($buffer->dbh, $u->{user_id},$groupid,$projectid)				
				}
				$ok++;
			}
		}
		if ($op eq "rem") {
			if ($ctrlUGP->{ugroup_id}) {
				queryPolyproject::delUserGroup2project($buffer->dbh, $u->{user_id},$groupid,$projectid);			
				$ok++;
			}
		}
	}
	return $ok;	
}

sub remProject2GroupSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listGroup = $cgi->param('GrpSel');

	my @field = split(/,/,$listGroup);
	my @fieldP = split(/,/,$projid );	
	my (%seenG);
	my $allProj="";
	my $allGrp="";
	my $ok;
	my $op="rem"; # for remove
	foreach my $p (@fieldP) {
		my $projectname = queryPolyproject::getProjectName($buffer->dbh,$p);
		foreach my $g (@field) {
			my $g_info = queryPolyproject::getUgroupId($buffer->dbh,$g);
			$allGrp.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
			$ok=updateProjectForGroup($g,$p,$op);
			$allProj.=$projectname."," if $ok;
			
		}
	}
	chop($allProj,$allGrp);
	if ($allProj eq "") {
		sendError("Error: No Group User $allGrp removed from projects");
	} else {	### End Autocommit dbh ###########
	$dbh->commit();
		sendOK("ok: Group User $allGrp remuved from Projects $allProj");
	}		
}

# a suppimer 
sub remUserGroupProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listGroup = $cgi->param('GrpSel');

	my @field = split(/,/,$listGroup);
	my @fieldP = split(/,/,$projid );	
	my (%seenG);
	my $allProj="";
	my $allGrp="";
	my $ok;
	my $op="rem"; # for remove
	foreach my $p (@fieldP) {
		my $projectname = queryPolyproject::getProjectName($buffer->dbh,$p);
		foreach my $g (@field) {
			my $g_info = queryPolyproject::getUgroupId($buffer->dbh,$g);
			$allGrp.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
			$ok=updateUserProjectFromGroup($g,$p,$op);
			$allProj.=$projectname."," if $ok;
			
		}
	}
	chop($allProj,$allGrp);
	if ($allProj eq "") {
		sendError("Error: No Group User $allGrp removed from projects");
	} else {	### End Autocommit dbh ###########
	$dbh->commit();
		sendOK("ok: Group User $allGrp remuved from Projects $allProj");
	}		
}

###### UNITE bipd_users ######################################################################
sub DirectorNameSection {
	my $DirectorList = queryPolyproject::getDirectorInfo($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="label";
	$hdata{identifier}="value";
	foreach my $c (@$DirectorList){
		my %s;
		$s{value} = $c->{unite_id} += 0;
		$s{label} = "$c->{directeur}($c->{code_unite}) | $c->{site}";
		$s{site} = $c->{site};
		$s{directeur} = $c->{directeur};
		push(@data,\%s);
	}
	my @result_sorted=sort {$a->{site} cmp $b->{site}||lc($a->{directeur}) cmp lc($b->{directeur})} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
	
}

sub UnitNameSection {
	my $DirectorList = queryPolyproject::getDirectorInfo($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="value";
	$hdata{identifier}="name";
	foreach my $c (@$DirectorList){
		my %s;
		$s{value} = $c->{unite_id} += 0;
		#$s{label} = "$c->{directeur}($c->{code_unite}) | $c->{site}";
		$s{site} = $c->{site};
		$s{unit} = $c->{code_unite};
		$s{name} = $c->{code_unite}." ".$c->{site};
		push(@data,\%s);
	}
	my @result_sorted=sort {lc($b->{site}) cmp lc($a->{site}) ||lc($a->{unit}) cmp lc($b->{unit})} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);	
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

# person
sub PatientProjectSection {
	my $projid = $cgi->param('ProjSel');
	my $patientList = queryPerson::getPatientPersonProjectInfo($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	my $projname=queryPolyproject::getProjectName($buffer->dbh,$projid);
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$patientList){
		my %s;
		$s{Row} = $row++;
		$s{patientName} = $c->{name};
		$s{PatId} = $c->{patient_id};
		my $inf_species= queryPolyproject::getSpecies($buffer->dbh,$c->{species_id});
		$s{species}=join(" ",map{$_->{name}}@$inf_species) if defined $inf_species;		
		$s{sp}="";
		$s{sp}=join(" ",map{$_->{code}}@$inf_species) if defined $inf_species;		
		$s{ProjectName} = $projname;
		$s{ProjectIdDest} = $c->{project_id_dest};
		$s{ProjectNameDest} = "";
		$s{ProjectNameDest} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id_dest}) if $c->{project_id_dest};
		my $group= queryPolyproject::getPatientGroup($buffer->dbh,$c->{patient_id});
		$s{group} = $group->{name} if defined $group->{name};
		$s{group} = "" unless defined $group->{name};
		$s{family} = $c->{family};
		$s{father} = $c->{father};
		$s{mother} = $c->{mother};
		$s{Sex} = $c->{sex};
		$s{Status} = $c->{status};
		$s{type} = $c->{type};
		$s{bc} = $c->{bar_code};
		$s{bc2} = $c->{bar_code2};
		$s{iv} = "";	
		$s{iv} = $c->{identity_vigilance} if $c->{identity_vigilance};	
		$s{iv_vcf} = "";	
		$s{iv_vcf} = $c->{identity_vigilance_vcf} if $c->{identity_vigilance_vcf};
		$s{grna} = "";	
		$s{grna} = $c->{grna} if $c->{grna};
		$s{control} = $c->{control};
		$s{flowcell} = $c->{flowcell};		
		$s{RunId} = $c->{run_id};
		$s{nameRun} = $c->{nameRun};		
		$s{desRun} = $c->{desRun};		
		$s{macName} = $c->{macName};
		$s{plateformName} = $c->{plateformName};
		$s{Gproject} = "";
		$s{Gproject} = $c->{g_project} if $c->{g_project};

		my $methaln = queryPolyproject::getnewAlnMethodName($buffer->dbh,$s{RunId},$projid,$s{PatId});
		$s{methAln}=join(" ",map{$_->{methAln}}@$methaln);

		my $methsnp = queryPolyproject::getnewCallMethodName($buffer->dbh,$s{RunId},$projid,$s{PatId});
		$s{methSnp}=join(" ",map{$_->{methCall}}@$methsnp);
				
		my $methpipe = queryPolyproject::getnewPipeMethodName($buffer->dbh,$s{RunId},$projid,$s{PatId});
		$s{methPipe}=join(" ",map{$_->{methPipe}}@$methpipe);

		$s{methSeqName} = $c->{methSeqName};
		$s{capName} = $c->{capName};
		$s{capAnalyse} = $c->{capAnalyse};

		my $profiles;
		$s{profile}="";
		$profiles = queryPolyproject::getProfile_byId($buffer->dbh,$c->{profile_id}) if $c->{profile_id};
		$s{profile}=$profiles->[0]->{name} if $c->{profile_id};
# Uniquement les patients malades		
		$s{phenotype}="";
		my $patPhenotype = queryPolyproject::getPatientPhenotype($buffer->dbh,$c->{patient_id});
		$s{phenotype}=join(",",map{$_->{name}}@$patPhenotype) if defined $patPhenotype;		
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		$s{FileName} = $c->{FileName};
		$s{FileType} = $c->{FileType};
		##### person ####
		$s{p_personId} = $c->{person_id};
		$s{p_personId} += 0;
		$s{p_personName} = $c->{person};
		$s{p_familyId} = $c->{family_id};
		my $p_fam = queryPerson::getFamily($buffer->dbh,$c->{family_id});
		$s{p_family} = $p_fam->{name};
		$s{p_fatherId} = $c->{father_id};
		my $p_fat = queryPerson::getPersonName_fromId($buffer->dbh,$c->{father_id});
		$s{p_father} = $p_fat;
		
		$s{p_motherId} = $c->{mother_id};
		my $p_mot = queryPerson::getPersonName_fromId($buffer->dbh,$c->{mother_id});
		$s{p_mother} = $p_mot;
		$s{p_Sex} = $c->{esex};		
		$s{p_Status} = $c->{estatus};		
		#major_project_id
		$s{major}="";
		my $mj = queryPerson::getMajorProject($buffer->dbh,$c->{major_project_id});
		$s{major}=$mj->{name} if $mj->{name};
		
		my @p_datec = split(/ /,$c->{eDate});
		my ($p_YY, $p_MM, $p_DD) = split("-", $p_datec[0]);
		my $p_mydate = sprintf("%02d/%02d/%4d",$p_DD, $p_MM, $p_YY);
		$s{p_Date} = $p_mydate;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub genomicPatientProjectDestSection {
	my $selDateBegin = $cgi->param('USDate_B');
	my $selDateEnd = $cgi->param('USDate_E');

	my $projid= $cgi->param('ProjId');
	my $sex= $cgi->param('Sex');
	my $patientList;
	$patientList = queryPolyproject::getPatientProject($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="patname";
	$hdata{label}="patproj";
	foreach my $c (@$patientList){
		my %s;
		$s{id} = $c->{id};
		$s{id} += 0;
		$s{projectid} = $c->{project_id};
		$s{projectid_dest} = $c->{project_id_dest};
		$s{projname} = $c->{projname};
		$s{projname} = "NGSRun"  unless $c->{projname};
		$s{patname} = $c->{name};
		$s{sex} = $c->{sex};
		$s{patproj} = $c->{name};
		if ($sex) {
			if ($sex == 1 ) {next if $s{sex} == 2}
			if ($sex == 2 ) {next if $s{sex} == 1}			
		}	
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{projectid} <=> $a->{projectid} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub RunProjectSection {
	my $runid = $cgi->param('RunSel');
	my $projListId = queryPolyproject::getUniqProjectRunFromPatient($buffer->dbh,$runid);
	my $newfreerun=1;
	foreach my $v (@$projListId){
		$newfreerun=0 if $v->{project_id}==0;
	}
	my @data;
	my %hdata;
	$hdata{identifier}="ProjectId";
	$hdata{label}="ProjectId";
	foreach my $c (@$projListId){
		my %s;
		$s{ProjectName} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id});
		$s{ProjectId} = $c->{project_id};	
		if($s{ProjectId} == 0 ) {
				$s{FreeRun}=1
		} else {
				$s{FreeRun}=""
		}			
		push(@data,\%s);
	}
	if ($newfreerun) {
		my $new={"ProjectId"=>"0","ProjectName"=>undef,"FreeRun"=>1};
		push(@data,$new);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub FindPatientSection {
	my $patname = $cgi->param('PatName');
	my $patList = queryPolyproject::getPatName($buffer->dbh,$patname);
	my @data;
	my %hdata;
	$hdata{label}="patName";
	my $patInfoList;
	my $patNoInfoList;
	foreach my $c (@$patList){
		my @uniqList;
		my %s;
		$patInfoList = queryPolyproject::getPatNameInfo($buffer->dbh,$c->{name});
		$patNoInfoList = queryPolyproject::getPatNameNoProjInfo($buffer->dbh,$c->{name});
		
		foreach my $r (@$patInfoList){
			my %child;
			if($r->{projid} == 0 ) {
				$r->{FreeRun}=1;
			} else {
				$r->{FreeRun}=""
			}
			if($r->{projiddest} != 0 ) {
				$r->{ProjNameDest}=$r->{ProjName};
				if($r->{projid} == 0 ) {
					$r->{ProjName}="";
				}			
			} else {
				$r->{ProjNameDest}=""
			}
						
			$child{info} = $r;
			push(@uniqList,$child{info});
		}
		foreach my $r (@$patNoInfoList){
			my %child;
			if($r->{projid} == 0 ) {
				$r->{FreeRun}=1;
			} else {
				$r->{FreeRun}=""
			}			
			if($r->{projiddest} != 0 ) {
				$r->{ProjNameDest}=$r->{ProjName};
				if($r->{projid} == 0 ) {
					$r->{ProjName}="";
				}			
			} else {
				$r->{ProjNameDest}=""
			}
			$child{info} = $r;
			push(@uniqList,$child{info});
		}
		$s{children}=\@uniqList unless scalar(@uniqList)<2;
		if (scalar(@uniqList)<2){
			$s{runid}= @uniqList[0]->{runid};
			$s{ProjName}= @uniqList[0]->{ProjName};
			$s{projid}= @uniqList[0]->{projid};
			$s{ProjNameDest}= @uniqList[0]->{ProjNameDest};
			$s{projiddest}= @uniqList[0]->{projiddest};
			if($s{projid} == 0 ) {
				$s{FreeRun}=1;
			} else {
				$s{FreeRun}=""
			}			
		}
		$s{patName} = $c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);	
}

###### Project  ###################################################################
sub ProjectSection	{
	my $pid = $cgi->param('ProjSel');
	my $sql2 = qq {and p.project_id='$pid'};
	$sql2 = "" unless $pid;
	my $sql = qq{select p.project_id as id , p.name as name, 
		p.description as description,
		p.creation_date as cDate
 		from PolyprojectNGS.projects p ,
   		PolyprojectNGS.databases_projects dp
		where p.type_project_id=3
    	and p.project_id =dp.project_id
    	and dp.db_id !=2
		$sql2
		order by p.project_id
	};

	my $sth = $buffer->dbh->prepare($sql) || die();
	$sth->execute();
	my $res = $sth->fetchall_hashref("name");
	my @result;
	my $row=1;
	my $buffer = GBuffer->new(-verbose=>1);
	foreach my $name (sort keys %$res){
		my $item;
		foreach my $k (keys %{$res->{$name} }){
			if ($k eq "id") {
				$item->{id} = $res->{$name}->{$k};
			}
			if ($k eq "name") {
				$item->{name} = $res->{$name}->{$k};
			}
			if ($k eq "description") {
				$item->{description} = $res->{$name}->{$k};
			}
		}		
		my $projSomatic = queryPolyproject::getProjectSomatic($buffer->dbh,$item->{id});
		$item->{somatic} = $projSomatic->{somatic};
		my $projdejaVu = queryPolyproject::getProjectdejaVu($buffer->dbh,$item->{id});
		$item->{dejaVu} = $projdejaVu->{dejaVu};
		my $projPhenotype = queryPolyproject::getProjectPhenotype($buffer->dbh,$item->{id});
		$item->{phenotype}=join(",",map{$_->{name}}@$projPhenotype);
		$item->{pheid}=join(",",map{$_->{phenotype_id}}@$projPhenotype);
		
		my $runList = queryPolyproject::getRunfromProject($buffer->dbh,$item->{id});
		if ($runList->{RunId}=="") {
			$item->{FreeProj}=1;
		} else {
			$item->{FreeProj}="";
		}
		$item->{RunId} = $runList->{RunId};
		my $super_unit = queryPolyproject::getCodeUnitFromTeamId($buffer->dbh,6);
		my $users = queryPolyproject::getUsersAllInfoFromProject($buffer->dbh,$item->{id},$super_unit);
		$item->{users} = join(" ",map{$_->{name}}@$users);
		push(@result,$item);
	}
	my @result_sorted=sort { $b->{id} <=> $a->{id} } @result;
	export_data::print(undef,$cgi,\@result_sorted);
}

sub saveProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projectid = $cgi->param('ProjSel');
	my $description = $cgi->param('description');
	my $dejavu = $cgi->param('dejaVu');
	my $somatic = $cgi->param('somatic');
	my $phenotype = $cgi->param('phenotype');
	my $name = queryPolyproject::getProjectName($buffer->dbh,$projectid);
	#dejaVu & somatic update Project
	queryPolyproject::upProject($buffer->dbh,$projectid,$description,$dejavu,$somatic);
	my $message_phe;
	if ($phenotype) {
		if ($phenotype eq "No Phenotype") {
			my $patList= queryPolyproject::getPatientsFromProject($buffer->dbh,$projectid);
			foreach my $c (@$patList){
				queryPolyproject::removePhenotypePatientByPatient($buffer->dbh,$c->{patient_id}) ;
			}
			queryPolyproject::removePhenotypeProjectByProject($buffer->dbh,$projectid) ;
			$message_phe= "Delete All phenotypes for project $name and their patients.";			
		} else {
			my $r_phe = queryPolyproject::getPhenotypeFromName($buffer->dbh,$phenotype);
			addPhenotype2project($r_phe->{phenotype_id},$projectid) if $projectid;
			my $patList= queryPolyproject::getPatientsFromProject($buffer->dbh,$projectid);
			foreach my $c (@$patList){
				addPhenotype2patientAffected($r_phe->{phenotype_id},$c->{patient_id}) ;
			}
			$message_phe="Phenotype: $phenotype added to the project $name and to their patients";
		}		
	}	
#	my $buffer = GBuffer->new();
#	my $projectG = $buffer->newProject(-name=>$name);
#	$projectG->getProjectPath();
	#$projectG->makePath();
#### End Autocommit dbh ###########
	$dbh->commit();
	my $message="Project ".$name." updated. ";
	$message.=$message_phe if $phenotype;
	sendOK("$message");	
}

sub delProjectSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projectid = $cgi->param('ProjSel');
	my $runList = queryPolyproject::getRunfromProject($buffer->dbh,$projectid);
	my $pDestList = queryPolyproject::getRunfromProjectIdDest($buffer->dbh,$projectid);
	if ($runList->{RunId}=="" && $pDestList->{RunId}=="") {
		queryPolyproject::delProject($buffer->dbh,$projectid);
#### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Project (".$projectid.") deleted ");	
	} else {
		sendError("Project (".$projectid.") Not deleted. Project linked to run ". $runList->{RunId}." or Patient contains this Target Project");
	}
	exit(0);
}

sub lastProjectSection {
	my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="project_id";
	$hdata{label}="project_id";
	foreach my $c (@$lastProjectId){
		my %s;
		$s{project_id} = $c->{project_id};
		$s{project_id} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;	
	printJson(\%hdata);
}

sub lastDesProjectSection {
	my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="project_id";
	$hdata{label}="project_id";
	foreach my $c (@$lastProjectId){
		my %s;
		$s{project_id} = $c->{project_id};
		$s{project_id} += 0;
		$s{description} = $c->{description};
		push(@data,\%s);
	}
	$hdata{items}=\@data;	
	printJson(\%hdata);
}

sub ProjectDestSection {
	my $selrun = $cgi->param('SelRun');
	my $projDestList = queryPolyproject::getProjectDest($buffer->dbh,$selrun);	
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	my $row=10;
	foreach my $c (@$projDestList){
		my %s;
		next if $c->{project_dest} eq "";
		$s{projname} = $c->{project_dest};
		$s{name} = $c->{project_dest}."|";
		$s{id} = $row++;
		$s{projectId} = $s{id};
		$s{value} =$s{projname};
		push(@data,\%s);
	}
#	my @result_sorted=sort { $b->{projectId} <=> $a->{projectId} } @data;
#	my @result_sorted=sort { $b->{id} <=> $a->{id} } @data;
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub lastRunSection {
	my $lastRunId = queryPolyproject::getLastRun($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="run_id";
	$hdata{label}="run_id";
	foreach my $c (@$lastRunId){
		my %s;
		$s{run_id} = $c->{run_id};
		$s{run_id} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub allqRunDevSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $selrun = $cgi->param('SelRun');
	my $runList;
	my $s1=time();
	$runList = queryPolyproject::getAllqRunInfo($buffer->dbh,$selrun);
#	my $e1=time();
#	my $r1=$e1 - $s1;
#	print "\nstart 1: $s1 end: $e1 diff: $r1\n";
	my @data;
	my %hdata;
	my $row=1;
	$hdata{label}="RunId";
	$hdata{identifier}="RunId";
	my $s2=time();
	foreach my $c (@$runList){
		next unless $c->{patId};
		my $patId=$c->{patId};
		# Capture
		my $capInfo=queryPolyproject::getCaptureFromPatients($buffer->dbh,$patId);
		if ($numAnalyse ==1 ) {
#all #no filter
		} elsif ($numAnalyse ==2 ) {
#exome
			next unless $capInfo->{capAnalyse} eq "exome"
		} elsif ($numAnalyse ==3 ) {
#genome
			next unless $capInfo->{capAnalyse} eq "genome"
		} elsif ($numAnalyse ==4 ) {
#panel
			next unless $capInfo->{capAnalyse} !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/
		} elsif ($numAnalyse ==5 ) {
#rnaseq
			next unless $capInfo->{capAnalyse} eq "rnaseq"
		} elsif ($numAnalyse ==6 ) {
#singlecell
			next unless $capInfo->{capAnalyse} eq "singlecell"
		} elsif ($numAnalyse ==7 ) {
#amplicon
			next unless $capInfo->{capAnalyse} eq "amplicon"
		} elsif ($numAnalyse ==8 ) {
#other
			next unless $capInfo->{capAnalyse} eq "other"
		}				
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{name} = $c->{name};#run name
		$s{name} = "" unless defined $c->{name};
		$s{desRun} = $c->{description};	
		$s{pltRun} = $c->{pltRun};
		# Projects
		$s{ProjectId} = 0;
		$s{ProjectId} = $c->{projectId} if $c->{projectId};
		$s{ProjectDestId} = 0;
		$s{ProjectDestId} = $c->{projectDestId} if $c->{projectDestId};
		$s{ProjectName} = "";
		my $p_info = queryPolyproject::getProjectNameFromId($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		$s{ProjectName} = $p_info->{projName} if $c->{projectId};
		$s{ProjectDestName} = "";
		my $pdest_info = queryPolyproject::getProjectNameFromId($buffer->dbh,$s{ProjectDestId}) if $c->{projectDestId};
		$s{ProjectDestName} = $pdest_info->{projName} if $c->{projectDestId};
		$s{somatic} = "";
		$s{somatic} = $p_info->{somatic} if $c->{projectId};
		
		#patient
		$s{patName} = $c->{patName};
		#$s{patId} = $c->{patId};
		$s{nbpatient} = $c->{nbpatRun};
		$s{nbpatient} += 0;
		$s{nbpatient} = "" unless defined $c->{nbpatRun};
		$s{nbpatProjectRun} = $c->{nbPrjRun};
		$s{nbpatProjectRun} += 0;
		$s{patBC} = $c->{patBC};
		$s{sp} = $c->{spCode};
		
		#Project Release Annotation
		$s{projRel} = "";
		$s{projRel} = queryPolyproject::getReleaseNameFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_ppversion=queryPolyproject::getVersionIdFromProject_release_public_database($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_relGene=queryPolyproject::getReleaseGeneFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		$s{projRelAnnot} ="";
		$s{projRelAnnot} = (max @d_relGene).".".(max @d_ppversion) if scalar @d_relGene;		

		#Phenotype Project
		$s{phenotype}="";
		$s{phenotype} = queryPolyproject::getPhenotypeFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};

		#capture
		$s{CaptureId} = $capInfo->{capId};
		$s{CaptureName} = $capInfo->{capName};
		$s{CaptureAnalyse} = $capInfo->{capAnalyse};
		$s{capValidation} = $capInfo->{capValidation};
		$s{capMeth} = $capInfo->{capMeth};
		$s{capRel} = $capInfo->{capRel};

		# Plateform
		my $plateformList = queryPolyproject::getPlateform($buffer->dbh,$s{RunId});	
		$s{plateformName}=join(" ",map{$_->{name}}@$plateformList);
		# Machine
		$s{macName} = queryPolyproject::getSequencingMachines($buffer->dbh,$s{RunId});
		# Method seq
		$s{methSeqName} = queryPolyproject::getMethSeq($buffer->dbh,$s{RunId});

		# Methods
		my $i_snp = queryPolyproject::getMethodsNameFromPatient($buffer->dbh,"SNP",$patId);
		$s{MethSnp} = $i_snp->{meths};
		$s{nbCall} = $i_snp->{nbMeths};
		$s{nbCall} += 0;
		my $i_aln = queryPolyproject::getMethodsNameFromPatient($buffer->dbh,"ALIGN",$patId);
		$s{MethAln} = $i_aln->{meths};
		$s{nbAln} = $i_aln->{nbMeths};
		$s{nbAln} += 0;

		# Other Methods from Pipeline Methods
		my $i_pipe = queryPolyproject::getOtherMethodsNameFromPatient($buffer->dbh,$patId);
		$s{MethPipe} = $i_pipe->{meths};
		
		# Users
		$s{Users}="";
		$s{Users}=queryPolyproject::getUsersFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		# User group
		$s{UserGroups} = "";	
		$s{UserGroups} = queryPolyproject::getGroupsFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};	

		#date
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		if ($YY=="0000") {
			$mydate =""
		}
		$s{cDate} = $mydate;

		#controle
		$s{statRun} = "" if ($s{nbpatient} == $s{nbCall});#green
		$s{statRun}= 2 if ($s{nbpatProjectRun} != $s{nbpatient});#orange
		$s{statRun}= 1 if ($s{nbpatProjectRun} == 0);#red
		$s{statRun}= 3 if (($s{nbpatient} != $s{nbCall}));#blue
		$s{Rapport}= "$s{nbpatProjectRun}"."/"."$s{nbpatient}";
		$s{luser} = 1;
		if (scalar(split(/ /,$s{Users}))>0 || scalar(split(/ /,$s{UserGroups}))>0) {
			$s{luser} = 0;
		}
		if (defined $selrun) {
			my $runFileInfo = queryPolyproject::getRunFileInfo($buffer->dbh,$selrun);
			$s{FileName} = $runFileInfo->{FileName};
			$s{FileType} = $runFileInfo->{FileType};
			$s{icon} = $runFileInfo->{FileType};
		}
		push(@data,\%s);
	}
#	print "\nstart 1: $s1 end: $e1 diff: $r1\n";
#	my $E2=time();
#	my $r2=$E2 - $s2;
#	my $R=$E2 - $s1;
#	print "start 2: $s2 end: $E2 diff: $r2 Tot: $R\n";
	$hdata{items}=\@data;
	printJson(\%hdata);	
}

#ancien DEV pour PLT
sub allqRunSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $selrun = $cgi->param('SelRun');
	my $runList;
	my $s1=time();
	$runList = queryPolyproject::getAllqRunInfo($buffer->dbh,$selrun);
#	my $e1=time();
#	my $r1=$e1 - $s1;
#	print "\nstart 1: $s1 end: $e1 diff: $r1\n";
	my @data;
	my %hdata;
	my $row=1;
	$hdata{label}="RunId";
	$hdata{identifier}="RunId";
#	my $s2=time();
	foreach my $c (@$runList){
		next unless $c->{patId};
		next if $c->{step}==2;
		my $patId=$c->{patId};
		# Capture
		my $capInfo=queryPolyproject::getCaptureFromPatients($buffer->dbh,$patId);
		if ($numAnalyse ==1 ) {
#all #no filter
		} elsif ($numAnalyse ==2 ) {
#exome
			next unless $capInfo->{capAnalyse} eq "exome"
		} elsif ($numAnalyse ==3 ) {
#genome
			next unless $capInfo->{capAnalyse} eq "genome"
		} elsif ($numAnalyse ==4 ) {
#panel
			next unless $capInfo->{capAnalyse} !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/
		} elsif ($numAnalyse ==5 ) {
#rnaseq
			next unless $capInfo->{capAnalyse} eq "rnaseq"
		} elsif ($numAnalyse ==6 ) {
#singlecell
			next unless $capInfo->{capAnalyse} eq "singlecell"
		} elsif ($numAnalyse ==7 ) {
#amplicon
			next unless $capInfo->{capAnalyse} eq "amplicon"
		} elsif ($numAnalyse ==8 ) {
#other
			next unless $capInfo->{capAnalyse} eq "other"
		}				
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{name} = $c->{name};#run name
		$s{name} = "" unless defined $c->{name};
		$s{desRun} = $c->{description};	
		$s{pltRun} = $c->{pltRun};
		# Projects
		$s{ProjectId} = 0;
		$s{ProjectId} = $c->{projectId} if $c->{projectId};
		$s{ProjectDestId} = 0;
		$s{ProjectDestId} = $c->{projectDestId} if $c->{projectDestId};
		$s{ProjectName} = "";
		my $p_info = queryPolyproject::getProjectNameFromId($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		$s{ProjectName} = $p_info->{projName} if $c->{projectId};
		$s{ProjectDestName} = "";
		my $pdest_info = queryPolyproject::getProjectNameFromId($buffer->dbh,$s{ProjectDestId}) if $c->{projectDestId};
		$s{ProjectDestName} = $pdest_info->{projName} if $c->{projectDestId};
		$s{somatic} = "";
		$s{somatic} = $p_info->{somatic} if $c->{projectId};		
		
		#patient
		$s{patName} = $c->{patName};
		#$s{patId} = $c->{patId};
		$s{nbpatient} = $c->{nbpatRun};
		$s{nbpatient} += 0;
		$s{nbpatient} = "" unless defined $c->{nbpatRun};
		$s{nbpatProjectRun} = $c->{nbPrjRun};
		$s{nbpatProjectRun} += 0;
		$s{patBC} = $c->{patBC};
		$s{sp} = $c->{spCode};
		$s{Gproject} = "";
		$s{Gproject} = $c->{Gproject} if $c->{Gproject};
		
		#Project Release Annotation
		$s{projRel} = "";
		$s{projRel} = queryPolyproject::getReleaseNameFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_ppversion=queryPolyproject::getVersionIdFromProject_release_public_database($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_relGene=queryPolyproject::getReleaseGeneFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		$s{projRelAnnot} ="";
		$s{projRelAnnot} = (max @d_relGene).".".(max @d_ppversion) if scalar @d_relGene;		

		#Phenotype Project
		$s{phenotype}="";
		$s{phenotype} = queryPolyproject::getPhenotypeFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};

		#capture
		$s{CaptureId} = $capInfo->{capId};
		$s{CaptureName} = $capInfo->{capName};
		$s{CaptureAnalyse} = $capInfo->{capAnalyse};
		$s{capValidation} = $capInfo->{capValidation};
		$s{capMeth} = $capInfo->{capMeth};
		$s{capRel} = $capInfo->{capRel};

		# Plateform
		my $plateformList = queryPolyproject::getPlateform($buffer->dbh,$s{RunId});	
		$s{plateformName}=join(" ",map{$_->{name}}@$plateformList);
		# Machine
		$s{macName} = queryPolyproject::getSequencingMachines($buffer->dbh,$s{RunId});
		# Method seq
		$s{methSeqName} = queryPolyproject::getMethSeq($buffer->dbh,$s{RunId});

		# Methods
		my $i_snp = queryPolyproject::getMethodsNameFromPatient($buffer->dbh,"SNP",$patId);
		$s{MethSnp} = $i_snp->{meths};
		$s{nbCall} = $i_snp->{nbMeths};
		$s{nbCall} += 0;
		my $i_aln = queryPolyproject::getMethodsNameFromPatient($buffer->dbh,"ALIGN",$patId);
		$s{MethAln} = $i_aln->{meths};
		$s{nbAln} = $i_aln->{nbMeths};
		$s{nbAln} += 0;

		# Other Methods from Pipeline Methods
		my $i_pipe = queryPolyproject::getOtherMethodsNameFromPatient($buffer->dbh,$patId);
		$s{MethPipe} = $i_pipe->{meths};
		
		# Users
		$s{Users}="";
		$s{Users}=queryPolyproject::getUsersFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		# User group
		$s{UserGroups} = "";	
		$s{UserGroups} = queryPolyproject::getGroupsFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};	

		#date
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		if ($YY=="0000") {
			$mydate =""
		}
		$s{cDate} = $mydate;

		#controle
		$s{statRun} = "" if ($s{nbpatient} == $s{nbCall});#green
		$s{statRun}= 2 if ($s{nbpatProjectRun} != $s{nbpatient});#orange
		$s{statRun}= 1 if ($s{nbpatProjectRun} == 0);#red
		$s{statRun}= 3 if (($s{nbpatient} != $s{nbCall}));#blue
		$s{Rapport}= "$s{nbpatProjectRun}"."/"."$s{nbpatient}";
		$s{luser} = 1;
		if (scalar(split(/ /,$s{Users}))>0 || scalar(split(/ /,$s{UserGroups}))>0) {
			$s{luser} = 0;
		}
		if (defined $selrun) {
			my $runFileInfo = queryPolyproject::getRunFileInfo($buffer->dbh,$selrun);
			$s{FileName} = $runFileInfo->{FileName};
			$s{FileType} = $runFileInfo->{FileType};
			$s{icon} = $runFileInfo->{FileType};
		}
		push(@data,\%s);
	}
#	print "\nstart 1: $s1 end: $e1 diff: $r1\n";
#	my $E2=time();
#	my $r2=$E2 - $s2;
#	my $R=$E2 - $s1;
#	print "start 2: $s2 end: $E2 diff: $r2 Tot: $R\n";
	$hdata{items}=\@data;
	printJson(\%hdata);	
}


sub allRunSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $selrun = $cgi->param('SelRun');
	my $runList;
	my $t=time;
	$runList = queryPolyproject::getAllRunInfo($buffer->dbh,$numAnalyse,$selrun);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{label}="RunId";
	$hdata{identifier}="RunId";

	foreach my $c (@$runList){
		my %s;
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{name} = $c->{name};
		$s{name} = "" unless defined $c->{name};
		$s{desRun} = $c->{description};	
		$s{pltRun} = $c->{pltRun};
		$s{somatic} = $c->{somatic};
		$s{CaptureAnalyse} = $c->{capAnalyse}; # a retirer

		# Projects
		$s{ProjectId} = $c->{ProjectId};
		$s{ProjectName} = $c->{ProjectName};
		$s{ProjectId} = 0 unless $s{ProjectId};
		$s{ProjectName}= "" unless $s{ProjectName};
#	
		$s{ProjectDestId} = $c->{ProjectDestId};
		$s{ProjectDestName} = $c->{ProjectDestName};
		$s{ProjectDestId} = 0 unless $s{ProjectDestId};
		$s{ProjectDestName}= "" unless $s{ProjectDestName};
#Project Release Annotation
		$s{projRel} = $c->{projRel};
		my @d_ppversion=split( / /, $c->{ppversionid});
		my @d_relGene=split( / /, $c->{relGene});
		$s{projRelAnnot} ="";
		$s{projRelAnnot} = (max @d_relGene).".".(max @d_ppversion) if scalar @d_relGene;		
		$s{macName} = $c->{macName};
		$s{plateformName} = $c->{plateformName};
		$s{methSeqName} = $c->{methSeqName};
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		if ($YY=="0000") {
			$mydate =""
		}
		$s{cDate} = $mydate;
				
		# Capture
		$s{CaptureName} = $c->{capName};
		$s{CaptureId} = $c->{capId};
		$s{CaptureAnalyse} = $c->{capAnalyse};
		$s{capValidation} = $c->{capValidation};
		$s{capMeth} = $c->{capMeth};
		$s{capRel} = $c->{capRel};
		
		#Phenotype Project
		$s{phenotype}="";
		my $projPhenotype = queryPolyproject::getProjectPhenotype($buffer->dbh,$s{ProjectId}) if  ($s{ProjectId});
		$s{phenotype}=join(",",map{$_->{name}}@$projPhenotype) if defined $projPhenotype;

		#Patient
		$s{patName} = $c->{patName};
		$s{patBC} = $c->{patBC};
		$s{nbpatient} = $c->{nbpatRun};
		$s{nbpatient} += 0;
		$s{nbpatient} = "" unless defined $c->{nbpatRun};
		$s{nbpatProjectRun} = $c->{nbPrjRun};
		$s{nbpatProjectRun} += 0;
		
		# Methods
		$s{MethSnp} = $c->{methCall};
		$s{MethAln} = $c->{methAln};

		$s{nbAln} = $c->{nbAln};
		$s{nbAln} += 0;
		$s{nbCall} = $c->{nbCall};
		$s{nbCall} += 0;
		
		# Users 
		$s{Users}=$c->{username};
		$s{UserGroups} = $c->{usergroup};	

		$s{statRun} = "" if ($s{nbpatient} == $s{nbCall});#green
		$s{statRun}= 2 if ($s{nbpatProjectRun} != $s{nbpatient});#orange
		$s{statRun}= 1 if ($s{nbpatProjectRun} == 0);#red
		$s{statRun}= 3 if (($s{nbpatient} != $s{nbCall}));#blue
		$s{Rapport}= "$s{nbpatProjectRun}"."/"."$s{nbpatient}";
		$s{luser} = 1;
		if((scalar(split(/ /,$c->{username}))>0)||(scalar(split(/ /,$c->{usergroup}))>0)) {
			$s{luser}= 0;
		}

		if (defined $selrun) {
			my $runFileInfo = queryPolyproject::getRunFileInfo($buffer->dbh,$selrun);
			$s{FileName} = $runFileInfo->{FileName};
			$s{FileType} = $runFileInfo->{FileType};
			$s{icon} = $runFileInfo->{FileType};
		}

		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);	
}

###### Phenotype ####################################################################

sub phenotypeSection {
	my $phenotype = queryPolyproject::getPhenotype($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$phenotype){
		my %s;
		$s{label} = $c->{name};
		$s{value} = $c->{phenotype_id};
		push(@data,\%s);
	}
	my @data_nophe;
	my %hash_nophe=("label"=>"No Phenotype","value"=>"999");
	push(@data_nophe,\%hash_nophe);
	my @data_sorted=sort { uc($a->{label}) cmp uc($b->{label}) } @data;
	my @result_sorted=(@data_nophe,@data_sorted);
	$hdata{items}=\@result_sorted;
#	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub phenotypeNameSection {
	my $phenotypeName = queryPolyproject::getPhenotype($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$phenotypeName){
		my %s;
		$s{phenotypeId} = $c->{phenotype_id};
		$s{phenotypeId} += 0;
		$s{value} = $c->{name};
		$s{name} = $c->{name};
		push(@data,\%s);
	}
	my %hash_nophe=("phenotypeId"=>0,"name"=>"No Phenotype","value"=>"");
	push(@data,\%hash_nophe);
	my @result_sorted=sort { $a->{phenotypeId} <=> $b->{phenotypeId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub addPhenotypeSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $pheid = $cgi->param('PheIdSel');
	my @ListPheid = split(/,/,$pheid);
	my $projectid = $cgi->param('ProjIdSel');
	my $patid = $cgi->param('PatIdSel');
	my @ListPatid = split(/,/,$patid);
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$projectid) if $projectid;
	my $AllpheName="";
	for (my $i = 0; $i< scalar(@ListPheid); $i++) {
		next if $ListPheid[$i] =="999";
		my $phenotypeName = queryPolyproject::getPhenotype($buffer->dbh,$ListPheid[$i]);
		$AllpheName.=$phenotypeName->[0]->{name}.',';
		addPhenotype2project($ListPheid[$i],$projectid) if $projectid;
		addPhenotype2patientAffected ($ListPheid[$i],@ListPatid)  if scalar @ListPatid ;
	}
	chop($AllpheName);
	$dbh->commit();
	sendOK("OK: Phenotype $AllpheName added for project $projectname($projectid) and its Patients")  if ($projectid && scalar @ListPatid);	
	sendOK("OK: Phenotype $AllpheName added for project $projectname($projectid)")  if ($projectid && not @ListPatid);	
	sendOK("OK: Phenotype $AllpheName added for patients")  if (not $projectid && scalar @ListPatid);	
	
}

sub addPhenotype2project {
	my ($pheid,$projid) = @_;
	my $res_pheP=queryPolyproject::getPhenotypeProject($buffer->dbh,$pheid,$projid);
	queryPolyproject::newPhenotypeProject($buffer->dbh,$pheid,$projid) unless  $res_pheP->[0]->{phenotype_id};	
}

sub addPhenotype2patientAffected {
	my ($pheid,@patid) = @_;
	for (my $i = 0; $i< scalar(@patid); $i++) {
		my $res_pat=queryPolyproject::getPatientInfo($buffer->dbh,$patid[$i]);
		next unless $res_pat->{status} eq '2';
		my $res_pheP=queryPolyproject::getPhenotypePatient($buffer->dbh,$pheid,$patid[$i]);
		queryPolyproject::newPhenotypePatient($buffer->dbh,$pheid,$patid[$i]) unless  $res_pheP->[0]->{phenotype_id};
	}
}

###### Species ####################################################################
sub speciesNameSection {
	my $species = queryPolyproject::getSpecies($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="name";
	foreach my $c (@$species){
		my %s;
		next unless $c->{species_id};
		$s{speciesId} = $c->{species_id};
		$s{speciesId} += 0;
		$s{value} = $c->{species_id};
		$s{name} = $c->{name};
		$s{latin} = $c->{latin};
		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###### Profile Perspective Technology Preparation ####################################################################
sub ProfileSection {
	my $profListId = queryPolyproject::getProfile_byId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="profName";
	$hdata{label}="profName";
	foreach my $c (@$profListId){
		my %s;
		$s{profId} = $c->{profile_id};
		$s{profId} += 0;
		$s{profName} = $c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub profileNameSection {
	my $profiles = queryPolyproject::getProfile_byId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="name";
	foreach my $c (@$profiles){
		my %s;
		next unless $c->{profile_id};
		$s{profileId} = $c->{profile_id};
		$s{profileId} += 0;
		$s{value} = $c->{profile_id};
		$s{name} = $s{profileId}." ".$c->{name};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub newupdateProfileSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $profile = $cgi->param('profileName');
        my $s_profileid = $cgi->param('SelprofId');
		my $i_profile = queryPolyproject::getProfile_byName($buffer->dbh,$profile);
		
		if ($s_profileid) {
			if (exists $i_profile->{profile_id} && ($s_profileid != $i_profile->{profile_id})) {
				sendError("Profile Name: " . $profile ."...". " already in Profile database");
			}			
		} else {
			if (exists $i_profile->{profile_id}) {
				sendError("Profile Name: " . $profile ."...". " already in Profile database");
			}			
		}
		my @sp_profile=split(/ /,$profile);
		my ($pers_id,$tech_id,$prep_id)=0;
		my ($pers_name,$tech_name,$prep_name)="";
		if (scalar (@sp_profile != 3)) {
			sendError("Problem with Profile Name: " . $profile ."...");			
		} else {
			for (my $i = 0; $i< scalar(@sp_profile); $i++) {
				warn Dumper $sp_profile[$i];
				if ($i==0) {
					my $i_pers= queryPolyproject::getPerspectiveFromName($buffer->dbh,$sp_profile[$i]);
					$pers_id= $i_pers->{id};
					$pers_name= $i_pers->{name};
				} elsif ($i==1) {
					my $i_tech= queryPolyproject::getTechnologyFromName($buffer->dbh,$sp_profile[$i]);
					$tech_id= $i_tech->{id};
					$tech_name= $i_tech->{name};
				} elsif ($i==2) {
					my $i_prep= queryPolyproject::getPreparationFromName($buffer->dbh,$sp_profile[$i]);
					$prep_id= $i_prep->{id};
					$prep_name= $i_prep->{name};
				}
			}
		}

		if ($pers_id && $tech_id && $prep_id) {
			my $i_pers_tech= queryPolyproject::getPerspective_Technology($buffer->dbh,$pers_id,$tech_id);
			queryPolyproject::addPerspective_Technology($buffer->dbh,$pers_id,$tech_id) unless $i_pers_tech;			
			my $i_tech_prep= queryPolyproject::getTechnology_Preparation($buffer->dbh,$tech_id,$prep_id);
			queryPolyproject::addTechnology_Preparation($buffer->dbh,$tech_id,$prep_id) unless $i_tech_prep;
			my $last_profileid = queryPolyproject::newProfileData($buffer->dbh,$pers_id,$tech_id,$prep_id,$profile) unless $s_profileid;			
			queryPolyproject::updateProfileData($buffer->dbh,$pers_id,$tech_id,$prep_id,$profile,$s_profileid) if $s_profileid;
### End Autocommit dbh ###########	
			$dbh->commit();
			sendOK("Profile created: <b>".$last_profileid->{'LAST_INSERT_ID()'}." ".$profile."</b> with Perspective: ".$pers_name.", Technology: ".$tech_name.", Technology: ".$prep_name) unless $s_profileid;	
			sendOK("Profile updated: <b>".$s_profileid." ".$profile."</b> with Perspective: ".$pers_name.", Technology: ".$tech_name.", Technology: ".$prep_name) if $s_profileid;	
		}
	exit(0);
}

###### Pipeline Profile Methods ####################################################################
sub pipelineNameSection {
	my $pipelines = queryPolyproject::getPipelineMethods_byId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="name";
	foreach my $c (@$pipelines){
		my %s;
		next unless $c->{pipeline_id};
		$s{pipelineId} = $c->{pipeline_id};
		$s{pipelineId} += 0;
		$s{value} = $c->{pipeline_id};
		$s{Name} = $c->{name};
		$s{name} = $s{pipelineId}." ".$c->{name}.": ".$c->{content};
		$s{content} = $c->{content};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub pipelineMethSection {
	my $pipelineid = $cgi->param('pipeId');
	my $pipe = queryPolyproject::getPipelineMethods_byId($buffer->dbh,$pipelineid);
	my $pipeName=$pipe->[0]->{name};
	my $pipeline = queryPolyproject::getMethods_inMethodPipeline($buffer->dbh,$pipelineid);
	my @data;
	my %hdata;
	$hdata{identifier}="methodId";
	$hdata{label}="methodId";
	foreach my $c (@$pipeline){
		my %s;
		my $metListId = queryPolyproject::getMethodId($buffer->dbh,$c->{method_id});
		$s{methodId} = $c->{method_id};
		$s{methodId} += 0;
		$s{methName} = $metListId->[0]->{methName};
		$s{methType} = $metListId->[0]->{methType};
		$s{pipeId} = $c->{pipeline_id};
		$s{pipeName} = $pipeName;		
		push(@data,\%s);		
	}
	$hdata{items}=\@data;
	printJson(\%hdata);

}

sub newPipelineSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $pipeline = $cgi->param('pipeline');
	my $content = $cgi->param('content');
	my $r_pipeline = queryPolyproject::getPipelineMethods_fromName($buffer->dbh,$pipeline);
 	if (exists $r_pipeline ->{pipeline_id}) {
		sendError("Pipeline Name: " . $pipeline ."...". " already in Pipeline database");
	} else 	{
### End Autocommit dbh ###########
		my @sp_content=split(/ /,$content);
		my $last_pipelineid = queryPolyproject::insertPipeline($buffer->dbh,$pipeline,$content);		
		my $pipelineid = $last_pipelineid->{'LAST_INSERT_ID()'} if defined $last_pipelineid;
		if ($pipelineid) {
			foreach my $t (@sp_content){
				my $r_meth = queryPolyproject::getMethodFromName($buffer->dbh,$t);
				queryPolyproject::insertMethodsPipeline($buffer->dbh,$r_meth->{methodId},$pipelineid);
			}
### End Autocommit dbh ###########
			$dbh->commit();
			sendOK("OK : Pipeline Methods created: ". $pipeline ." Content: " .$content);	
		}
	}
}

sub upPipelineSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $pipelineId = $cgi->param('pipeId');
	my $pipeline = $cgi->param('pipeline');
	my $content = $cgi->param('content');
	my $pipe = queryPolyproject::getMethods_inMethodPipeline($buffer->dbh,$pipelineId);
	my $hash_meth;		
	foreach my $c (@$pipe){
		$hash_meth->{$c->{method_id}} = 1;
	}
	queryPolyproject::upPipeline($buffer->dbh,$pipelineId,$pipeline,$content);
	my @sp_content=split(/ /,$content);
	foreach my $t (@sp_content){
		my $r_meth = queryPolyproject::getMethodFromName($buffer->dbh,$t);
		my $is_mp=queryPolyproject::isMethodPipeline($buffer->dbh,$r_meth->{methodId},$pipelineId);
		if ($hash_meth->{$r_meth->{methodId}}) {
			delete $hash_meth->{$r_meth->{methodId}};
		}
		next if $is_mp->{method_id};
		queryPolyproject::insertMethodsPipeline($buffer->dbh,$r_meth->{methodId},$pipelineId);
	}
	foreach my $n (keys %$hash_meth) {
		queryPolyproject::delMethodsPipeline($buffer->dbh,$n,$pipelineId);
	}
		
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("OK : Pipeline Methods updated: ". $pipeline ." Content: " .$content);	
}

###### year ####################################################################
sub yearsSection {
	my $nowDate = DateTime->now(time_zone => 'local');
	my $year=$nowDate->year;
	my @years;
	for (my $i = 0; $i< 3; $i++) {
		push(@years,$year-$i);
	}
	my @data;
	my %hdata;
	$hdata{identifier}="value";
	$hdata{label}="year";
	foreach my $c (@years){
		my %s;
		$s{year} = $c;
		$s{year} += 0;
		$s{value} = $s{year};
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

sub printJson_noexit {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
}


sub sendFormOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendFormError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendComplexOK {
	my ($text,$sheet) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendComplexError {
	my ($text,$sheet) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendExtended {
	my ($text,$extend) = @_;
	my $resp;
	$resp->{status}  = "Extended";
	$resp->{message} = $text;
	$resp->{extend} = $extend;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendError2 {
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




exit(0);



