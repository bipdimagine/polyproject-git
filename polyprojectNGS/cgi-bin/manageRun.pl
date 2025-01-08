#!/usr/bin/perl
########################################################################
###### manageRun.pl
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
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
#use DateTime;
#use DateTime::Duration;
use File::Basename;
use GBuffer;
use connect;
use queryPolyproject;
use querySample;
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

if ( $option eq "allqRun" ) {
	allqRunSection();
} elsif ( $option eq "allqRunOld" ) {
	allqRunSectionOld();
} elsif ( $option eq "runPerson" ) {
#gpatient 	genomicRunPatientSection
	runPersonSection();
} elsif ( $option eq "sexPerson" ) {
#gpatientProjectDest genomicPatientProjectDestSection
	sexPersonProjectSection();
} elsif ( $option eq "upPerson" ) {
#upPatient  UpPatientSection
	upPersonSection();
} elsif ( $option eq "delPerson" ) {
#delPatient  DelPatientSection
	delPersonSection();
} elsif ( $option eq "upPersonIV" ) {
#upPatientIV  upPatientIVSection
	upPersonIVSection();
} elsif ( $option eq "upPersonControl" ) {
#upPatientControl  upPatientControlSection
	upSamplePersonControlSection();
} elsif ( $option eq "newRun" ) {
#newRunG genomicRunSection
	newRunSection();
} 


######################################################################################
# Run
sub allqRunSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $selrun = $cgi->param('SelRun');
	my $runList;
	my $s1=time();
#	$runList = queryPolyproject::getAllqRunInfo($buffer->dbh,$selrun);
	$runList = querySample::getAllqRunInfo($buffer->dbh,$selrun);
#	warn Dumper $runList;
	my $e1=time();
	my $r1=$e1 - $s1;
#	print "\nstart 1: $s1 end: $e1 diff: $r1\n";
	my @data;
	my %hdata;
	my $row=1;
	$hdata{label}="RunId";
	$hdata{identifier}="RunId";
	my $s2=time();
	foreach my $c (@$runList){
		next unless $c->{sampleId};
		next unless $c->{personId};
		my $sampleId=$c->{sampleId};
		
		# Capture
		my $capInfo=querySample::getCaptureFromSamples($buffer->dbh,$sampleId);
		if ($numAnalyse ==1 ) {
#all #no filter
		} elsif ($numAnalyse ==2 ) {
#exome
			next unless $capInfo->{AnalyseId}==1
		} elsif ($numAnalyse ==3 ) {
#genome
			next unless $capInfo->{AnalyseId}==2
		} elsif ($numAnalyse ==4 ) {
#panel/target
			next unless $capInfo->{AnalyseId}==3;
		} elsif ($numAnalyse ==5 ) {
#rnaseq
			next unless $capInfo->{AnalyseId}==4
		}  elsif ($numAnalyse ==6 ) {
#singlecell
			next unless $capInfo->{AnalyseId}==5
		}
		my %s;
		#run
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

		#person patient
		$s{patName} = $c->{personName};
		$s{nbpatient} = $c->{nbpatRun};
		$s{nbpatient} += 0;
		$s{nbpatient} = "" unless defined $c->{nbpatRun};
		$s{nbpatProjectRun} = $c->{nbPrjRun};
		$s{nbpatProjectRun} += 0;
		$s{patBC} = $c->{patBC};
		$s{patBC2} = $c->{patBC2};
		$s{lane} = "";
		$s{lane} = $c->{lane} if defined $c->{lane};

		#Project Release Annotation
		$s{projRel} = "";
		$s{projRel} = queryPolyproject::getReleaseNameFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_ppversion;
		@d_ppversion=queryPolyproject::getVersionIdFromProject_release_public_database($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		my @d_relGene;
		@d_relGene=queryPolyproject::getReleaseGeneFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};
		$s{projRelAnnot} ="";
		$s{projRelAnnot} = (max @d_relGene).".".(max @d_ppversion) if scalar @d_relGene;		
		$s{projRelAnnot} ="" if $s{projRelAnnot} eq ".";

		#Phenotype Project
		$s{phenotype}="";
		$s{phenotype} = queryPolyproject::getPhenotypeFromProjects($buffer->dbh,$s{ProjectId}) if $c->{projectId};

		#capture
		$s{CaptureId} = $capInfo->{capId};
		$s{CaptureName} = $capInfo->{capName};
		$s{CaptureAnalyse} = $capInfo->{capAnalyse};
#		$s{CaptureAnalyse} = $capInfo->{Analyse};
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
		my $i_snp = querySample::getMethodsNameFromSample($buffer->dbh,"SNP",$sampleId);
		$s{MethSnp} = $i_snp->{meths};
		$s{nbCall} = $i_snp->{nbMeths};
		$s{nbCall} += 0;
		my $i_aln = querySample::getMethodsNameFromSample($buffer->dbh,"ALIGN",$sampleId);
		$s{MethAln} = $i_aln->{meths};
		$s{nbAln} = $i_aln->{nbMeths};
		$s{nbAln} += 0;

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
	my $E2=time();
	my $r2=$E2 - $s2;
	my $R=$E2 - $s1;
#	print "start 2: $s2 end: $E2 diff: $r2 Tot: $R\n";
	$hdata{items}=\@data;
	printJson(\%hdata);	
}

### New Run
sub newRunSection  {
	my $selplt = $cgi->param('SelPlt');
	my $description = $cgi->param('description');
	my $name = $cgi->param('name');
	my $pltname = $cgi->param('pltname');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');
	
	my $methALN_name = $cgi->param('method_align');
	my $methSNP_name = $cgi->param('method_call');
	
	my $method_seq = $cgi->param('mseq');
	my $captureId = $cgi->param('capture');
	my $type = $cgi->param('type');
	my $nbpat = $cgi->param('nbpat');
	my $fc = $cgi->param('fc');
# group
	my $groups = $cgi->param('group');
	$groups=~ s/ //g;
	$groups=~ s/\n/;/g;
	my @grp=split(/,/,$groups);

	my $persons = $cgi->param('patient');
	$persons=~ s/ //g;
	$persons=~ s/\n/;/g;
	my @pers=split(/,/,$persons);
	
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

	my $status = $cgi->param('status');
	$status=~ s/ //g;
	$status=~ s/\n/;/g;
	my @lstatus=split(/,/,$status);

	my $barcode = $cgi->param('bc');
	$barcode=~ s/ //g;
	$barcode=~ s/\n/;/g;
	my @bc=split(/,/,$barcode);
	
	my $barcode2 = $cgi->param('bc2');
	$barcode2=~ s/ //g;
	$barcode2=~ s/\n/;/g;
	my @bc2=split(/,/,$barcode2);
	
#	my $gbarcode = $cgi->param('bcg');
	my $gbarcode = $cgi->param('iv');#gbc iv
	$gbarcode=~ s/ //g;
	$gbarcode=~ s/\n/;/g;
	my @gbc=split(/,/,$gbarcode);

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);	
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);

	# Error Persons 
	my $novalidPerson = isUniqPerson($buffer->dbh,@pers);
	#warn Dumper $novalidPerson;
	sendError( "<b>Error Patient:<b> Duplicated Patients $novalidPerson in this current Run..." ) if ($novalidPerson);
	
	# Warning Genotype Bar Code IV gbc
	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @gbc;

	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code : $messageduplicateB" if scalar @duplicateB;

# create runid
	#warn Dumper "$rtype->{id}, $description, $name, $pltname, $nbpat";
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id},$description,$name,$pltname,$nbpat);
	my $runid;
	$runid=$last_run_id->{'LAST_INSERT_ID()'};
	queryPolyproject::upStep2run($buffer->dbh,$runid,1);#genomic plateform: update field step: 1 => not validate ; 0 => validate	

# method aln
	my $validAln="";
	my $validSNP="";
	unless ($selplt) {
		if ($methALN_name) {
			my @ListAln = split(/,/,$methALN_name);
			foreach my $u (@ListAln) {
				my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
				$validAln.=$method_align->{id}."," if ($method_align);
			}
			chop($validAln);
			sendError("Error undefined method_align: " . $methALN_name ) unless $validAln;	
		}
# method call  SNP
		if ($methSNP_name) {
			my @ListSNP = split(/,/,$methSNP_name);
			foreach my $u (@ListSNP) {
				my $method_snp = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validSNP.=$method_snp->{id}."," if ($method_snp);
			}
			chop($validSNP);
			sendError("Error undefined method_call: " . $methSNP_name ) unless $validSNP;	
		}
	}
	#warn Dumper "$validAln $validSNP";
# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
# new patient & family
	my $validR="";
	my $validP="";
	my %seen;
	my %seen2;
	my $i;
	for my $p (@pers) {
		my $j;
		for my $f (@fam) {
			if ($i==$j) {
				my $s_pers=querySample::getSamplePersonFrom_Name_Project($buffer->dbh,$p);
				for my $pc (@$s_pers) {
					$validR.=$pc->{name}.":".$pc->{run_id}."," unless $seen{$pc->{name}}++;
					#warn Dumper $validR;
					my $r_proj;
					$r_proj=querySample::getProjectNamefromPerson($buffer->dbh,$pc->{run_id},$pc->{project_id}) if $pc->{project_id};
					warn "titi";
					#warn Dumper $r_proj;					
					if (defined $r_proj) {
						$validP.=$pc->{name}.":". $r_proj->{name}."," unless $seen2{$pc->{name}}++;
					};
					#warn Dumper $validP;
				}
#1) insert person sans code name avec status mother father 
#2) rechercher selon captureId @fieldCI[$i] => release =speceis 2L 
#3) codename avec 2L+format lastperson-id => modif persone codename
#4) insert sample avec name init-name sex family
				my $r_rel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$captureId);
				my $species;
				$species =$r_rel->[0]->{species} if $r_rel->[0]->{species};
				$species ="human" unless $r_rel->[0]->{species};
				my $r_species=querySample::getSpecies_FromName($buffer->dbh,$species);
#				my $last_person_id=querySample::insertPerson($buffer->dbh,$r_species->{species_id},$lstatus[$i],$lfathers[$i],$lmothers[$i]);#sex
				my $last_person_id=querySample::insertPerson($buffer->dbh,$r_species->{species_id},$lsexs[$i],$lfathers[$i],$lmothers[$i]);
				my $person_id=$last_person_id->{'LAST_INSERT_ID()'};
				my $codename= $r_species->{code}.sprintf("%010d",$person_id);
				querySample::upPersonCodeName($buffer->dbh,$person_id,$codename);			

#				my $last_sample_id=querySample::insertSample($buffer->dbh,$person_id,$runid,0,0,$captureId,$p,$p,$f,$lsexs[$i],$bc[$i],$fc,$gbc[$i]);#status
				my $last_sample_id=querySample::insertSample($buffer->dbh,$person_id,$runid,0,0,$captureId,$p,$p,$f,$lstatus[$i],$bc[$i],$bc2[$i],$fc,$gbc[$i]);
 				my $sample_id=$last_sample_id->{'LAST_INSERT_ID()'};
				
				#my $last_person_id=querySample::insertPerson($buffer->dbh,$p,$p,$lsexs[$i],$lstatus[$i],$f,$lfathers[$i],$lmothers[$i]);
				#my $person_id=$last_person_id->{'LAST_INSERT_ID()'};
				#my $last_sample_id=querySample::insertSample($buffer->dbh,$runid,0,0,$captureId,$bc[$i],$fc,$gbc[$i]);
				#my $sample_id=$last_sample_id->{'LAST_INSERT_ID()'};
				#querySample::insertSamplePerson($buffer->dbh,$sample_id,$person_id) if ($sample_id && $person_id);			

				#Group (new/old)
				if (defined $grp[$i] && $grp[$i]) {
					my $groupid;
					my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,$grp[$i]) if (defined $grp[$i] && $grp[$i]);
					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$grp[$i]) unless defined $group;
					$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
					$groupid = $group->{group_id} unless defined $last_groupid;
					querySample::addGroup2sample($buffer->dbh,$sample_id,$groupid) if ($groupid);
				}
			}			
			$j++;
		}
		$i++;
	}
	chop($validR);
	chop($validP);

#  add Meth call & aln to sample
	unless ($selplt) {
		for my $u (@pers) {
			if ($methALN_name) {
				my @ListAln = split(/,/,$validAln);
				foreach my $m (@ListAln) {
					my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$u,$runid);
					my @s_sampleid;
					if (scalar @$r_pers) {
						@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers);
						my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$m);
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$m) unless $ctrlSM->{sample_id};						
					}
				}	
			}
			if ($methSNP_name) {
				my @ListSNP = split(/,/,$validSNP);
				foreach my $m (@ListSNP) {
					my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$u,$runid);
					my @s_sampleid;
					if (scalar @$r_pers) {
						@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers);
						my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$m);
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$m) unless $ctrlSM->{sample_id};						
					}
				}	
			}
		}
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	if ($validP)	{
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR."<BR>and Project: ".$validP.$messageduplicateB)
	} elsif ($validR)	{
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR.$messageduplicateB)
	} else {
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid."</B>".$messageduplicateB)
	}
}

sub newRunSection_OLD  {
	my $selplt = $cgi->param('SelPlt');
	my $description = $cgi->param('description');
	my $name = $cgi->param('name');
	my $pltname = $cgi->param('pltname');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');
	
	my $methALN_name = $cgi->param('method_align');
	my $methSNP_name = $cgi->param('method_call');
	
	my $method_seq = $cgi->param('mseq');
	my $captureId = $cgi->param('capture');
	my $type = $cgi->param('type');
	my $nbpat = $cgi->param('nbpat');
	my $fc = $cgi->param('fc');
# group
	my $groups = $cgi->param('group');
	$groups=~ s/ //g;
	$groups=~ s/\n/;/g;
	my @grp=split(/,/,$groups);

	my $persons = $cgi->param('patient');
	$persons=~ s/ //g;
	$persons=~ s/\n/;/g;
	my @pers=split(/,/,$persons);
	
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

	my $status = $cgi->param('status');
	$status=~ s/ //g;
	$status=~ s/\n/;/g;
	my @lstatus=split(/,/,$status);

	my $barcode = $cgi->param('bc');
	$barcode=~ s/ //g;
	$barcode=~ s/\n/;/g;
	my @bc=split(/,/,$barcode);

#	my $gbarcode = $cgi->param('bcg');
	my $gbarcode = $cgi->param('iv');#gbc iv
	$gbarcode=~ s/ //g;
	$gbarcode=~ s/\n/;/g;
	my @gbc=split(/,/,$gbarcode);

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);	
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);

	# Error Persons 
	my $novalidPerson = isUniqPerson($buffer->dbh,@pers);
	#warn Dumper $novalidPerson;
	sendError( "<b>Error Patient:<b> Duplicated Patients $novalidPerson in this current Run..." ) if ($novalidPerson);
	
	# Warning Genotype Bar Code IV gbc
	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @gbc;

	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code : $messageduplicateB" if scalar @duplicateB;

# create runid
	#warn Dumper "$rtype->{id}, $description, $name, $pltname, $nbpat";
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id},$description,$name,$pltname,$nbpat);
	my $runid;
	$runid=$last_run_id->{'LAST_INSERT_ID()'};
	queryPolyproject::upStep2run($buffer->dbh,$runid,1);#genomic plateform: update field step: 1 => not validate ; 0 => validate	

# method aln
	my $validAln="";
	my $validSNP="";
	unless ($selplt) {
		if ($methALN_name) {
			my @ListAln = split(/,/,$methALN_name);
			foreach my $u (@ListAln) {
				my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
				$validAln.=$method_align->{id}."," if ($method_align);
			}
			chop($validAln);
			sendError("Error undefined method_align: " . $methALN_name ) unless $validAln;	
		}
# method call  SNP
		if ($methSNP_name) {
			my @ListSNP = split(/,/,$methSNP_name);
			foreach my $u (@ListSNP) {
				my $method_snp = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validSNP.=$method_snp->{id}."," if ($method_snp);
			}
			chop($validSNP);
			sendError("Error undefined method_call: " . $methSNP_name ) unless $validSNP;	
		}
	}
	#warn Dumper "$validAln $validSNP";
# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
# new patient & family
	my $validR="";
	my $validP="";
	my %seen;
	my %seen2;
	my $i;
	for my $p (@pers) {
		my $j;
		#warn Dumper $p;
		for my $f (@fam) {
		#	warn Dumper $f;
			if ($i==$j) {
				my $s_pers=querySample::getSamplePersonFrom_Name_Project($buffer->dbh,$p);
				#warn Dumper $s_pers;
				for my $pc (@$s_pers) {
					$validR.=$pc->{name}.":".$pc->{run_id}."," unless $seen{$pc->{name}}++;
					#warn Dumper $validR;
					my $r_proj;
					$r_proj=querySample::getProjectNamefromPerson($buffer->dbh,$pc->{run_id},$pc->{project_id}) if $pc->{project_id};
					warn "titi";
					warn Dumper $r_proj;					
					if (defined $r_proj) {
						$validP.=$pc->{name}.":". $r_proj->{name}."," unless $seen2{$pc->{name}}++;
					};
					#warn Dumper $validP;
				}
				##my $last_patient_id=queryPolyproject::newPatientRun($buffer->dbh,$p,$p,$runid, $captureId,$f,$fc,@bc[$i],@bcg[$i],@lfathers[$i],@lmothers[$i],@lsexs[$i],@lstatuss[$i]);
				my $last_person_id=querySample::insertPerson($buffer->dbh,$p,$p,$lsexs[$i],$lstatus[$i],$f,$lfathers[$i],$lmothers[$i]);
				my $person_id=$last_person_id->{'LAST_INSERT_ID()'};
##				runid,project_id,project_id_dest,capture_id,bar_code,flowcell,iv			
				my $last_sample_id=querySample::insertSample($buffer->dbh,$runid,0,0,$captureId,$bc[$i],$fc,$gbc[$i]);
				my $sample_id=$last_sample_id->{'LAST_INSERT_ID()'};
				querySample::insertSamplePerson($buffer->dbh,$sample_id,$person_id) if ($sample_id && $person_id);			

				#Group (new/old)
				if (defined $grp[$i] && $grp[$i]) {
					my $groupid;
					my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,$grp[$i]) if (defined $grp[$i] && $grp[$i]);
					#warn Dumper $group;
					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$grp[$i]) unless defined $group;
					$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
					$groupid = $group->{group_id} unless defined $last_groupid;
					#warn Dumper $groupid;
					#Patient Group
					querySample::addGroup2sample($buffer->dbh,$sample_id,$groupid) if ($groupid);
				}
			}			
			$j++;
		}
		$i++;
	}
	chop($validR);
	chop($validP);

#  add Meth call & aln to sample
	unless ($selplt) {
		for my $u (@pers) {
			if ($methALN_name) {
				my @ListAln = split(/,/,$validAln);
				#warn Dumper @ListAln;
				#warn Dumper $u;
				foreach my $m (@ListAln) {
					my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$u,$runid);
					my @s_sampleid;
					if (scalar @$r_pers) {
						@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers);
						my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$m);
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$m) unless $ctrlSM->{sample_id};						
					}
				}	
			}
			if ($methSNP_name) {
				my @ListSNP = split(/,/,$validSNP);
				#warn Dumper @ListSNP;
				#warn Dumper $u;
				foreach my $m (@ListSNP) {
					my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$u,$runid);
					my @s_sampleid;
					if (scalar @$r_pers) {
						@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers);
						my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$m);
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$m) unless $ctrlSM->{sample_id};						
					}
				}	
			}
		}
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	if ($validP)	{
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR."<BR>and Project: ".$validP.$messageduplicateB)
	} elsif ($validR)	{
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR.$messageduplicateB)
	} else {
		sendOK("OK: Patient created: <B>". $persons."</B> in Run: <B>".$runid."</B>".$messageduplicateB)
	}
}




sub isUniqPerson {
	my ($dbh,@person) = @_;
	my $novalidP="";
	my %seen;
	for my $p (@person) {
		$novalidP.=$p."," if $seen{$p}++;
	}
	chop($novalidP);
	return $novalidP
}

