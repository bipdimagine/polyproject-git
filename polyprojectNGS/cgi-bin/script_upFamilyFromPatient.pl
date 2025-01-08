#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_upFamilyFromPatient.pl
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

#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;
#use warnings;

my $cgi    = new CGI;
my $buffer = GBuffer->new;
#print "Temporary Modified  creation_date  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP In patient\n";

##$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` CHANGE COLUMN `creation_date` `creation_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP");

#die;
my $pat_noFam = get_noFamilyFromPatient($buffer->dbh);
#warn Dumper $pat_noFam;
my $cnt=1;
foreach my $u (@$pat_noFam) {
	#next unless ($u->{patient_id} >=1 && $u->{patient_id} <=2);
	my $family=$u->{name};
	up_FamPatient($buffer->dbh,$u->{patient_id},$family);
	print "$cnt\tpatient Id: $u->{patient_id} name: $u->{name} family: $family \t\t$u->{creation_date}\n";
	$cnt++;	
}
#print "Restore Modified  creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP In patient\n";
#$buffer->dbh->do("ALTER TABLE `PolyprojectNGS`.`patient` CHANGE COLUMN `creation_date` `creation_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ;");

sub get_noFamilyFromPatient {
	my ($dbh) = @_;
#	my $query2 = qq {AND r.run_id='$run'};
#	$query2 = "" unless $run;
	my $query = qq{
		SELECT * FROM PolyprojectNGS.patient
		where family=""
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

sub up_FamPatient {
	my ($dbh,$patid,$family) = @_;
 	my $sql = qq{
		update PolyprojectNGS.patient
		set family=?
		where patient_id='$patid';
	 };
	my $sth= $dbh->prepare($sql);
	$sth->execute($family);
	$sth->finish;
	return;
} 

sub up_DatePatient {
	my ($dbh,$patid,$cdate) = @_;
 	my $sql = qq{
		update PolyprojectNGS.patient
		set creation_date=?
		where patient_id='$patid';
	 };
	my $sth= $dbh->prepare($sql);
	$sth->execute($cdate);
	$sth->finish;
	return;
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

=mod
my $opt;
my $project;
my $methods;
my $patient;

GetOptions(
 		'opt=s' => \$opt,
		'project=s' => \$project,
        'methods=s' => \$methods,
        'patient=s' => \$patient,
        
);
unless ($opt && $project && $methods) {
	confess ("usage :
 $0 -opt=add -project=Project_name -methods=method1,method2,... [-patient=patient1,patient2,...]
 $0 -opt=del -project=Project_name -methods=method1,method2,... [-patient=patient1,patient2,...]
 ex:
 $0 -opt=add -project=NGS2015_0038 -methods=bwa,unifiedgenotyper [-patient=patient1,patient2,...]
 $0 -opt=del -project=NGS2015_0038 -methods=bwa,unifiedgenotyper [-patient=patient1,patient2,...]\n");
}

my $projid = queryPolyproject::getProjectFromName($buffer->dbh,$project);
die( "ERROR: Unknown project: " . $project."\n") unless $projid;

my @fieldP= split(/,/,$patient) if $patient;
my $patidList;
my $invalidPat;
if ($patient) {
	for (my $i = 0; $i< scalar(@fieldP); $i++) {
		my $res = queryPolyproject::getProjectPatientId($buffer->dbh,@fieldP[$i],$projid->{projectId});
		$invalidPat.=@fieldP[$i]."," unless $res;
		next unless $res;
		$patidList.=$res.",";
	}
	chop $patidList;
	chop $invalidPat;
}
my @fieldM = split(/,/,$methods);
my $NotValid="";
for (my $i = 0; $i< scalar(@fieldM); $i++) {
	my $res = queryPolyproject::getMethodFromName($buffer->dbh,@fieldM[$i]);
	$NotValid.=@fieldM[$i]."," unless $res->{methName};
}
chop($NotValid);
die( "ERROR ==> Unknown Methods: " .$NotValid."\n") if $NotValid;
my $patientsP=[];

$patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$projid->{projectId},$patidList) if $patidList;

$patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$projid->{projectId}) unless (defined $patient) ;

#die( "ERROR ==> Unknown Patient from Project: " .$project."\n") unless (scalar(@$patientsP) && not $patient);
die( "ERROR ==> Unknown Patient from Project: " .$project."\n") unless (scalar(@$patientsP));
print "------------------------------------\n";
print "Project: ".$project." Id:". $projid->{projectId}."\n";
print "-----------------0-------------------\n";
for (my $i = 0; $i< scalar(@fieldM); $i++) {
	foreach my $u (@$patientsP) {
		my $patid=queryPolyproject::getProjectPatientId($buffer->dbh,$u->{name},$projid->{projectId});
		my $res = queryPolyproject::getMethodFromName($buffer->dbh,@fieldM[$i]);
		next if ($opt ne "add" && $opt ne "del");
		queryPolyproject::addMeth2pat($buffer->dbh,$patid,$res->{methodId}) if $opt eq "add";
		queryPolyproject::delMeth2pat($buffer->dbh,$patid,$res->{methodId}) if $opt eq "del";
		print "Patient: ".$u->{name}." Id:". $patid." -- Add Method:".@fieldM[$i]." Id: ".$res->{methodId}."\n" if $opt eq "add";
		print "Patient: ".$u->{name}." Id:". $patid." -- Delete Method:".@fieldM[$i]." Id: ".$res->{methodId}."\n" if $opt eq "del";
	}
	print "----------------b--------------------\n";
}
print "------------------------------------\n" if $invalidPat;
print "ERROR ==> Invalid Patient: ".$invalidPat."\n" if $invalidPat;
print "------------------------------------\n" if $invalidPat;

print "End\n";
=cut

exit(0);

