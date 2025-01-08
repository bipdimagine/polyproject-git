#!/usr/bin/perl
########################################################################
#./run_pythonScript.pl source=/poly-disk/poly-src/Spring/cgi-bin/SPRING_dev dirIn=/poly-disk/poly-data/spring/inFILES/ dirOut=/poly-disk/poly-data/spring/outFILES/ name=fff matrix=ExprData2.mtx genes=Genelist2.csv
########################################################################
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use Carp;
use strict;
use Data::Dumper;
#use GBuffer;
use Getopt::Long;
use util_file qw(readXmlVariations);
#use insert;
use File::Basename;
use File::Find::Rule;
#use Logfile::Rotate; 
use File::Find::Rule;
use File::Glob qw(:globally :nocase);

#use GD;
use Getopt::Long;
#use response;
#use Spreadsheet::WriteExcel;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
#use JSON::XS;
use JSON;
#use queryPolyproject;
use DBI;
use feature qw/switch/; 
use Try::Tiny;
use Proc::Simple;

$| =1;


my $cgi = new CGI;
#my $buffer = GBuffer->new;

my $rootdir = "/poly-disk/poly-data/";
my $source = "$Bin/SPRING_dev";
my $lpython = $cgi->param("lpython");#1=> 102 dockerJM 0=>108 Docker en ligne

#my $source = $cgi->param("source");
#my $dir_in = $cgi->param("dirIn");#/poly-disk/poly-data/spring/inFILES/plaza
#my $dir_out = $cgi->param("dirOut");#/poly-disk/poly-data/spring/outFILES/plaza
my $p_dir_in = $cgi->param("dirIn");#spring/inFILES/plaza
my $p_dir_out = $cgi->param("dirOut");#spring/outFILES/plaza
my $dir_in;
my $dir_out;
$dir_in=$rootdir.$p_dir_in;
$dir_out=$rootdir.$p_dir_out;

my $name = $cgi->param("name");# input out ???
my $matrix = $cgi->param("matrix");# input name Matrix firstfile

my $genes = $cgi->param("genes");# input name Gene secondfile
my $cells = $cgi->param("cells");# input name Cells Grouping optional file
my $genesets = $cgi->param("genesets");# input name Gene Set file
my $customcolor = $cgi->param("customcolor");# input Custom Color file
my $colgene = $cgi->param("colgene");# gene column number
$colgene += 0;

my $dmatrix = $dir_in."/".$name."/".$matrix;
my $dgenes = $dir_in."/".$name."/".$genes;
my $dcells = $dir_in."/".$name."/".$cells;
my $dcustomcolor = $dir_in."/".$name."/".$customcolor;
my $outdir = $dir_out."/".$name."/";
my $indir = $dir_in."/".$name."/";

my $project=$outdir;
my $sub_project=$name;
my $gmt_file=$indir.$genesets;

run("rm -rf $outdir");
mkdir ($outdir,0755);
#makedir($outdir);
#system("chmod -R 777 $outdir");

my $pythonBin;
$pythonBin="/usr/bin" if $lpython;
$pythonBin="/usr/local/bin" unless $lpython;
#my $mycommand="$pythonBin/python $source/prepare_data_matrix3.py -im $dmatrix -ig $dgenes -o $outdir -g $name";
my $mycommand="$pythonBin/python $source/prepare_data_matrix3.py -im $dmatrix -c $colgene -ig $dgenes -o $outdir -g $name";
$mycommand="$mycommand" . " -gr $dcells" if $cells;
$mycommand="$mycommand" . " -co $dcustomcolor" if $customcolor;
$mycommand="$mycommand" . " > /dev/null 2>&1";
#warn Dumper $mycommand;

my $myproc=Proc::Simple->new();
$myproc->start($mycommand);
print $cgi->header('text/json-comment-filtered');
print "{".qq{ "wait":"};
print ".";
while ($myproc->poll() == 1) {
    sleep 15;
    print ".";
}

# 	if ($paramfile eq "genesetsFile" && $extension_i !~ m/(gmt)/) {
#if ($gmt_file) {
if ($gmt_file =~ m/(gmt)/) {
	my $myproc2=Proc::Simple->new();
#	my $mycommand2="/usr/bin/python $source/cgi-bin/apply_gene_set_retrospective.py $project $sub_project $gmt_file";
#	my $mycommand2="$Bin/python $source/cgi-bin/apply_gene_set_retrospective.py $project $sub_project $gmt_file";
	my $mycommand2="$pythonBin/python $source/cgi-bin/apply_gene_set_retrospective.py $project $sub_project $gmt_file";
	$mycommand2="$mycommand2" . " > /dev/null 2>&1";
	
	$myproc2->start($mycommand2);
	while ($myproc2->poll() == 1) {
    	sleep 1;
    	print ".";
	}
}
print qq{"};


system("chmod -R 777 $outdir");
system("chmod -R 777 $indir");
sendOK("OK: Setting Spring Ready for Matrix: <b>$matrix</b> Genes: <b>$genes</b> in  Directory: <b>$name</b>") unless $cells; 
sendOK("OK: Setting Spring Ready for Matrix: <b>$matrix</b> Genes: <b>$genes</b> Cells: <b>$cells</b> in  Directory: <b>$name</b>") if $cells; 

sub sendOK{
	my ($text) = @_;
	print qq{,"status":"OK",};
	print qq{"message":"$text"}."}";
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
	exit(0);
}

sub run {
	my ($cmd) = @_;
	my $return = system($cmd);
	if ($return ne 0){
		#confess("error : $cmd");
			#sendError("Error: error"); 
		
	} 
	if ($return eq 0){
	
		#sendOK("OK: OK"); 
	}
	
}

sub makedir {
	my ($dir) = @_;
	if (!(-d $dir)){
		mkdir ($dir,0755);
	}
	return $dir;	
} 

=mod
=cut


