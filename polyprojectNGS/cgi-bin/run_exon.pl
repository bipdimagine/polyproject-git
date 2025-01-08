#!/usr/bin/perl
########################################################################
###### run_exon.pl
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

use util_file qw(readXmlVariations);
use Time::Local;
use File::Basename;

use GBuffer;
use connect;
use queryPolyproject;
use queryValidationDB;
use Data::Dumper;
use Carp;
use JSON;
use Proc::Simple;
use File::Find::Rule;

use export_data;
#for given/when
use feature qw/switch/; 

$| =1;
my $cgi = new CGI;
my $buffer = GBuffer->new;
my $option = $cgi->param('option');
my $capid = $cgi->param('CapSel');
my $rel = $cgi->param('RelSel');
my $widePos = $cgi->param('widePos');
my $matched = $cgi->param('matched');

if ( $option eq "deposeExons" ) {
	deposeExonsSection();
} elsif ($option eq "retrieveExonsParam") {
	retrieveExonsParamSection();
} elsif ($option eq "retrieveExons") {
	retrieveExonsSection();
}
#./run_exon.pl option=deposeExons CapSel=287 RelSel=HG19  widePos=0 matched=0

sub deposeExonsSection {
	my $version=$rel;
	my $publicdir = $buffer->config()->{public_data}->{root}."/".$version."/";
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir."capture/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};
	my ( $name_o, $path_o, $extension_o ) = fileparse($filename, '\.[^\.]*');	
	if (!(-e $path_o."/".$name_o.".bed")) {
		sendError("Error: No Capture bed File found...");
	}
	justsendOK("Submission of the Transcript Exons File for Capture: <b>".$cap->[0]->{capName}."</b>" );
	system("$Bin/exonCapture.pl -option=deposeExons -CapSel=$capid -RelSel=$rel -widePos=$widePos -matched=$matched &>/dev/null &");
}

sub retrieveExonsParamSection {
	my $version=$rel;
	my $publicdir = $buffer->config()->{public_data}->{root}."/".$version."/";
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir."capture/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};
	my ( $name_o, $path_o, $extension_o ) = fileparse($filename, '\.[^\.]*');
	my $f_exons=findFile($path_o,$name_o);
	sendError("Error: No Exon File found") unless $f_exons ne '0';
	my (undef,undef,$f_extension)= fileparse($f_exons, '\.[^\.]*');
	sendError("Error: Presence of a temporary file for ".$name_o." being processed for the search for exons") if $f_extension =~ "exonstmp";;
	my @sp_ext = split( /_/,$f_extension);	
	$widePos=$sp_ext[1];
	$matched=$sp_ext[2];
	justsendOK("Widened Capture Position:".$widePos.", Exon Covered or Not (0,1):".$matched);	
}

sub retrieveExonsSection {
	my $version=$rel;
	my $publicdir = $buffer->config()->{public_data}->{root}."/".$version."/";
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir."capture/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};
	my ( $name_o, $path_o, $extension_o ) = fileparse($filename, '\.[^\.]*');
	my $f_exons=findFile($path_o,$name_o);
	viewFile($f_exons);
}

sub findFile {
	my ($Dir,$i_file) = @_;
	my @sp_file;
	@sp_file=($i_file.".exons*");
	my @e_files;
	@e_files = File::Find::Rule->file()
		->name( [  @sp_file ])
		->in( $Dir );
	return $e_files[0] if scalar @e_files;
	return 0;
}

sub viewFile {
	my ($file) = @_;
	my $FH;
	open( $FH, '<', $file );
	while ( my $Line = <$FH> ) {
		printFile($Line);
	}
	close($FH);
    exit(0);
}

sub printFile {
 	my ($FH)= @_;
	print $cgi->header('text/json-comment-filtered');
	print $FH;
}


####################################################################################
sub justsendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	return 0;
}

sub sendError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