sub genomicRunSectionOld  {
	my $selplt = $cgi->param('SelPlt');
	my $description = $cgi->param('description');
	my $name = $cgi->param('name');
	my $pltname = $cgi->param('pltname');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');
	
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	
	my $method_seq = $cgi->param('mseq');
	my $captureId = $cgi->param('capture');
	my $type = $cgi->param('type');
	my $nbpat = $cgi->param('nbpat');
	my $fc = $cgi->param('fc');
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

#	my $gbarcode = $cgi->param('bcg');
	my $gbarcode = $cgi->param('iv');
	$gbarcode=~ s/ //g;
	$gbarcode=~ s/\n/;/g;
	my @bcg=split(/,/,$gbarcode);

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);
	
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

# create runid
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id},$description,$name,$pltname,$nbpat);
	my $runid=$last_run_id->{'LAST_INSERT_ID()'};
# genomic plateform: update field step: 1 => not validate ; 0 => validate
	queryPolyproject::upStep2run($buffer->dbh,$runid,1);	

# method aln
	my $validAln="";
	my $validMeth="";
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
			my @ListMeth = split(/,/,$group_method_calling_name);
			foreach my $u (@ListMeth) {
				my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validMeth.=$method_call->{id}."," if ($method_call);
			}
			chop($validMeth);
			sendError("Error undefined method_call: " . $group_method_calling_name ) unless $validMeth;	
		}
	}

# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
# new patient & family
	my $i;
	my $validR="";
	my $validP="";
	my %seen;
	my %seen2;
	for my $p (@pat) {
		my $j;
		for my $f (@fam) {
			if ($i==$j) {
				my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,$p);
				for my $pc (@$pname) {
					$validR.=$pc->{name}.":".$pc->{run_id}."," unless $seen{$pc->{name}}++;
					my $proj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$pc->{run_id},$pc->{project_id}) if $pc->{project_id};
					if (defined $proj) {
						$validP.=$pc->{name}.":". $proj->{name}."," unless $seen2{$pc->{name}}++;
					};
				}
				my $last_patient_id=queryPolyproject::newPatientRun($buffer->dbh,$p,$p,$runid, $captureId,$f,$fc,@bc[$i],@bcg[$i],@lfathers[$i],@lmothers[$i],@lsexs[$i],@lstatuss[$i]);

				#Group (new/old)
				if (defined @grp[$i] && @grp[$i]) {
					my $groupid;
					# test si group exist
					my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,@grp[$i]) if (defined @grp[$i] && @grp[$i]);
					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@grp[$i]) unless defined $group;
					$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
					$groupid = $group->{group_id} unless defined $last_groupid;
					my $patient_id=$last_patient_id->{'LAST_INSERT_ID()'};
				#Patient Group
					queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$groupid) if ($groupid);
				}
			};
			$j++;
		}
		$i++;
	}	
	chop($validR);
	chop($validP);

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
				my @ListMeth = split(/,/,$validMeth);	
				foreach my $m (@ListMeth) {
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
############################################# Run Sample Person ######################################################

sub runPersonSection {
	my $runid = $cgi->param('RunSel');
	my $projid = $cgi->param('ProjSel'); # voir si project_id ou project_id_dest, PAs fait
	my $patid = $cgi->param('PatSel');
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	warn Dumper "$runid,$projid";
	my $runListId = querySample::getSamplePersonsFrom_Run_Project_ProjectDest($buffer->dbh,$runid,$projid);	
	my @data;
	my %hdata;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
#	$hdata{identifier}="SampleId";
#	$hdata{label}="SampleId";
#	$hdata{identifier}="PatId";
#	$hdata{label}="PatId";
	my $nbPatRun=0;
	my $row=1;
	foreach my $c (@$runListId){
		my %s;
		if (defined $patid) {
			next unless $patid==$c->{patient_id};
		}
		$s{Row} = $row++;
		# Run Project Capture
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{ProjectCurrentId} = $c->{project_id};
		$s{ProjectId} = $c->{project_id_dest} if $c->{project_id_dest};
		$s{ProjectId} = $c->{project_id} if (! $c->{project_id_dest});
		$s{ProjectId} += 0;
		$s{ProjectCurrentName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectCurrentId});
		$s{ProjectName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectId});
		$s{ProjectIdDest} = 0;
		$s{ProjectIdDest} = $c->{project_id_dest} if $c->{project_id_dest};
		$s{ProjectNameDest} = "";
		$s{ProjectNameDest} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id_dest}) if $c->{project_id_dest};
		$s{CaptureId} = $c->{capture_id};
		$s{CaptureId} += 0;
		my $cap = queryPolyproject::getCaptureName($buffer->dbh,$s{CaptureId});
		$s{capName} = $cap->[0]->{capName};
		
		#Sample Person Patient
		my $sampleId=$c->{sample_id};
		#$s{SampleId}=$c->{sample_id};
		#$s{SampleId} += 0;
		$s{PatId} = $c->{person_id};
		$s{PatId} += 0;
		$s{PatCodeName} = $c->{code_name};
		$s{patientName} = $c->{name};
		$s{family} = $c->{family};
		$s{father} = $c->{father};
		$s{mother} = $c->{mother};
		$s{Sex} = $c->{sex};		
		$s{Status} = $c->{status};
		
		#Sample info
		$s{bc} = $c->{bar_code};
		$s{bc2} = $c->{bar_code_2};

		$s{iv} = "";	
		$s{iv} = $c->{identity_vigilance} if $c->{identity_vigilance};	
		$s{iv_vcf} = "";
		$s{iv_vcf} = $c->{identity_vigilance_vcf} if $c->{identity_vigilance_vcf};
		
		$s{control} = $c->{control};		
		#$s{control} += 0;
		$s{flowcell} = $c->{flowcell};
		$s{lane} = $c->{lane} if $c->{lane};
		$s{lane} = "" unless $c->{lane};

		# Machine
		$s{machine} = queryPolyproject::getSequencingMachines($buffer->dbh,$s{RunId});
		# Method seq
		$s{methseq} = queryPolyproject::getMethSeq($buffer->dbh,$s{RunId});
		# Plateform
		my $plateformList = queryPolyproject::getPlateform($buffer->dbh,$s{RunId});	
		$s{Plateform}=join(" ",map{$_->{name}}@$plateformList);
		# Date
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;

		#Group
		my $group= querySample::getGroupsFromSample($buffer->dbh,$sampleId);
		$s{group} = $group->{name} if defined $group->{name};
		$s{group} = "" unless defined $group->{name};

		# Methods		
		my $i_snp = querySample::getMethodsNameFromSample($buffer->dbh,"SNP",$sampleId);
		$s{MethSnp} = $i_snp->{meths};
		my $i_aln = querySample::getMethodsNameFromSample($buffer->dbh,"ALIGN",$sampleId);
		$s{MethAln} = $i_aln->{meths};

		#Phenotype Patient
		my $patPhenotype = querySample::getPersonPhenotype($buffer->dbh,$s{PatId});
		$s{phenotype}="";		
		$s{phenotype}=join(",",map{$_->{name}}@$patPhenotype) if defined $patPhenotype;

		#Users & User Groups
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

		#control
		if(($s{ProjectId}==0) && ($s{ProjectCurrentId}==0)) {
			$s{FreeRun}=1;
		} else {
			$s{FreeRun}=""
		}
		$s{FreeRun} = 3 unless ( $s{MethAln} );#blue => Plt Imagine
		$s{FreeRun} = 3 unless ( $s{MethSnp} );#blue => Plt Imagine

		$nbPatRun++;
		push(@data,\%s);
	}	
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub runPersonSection_OLD {
	my $runid = $cgi->param('RunSel');
	my $projid = $cgi->param('ProjSel'); # voir si project_id ou project_id_dest, PAs fait
	my $patid = $cgi->param('PatSel');
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	warn Dumper "$runid,$projid";
	my $runListId = querySample::getSamplePersonsFrom_Run_Project_ProjectDest($buffer->dbh,$runid,$projid);	
	my @data;
	my %hdata;
	$hdata{identifier}="PatId";
	$hdata{label}="PatId";
	my $nbPatRun=0;
	foreach my $c (@$runListId){
		my %s;
		if (defined $patid) {
			next unless $patid==$c->{patient_id};
		}
		# Run Project Capture
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{ProjectCurrentId} = $c->{project_id};
		$s{ProjectId} = $c->{project_id_dest} if $c->{project_id_dest};
		$s{ProjectId} = $c->{project_id} if (! $c->{project_id_dest});
		$s{ProjectId} += 0;
		$s{ProjectCurrentName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectCurrentId});
		$s{ProjectName} = queryPolyproject::getProjectName($buffer->dbh,$s{ProjectId});
		$s{ProjectIdDest} = 0;
		$s{ProjectIdDest} = $c->{project_id_dest} if $c->{project_id_dest};
		$s{ProjectNameDest} = "";
		$s{ProjectNameDest} = queryPolyproject::getProjectName($buffer->dbh,$c->{project_id_dest}) if $c->{project_id_dest};
		$s{CaptureId} = $c->{capture_id};
		$s{CaptureId} += 0;
		my $cap = queryPolyproject::getCaptureName($buffer->dbh,$s{CaptureId});
		$s{capName} = $cap->[0]->{capName};
		
		#Sample Person Patient
		my $sampleId=$c->{sample_id};
		$s{PatId} = $c->{person_id};
		$s{PatId} += 0;
		$s{PatCodeName} = $c->{code_name};
		$s{patientName} = $c->{name};
		$s{family} = $c->{family};
		$s{father} = $c->{father};
		$s{mother} = $c->{mother};
		$s{Sex} = $c->{sex};		
		$s{Status} = $c->{status};
		
		#Sample info
		$s{bc} = $c->{bar_code};
		$s{bc2} = $c->{bar_code_2};

		$s{iv} = "";	
		$s{iv} = $c->{identity_vigilance} if $c->{identity_vigilance};	
		$s{iv_vcf} = "";
		$s{iv_vcf} = $c->{identity_vigilance_vcf} if $c->{identity_vigilance_vcf};
		
		$s{control} = $c->{control};		
		#$s{control} += 0;
		$s{flowcell} = $c->{flowcell};
		$s{lane} = $c->{lane} if $c->{lane};
		$s{lane} = "" unless $c->{lane};

		# Machine
		$s{machine} = queryPolyproject::getSequencingMachines($buffer->dbh,$s{RunId});
		# Method seq
		$s{methseq} = queryPolyproject::getMethSeq($buffer->dbh,$s{RunId});
		# Plateform
		my $plateformList = queryPolyproject::getPlateform($buffer->dbh,$s{RunId});	
		$s{Plateform}=join(" ",map{$_->{name}}@$plateformList);
		# Date
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;

		#Group
		my $group= querySample::getGroupsFromSample($buffer->dbh,$sampleId);
		$s{group} = $group->{name} if defined $group->{name};
		$s{group} = "" unless defined $group->{name};

		# Methods		
		my $i_snp = querySample::getMethodsNameFromSample($buffer->dbh,"SNP",$sampleId);
		$s{MethSnp} = $i_snp->{meths};
		my $i_aln = querySample::getMethodsNameFromSample($buffer->dbh,"ALIGN",$sampleId);
		$s{MethAln} = $i_aln->{meths};

		#Phenotype Patient
		my $patPhenotype = querySample::getPersonPhenotype($buffer->dbh,$s{PatId});
		$s{phenotype}="";		
		$s{phenotype}=join(",",map{$_->{name}}@$patPhenotype) if defined $patPhenotype;

		#Users & User Groups
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

		#control
		if(($s{ProjectId}==0) && ($s{ProjectCurrentId}==0)) {
			$s{FreeRun}=1;
		} else {
			$s{FreeRun}=""
		}
		$s{FreeRun} = 3 unless ( $s{MethAln} );#blue => Plt Imagine
		$s{FreeRun} = 3 unless ( $s{MethSnp} );#blue => Plt Imagine

		$nbPatRun++;
		push(@data,\%s);
	}	
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub sexPersonProjectSection {
	my $projid= $cgi->param('ProjId');
	my $sex= $cgi->param('Sex');
	my $patientList;
	$patientList = querySample::getSampleFrom_SexPerson_ProjectId($buffer->dbh,$sex,$projid);
#	$patientList = querySample::getPersonProjectFrom_Sex($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="patname";
	$hdata{label}="patproj";
	foreach my $c (@$patientList){
		next unless $c->{id};
		next unless $c->{projname};
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
#		if ($sex) {
#			if ($sex == 1 ) {next if $s{sex} == 2}
#			if ($sex == 2 ) {next if $s{sex} == 1}			
#		}	
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{projectid} <=> $a->{projectid} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub sexPersonProjectSection_OLD {
	my $projid= $cgi->param('ProjId');
	my $sex= $cgi->param('Sex');
	my $patientList;
	$patientList = querySample::getPersonProjectFrom_Sex($buffer->dbh,$sex,$projid);
#	$patientList = querySample::getPersonProjectFrom_Sex($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="patname";
	$hdata{label}="patproj";
	foreach my $c (@$patientList){
		next unless $c->{id};
		next unless $c->{projname};
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
#		if ($sex) {
#			if ($sex == 1 ) {next if $s{sex} == 2}
#			if ($sex == 2 ) {next if $s{sex} == 1}			
#		}	
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{projectid} <=> $a->{projectid} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}


#	upPersonSection();
#./manageRun.pl option=upPerson partial=0 choice=U run=3813 projname=NGS2021_4805 currentprojname= PatIdSel=89137 family=3813-JM3 father= mother= sex=1 status=1 bc= iv= flowcell= capture=oncoB_reduit2 machine=NEXTSEQ500 plateform=HEMATO methseq=paired-end aln=agent call=bipd PatNameSel=3813-JM3 GroupNameSel=

sub upPersonSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $partial = $cgi->param('partial');#1 from project , 0 from run
	
	my $runId = $cgi->param('run');
		my @fieldR = split(/,/,$runId);	
#	my $projectId = $cgi->param('project');
	my $listChoice = $cgi->param('choice');
		my @fieldCh = split(/,/,$listChoice);
	my $listProject = $cgi->param('projname');
		my @fieldG = split(/,/,$listProject);
	my @fieldGI;
	for (my $i = 0; $i< scalar(@fieldG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,@fieldG[$i]);
		$res->{projectId} += 0;
		@fieldGI[$i] = $res->{projectId};
	}
	my $listCurrentProject = $cgi->param('currentprojname');
		my @fieldCG = split(/,/,$listCurrentProject);
	my @fieldCGI;
	for (my $i = 0; $i< scalar(@fieldCG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,@fieldCG[$i]);
		$res->{projectId} += 0;
		@fieldCGI[$i] = $res->{projectId};
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
#	my $listDesPat = $cgi->param('desPat'); ########################## Decription Patient Person à supprimer
#		my @fieldD = split(/,/,$listDesPat);
	my $listBC = $cgi->param('bc');
		my @fieldB = split(/,/,$listBC);	
	my $listBC2 = $cgi->param('bc2');
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

	my $listCapture = $cgi->param('capture');
		my @fieldC = split(/,/,$listCapture);
	my @fieldCI;
	for (my $i = 0; $i< scalar(@fieldC); $i++) {
		my $res = queryPolyproject::getCaptureFromName($buffer->dbh,@fieldC[$i]);
		$res->{captureId} += 0;
		@fieldCI[$i] = $res->{captureId};
		my $relcProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,@fieldCGI[$i]);		
		my $relProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,@fieldGI[$i]);
		my $relCap = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,@fieldCI[$i]);
		my $relCapj=join(" ",map{$_->{name}}@$relCap) if defined $relCap ;		
		if (($relcProj ne $relCapj) && $relcProj) {
		### End Autocommit dbh ###########
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
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,@fieldAl[$i],"ALIGN");
		$res->{id} += 0;
		@fieldAln[$i] = $res->{id};
	}	
	my $listCall = $cgi->param('call');
		my @fieldCa = split(/,/,$listCall);	
	my @fieldCall;
	for (my $i = 0; $i< scalar(@fieldCa); $i++) {
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,@fieldCa[$i],"SNP");
		$res->{id} += 0;
		@fieldCall[$i] = $res->{id};
	}	

	my $listGroup = $cgi->param('GroupNameSel');
		my @fieldGN = my @fieldGNname= split(/,/,$listGroup,-1);
		
	for (my $i = 0; $i< scalar(@fieldGN); $i++) {
		my $res = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGN[$i]);
		$res->{group_id} += 0;
		@fieldGN[$i] = $res->{group_id} if $res->{group_id};
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
		warn "totot";		
