#!/usr/bin/perl
########################################################################
###### sc_ManagePatient.pl #################################################
#./sc_ManagePatient.pl
########################################################################
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

use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use queryPerson;
use Data::Dumper;
use Carp;
use JSON;
use Getopt::Long;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $opt;
my $insert;

my $patname;
my $dup_patname;
my $dup_family;
my $runid;
my $project;
my $h;
my $help;

my $message ="Usage :
\t$0	-h or -help 
\t$0	-opt=<option name>\toption name: duplicatePatient
\t\t\tduplicatePatient: Duplicate a Patient from a Run. The new patient is identical to the original Patient 
\t\t\t\tExcept: Patient Name for the Duplicated patient Name
\t\t\t\tExcept: Origin_patient_id, value given by Original Patient Id
\t\t\tA link to the same Person is added with a New Patient Id
\t\t\tLinks to Methods are added with a New Patient Id
\t\t\tLinks to Groups are added with a New Patient Id

\t\t-project=<project name>\tNGS Project Name in PolyprojectNGS
\t\t\tOption used alone ==> List All the Patients in a Project         							
\t\t-patname=<Patient Name>\tPatient to be duplicated
\t\t-dup_patname=<Duplicated Patient Name>\tnew Patient Name
\t\t-dup_family=<Duplicated Family Name>\tnew Family Name [optional]

\t\t-insert\tCreate a New Patient Name with <Duplicated Patient Name> 

\n";

=mod
 ./sc_ManagePatient.pl -opt=duplicatePatient -runid=5728 -patname=24OH3464_M -dup_patname=24OH3464_MM

=cut

GetOptions(
	'h'  => \$h,
	'help'  => \$help,
 	'opt=s' => \$opt,
	'insert'  => \$insert,
 	'project=s' => \$project,
	'patname=s' => \$patname,
	'dup_patname=s' => \$dup_patname,
	'dup_family=s' => \$dup_family,
) or confess($message);

if ($h|$help) {
	confess ($message);	
}

unless ($opt && $project) {
	confess ($message);
}


if ($opt eq "duplicatePatient") {
	duplicatePatient();#
}

sub duplicatePatient {
	print "Duplicate Patient\n";
	my $res = queryPolyproject::getProjectFromName($buffer->dbh,$project);
#	warn Dumper  $res;
	die "Unknown Project: $project" unless $res->{projectId};
	$res->{projectId} += 0;
	my $projectid=$res->{projectId};
	
	my $i_runid=queryPolyproject::getRunId($buffer->dbh,$runid);
#	die "Unknown Run Id :$runid" unless  $i_runid->[0]->{run_id};
	
	my $cpt=1;
	unless ($patname) {
		my $patProjList = getPatient_fromProjectId_Name($buffer->dbh,$projectid);
		foreach my $c (@$patProjList) {	
			print "$cpt Project: $c->{project_id} $project\t RunId: $c->{run_id}\t Patient: $c->{patient_id} $c->{name}\t Sex: $c->{sex} Status: $c->{status} Family: $c->{family} Father: $c->{father} Mother: $c->{mother}\n";
			$cpt++;
		}		
	} else {
		my $patProjList = getPatient_fromProjectId_Name($buffer->dbh,$projectid,$patname);
		my $patRunList = getPatient_fromRun_Name($buffer->dbh,$runid,$patname);
		die "Unknown Patient Name: $patname in Project: $project" unless scalar @$patProjList;
		if (scalar @$patProjList==1 ) {
			my $a=$patProjList->[0];
			my $family=$a->{family};
			$family= $dup_family if $dup_family;				
			print "$cpt Project: $a->{project_id} $project\t RunId: $a->{run_id}\t Patient: $a->{patient_id} $a->{name}\t Sex: $a->{sex} Status: $a->{status} Family: $a->{family} Father: $a->{father} Mother: $a->{mother}\n";
			if ($dup_patname) {
				my $family=$a->{family};
				$family= $dup_family if $dup_family;
				my $dup_patProjList = getPatient_fromProjectId_Name($buffer->dbh,$projectid,$dup_patname);
				#my $dup_patRunList = getPatient_fromRun_Name($buffer->dbh,$runid,$dup_patname);
				die "Duplicate Patient Name: $dup_patname is already Present in table Patient for Project: $project " if scalar @$dup_patProjList;

				print "Origin Patient: $a->{patient_id} $a->{name}  Origin: $a->{origin} Project: $a->{project_id} $project Run: $a->{run_id}\n".
				"\t==> CapId: $a->{capture_id} Family: $a->{family} flowcell: $a->{flowcell} bc1: $a->{bar_code}  bc2: $a->{bar_code2} iv: $a->{identity_vigilance} iv_vcf: $a->{identity_vigilance_vcf}\n".
				"\t==> Father: $a->{father} Mother: $a->{mother} Sex: $a->{sex} Status: $a->{status} Type: $a->{type} SpeciesId: $a->{species_id}  ProfileId: $a->{profile_id} Lane: $a->{lane} Control: $a->{control}\n".
				"\t==> ProjectIdDest: $a->{project_id_dest} genomicProject: $a->{g_project} Description: $a->{description} Origin PatientId: $a->{origin_patient_id} Date: $a->{creation_date}\n"; 
				my $originPatId=$a->{patient_id};
				print "New Patient: $dup_patname  Origin: $a->{origin} Project: $a->{project_id} $project Run: $a->{run_id}\n".
				"\t==> CapId: $a->{capture_id} Family: $family flowcell: $a->{flowcell} bc1: $a->{bar_code}  bc2: $a->{bar_code2} iv: $a->{identity_vigilance} iv_vcf: $a->{identity_vigilance_vcf}\n".
				"\t==> Father: $a->{father} Mother: $a->{mother} Sex: $a->{sex} Status: $a->{status} Type: $a->{type} SpeciesId: $a->{species_id}  ProfileId: $a->{profile_id} Lane: $a->{lane} Control: $a->{control}\n".
				"\t==> ProjectIdDest: $a->{project_id_dest} genomicProject: $a->{g_project} Description: $a->{description} Origin PatientId: $originPatId Date: $a->{creation_date}\n"; 
				my $res_patpers=queryPerson::getPatientPerson_byPatientId($buffer->dbh,$a->{patient_id});
				die "Error: multiple Person Id for Patient Id: $a->{patient_id} $a->{name}" if (scalar @$res_patpers >1 );
				die "Error: No Person Id for Patient Id: $a->{patient_id} $a->{name}" if (scalar @$res_patpers ==0 );
				if (scalar @$res_patpers==1 ) {
					my $person_id=$res_patpers->[0]->{person_id};
					print "Person\n";
					print "\t==> Person Id: $person_id\n";
					my $patient_id;
					if ($insert) {
						my $last_patient_id=newPatientRunProjectDate($buffer->dbh,$dup_patname,$a->{origin},$a->{run_id},$a->{capture_id},$family,$a->{flowcell},$a->{bar_code},$a->{bar_code2},$a->{identity_vigilance},$a->{identity_vigilance_vcf},$a->{father},$a->{mother},$a->{sex},$a->{status},$a->{type},$a->{species_id},$a->{profile_id},$a->{lane},$a->{control},$a->{project_id},$a->{project_id_dest},$a->{g_project},$a->{description},$originPatId,$a->{creation_date});
						$patient_id=$last_patient_id->{'LAST_INSERT_ID()'};
						print "\t==> Patient Id: $patient_id   Person Id: $person_id\n";
						queryPerson::insertPatientPerson($buffer->dbh,$patient_id,$person_id);							
					}
										# Ajouter les method;
					my $methodsList=getAllMethods_fromPatId($buffer->dbh,$a->{patient_id});
					print "Methods\n";
					foreach my $c (@$methodsList) {
						print "\t==> Origin Patient: $a->{patient_id} $a->{name} Method: $c->{method_id} $c->{name} $c->{type}\n" unless $insert;
						queryPolyproject::addMeth2pat($buffer->dbh,$patient_id,$c->{method_id}) if $insert;
						print "\t==> New Patient: $patient_id $dup_patname Method: $c->{method_id} $c->{name} $c->{type}\n" if $insert;
						
					}
					# Ajouter les group;
					print "Groups\n";
					my $groupsList=getAllGroups_fromPatId($buffer->dbh,$a->{patient_id});
					foreach my $c (@$groupsList) {
						print "\t==> Origin Patient: $a->{patient_id} $a->{name} Group: $c->{group_id} $c->{name}\n" unless $insert;
						queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$c->{group_id}) if $insert;
						print "\t==> New Patient: $patient_id $dup_patname Group: $c->{group_id} $c->{name}\n" if $insert;
					}
					
					unless ($insert) {
						print "\nWarning: Use -insert to Create a Duplicate Patient\n";	
					}
					
					
				}
			} else {
				confess ($message);					
			}			
		} else {
			die "Multiple Results for RunId $runid And Patient Name: $patname";
		}
	}
}

