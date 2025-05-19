#!/usr/bin/perl
########################################################################
###### sc_ManagePatient.pl #################################################
#./sc_newCumulProject_Patient.pl< /data-isilon/bipd-src/plaza/poly-disk/tmp/data_dev/inDocker_project_patient
#./sc_newCumulProject_Patient.pl -rel="HG_MT"< /data-isilon/bipd-src/plaza/poly-disk/tmp/data_dev/inDocker_project_patient
#./new_polyproject.pl opt=newPoly golden_path=HG19_MT description=test database=Polyexome dejaVu=1 somatic=0

########################################################################
#use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";

use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;
use CGI;

use GBuffer;
use connect;
use queryPolyproject;
use queryPerson;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;
#use warnings;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $h;
my $help;
my $insert;
my $rel;
my $des;
my $methods;
my $tproject; #target Project (not new Project)
my $oldproject; # old project
my $profile;

my $message ="Usage :
	$0	-h or -help 
  	$0	-rel=<release>	< File_In			# Input tabulated file of NGSProject and Patient Name 
 											show old projet patient
  	$0	-rel=<release>	-insert	< File_In		# create a New Project (when no -tproject) and New Patients
  											from Input tabulated file
  	optional parameters:
 		-oldproject=<NGSProject1,NGSProject2,...>	All Patients from NGSProject1,NGSProject2,...
 			In this case, no need for Input tabulated file File_In
 		-tproject=<NGS Target Project>			NGS Project to append Patient 
			
  		-des=<description>				if this option is not set: List of all Input projects 
  						  		use quoted \"<description>\" if spaces are used
  		-methods=<method1,method2>			Methods: calling, alignment or others methods
  		-profile=<Profile Name>
  		
  	File In: No Header, Tabulated lines with NGSProject, Patient Name [Optionally third column: Status case/control] 
  	NGS<Year>_<.....>	Patient1	case
  	NGS<Year>_<.....>	Patient2	case
  	NGS<Year>_<.....>	PatientN	control
  	
  	Status : status=2  for case or affected or 2
  	         status=1  for control or unaffected or 1
\n";

GetOptions(
	'h'  => \$h,
	'help'  => \$help,
	'insert'  => \$insert,
	'rel=s' => \$rel,
	'des=s' => \$des,
	'methods=s' => \$methods,
	'tproject=s' => \$tproject,
	'oldproject=s' => \$oldproject,
	'profile=s' => \$profile,
) or confess($message);

if ($h|$help) {
	confess ($message);	
}

confess($message) unless ($rel);
my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$rel);#$golden_path
die("$message Error: Unknown Release Genome : $rel\n") unless $releaseid;

my @methId;
if ($methods) {
	$methods=~ s/ //g;
	my @meth=split(/,/,$methods);
	foreach my $m (@meth){
		my $r_meth = getMethodFromName($buffer->dbh,$m);
		die("$message Error: Unknown Method Name : $m\n") unless $r_meth->{method_id};
		push(@methId,$r_meth->{method_id}) if $r_meth->{method_id};		
	}	
}
my $t_projid;
my $tprojectid;
if ($tproject) {
	$t_projid = queryPolyproject::getProjectFromName($buffer->dbh,$tproject);
	die("$message Error: Unknown NGS Project Name : $tproject\n") unless $t_projid->{projectId};
	$tprojectid=$t_projid->{projectId};	
}

my $i_profile;
my $i_profileid;
if ($profile) {
	$i_profile = queryPolyproject::getProfile_byName($buffer->dbh,$profile);
	die("$message Error: Unknown Profile Name : $profile\n") unless $i_profile->{profile_id};
	$i_profileid=$i_profile->{profile_id};		
}
# J'en suis la ::a tester ###############################################
#if ($oldproject && !-t STDIN) {
#    die "Erreur : aucun fichier d'entrée fourni en redirection (< File_in)\n";
#}

#if (-t STDIN) {
#    die "Erreur : aucun fichier d'entrée fourni en redirection (< File_in)\n";
#}
if ($oldproject) {
	warn "toto";
	if (!-t STDIN) {
		warn "titi";
	    die "$message Error : choose between -oldprojet or  Input tabulated file of NGSProject Patient Name  (< File_in)\n";
	}	
#    die "Erreur : aucun fichier d'entrée fourni en redirection (< File_in)\n";
} else {
	if (-t STDIN) {
		warn "tutu";
	    die "$message Error : Need an Input tabulated file of NGSProject Patient Name  (< File_in)\n";
	#    die "Erreur : aucun fichier d'entrée fourni en redirection (< File_in)\n";
	}	
	
}