#		my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,@fieldN[$i]);
		my $pname=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$fieldN[$i]);
#		warn Dumper $pname;
		for my $p (@$pname) {
			if ($p->{run_id} != $fieldR[$i]) {
				$validR.=$p->{name}.":".$p->{run_id}."," ;
			}
		warn "totot1";		
#			my $proj=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,@fieldN[$i]);
			my $proj=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$fieldN[$i]);
			if (defined $proj) {
			warn "totot2";		
				if ($p->{run_id} != @fieldR[$i]) {
			warn "totot3";		
#					my $nameproj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$p->{run_id},$proj->[0]->{project_id});
					my $nameproj=querySample::getProjectNamefromPerson($buffer->dbh,$p->{run_id},$proj->[0]->{project_id});# PAS TESTER
					$validP.=$p->{name}.":". $nameproj->{name}."," if $nameproj->{name};
				}
			}
		}
		if (@fieldCh[$i] eq "U") {
			warn "totot4";
  #			queryPolyproject::upPatientInfo($buffer->dbh,@fieldI[$i],@fieldN[$i],@fieldS[$i],@fieldT[$i],@fieldD[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i]);
#			my $r_sp=querySample::getSampleFrom_PersonId($buffer->dbh,$c->{patient_id});#for select where person_id
#		#	warn Dumper $r_sp;
#			my $sampleId=$r_sp->{sample_id};
 # 			my $r_sp=querySample::getSamplePerson_Id($buffer->dbh,@fieldI[$i],1); #for select where person_id
#  			my @s_sampleid=join(",",map{$_->{sample_id}}@$r_sp);
			my $r_sp=querySample::getSampleFrom_PersonId($buffer->dbh,$fieldI[$i]);#for select where person_id
			my $sampleId=$r_sp->{sample_id};
#		 	if (scalar @s_sampleid) {
		 	if ($sampleId) {
      			# my ($dbh,$personid,$status,$father,$mother) = @_;
#				querySample::upPersonInfo($buffer->dbh,$fieldI[$i],$fieldN[$i],$fieldS[$i],$fieldT[$i],$fieldF[$i],$fieldA[$i],$fieldM[$i]);
#				querySample::upPersonInfo($buffer->dbh,$fieldI[$i],$fieldT[$i],$fieldA[$i],$fieldM[$i]);#sex
				querySample::upPersonInfo($buffer->dbh,$fieldI[$i],$fieldS[$i],$fieldA[$i],$fieldM[$i]);
#				querySample::upSampleInfo($buffer->dbh,@s_sampleid,@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldCI[$i]);		 		
        		#my ($dbh,$sampleid,$personname,$sex,$family,$bc,$iv,$flowcell,$capid) = @_;
#				querySample::upSampleInfo($buffer->dbh,$sampleId,$fieldN[$i],$fieldS[$i],$fieldF[$i],$fieldB[$i],$fieldBG[$i],$fieldO[$i],$fieldCI[$i]);	
#				querySample::upSampleInfo($buffer->dbh,$sampleId,$fieldN[$i],$fieldS[$i],$fieldF[$i],$fieldB[$i],$fieldB2[$i],$fieldBG[$i],$fieldO[$i],$fieldCI[$i]);#status		 		
				querySample::upSampleInfo($buffer->dbh,$sampleId,$fieldN[$i],$fieldT[$i],$fieldF[$i],$fieldB[$i],$fieldB2[$i],$fieldBG[$i],$fieldO[$i],$fieldCI[$i]);		 		
 #				queryPolyproject::addMeth2pat($buffer->dbh,@fieldI[$i],@fieldAln[$i]) unless $partial;
#				queryPolyproject::addMeth2pat($buffer->dbh,@fieldI[$i],@fieldCall[$i]) unless $partial;
				unless ($partial) {
					@fieldAln[$i]+= 0;
					@fieldCall[$i]+= 0;
#	#				warn "not partial";
#					warn Dumper @fieldAln[$i];
#					my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$fieldAln[$i]);
					my $ctrlSM=querySample::isSampleMeth($buffer->dbh,$sampleId,$fieldAln[$i]);
#					warn Dumper $ctrlSM;
					if ($fieldAln[$i]) {
#						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldAln[$i]) unless $ctrlSM->{sample_id};						
						querySample::addMeth2sample($buffer->dbh,$sampleId,$fieldAln[$i]) unless $ctrlSM->{sample_id};						
					}					
#					$ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$fieldCall[$i]);
					$ctrlSM=querySample::isSampleMeth($buffer->dbh,$sampleId,$fieldCall[$i]);
					if ($fieldCall[$i]) {
						querySample::addMeth2sample($buffer->dbh,$sampleId,$fieldCall[$i]) unless $ctrlSM->{sample_id};
						
					}					
#					querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldAln[$i]) if $fieldAln[$i];
#					querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldCall[$i]) if $fieldCall[$i];					
					warn "end not partial";
				}
				@fieldI[$i]+= 0;
#				my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,@fieldI[$i]);
#				my $groupid=querySample::getGroupIdFromSampleGroups($buffer->dbh,@s_sampleid);
				my $groupid=querySample::getGroupIdFromSampleGroups($buffer->dbh,$sampleId);
				if ($groupid->[0]->{group_id}) {
					@fieldGN[$i]+= 0;
					warn "totot5";		
#					queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) if @fieldGNname[$i] eq "";
#					querySample::removeGroup2sample($buffer->dbh,@s_sampleid) if @fieldGNname[$i] eq "";
					querySample::removeGroup2sample($buffer->dbh,$sampleId) if @fieldGNname[$i] eq "";
  					next if @fieldGNname[$i] eq "";
					warn "totot5-1";
   					#queryPolyproject::upPatientGroup($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
#   					querySample::upSampleGroup($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
   					querySample::upSampleGroup($buffer->dbh,$sampleId,@fieldGN[$i]) if (@fieldGN[$i]);
   					#queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) unless (@fieldGN[$i]);
   					#querySample::removeGroup2sample($buffer->dbh,@s_sampleid) unless (@fieldGN[$i]);
 					unless (@fieldGN[$i]) {					
						warn "totot6";		
 #  					queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]);
#  						querySample::removeGroup2sample($buffer->dbh,@s_sampleid);
   						querySample::removeGroup2sample($buffer->dbh,$sampleId);
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]);
						@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 						#queryPolyproject::addGroup2patient($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
# 						querySample::addGroup2sample($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
 						querySample::addGroup2sample($buffer->dbh,$sampleId,@fieldGN[$i]) if (@fieldGN[$i]);
 					}

 				} else {
 					unless (@fieldGN[$i] ) {
						warn "totot7";		
#						queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) if @fieldGNname[$i] eq "";
#						querySample::removeGroup2sample($buffer->dbh,@s_sampleid) if @fieldGNname[$i] eq "";
						querySample::removeGroup2sample($buffer->dbh,$sampleId) if @fieldGNname[$i] eq "";
  						next if @fieldGNname[$i] eq "";
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless @fieldGNname[$i] eq "" ;
						@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 					}
 				
  					if (@fieldGN[$i] ) { 					
						warn "totot8";
						my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGNname[$i]) if defined @fieldGNname[$i];
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless defined $group;
						$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
						$groupid = $group->{group_id} unless defined $last_groupid;
						#my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless @fieldGNname[$i] eq "" ;
						#@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
						@fieldGN[$i] = $groupid;
 					}
  					#queryPolyproject::addGroup2patient($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
 # 					querySample::addGroup2sample($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
  					querySample::addGroup2sample($buffer->dbh,$sampleId,@fieldGN[$i]) if (@fieldGN[$i]);
 				}
		 	}			
		} elsif (@fieldCh[$i] eq "A") {
					warn "titi1";	
			$validNew.=@fieldN[$i].",";
			@fieldGI[$i]=0 if @fieldGI[$i] eq "";
#			my $last_patient_id=queryPolyproject::addPatientInfo($buffer->dbh,@fieldN[$i],@fieldN[$i],$runId,@fieldS[$i],@fieldT[$i],@fieldD[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i],@fieldGI[$i]);
#			my $last_patient_id=queryPolyproject::addPatientInfo($buffer->dbh,@fieldN[$i],@fieldN[$i],$runId,@fieldS[$i],@fieldT[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i],@fieldGI[$i]);
#			my $last_person_id=querySample::insertPerson($buffer->dbh,@fieldN[$i],@fieldN[$i],@fieldS[$i],@fieldT[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i]);
# j'en suis là: toto
#1) insert person sans code name avec status mother father 
#2) rechercher selon captureId @fieldCI[$i] => release =speceis 2L 
#3) codename avec 2L+format lastperson-id => modif persone codename
#4) insert sample avec name init-name sex family
			#warn Dumper  @fieldCI[$i];
			my $r_rel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$fieldCI[$i]);
			#warn Dumper $r_rel;
			my $species;
			$species =$r_rel->[0]->{species} if $r_rel->[0]->{species};
			$species ="human" unless $r_rel->[0]->{species};
			#warn Dumper $species;
			my $r_species=querySample::getSpecies_FromName($buffer->dbh,$species);
		#warn Dumper $r_species;
			#warn Dumper  $r_species->{code};
