#!/usr/bin/perl
########################################################################
###### sc_newCapHG38.pl #################################################
#./sc_newCapHG38.pl -project=NGS2024_7792 -patientid=133112 -insert
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
my $patientid; #

my $message ="Usage :
	$0	-h or -help 
  	$0	-project=<NGS-Project>			# Input NGS Project Name 
  	$0	-patientid=<PatientId>			# Input PatientId from  NGS Project Name called
 	$0		 -insert                        # create a New Capture HG38
 \n";

GetOptions(
	'h'  => \$h,
	'help'  => \$help,
	'insert'  => \$insert,
	'project=s' => \$project,
	'patientid=s' => \$patientid,
) or confess($message);

if ($h|$help) {
	confess ($message);	
}

my $res = queryPolyproject::getProjectFromName($buffer->dbh,$project);
die("$message Error: Unknown Project : $project\n") unless $res->{projectId};

my $p=getPatient_byPatientIdProjectId($buffer->dbh,$patientid,$res->{projectId});
die("$message Error: For Project $project, Unknown PatientId : $patientid\n") unless $p->{patient_id};

my $c=getCapture_fromCaptureId($buffer->dbh,$p->{capture_id});
if ($c->{name}=~ m/([Hh][Gg]38)/) {
	print "version: HG38: Done ==> $c->{capture_id} $c->{name} , Bed file: $c->{filename}\n" ;
	exit;
}

my $capNameHG38=$c->{name}."_HG38";
my $relIdHG38="938";
my $capFileHG38="all_exon.bed";
my $capInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$capNameHG38);
if ($capInfo->{capName}=~ m/([Hh][Gg]38)/) {
	print "version2: HG38: Done ==> $capInfo->{captureId} $capInfo->{capName} , Bed file: $capInfo->{capFile}\n";
	exit;
}

#print "$capNameHG38, $c->{version},$c->{description},$capFileHG38,$c->{type},$c->{umi_id},$c->{method},$c->{release_id},$c->{rel_gene_id},$c->{analyse},$c->{validation_db},$c->{primers_filename},$c->{transcripts},$c->{def},$c->{plt},$c->{design_id}\n";
my $last_captureid = newCaptureData($buffer->dbh,$capNameHG38,$c->{version},$c->{description},$capFileHG38,$c->{type},$c->{umi_id},$c->{method},$relIdHG38,$c->{rel_gene_id},$c->{analyse},$c->{validation_db},$c->{primers_filename},$c->{transcripts},$c->{def},$c->{plt},$c->{design_id}) if $insert;
my $captureid=$last_captureid->{'LAST_INSERT_ID()'};
print "version: HG38: NEW ==> $captureid $capNameHG38 , Bed file: $capFileHG38\n" if $insert;
print "version: HG38: NEW ==>  Add -insert  for New Capture ($capNameHG38 , Bed file: $capFileHG38)\n" unless  $insert;

sub newCaptureData {
	my ($dbh,$capture,$capVs,$capDes,$capFile,$capType,$capUmi,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers,$transcripts,$def,$plt,$design_id) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.capture_systems (name,version,description,filename,type,umi_id,method,release_id,rel_gene_id,analyse,validation_db,primers_filename,transcripts,def,plt,design_id)
		values ('$capture','$capVs','$capDes','$capFile','$capType','$capUmi','$capMeth','$releaseid','$caprelgeneid','$capAnalyse','$capValidation','$capFilePrimers','$transcripts','$def','$plt','$design_id');
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.capture_systems;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPatient_byPatientIdProjectId {
	my ($dbh,$patid,$projid) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid'
		and a.project_id='$projid'
		;
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getCapture_fromCaptureId{
        my ($dbh,$capid)=@_;
        my $query = qq{
			select *
			from PolyprojectNGS.capture_systems C
			where C.capture_id='$capid'	
			;
		};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}


exit(0);