my $ok=0;
my $okstat=0;
my $cpt=1;
my @Indata;
my $l_projects="Duplicated: ";
if ($oldproject) {
	$l_projects .= $oldproject;
	$l_projects =~ s/,/ /g;	
	@Indata=getPatientsfromProjects($oldproject);
	$ok=1;
} else {
	while (my $line = <>) {
    	chomp $line;
   	 	next unless $line;
		if ($tproject) {
			print "Target Project: $tprojectid $tproject \n\n" unless $insert;		
		}
    	print "Input $cpt: $line\n" unless $insert;
		my @sp_line = split(/\s+/,$line);#tab ou espace
		die "Input file not valid" unless $sp_line[0];
		die "Input file not valid" unless $sp_line[1];
		if ( $sp_line[2] ) {
			$okstat=1;
			die "Error: Status value synonym list: for affected => affected, case, 2  for unafected => control, unaffected, 1" if $sp_line[2] !~ m/(affected)|(case)|(control)|(unaffected)|(1)|(2)/;		
		}
		my $projNGS=$sp_line[0];
		my $patNGS=$sp_line[1];
		my $s_projid = queryPolyproject::getProjectFromName($buffer->dbh,$projNGS);
		my $projectid=$s_projid->{projectId};
		die "Error: Input Project not valid: $projNGS" unless $s_projid->{projectId};
		my $s_patient=getPatient_FromName_Projid($buffer->dbh,$patNGS,$projectid);
		#warn Dumper $s_patient;
		#warn Dumper $s_patient->{profile_id};
		#die;
		my $patientid=$s_patient->{patient_id};
	
		die "Error: Input Patient not valid in Project $projNGS: $patNGS" unless $s_patient->{patient_id};
		my $r_patpers=queryPerson::getPatientPerson_byPatientId($buffer->dbh,$patientid);	
		die "Error: Input Patient - Person not valid" unless (scalar(@$r_patpers)>=1);
		my $personid=$r_patpers->[0]->{person_id};
	
		my $p=queryPolyproject::getPatient_byPatientId($buffer->dbh,$patientid);
		my $p_profileid=$p->{profile_id};
		#warn "toto";
		#warn Dumper $p_profileid;
		my $r_profile;
		$r_profile = queryPolyproject::getProfile_byId($buffer->dbh,$p_profileid) if $p_profileid;
		#warn Dumper $r_profile;
		#warn Dumper $r_profile->[0]->{name};
		#warn "toto1";
		unless ($i_profileid) {		
			die "$message Error: No Profile for Patient $patNGS" unless ($p_profileid);	
		}
		my $p_profile="";
		$p_profile=$r_profile->[0]->{name} if $r_profile->[0]->{name};
		$p_profile=$profile unless $r_profile->[0]->{name};
		if ( $sp_line[2] ) {
			print "Project: $projectid $projNGS - Patient: $patientid $patNGS PersonId: $personid Status: $sp_line[2] Profile:$p_profile\n" unless $insert;
			print "\n" unless $insert;
			my $status=0;
			$status=2 if $sp_line[2] =~ m/(affected)|(case)|(2)/;
			$status=1 if $sp_line[2] !~ m/(affected)|(case)|(2)/;
			push(@Indata,$projectid.",".$projNGS.",".$patientid.",".$patNGS.",".$personid.",".$status);
		} else {
			print "Project: $projectid $projNGS - Patient: $patientid $patNGS PersonId: $personid Profile:$p_profile\n" unless $insert;
			print "\n" unless $insert;
			push(@Indata,$projectid.",".$projNGS.",".$patientid.",".$patNGS.",".$personid);
		
		}
		$l_projects.=$projNGS." ";
		$ok=1;
		$cpt++;
		#die if $cpt>66;
	}
}
my %seen;
my $uniq_des=join(' ', grep { !$seen{$_}++ } split(' ', $l_projects)) unless $des;# redundant uniq
$l_projects=$uniq_des unless $des;
$des=$l_projects unless $des;
my $newprojectid;
my $newprojectname;
if ($insert && $ok) {
	### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
	#############################
	unless ($tproject) {
		my $username = $ENV{'LOGNAME'};
		my %config;
		my $database="Polyexome";
		$config{type_db} = $database;
		my $dbid = queryPolyproject::getDbId($buffer->dbh,$config{type_db});
		die "Error: undefined database $dbid " unless ($dbid);
		my $type={"id"=>3};
		my $prefix = "NGS";
		#call => renvoit id et nom
		my $description = $des;
		my $query = qq{CALL PolyprojectNGS.new_project("$prefix",$type->{id},"$description");};
		my $sth = $buffer->dbh()->prepare( $query );
		$sth->execute();

		my $res = $sth->fetchall_arrayref({});
		sendError("No project created") if ( scalar(@$res) == 0 );

		$newprojectid = $res->[0]->{project_id};
		sendError("No project created") unless ($newprojectid);

		queryPolyproject::addDb($buffer->dbh,$newprojectid,$dbid);
		#add Release to Project
		queryPolyproject::addRelease($buffer->dbh,$newprojectid,$releaseid);
	
		#decription dejaVu somatic update Project	
		my $dejavu=0;
		my $somatic=0;
		queryPolyproject::upProject($buffer->dbh,$newprojectid,$description,$dejavu,$somatic);
#		upProject($buffer->dbh,$newprojectid,$dejavu,$somatic);
	### End Autocommit dbh ###########
		$dbh->commit();
	
		my $typeId=$type->{id};
		$newprojectname = $res->[0]->{name};
		print "New Project: $newprojectid $newprojectname\n";
##############################
		$ENV{'DATABASE'} = "";
		my $buffer = GBuffer->new(-verbose=>1);
		my $projectG = $buffer->newProject(-name=>$newprojectname);
		$projectG->makePath();
# 		cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
	} else {
		my $dejavu=0;
		my $somatic=0;
		my $description = $des;
		queryPolyproject::upProject($buffer->dbh,$tprojectid,$description,$dejavu,$somatic);
		
	}
	### Autocommit dbh ###########
	$dbh = $buffer->dbh;		
	$dbh->{AutoCommit} = 0;
	#############################
	$cpt=1;
	foreach my $c (@Indata){
		my $projectId=(split(',',$c))[0];
		my $projectName=(split(',',$c))[1];
		my $patientId=(split(',',$c))[2];
		my $patientName=(split(',',$c))[3];
		my $personId=(split(',',$c))[4];
		my $patstatus=(split(',',$c))[5] if $okstat;
		my $r=getPatient_FromName_Projid($buffer->dbh,$patientName,$projectId);
		my $r_status=$r->{status};
		$r_status=$patstatus if $okstat;
		my $r_profileid="";
		$r_profileid=$r->{profile_id} if $r->{profile_id};
		$r_profileid=$i_profileid unless $r->{profile_id};
		my $last_patient_id;
		my $newpatient_id;
		if ($tproject) {			
			$last_patient_id=newPatient($buffer->dbh,$r->{name},$r->{name},$tprojectid,$r->{run_id},$r->{capture_id},$r->{family},$r->{flowcell},$r->{bar_code},$r->{bar_code2},$r->{identity_vigilance},$r->{father},$r->{mother},$r->{sex},$r_status,$r->{type},$r->{species_id},$r_profileid,$r->{lane},$r->{control},$r->{description},$r->{g_project},$r->{identity_vigilance_vcf},$r->{patient_id},$r->{demultiplex_only});
			$newpatient_id=$last_patient_id->{'LAST_INSERT_ID()'};
			print "$cpt Target Project: $tprojectid $tproject - New Patient: $newpatient_id $r->{name} $r->{name} (old patId:$r->{patient_id}) - PersonId: $personId Status: $r_status\n" if $okstat;
			print "$cpt Target Project: $tprojectid $tproject - New Patient: $newpatient_id $r->{name} $r->{name} (old patId:$r->{patient_id}) - PersonId: $personId\n" unless $okstat;
			
		} else {
			$last_patient_id=newPatient($buffer->dbh,$r->{name},$r->{name},$newprojectid,$r->{run_id},$r->{capture_id},$r->{family},$r->{flowcell},$r->{bar_code},$r->{bar_code2},$r->{identity_vigilance},$r->{father},$r->{mother},$r->{sex},$r_status,$r->{type},$r->{species_id},$r_profileid,$r->{lane},$r->{control},$r->{description},$r->{g_project},$r->{identity_vigilance_vcf},$r->{patient_id},$r->{demultiplex_only});
			$newpatient_id=$last_patient_id->{'LAST_INSERT_ID()'};
			print "$cpt Old Project: $projectId $projectName - New Project: $newprojectid $newprojectname - New Patient: $newpatient_id $r->{name} $r->{name} (old patId:$r->{patient_id}) - PersonId: $personId Status: $r_status\n" if $okstat;
			print "$cpt Old Project: $projectId $projectName - New Project: $newprojectid $newprojectname - New Patient: $newpatient_id $r->{name} $r->{name} (old patId:$r->{patient_id}) - PersonId: $personId\n" unless $okstat;
			
		}		 
# Patient Person
		queryPerson::insertPatientPerson($buffer->dbh,$newpatient_id,$personId);		
# Patient Methods
		if ($methods) {
			foreach my $m (@methId){
				queryPolyproject::addMeth2pat($buffer->dbh,$newpatient_id,$m);
			}
		}
		print "\n";
		$cpt++;
	}
	$dbh->commit();	
}