#$r_species->{species_id}
		#my $codename= $r_species->{code}.sprintf("%010d", $c->{patient_id});
		
		
      			# my ($dbh,$personid,$status,$father,$mother) = @_;
#				querySample::upPersonInfo($buffer->dbh,$fieldI[$i],$fieldN[$i],$fieldS[$i],$fieldT[$i],$fieldF[$i],$fieldA[$i],$fieldM[$i]);
				#querySample::upPersonInfo($buffer->dbh,$fieldI[$i],$fieldT[$i],$fieldA[$i],$fieldM[$i]);
				
			#my $last_person_id=querySample::insertPerson($buffer->dbh,$fieldN[$i],$fieldN[$i],$fieldS[$i],$fieldT[$i],$fieldF[$i],$fieldA[$i],$fieldM[$i]);#sex
				
			my $last_person_id=querySample::insertPerson($buffer->dbh,$r_species->{species_id},$fieldS[$i],$fieldA[$i],$fieldM[$i]);
			my $person_id=$last_person_id->{'LAST_INSERT_ID()'};
			my $codename= $r_species->{code}.sprintf("%010d",$person_id);
			querySample::upPersonCodeName($buffer->dbh,$person_id,$codename);			
	#my ($dbh,$personid,$runid,$projectid,$projectiddest,$captureid,$name,$initname,$family,$sex,$barcode,$fowcell,$identity_vigilance) = @_;
#			my $last_sample_id=querySample::insertSample($buffer->dbh,$person_id,$runId,0,@fieldGI[$i],@fieldCI[$i],$fieldN[$i],$fieldN[$i],$fieldF[$i],$fieldS[$i],@fieldB[$i],@fieldB2[$i],@fieldO[$i],@fieldBG[$i]);#status
			my $last_sample_id=querySample::insertSample($buffer->dbh,$person_id,$runId,0,@fieldGI[$i],@fieldCI[$i],$fieldN[$i],$fieldN[$i],$fieldF[$i],$fieldT[$i],@fieldB[$i],@fieldB2[$i],@fieldO[$i],@fieldBG[$i]);
 			my $sample_id=$last_sample_id->{'LAST_INSERT_ID()'};
#			querySample::insertSamplePerson($buffer->dbh,$sample_id,$person_id) if ($sample_id && $person_id);			
#die;			
			# Aln Call
#			queryPolyproject::addMeth2pat($buffer->dbh,$patient_id,@fieldAln[$i]);
#			queryPolyproject::addMeth2pat($buffer->dbh,$patient_id,@fieldCall[$i]);
			@fieldAln[$i]+= 0;
			@fieldCall[$i]+= 0;
			querySample::addMeth2sample($buffer->dbh,$sample_id,$fieldAln[$i]) if $fieldAln[$i];
			querySample::addMeth2sample($buffer->dbh,$sample_id,$fieldCall[$i]) if $fieldCall[$i];	
#			warn Dumper @fieldGN[$i];	
					
			if (defined @fieldGN[$i] && @fieldGN[$i] ne "") {
 					warn "titi2";		
 				my $groupid;
				my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGNname[$i]) if defined @fieldGNname[$i];
				my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless defined $group;
				$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
				$groupid = $group->{group_id} unless defined $last_groupid;
