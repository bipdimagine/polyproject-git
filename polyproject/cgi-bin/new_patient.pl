#!/usr/bin/perl
#############################################################################
# new_patient.pl ##from GenBo/script/ngs_exome/last_script/create_patient.pl
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
#./new_patient.pl opt=addPatient projectName="ROCK2011_0029" patient="aaaa"
if ( $opt eq "addPatient" ) {
	my $projectName= $cgi->param('projectName');
	my $patientName= $cgi->param('patient');
	$patientName=~ s/ //g;
	$patientName=~ s/\n/;/g;
#	warn $patientName;
	my @pat=split(/,/,$patientName);
	### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
	############################# 
	my $project = $buffer->newProject(-name=>$projectName);
	die ("unknown project ".$projectName ) unless $project;
	#sendError( "Unknown project " . $projectName ) unless ($projectName);
	my $type=$buffer->getType("patient");
	for my $u (@pat) {
		#my ($patient_id) = GenBoWrite::createGenBo($buffer->dbh,$patientName,$type,$project->id);	
		my ($patient_id) = GenBoWrite::createGenBo($buffer->dbh,$u,$type,$project->id);	
	}
	### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful Patient validation for project name: " . $projectName);	
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

sub response {
	my ($rep) = @_;
	print qq{<textarea>};
	print to_json($rep);
	print qq{</textarea>};

	exit(0);
}

exit(0);