sub getPatientsfromProjects {
	my ($projects) = @_;
	my @s_projects=split(",",$projects);
	ctrlValidProjects(@s_projects);
	for (my $i = 0; $i< scalar(@s_projects); $i++) {
		my $s_projid = queryPolyproject::getProjectFromName($buffer->dbh,$s_projects[$i]);
		my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$s_projid->{projectId});
		foreach my $c (@$patientsP) {
			#warn Dumper $c;
#push(@Indata,$projectid.",".$projNGS.",".$patientid.",".$patNGS.",".$personid);
		#	print "Project: $projectid $projNGS - Patient: $patientid $patNGS PersonId: $personid Profile:$p_profile\n" unless $insert;
		#	print "\n" unless $insert;
		#	push(@Indata,$projectid.",".$projNGS.",".$patientid.",".$patNGS.",".$personid);
			#warn Dumper $p;
			my $r_patpers=queryPerson::getPatientPerson_byPatientId($buffer->dbh,$c->{patient_id});	
			die "Error: Input Patient - Person not valid" unless (scalar(@$r_patpers)>=1);
			my $p=queryPolyproject::getPatient_byPatientId($buffer->dbh,$c->{patient_id});
			my $p_profileid=$p->{profile_id};	
			unless ($i_profileid) {		
			#die "$message Error: No Profile for Patient $patNGS" unless ($p_profileid);	
				die "$message Error: No Profile for Patient $c->{name}" unless ($p_profileid);	
			}
			my $r_profile;
			$r_profile = queryPolyproject::getProfile_byId($buffer->dbh,$p_profileid) if $p_profileid;
			my $p_profile="";
			$p_profile=$r_profile->[0]->{name} if $r_profile->[0]->{name};
			$p_profile=$profile unless $r_profile->[0]->{name};
			
			
			
			my $personid=$r_patpers->[0]->{person_id};
			print "Project: $s_projid->{projectId} $s_projects[$i] - Patient: $c->{patient_id} $c->{name} PersonId: $personid Profile:$p_profile\n" unless $insert;
			print "\n" unless $insert;
			push(@Indata,$s_projid->{projectId}.",".$s_projects[$i].",".$c->{patient_id}.",".$c->{name}.",".$personid);

		#	warn Dumper $c->{};
		}
	}