#				queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$groupid) if ($groupid);
				querySample::addGroup2sample($buffer->dbh,$sample_id,$groupid) if ($groupid);
			}
		}
	}
	my $resEmptyGrp=queryPolyproject::searchEmptyGroup($buffer->dbh);# ????
	#warn Dumper $resEmptyGrp;
	if ($resEmptyGrp->{group_id}) {
					warn "titi3";		
	#	my $resPatGrp=queryPolyproject::searchPatientGroup($buffer->dbh);# PAS BON
		my $resPatGrp=querySample::searchSampleGroup($buffer->dbh);#
		#print "===============================================================\n";
		#print "Empty Name : Purge table group from groupid of patient_groups\n";
		#print "===============================================================\n";
		foreach my $u (@$resPatGrp) {
					warn "titi4";		
			my $grpid=queryPolyproject::getGroupId($buffer->dbh,$u->{group_id});
#			warn Dumper $grpid;
			queryPolyproject::delGroup($buffer->dbh,$grpid->[0]->{group_id}) unless $grpid->[0]->{groupName};	
			querySample::delSampleGroup($buffer->dbh,$u->{group_id}) unless $grpid->[0]->{group_id};	
		}
		
		#print "\n";
		#print "===============================================================\n";
		#print "Empty Name : Purge table group and patient_groups:\n";
		#print "===============================================================\n";
		my $resGrp=queryPolyproject::searchGroup($buffer->dbh);
		foreach my $u (@$resGrp) {
					warn "titi5";		
#			my $patientid="";
#			my $patientid=queryPolyproject::getPatientIdFromPatientGroups($buffer->dbh,$u->{group_id}) unless $u->{name};
			my $r_sg="";
			$r_sg=querySample::getSampleGroups_Id($buffer->dbh,$u->{group_id},1) unless $u->{name}; #1 for select where group_id
			if (defined $r_sg && $r_sg ne "") {
				warn "titi6";		
				querySample::delSampleGroup($buffer->dbh,$u->{group_id},$r_sg->{sample_id}) unless $u->{name};	#?????? A TESTER
			}
			queryPolyproject::delGroup($buffer->dbh,$u->{group_id}) unless $u->{name};	
		}

		#print "===============================================================\n";
		#print "============================= END =============================\n";
		#print "===============================================================\n";
	
	}
	# Add pat
	if ($validNew) {
					warn "titi7";		
#		my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runId);
#		queryPolyproject::upNbPat2run($buffer->dbh,$runId,scalar(@$listPatRun));
		my $l_samples=querySample::getSamplesfrom_Run($buffer->dbh,$runId);
		queryPolyproject::upNbPat2run($buffer->dbh,$runId,scalar(@$l_samples));
	}
	
	chop($validP,$validR,$validNew);
#	
	#### End Autocommit dbh ###########
	$dbh->commit();
	if ($partial) {
					warn "titi8";		
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

sub upPersonSection_OLD {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $partial = $cgi->param('partial');#1 from project , 0 from run
	
	my $runId = $cgi->param('run');
		my @fieldR = split(/,/,$runId);	
#	my $projectId = $cgi->param('project');
	my $listChoice = $cgi->param('choice');
		my @fieldCh = split(/,/,$listChoice);
	my $listProject = $cgi->param('projname');
		my @fieldG = split(/,/,$listProject);
	my @fieldGI;
	for (my $i = 0; $i< scalar(@fieldG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,@fieldG[$i]);
		$res->{projectId} += 0;
		@fieldGI[$i] = $res->{projectId};
	}
	my $listCurrentProject = $cgi->param('currentprojname');
		my @fieldCG = split(/,/,$listCurrentProject);
	my @fieldCGI;
	for (my $i = 0; $i< scalar(@fieldCG); $i++) {
		my $res = queryPolyproject::getProjectFromName($buffer->dbh,@fieldCG[$i]);
		$res->{projectId} += 0;
		@fieldCGI[$i] = $res->{projectId};
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
#	my $listDesPat = $cgi->param('desPat'); ########################## Decription Patient Person à supprimer
#		my @fieldD = split(/,/,$listDesPat);
	my $listBC = $cgi->param('bc');
		my @fieldB = split(/,/,$listBC);	
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

	my $listCapture = $cgi->param('capture');
		my @fieldC = split(/,/,$listCapture);
	my @fieldCI;
	for (my $i = 0; $i< scalar(@fieldC); $i++) {
		my $res = queryPolyproject::getCaptureFromName($buffer->dbh,@fieldC[$i]);
		$res->{captureId} += 0;
		@fieldCI[$i] = $res->{captureId};
		my $relcProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,@fieldCGI[$i]);
		
		my $relProj=queryPolyproject::getReleaseNameFromProject($buffer->dbh,@fieldGI[$i]);
		my $relCap = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,@fieldCI[$i]);
		my $relCapj=join(" ",map{$_->{name}}@$relCap) if defined $relCap ;
		if (($relcProj ne $relCapj) && $relcProj) {
		### End Autocommit dbh ###########
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
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,@fieldAl[$i],"ALIGN");
		$res->{id} += 0;
		@fieldAln[$i] = $res->{id};
	}	
	my $listCall = $cgi->param('call');
		my @fieldCa = split(/,/,$listCall);	
	my @fieldCall;
	for (my $i = 0; $i< scalar(@fieldCa); $i++) {
		my $res = queryPolyproject::getMethodsFromName($buffer->dbh,@fieldCa[$i],"SNP");
		$res->{id} += 0;
		@fieldCall[$i] = $res->{id};
	}	

	my $listGroup = $cgi->param('GroupNameSel');
		my @fieldGN = my @fieldGNname= split(/,/,$listGroup,-1);
#warn "debGN";
#warn Dumper @fieldGN;
#warn Dumper @fieldGNname;		
		
	for (my $i = 0; $i< scalar(@fieldGN); $i++) {
		my $res = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGN[$i]);
		$res->{group_id} += 0;
		@fieldGN[$i] = $res->{group_id} if $res->{group_id};
	}
#warn "finGN";
#warn Dumper @fieldGN;
#warn Dumper @fieldGNname;		
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
		warn "totot";		
#		my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,@fieldN[$i]);
		my $pname=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$fieldN[$i]);
#		warn Dumper $pname;
		for my $p (@$pname) {
			if ($p->{run_id} != $fieldR[$i]) {
				$validR.=$p->{name}.":".$p->{run_id}."," ;
			}
		warn "totot1";		
#			my $proj=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,@fieldN[$i]);
			my $proj=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,$fieldN[$i]);
			if (defined $proj) {
			warn "totot2";		
				if ($p->{run_id} != @fieldR[$i]) {
			warn "totot3";		
#					my $nameproj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$p->{run_id},$proj->[0]->{project_id});
					my $nameproj=querySample::getProjectNamefromPerson($buffer->dbh,$p->{run_id},$proj->[0]->{project_id});# PAS TESTER
					$validP.=$p->{name}.":". $nameproj->{name}."," if $nameproj->{name};
				}
			}
		}
		if (@fieldCh[$i] eq "U") {
			warn "totot4";		
  #			queryPolyproject::upPatientInfo($buffer->dbh,@fieldI[$i],@fieldN[$i],@fieldS[$i],@fieldT[$i],@fieldD[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i]);
  			my $r_sp=querySample::getSamplePerson_Id($buffer->dbh,@fieldI[$i],1); #for select where person_id
  			my @s_sampleid=join(",",map{$_->{sample_id}}@$r_sp);
		 	if (scalar @s_sampleid) {
				querySample::upPersonInfo($buffer->dbh,@fieldI[$i],@fieldN[$i],@fieldS[$i],@fieldT[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i]);
				querySample::upSampleInfo($buffer->dbh,@s_sampleid,@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldCI[$i]);		 		
 #				queryPolyproject::addMeth2pat($buffer->dbh,@fieldI[$i],@fieldAln[$i]) unless $partial;
#				queryPolyproject::addMeth2pat($buffer->dbh,@fieldI[$i],@fieldCall[$i]) unless $partial;
				unless ($partial) {
					@fieldAln[$i]+= 0;
					@fieldCall[$i]+= 0;
#	#				warn "not partial";
#					warn Dumper @fieldAln[$i];
					my $ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$fieldAln[$i]);
#					warn Dumper $ctrlSM;
					if ($fieldAln[$i]) {
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldAln[$i]) unless $ctrlSM->{sample_id};						
					}					
					$ctrlSM=querySample::isSampleMeth($buffer->dbh,@s_sampleid,$fieldCall[$i]);
					if ($fieldCall[$i]) {
						querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldCall[$i]) unless $ctrlSM->{sample_id};
						
					}					
#					querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldAln[$i]) if $fieldAln[$i];
#					querySample::addMeth2sample($buffer->dbh,@s_sampleid,$fieldCall[$i]) if $fieldCall[$i];					
					warn "end not partial";
				}
				@fieldI[$i]+= 0;