#sql
sub getPatient_fromProjectId_Name {
	my ($dbh,$projectid,$name) = @_;
	my $query2 = qq {and a.name='$name'};
	$query2 = "" unless $name;
	my $query = qq{
		select *
		FROM PolyprojectNGS.patient a
		where a.project_id='$projectid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatient_fromRun_Name {
	my ($dbh,$runid,$name) = @_;
	my $query2 = qq {and a.name='$name'};
	$query2 = "" unless $name;
	my $query = qq{
		select *
		FROM PolyprojectNGS.patient a
		where a.run_id='$runid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getAllMethods_fromPatId {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT distinct
		pm.patient_id,pm.method_id,m.name,m.type
		FROM PolyprojectNGS.patient_methods pm
		LEFT JOIN PolyprojectNGS.methods m
		ON pm.method_id=m.method_id
		WHERE patient_id='$patid'
		order by m.type
		;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getAllGroups_fromPatId {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT distinct
		pg.patient_id,pg.group_id,g.name
		FROM PolyprojectNGS.patient_groups pg
		LEFT JOIN PolyprojectNGS.group g
		ON pg.group_id=g.group_id
		WHERE patient_id='$patid'
		;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}



sub newPatientRunProjectDate {
	my ($dbh,$patient,$origin,$rid,$captureid,$fam,$fc,$bc,$bc2,$iv,$iv_vcf,$father,$mother,$sex,$status,$type,$speciesid,$profileid,$lane,$control,$projectid,$projectiddest,$gproject,$description,$originpatientid,$date) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,run_id,capture_id,family,flowcell,bar_code,bar_code2,identity_vigilance,identity_vigilance_vcf,father,mother,sex,status,type,species_id,profile_id,lane,control,project_id,project_id_dest,g_project,description,origin_patient_id,creation_date) 
 		values ("$patient","$origin","$rid","$captureid","$fam","$fc","$bc","$bc2","$iv","$iv_vcf","$father","$mother","$sex","$status","$type","$speciesid","$profileid","$lane","$control","$projectid","$projectiddest","$gproject","$description","$originpatientid","$date");
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 



exit(0);

