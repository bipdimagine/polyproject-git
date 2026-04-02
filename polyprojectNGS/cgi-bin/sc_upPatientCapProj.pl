#!/usr/bin/perl
########################################################################
###### sc_newCapHG38.pl #################################################
#./sc_upPatientCapProj.pl -project=NGS2025_08677 -capture=Twist_plus -patient="PLU-D_M","PLU-D_F"
########################################################################
#use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use Time::Local;
use List::MoreUtils qw/ uniq /;
use CGI;

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

my $h;
my $help;
my $insert;
my $project; #
my $capture; #
my $patient; #

my $message ="Usage :
	$0	-h or -help 
  	$0	-project=<NGS-Project>			# Input NGS Project Name 
   	$0	-capture=<Capture_Name>			# Input Exon Capture Name
   	$0	-insert                         # to update
   	
   	Optional: with Patients
  	$0	-project=<NGS-Project> -capture=<Capture_Name> -patient=<patientName_1>,...,<patientName_N>	[-insert]	# Patient Name List 	
  	$0	-project=<NGS-Project> -capture=<Capture_Name>	[-insert] < File_In		# File of Patient Name
 \n";

GetOptions(
	'h'  => \$h,
	'help'  => \$help,
	'insert'  => \$insert,
	'project=s' => \$project,
	'capture=s' => \$capture,
	'patient=s' => \$patient,
);

if ($h|$help) {
	confess ($message);	
}

confess($message) unless ($project && $capture);

my $res = queryPolyproject::getProjectFromName($buffer->dbh,$project);
die("$message Error: Unknown Project : $project\n") unless $res->{projectId};

my $capInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$capture);
die("$message Error: Unknown Capture : $capture\n") unless $capInfo->{capName};
print "#############################################################################################\n";
print "Project: $res->{projectId} $project - Capture: $capInfo->{captureId} $capInfo->{capName}\n";
print "#############################################################################################\n\n";


my @InPatient;
if (!-t STDIN) {
	# File , not Terminal
	while (my $line = <>) {
    	chomp $line;
   	 	next unless $line;
 		my $patproj = getPatientProject_byNamePatId($buffer->dbh,$line,$res->{projectId});  
		die("$message Error: In Project $project, Unknown Patient $line ....\n") unless $patproj->{patient_id};
		my %si;
		$si{patient_id} = $patproj->{patient_id};
		$si{name} = $patproj->{name};
		$si{project_id} = $patproj->{project_id};
		push(@InPatient,\%si);
	}
}	

if ($patient) {
	my @patient=split(/,/,$patient);
	foreach my $m (@patient){
		my $patproj = getPatientProject_byNamePatId($buffer->dbh,$m,$res->{projectId}); 
		die("$message Error: In Project $project, Unknown Patient $m ....\n") unless $patproj->{patient_id};
		my %si;
		$si{patient_id} = $patproj->{patient_id};
		$si{name} = $patproj->{name};
		$si{project_id} = $patproj->{project_id};
		push(@InPatient,\%si);
	}			
}

my @Patlist;
my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$res->{projectId});

if (scalar(@InPatient)>0) {
	@Patlist= @InPatient;
} else {
	@Patlist=@$patientList;
}

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
my $cpt=1;
foreach my $m (@Patlist) {
	print "$cpt\tPatient $m->{patient_id} $m->{name}\tProject: $m->{project_id} $project\n" unless $insert;
	queryPolyproject::upPatientCaptureOnly($buffer->dbh,$m->{patient_id},$capInfo->{captureId})  if $insert;
	print "$cpt\tPatient $m->{patient_id} $m->{name}\tProject: $m->{project_id} $project\t==> Capture: $capInfo->{captureId} $capInfo->{capName} Done...\n" if $insert;
	$cpt++;
}
print "Add option -insert to update \n" unless $insert;
$dbh->commit();	

sub getPatientProject_byNamePatId {
	my ($dbh,$patname,$pid) = @_;
	my $query = qq{
		select a.patient_id,a.name,a.project_id
		FROM PolyprojectNGS.patient a
		where a.name='$patname'
		and a.project_id='$pid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

exit(0);