#	warn Dumper @Indata;
	return @Indata;
}

sub ctrlValidProjects {
	my (@projects) = @_;
	my $ok=1;
	my $notvalid="";
	for (my $i = 0; $i< scalar(@projects); $i++) {
		my $s_projid = queryPolyproject::getProjectFromName($buffer->dbh,$projects[$i]);
		$notvalid.=$projects[$i]."," unless $s_projid->{projectId};
		$ok=0 unless $s_projid->{projectId};
	}
	chop $notvalid;
	die "Error: Unknown Projects : $notvalid" unless ($ok);
	return;
}

## getDB

sub getPatient_FromName_Projid {
	my ($dbh,$patname,$projid) = @_;
	my $query = qq{
		SELECT * 
		FROM PolyprojectNGS.patient a
		WHERE a.name='$patname'
		AND a.project_id='$projid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub newPatient {
	my ($dbh,$patient,$origin,$projectid,$rid,$captureid,$fam,$fc,$bc,$bc2,$iv,$father,$mother,$sex,$status,$type,$speciesid,$profileid,$lane,$control,$description,$gproject,$idvcf,$opatid,$mult) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,project_id,run_id,capture_id,family,flowcell,bar_code,bar_code2,identity_vigilance,father,mother,sex,status,type,species_id,profile_id,lane,control,description,g_project,identity_vigilance_vcf,origin_patient_id,demultiplex_only) 
 		values ("$patient","$origin","$projectid","$rid","$captureid","$fam","$fc","$bc","$bc2","$iv","$father","$mother","$sex","$status","$type","$speciesid","$profileid","$lane","$control","$description","$gproject","$idvcf","$opatid","$mult");
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

sub getPatientMethods_FromPatid {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT * 
		FROM PolyprojectNGS.patient_methods
		WHERE patient_id='$patid'
		;		
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getPatientGroups_FromPatid {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT * 
		FROM PolyprojectNGS.patient_groups
		WHERE patient_id='$patid'
		;		
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getMethodFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  *
			from PolyprojectNGS.methods M
			where M.name='$name';
	};
	#warn Dumper $query;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upProject {
        my ($dbh,$pid,$dejavu,$somatic) = @_;
 		my $sql = qq{
 			UPDATE PolyprojectNGS.projects
 			SET dejaVu='$dejavu', somatic='$somatic'
			WHERE project_id='$pid';
 		};
 		return ($dbh->do($sql));
}

sub upProjectDescription {
        my ($dbh,$pid,$dejavu,$somatic) = @_;
 		my $sql = qq{
 			UPDATE PolyprojectNGS.projects
 			SET dejaVu='$dejavu', somatic='$somatic'
			WHERE project_id='$pid';
 		};
 		return ($dbh->do($sql));
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

exit(0);

