#!/usr/bin/perl
########################################################################
###### sc_newCapHG38.pl #################################################
#./sc_upPatientCapProj.pl -project=NGS2025_08677 -capture=Twist_plus
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

my $message ="Usage :
	$0	-h or -help 
  	$0	-project=<NGS-Project>			# Input NGS Project Name 
   	$0	-capture=<Capture_Name>			# Input Exon Capture Name 
  	$0		 -insert                        # to update
 \n";

GetOptions(
	'h'  => \$h,
	'help'  => \$help,
	'insert'  => \$insert,
	'project=s' => \$project,
	'capture=s' => \$capture,
);# or confess($message);

if ($h|$help) {
	confess ($message);	
}

confess($message) unless ($project && $capture);

my $res = queryPolyproject::getProjectFromName($buffer->dbh,$project);
die("$message Error: Unknown Project : $project\n") unless $res->{projectId};

my $capInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$capture);
#warn Dumper $capInfo;
die("$message Error: Unknown Capture : $capture\n") unless $capInfo->{capName};
#warn Dumper $capInfo->{captureId};
print "#############################################################################################\n";
print "Project: $res->{projectId} $project - Capture: $capInfo->{captureId} $capInfo->{capName}\n";
print "#############################################################################################\n\n";


my $cpt=1;
my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$res->{projectId});

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################



foreach my $m (@$patientList) {
	print "$cpt\tPatient $m->{patient_id} $m->{name}\tProject: $m->{project_id} $project\n" unless $insert;
	queryPolyproject::upPatientCaptureOnly($buffer->dbh,$m->{patient_id},$capInfo->{captureId})  if $insert;
	print "$cpt\tPatient $m->{patient_id} $m->{name}\tProject: $m->{project_id} $project\t==> Capture: $capInfo->{captureId} $capInfo->{capName} Done...\n" if $insert;
	$cpt++;
}
print "Add option -insert to update \n" unless $insert;

$dbh->commit();	

exit(0);

