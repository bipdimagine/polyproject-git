#!/usr/bin/perl
#############################################################################
# new_polyproject.pl ##from GenBo/script/ngs_exome/last_script/new_project.pl
#############################################################################

use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use Carp;
use strict;
use Set::IntSpan::Fast::XS ;
use Data::Dumper;
use GBuffer;
use Getopt::Long;
use GenBoWrite;
use GenBoQuery;
use GenBoTrace;
use GenBoRelationWrite;
use GenBoProjectWrite;
use util_file qw(readXmlVariations);
use insert;

use CGI;
use connect;
use JSON::XS;
use queryPolyproject;


my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;


#paramètre passés au cgi
my $opt = $cgi->param('opt');

#print $cgi->header();

if ( $opt eq "addPoly" ) {
my $project_name;
my $project_type = $cgi->param('type');
my $golden_path = $cgi->param('golden_path');
my $plateform = $cgi->param('plateform');
my $group_method_align_name = $cgi->param('method_align');
my $group_method_calling_name = $cgi->param('method_call');
my $description = $cgi->param('description');
my $groupdisease_id = $cgi->param('disease');
my $seq_machine = $cgi->param('sequencing_machines');
my $cname = $cgi->param('capture');
my $database = $cgi->param('database');
my $plateform_name = $cgi->param('plateform');

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################

#warn $ENV{'LOGNAME'};
my $username = $ENV{'LOGNAME'};

my %config;
$config{type_db} = $database;

my $dbid = GenBoProjectQuery::getDbId($buffer->dbh,$config{type_db});
die("$database unknown") unless $dbid;
sendError( "undefined database " . $dbid ) unless ($dbid);
#warn "dbid :$dbid\n";
my $smid = GenBoProjectQuery::getSeqMachineId($buffer->dbh,$seq_machine);
die("$seq_machine unknown") unless $smid;
sendError( "undefined machine " . $smid ) unless ($smid);
#warn "smid :$smid\n";
my $captureid = GenBoProjectQuery::getCaptureId($buffer->dbh,$cname);
die("capture $cname  unknown") unless $captureid;
sendError( "undefined capture " . $captureid ) unless ($captureid);
#warn "captureid :$captureid\n";

my $releaseid = GenBoProjectQuery::getReleaseId($buffer->dbh,$golden_path);
die("release $golden_path  unknown") unless $releaseid;
sendError( "undefined release " . $releaseid) unless ($releaseid);
#warn "releaseid :$releaseid\n";

my $type = GenBoQuery::getOriginType($buffer->dbh, $project_type);
sendError( "undefined type " . $project_type) unless ($type);
#warn Dumper "type :$type->{id}\n";

my $validAln="";
if ($group_method_align_name) {
	my @ListAln = split(/,/,$group_method_align_name);
	foreach my $u (@ListAln) {
		my $method_align = GenBoProjectQuery::getMethodsFromName($buffer->dbh,$u,"ALIGN");
		$validAln.=$method_align->{id}."," if ($method_align);
	}
	chop($validAln);
	sendError("undefined method_align: " . $group_method_align_name ) unless $validAln;	

}
#warn "validAln :$validAln\n";
my $validMeth="";
if ($group_method_calling_name) {
	my @ListMeth = split(/,/,$group_method_calling_name);
	foreach my $u (@ListMeth) {
		my $method_call = GenBoProjectQuery::getMethodsFromName($buffer->dbh,$u,"SNP");
		$validMeth.=$method_call->{id}."," if ($method_call);
	}
	chop($validMeth);
	sendError("undefined method_call: " . $group_method_calling_name ) unless $validMeth;	
}
#warn "validMeth :$validMeth\n";

my $plateform = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform_name);
sendError( "undefined plateform " . $plateform_name) unless ($plateform);

my $validDisease="";
if ($groupdisease_id) {
	my @ListDisease = split(/,/,$groupdisease_id);
	foreach my $u (@ListDisease) {
		my $resId = queryPolyproject::ctrlDiseaseId($buffer->dbh, $u);
		$validDisease.=$resId->{diseaseId}."," if ($resId);
	}
	chop($validDisease);
	sendError("Disease number: " . $groupdisease_id . " not in Disease DB: ") unless $validDisease;
}
#warn "validDisease :$validDisease\n";
my $prefix;
if($database eq "polydev"){
	$prefix= "DEV";
}
elsif($database eq "Polyexome"){
	$prefix = "NGS";
#	$prefix = "TES";
}
elsif($database eq "Polyrock"){
	$prefix = "ROCK";
#	$prefix = "TES";
}
else {
	sendError("No project created for database Polyprod");
	die;
}
#call => renvoit id et nom
my $query = qq{CALL new_project("$prefix",$type->{id},"$description",$captureid);};
#warn "$prefix ".$type->{id}." $description ".$captureid;
my $sth = $buffer->dbh()->prepare( $query );
$sth->execute();

my $res = $sth->fetchall_arrayref({});
#warn Dumper $res;
sendError("No project created") if ( scalar(@$res) == 0 );

my $pid = $res->[0]->{project_id};
#warn $pid;

sendError("No project created") unless ($pid);

#warn  $res->[0]->{project_id} . " ". $res->[0]->{name} if $res;

if ($group_method_align_name) {
	my @ListAln = split(/,/,$validAln);	
	foreach my $u (@ListAln) {
		GenBoProjectWrite::addMethods($buffer->dbh,$pid,$u);
	}	
}

if ($group_method_calling_name) {
	my @ListMeth = split(/,/,$validMeth);	
	foreach my $u (@ListMeth) {
		GenBoProjectWrite::addMethods($buffer->dbh,$pid,$u);
	}	
}
#GenBoProjectWrite::addMethods($buffer->dbh,$pid,$method_align->{id});
#GenBoProjectWrite::addMethods($buffer->dbh,$pid,$method_call->{id});

queryPolyproject::addPlateform2poly($buffer->dbh,$plateform->{id},$pid);

if ($groupdisease_id) {
	my @listDisease = split(/,/,$validDisease);
	foreach my $u (@listDisease) {
		my $diseaseid = queryPolyproject::addDisease2poly($buffer->dbh, $u, $pid);
	}
}
#queryPolyproject::addDisease2poly($buffer->dbh,$disease->{id},$pid);

#GenBoProjectWrite::addUser($buffer->dbh,$pid,$userid);
GenBoProjectWrite::addMachine($buffer->dbh,$pid,$smid);
GenBoProjectWrite::addDb($buffer->dbh,$pid,$dbid);
GenBoProjectWrite::addRelease($buffer->dbh,$pid,$releaseid);

### End Autocommit dbh ###########
$dbh->commit();

my $typeId=$type->{id};
my $name = $res->[0]->{name};
$ENV{'DATABASE'} = "";
my $buffer = GBuffer->new();
my $projectG = $buffer->newProject(-name=>$name);
# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
$projectG->makePath();
my $dbh = $buffer->dbh;
### Autocommit dbh ###########
$dbh->{AutoCommit} = 0;
my $query1 =qq{INSERT INTO $database.ORIGIN(NAME,TYPE_ORIGIN_ID,DESCRIPTION) values ("$name",$typeId,"$description");};
$dbh->do($query1) ;
### End Autocommit dbh ###########
$dbh->commit();
sendOK("Successful validation for project name: " . $name);	

} # End of opt

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

exit(0);