#				my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,@fieldI[$i]);
				my $groupid=querySample::getGroupIdFromSampleGroups($buffer->dbh,@s_sampleid);
				if ($groupid->[0]->{group_id}) {
					@fieldGN[$i]+= 0;
					warn "totot5";		
#					queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) if @fieldGNname[$i] eq "";
					querySample::removeGroup2sample($buffer->dbh,@s_sampleid) if @fieldGNname[$i] eq "";
  					next if @fieldGNname[$i] eq "";
					warn "totot5-1";
   					#queryPolyproject::upPatientGroup($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
   					querySample::upSampleGroup($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
   					#queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) unless (@fieldGN[$i]);
   					#querySample::removeGroup2sample($buffer->dbh,@s_sampleid) unless (@fieldGN[$i]);
 					unless (@fieldGN[$i]) {					
						warn "totot6";		
 #  					queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]);
   						querySample::removeGroup2sample($buffer->dbh,@s_sampleid);
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]);
						@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 						#queryPolyproject::addGroup2patient($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
 						querySample::addGroup2sample($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
 					}

 				} else {
 					unless (@fieldGN[$i] ) {
						warn "totot7";		
#						queryPolyproject::removeGroup2patient($buffer->dbh,@fieldI[$i]) if @fieldGNname[$i] eq "";
						querySample::removeGroup2sample($buffer->dbh,@s_sampleid) if @fieldGNname[$i] eq "";
  						next if @fieldGNname[$i] eq "";
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless @fieldGNname[$i] eq "" ;
						@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
 					}
 				
  					if (@fieldGN[$i] ) { 					
						warn "totot8";
						my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGNname[$i]) if defined @fieldGNname[$i];
						my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless defined $group;
						$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
						$groupid = $group->{group_id} unless defined $last_groupid;
						#my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless @fieldGNname[$i] eq "" ;
						#@fieldGN[$i] = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
						@fieldGN[$i] = $groupid;
 					}
  					#queryPolyproject::addGroup2patient($buffer->dbh,@fieldI[$i],@fieldGN[$i]) if (@fieldGN[$i]);
  					querySample::addGroup2sample($buffer->dbh,@s_sampleid,@fieldGN[$i]) if (@fieldGN[$i]);
 				}
		 	}			
		} elsif (@fieldCh[$i] eq "A") {
					warn "titi1";	
			$validNew.=@fieldN[$i].",";
			@fieldGI[$i]=0 if @fieldGI[$i] eq "";
#			my $last_patient_id=queryPolyproject::addPatientInfo($buffer->dbh,@fieldN[$i],@fieldN[$i],$runId,@fieldS[$i],@fieldT[$i],@fieldD[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i],@fieldGI[$i]);
#			my $last_patient_id=queryPolyproject::addPatientInfo($buffer->dbh,@fieldN[$i],@fieldN[$i],$runId,@fieldS[$i],@fieldT[$i],@fieldB[$i],@fieldBG[$i],@fieldO[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i],@fieldCI[$i],@fieldGI[$i]);
			my $last_person_id=querySample::insertPerson($buffer->dbh,@fieldN[$i],@fieldN[$i],@fieldS[$i],@fieldT[$i],@fieldF[$i],@fieldA[$i],@fieldM[$i]);
			my $person_id=$last_person_id->{'LAST_INSERT_ID()'};
#			runid,project_id,project_id_dest,capture_id,bar_code,flowcell,iv			
			my $last_sample_id=querySample::insertSample($buffer->dbh,$runId,0,@fieldGI[$i],@fieldCI[$i],@fieldB[$i],@fieldO[$i],@fieldBG[$i]);
			my $sample_id=$last_sample_id->{'LAST_INSERT_ID()'};
			querySample::insertSamplePerson($buffer->dbh,$sample_id,$person_id) if ($sample_id && $person_id);			
#die;			
			# Aln Call
#			queryPolyproject::addMeth2pat($buffer->dbh,$patient_id,@fieldAln[$i]);
#			queryPolyproject::addMeth2pat($buffer->dbh,$patient_id,@fieldCall[$i]);
			@fieldAln[$i]+= 0;
			@fieldCall[$i]+= 0;
			querySample::addMeth2sample($buffer->dbh,$sample_id,$fieldAln[$i]) if $fieldAln[$i];
			querySample::addMeth2sample($buffer->dbh,$sample_id,$fieldCall[$i]) if $fieldCall[$i];	
			warn Dumper @fieldGN[$i];	
					
			if (defined @fieldGN[$i] && @fieldGN[$i] ne "") {
 					warn "titi2";		
 				my $groupid;
				my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,@fieldGNname[$i]) if defined @fieldGNname[$i];
				my $last_groupid = queryPolyproject::newGroup($buffer->dbh,@fieldGNname[$i]) unless defined $group;
				$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
				$groupid = $group->{group_id} unless defined $last_groupid;
#				queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$groupid) if ($groupid);
				querySample::addGroup2sample($buffer->dbh,$sample_id,$groupid) if ($groupid);
			}
		}
	}
	my $resEmptyGrp=queryPolyproject::searchEmptyGroup($buffer->dbh);# ????
	warn Dumper $resEmptyGrp;
	if ($resEmptyGrp->{group_id}) {
					warn "titi3";		
	#	my $resPatGrp=queryPolyproject::searchPatientGroup($buffer->dbh);# PAS BON
		my $resPatGrp=querySample::searchSampleGroup($buffer->dbh);#
		#print "===============================================================\n";
		#print "Empty Name : Purge table group from groupid of patient_groups\n";
		#print "===============================================================\n";
		foreach my $u (@$resPatGrp) {
					warn "titi4";		
			my $grpid=queryPolyproject::getGroupId($buffer->dbh,$u->{group_id});
#			warn Dumper $grpid;
			queryPolyproject::delGroup($buffer->dbh,$grpid->[0]->{group_id}) unless $grpid->[0]->{groupName};	
			querySample::delSampleGroup($buffer->dbh,$u->{group_id}) unless $grpid->[0]->{group_id};	
		}
		
		#print "\n";
		#print "===============================================================\n";
		#print "Empty Name : Purge table group and patient_groups:\n";
		#print "===============================================================\n";
		my $resGrp=queryPolyproject::searchGroup($buffer->dbh);
		foreach my $u (@$resGrp) {
					warn "titi5";		
#			my $patientid="";
#			my $patientid=queryPolyproject::getPatientIdFromPatientGroups($buffer->dbh,$u->{group_id}) unless $u->{name};
			my $r_sg="";
			$r_sg=querySample::getSampleGroups_Id($buffer->dbh,$u->{group_id},1) unless $u->{name}; #1 for select where group_id
			if (defined $r_sg && $r_sg ne "") {
				warn "titi6";		
				querySample::delSampleGroup($buffer->dbh,$u->{group_id},$r_sg->{sample_id}) unless $u->{name};	#?????? A TESTER
			}
			queryPolyproject::delGroup($buffer->dbh,$u->{group_id}) unless $u->{name};	
		}

		#print "===============================================================\n";
		#print "============================= END =============================\n";
		#print "===============================================================\n";
	
	}
	# Add pat
	if ($validNew) {
					warn "titi7";		
#		my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runId);
#		queryPolyproject::upNbPat2run($buffer->dbh,$runId,scalar(@$listPatRun));
		my $l_samples=querySample::getSamplesfrom_Run($buffer->dbh,$runId);
		queryPolyproject::upNbPat2run($buffer->dbh,$runId,scalar(@$l_samples));
	}
	
	chop($validP,$validR,$validNew);
