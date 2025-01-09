#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_upMethodFromPatient.pl
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

#use GenBoWriteNgs;
#use GenBoQueryNgs;
#use GenBoRelationWrite;
#use GenBoProjectWriteNgs;
#use GenBoProjectQueryNgs;
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
use Getopt::Long;
#use warnings;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

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

exit(0);