#	
	#### End Autocommit dbh ###########
	$dbh->commit();
	if ($partial) {
					warn "titi8";		
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

sub delPersonSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatient = $cgi->param('PatSel');
	my @field = split(/,/,$listPatient);
	my $failedPerson="";
	if($listPatient) {
		my @delPerson;
		foreach my $u (@field) {
  #     	my $personid = queryPolyproject::getFreePatientId($buffer->dbh,$runid, $u);
       		my $r_person = querySample::getFreeSampleIdFrom_Person($buffer->dbh,$runid, $u);
 #      		warn "r_person";
  #       	warn Dumper $r_person;
  #      		warn Dumper $r_person->{perpson_id};
  			$failedPerson.=$u."," unless scalar @$r_person;
 #  		warn Dumper $failedPerson;
  			
  			my (@s_personid,@s_sampleid);
       		@s_personid=join(",",map{$_->{person_id}}@$r_person) if scalar @$r_person;
 #      		warn Dumper @s_personid;
       		@s_sampleid=join(",",map{$_->{sample_id}}@$r_person) if scalar @$r_person;
 #      		warn Dumper @s_sampleid;
       		push(@delPerson,"@s_personid,@s_sampleid") if (@s_personid && @s_sampleid);
 #      		warn Dumper @delPerson;
 		}
 		chop($failedPerson);
 #		warn "failed";
 #		warn Dumper $failedPerson;
# 		warn '-------------------';
 #		warn Dumper @delPerson;
#		warn Dumper scalar @delPerson;
#		warn '-------------------';
#		chop($failedPerson);
		if (scalar @delPerson) {
			#warn "ttttttttttttt";
			foreach my $v (@delPerson) {
			#	warn Dumper $v;
				my @sp_v= split(/,/,$v);
			#	warn Dumper $sp_v[0];#person
			#	warn Dumper $sp_v[1];#sample
				# a faire: supp sample , sup sample_meth, sup person  #########################################
				#my $delpatientid = queryPolyproject::delFreePatientId($buffer->dbh,$runid, $v);
				#queryPolyproject::delPatMeth($buffer->dbh, $sp_v[0]);
				querySample::delFreeSample_FromRun($buffer->dbh,$runid, $sp_v[1]);
				querySample::delMeth2sample($buffer->dbh, $sp_v[1]);		
				querySample::delPerson($buffer->dbh, $sp_v[0]);
 				#querySample::delSamplePerson($buffer->dbh, $sp_v[1],$sp_v[0]);
 			#	warn '------------------e';
			}
			#my $yet_runid = queryPolyproject::getRunIdfromPatient($buffer->dbh,$runid);		
			my $yet_runid = querySample::getRunIdfrom_Person($buffer->dbh,$runid);	
			#warn Dumper $yet_runid;
			#Dans ce cas: Suppression en cascade dans run_method_seq, run_plateform,run_methods,run_machine
			queryPolyproject::delFreeRun($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunMethSeq($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunPlateform($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunMachine($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			#warn "delRun" unless exists $yet_runid->[0]->{run_id};
			#my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runid);
			my $l_samples=querySample::getSamplesfrom_Run($buffer->dbh,$runid);
			queryPolyproject::upNbPat2run($buffer->dbh,$runid,scalar(@$l_samples));
			
#### End Autocommit dbh ###########
			my $message="";
			$message="<br>Except for Persons(id): $failedPerson" if $failedPerson;
			$dbh->commit();
			sendOK("Patients deleted from run ID: ". $runid.$message);	
		} else {
### End Autocommit dbh ###########
			sendError("Patients Not deleted from run ID: ". $runid);			
		}
	}	
}

sub delPersonSection_OLD {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatient = $cgi->param('PatSel');
	my @field = split(/,/,$listPatient);
	my $failedPerson="";
	if($listPatient) {
		my @delPerson;
		foreach my $u (@field) {
  #     	my $personid = queryPolyproject::getFreePatientId($buffer->dbh,$runid, $u);
       		my $r_person = querySample::getFreeSampleIdFrom_Person($buffer->dbh,$runid, $u);
  #      		warn Dumper $r_person;
  #      		warn Dumper $r_person->{perpson_id};
  			$failedPerson.=$u."," unless scalar @$r_person;
  			my (@s_personid,@s_sampleid);
       		@s_personid=join(",",map{$_->{person_id}}@$r_person) if scalar @$r_person;
       		#warn Dumper @s_personid;
       		@s_sampleid=join(",",map{$_->{sample_id}}@$r_person) if scalar @$r_person;
       		#warn Dumper @s_sampleid;
       		push(@delPerson,"@s_personid,@s_sampleid") if (@s_personid && @s_sampleid);
 		}
 		chop($failedPerson);
# 		warn '-------------------';
 #		warn Dumper @delPerson;
#		warn Dumper scalar @delPerson;
		warn '-------------------';
#		chop($failedPerson);
		if (scalar @delPerson) {
			foreach my $v (@delPerson) {
#				warn Dumper $v;
				my @sp_v= split(/,/,$v);
				warn Dumper $sp_v[0];#person
				warn Dumper $sp_v[1];#sample
				# a faire: supp sample , sup sample_meth, sup person  #########################################
				#my $delpatientid = queryPolyproject::delFreePatientId($buffer->dbh,$runid, $v);
				#queryPolyproject::delPatMeth($buffer->dbh, $sp_v[0]);
				querySample::delFreeSample_FromRun($buffer->dbh,$runid, $sp_v[1]);
				querySample::delMeth2sample($buffer->dbh, $sp_v[1]);		
				querySample::delPerson($buffer->dbh, $sp_v[0]);
 				querySample::delSamplePerson($buffer->dbh, $sp_v[1],$sp_v[0]);
 				warn '------------------e';
			}
			#my $yet_runid = queryPolyproject::getRunIdfromPatient($buffer->dbh,$runid);		
			my $yet_runid = querySample::getRunIdfrom_Person($buffer->dbh,$runid);	
			warn Dumper $yet_runid;
			#Dans ce cas: Suppression en cascade dans run_method_seq, run_plateform,run_methods,run_machine
			queryPolyproject::delFreeRun($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunMethSeq($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunPlateform($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			queryPolyproject::delFreeRunMachine($buffer->dbh,$runid) unless exists $yet_runid->[0]->{run_id};
			warn "delRun" unless exists $yet_runid->[0]->{run_id};
			#my $listPatRun=queryPolyproject::getFreeRunIdfromPatient($buffer->dbh,$runid);
			my $l_samples=querySample::getSamplesfrom_Run($buffer->dbh,$runid);
			queryPolyproject::upNbPat2run($buffer->dbh,$runid,scalar(@$l_samples));
			
#### End Autocommit dbh ###########
			my $message="";
			$message="<br>Except for Persons(id): $failedPerson" if $failedPerson;
			$dbh->commit();
			sendOK("Patients deleted from run ID: ". $runid.$message);	
		} else {
### End Autocommit dbh ###########
			sendError("Patients Not deleted from run ID: ". $runid);			
		}
	}	
}

sub upPersonIVSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatname= $cgi->param('name');
	my $listIV= $cgi->param('iv');	
	
	my @PatName = split(/,/,$listPatname);
	my @IV = split(/,/,$listIV);

	my %seenP = ();
	my @duplicateP = map { 1==$seenP{$_}++ ? $_ : () } @PatName;
	if (scalar @duplicateP) {
		$dbh->commit();
		sendError("<B>Error Dulicated Patients:</B> @duplicateP");
	}

	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @IV;
	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	#warn Dumper @duplicateB;
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code (IV): $messageduplicateB" if scalar @duplicateB;
	#warn Dumper $messageduplicateB;
	my $notValid;
	my $Valid;
	for (my $i = 0; $i< scalar(@PatName); $i++) {
#getPatIdfromName getSamplePerson_Id		ctrlPersonNameInRun
		my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,@PatName[$i],$runid);
		my @s_sampleid;
		@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers) if scalar @$r_pers;
		$notValid.="@PatName[$i]"."," unless scalar @$r_pers;
		$Valid.="@PatName[$i]"."," if scalar @$r_pers;
		querySample::upSample_inIV($buffer->dbh,@s_sampleid,$IV[$i]) if scalar @$r_pers;
	}
	
	chop($notValid);	
	chop($Valid);	
#### End Autocommit dbh ###########
	$dbh->commit();	
	my $errorMessage="";
	$errorMessage="<br><b>Error: Genotype Bar Code (IV) NOT updated for Patients:</b> ".$notValid." not in Run: ".$runid if $notValid;
	if 	($Valid) {
		sendOK("OK: Genotype Bar Code (IV) updated for Patients: ".$Valid. " in Run: ".$runid.$errorMessage.$messageduplicateB);
	} else {
		sendError($errorMessage);
	}
}

sub upPersonIVSection_OLD {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $runid = $cgi->param('RunSel');
	my $listPatname= $cgi->param('name');
	my $listIV= $cgi->param('iv');	
	
	my @PatName = split(/,/,$listPatname);
	warn Dumper @PatName;
	my @IV = split(/,/,$listIV);

	my %seenP = ();
	my @duplicateP = map { 1==$seenP{$_}++ ? $_ : () } @PatName;
	if (scalar @duplicateP) {
		$dbh->commit();
		sendError("<B>Error Dulicated Patients:</B> @duplicateP");
	}

	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @IV;
	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	#warn Dumper @duplicateB;
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code (IV): $messageduplicateB" if scalar @duplicateB;
	#warn Dumper $messageduplicateB;
	my $notValid;
	my $Valid;
	for (my $i = 0; $i< scalar(@PatName); $i++) {
#getPatIdfromName getSamplePerson_Id		ctrlPersonNameInRun
		my $r_pers=querySample::getSamplePersonFrom_Name_Run($buffer->dbh,@PatName[$i],$runid);
		my @s_sampleid;
		@s_sampleid=join(",",map{$_->{sample_id}}@$r_pers) if scalar @$r_pers;
		$notValid.="@PatName[$i]"."," unless scalar @$r_pers;
		$Valid.="@PatName[$i]"."," if scalar @$r_pers;
		querySample::upSample_inIV($buffer->dbh,@s_sampleid,$IV[$i]) if scalar @$r_pers;
	}
	
	chop($notValid);	
	chop($Valid);	
#### End Autocommit dbh ###########
	$dbh->commit();	
	my $errorMessage="";
	$errorMessage="<br><b>Error: Genotype Bar Code (IV) NOT updated for Patients:</b> ".$notValid." not in Run: ".$runid if $notValid;
	if 	($Valid) {
		sendOK("OK: Genotype Bar Code (IV) updated for Patients: ".$Valid. " in Run: ".$runid.$errorMessage.$messageduplicateB);
	} else {
		sendError($errorMessage);
	}
}

sub upSamplePersonControlSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $control = $cgi->param('control');
	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
#		my $patname = queryPolyproject::getPatientName($buffer->dbh,@PatId[$i]);
#		my $patname = querySample::getPersonName($buffer->dbh,@PatId[$i]);
		my $patname = querySample::getPersonName($buffer->dbh,$PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;

#		my $r_sp=querySample::getSamplePerson_Id($buffer->dbh,@PatId[$i],1); #for select where person_id
 # 		my @s_sampleid=join(",",map{$_->{sample_id}}@$r_sp);
 # 		next unless scalar @s_sampleid;  		
 		my $r_sp=querySample::getSampleFrom_PersonId($buffer->dbh,$PatId[$i]);#for select where person_id
		my $sampleId=$r_sp->{sample_id};
		next unless $r_sp->{sample_id};
		if ($sampleId) {
		 	querySample::upSample_inControl($buffer->dbh,$sampleId,$control);
		}		
	}
#### End Autocommit dbh ###########
	my $mess;
	$mess="NOT " unless $control;
	$mess="" if $control;
	$dbh->commit();	
	sendOK("OK: Patients: ".$patname_chg. " are <b>$mess"."Patient Control</b>");
}

sub upSamplePersonControlSection_OLD {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	my $control = $cgi->param('control');

	my $patname_chg;
	my $patname_chg;
	for (my $i = 0; $i< scalar(@PatId); $i++) {
#		my $patname = queryPolyproject::getPatientName($buffer->dbh,@PatId[$i]);
		my $patname = querySample::getPersonName($buffer->dbh,@PatId[$i]);
		my $r_sp=querySample::getSamplePerson_Id($buffer->dbh,@PatId[$i],1); #for select where person_id
  		my @s_sampleid=join(",",map{$_->{sample_id}}@$r_sp);
  		next unless scalar @s_sampleid;  		
 		 if (scalar @s_sampleid) {
		 	querySample::upSample_inControl($buffer->dbh,@s_sampleid,$control);#J'en suis là#######################################
		 }
		
	}
#### End Autocommit dbh ###########
	my $mess;
	$mess="NOT " unless $control;
	$mess="" if $control;
	$dbh->commit();	
	sendOK("OK: Patients: ".$patname_chg. " are <b>$mess"."Patient Control</b>");
}

=mod
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
		my $patname = queryPolyproject::getPatientName($buffer->dbh,@PatId[$i]);
		next unless $patname;
		$patname_chg.=$patname."," if $patname;
		queryPolyproject::upPatientControl($buffer->dbh,@PatId[$i],$control);
	}
	chop $patname_chg;
#### End Autocommit dbh ###########
	my $mess;
	$mess="NOT " unless $control;
	$mess="" if $control;
	$dbh->commit();	
	sendOK("OK: Patients: ".$patname_chg. " are <b>$mess"."Patient Control</b>");
}
=cut

############################################# old ######################################################
sub genomicRunPatientSection {
	my $runid = $cgi->param('RunSel');
	my $projid = $cgi->param('ProjSel');
	my $patid = $cgi->param('PatSel');
	my $selplt = $cgi->param('SelPlt');
# group "STAFF"
	my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
	my $super_grp=$s_group->{UGROUP_ID};
	warn Dumper $projid;
	my $runListId = queryPolyproject::getPatientsInfoProjectDest($buffer->dbh,$runid,$projid);
	my @data;
	my %hdata;
	$hdata{identifier}="PatId";
	$hdata{label}="PatId";
	my $nbPatRun=0;
	foreach my $c (@$runListId){
		my %s;
		if (defined $patid) {
			next unless $patid==$c->{person_id};
		}
		$s{RunId} = $c->{run_id};
		$s{RunId} += 0;
		$s{PatId} = $c->{patient_id};
		$s{PatId} += 0;
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
		$s{patientName} = $c->{name};
		$s{family} = $c->{family};
		$s{father} = $c->{father};
		$s{mother} = $c->{mother};
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
#toto			@usergroup=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_->{name}=>1}@$usergroupList}};
			my @usercum;
			my %seenV;	
#			foreach my $c (@$usergroupList){
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
		$nbPatRun++;
		push(@data,\%s);
	}
	queryPolyproject::upNbPat2run($buffer->dbh,$runid,$nbPatRun);
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

exit(0);



