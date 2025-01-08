#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_pedigreeFile.pl
#/data-xfs/dev/plaza/polyprojectNGS/cgi-bin/pedigree_file.pl -opt=insert -ped="NGS2014_0429.ped"
#/data-xfs/dev/plaza/polyprojectNGS/cgi-bin/pedigree_file.pl -opt=extract -project="NGS2014_0429"
#./script_pedigreeFile.pl -opt=extract -project="NGS2014_0429" -dirped
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
use Logfile::Rotate; 

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;
#use warnings;

my $opt;
my $project_name;
my $dirsom=0;
my $somfile;

my $cgi    = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $project_name = $cgi->param('project');
my $dirsom = $cgi->param("dirsom");
my $force = $cgi->param("force");

GetOptions(
		'opt=s' => \$opt,
        'dirsom' => \$dirsom,
        'project=s'  => \$project_name,
        'force' => \$force,
        'somfile=s' => \$somfile,        
);

unless ($opt eq "extract") {
	confess ("usage :
		$0 -opt=extract -project=project_name [-dirsom]
		-dirsom : extract a somatic file into a project directory
		\n");
}

if ($opt eq "extract") {
	ExtractSomaticSection();
}
########################################################################################
sub ExtractSomaticSection {
	unless ($project_name) {
		confess ("usage :
          $0 -opt=extract -project=project_name [-dirsom] [-force]
          -dirsom : extract a somatic file into a project directory
          -force : make a copy of old somatic file and replace it
          \n");
	}
	my $project = $buffer->newProject(-name => $project_name);
	die( "unknown project" . $project_name ) unless $project->id();
	my $dir=$project->getProjectPath();
	my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$project->id());
#	$dir =~ s/HG[0-9]+\///;
	$dir =~ s/$rel\///;
	my $file_out;
	$file_out=$dir.$project_name.".somatic" if $dirsom;
	$file_out=$project_name.".somatic" unless $dirsom;
	if (-e $file_out && !$force) {
		sendError("Error: Project Somatic file  <b>". $project_name.".somatic"." </b> already exists in project folder: ". $project_name."<BR>Click Before on Force to make a copy version file and replace it");
 		return;
 	}

  	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$project->id());
	my @data;
	foreach my $p (@$patientList) {
		my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$p->{patient_id});
		foreach my $g (@$groupid) {
			queryPolyproject::delPatGroup($buffer->dbh,0,$p->{patient_id}) if (!$g->{group_id} );
		}
 		my $groupName = queryPolyproject::getGroupId($buffer->dbh,$groupid->[0]->{group_id}) if defined $groupid->[0]->{group_id};
		my %s;
  		$s{group} =join(" ",map{$_->{groupName}}@$groupName);
		$s{name} = $p->{name};
		$s{status}=$p->{status};
		$s{status}=2 unless $p->{status};		
		push(@data,\%s);
	}
	my @result_sorted=sort {$a->{group} cmp $b->{group}||$b->{name} cmp $a->{name}}@data;
	my $dlo="\t";
	my $file_out2;
	$file_out2=$project_name.".somatic";
	logrotate_File("$file_out2",$dir);
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $l (@result_sorted) {
		print $FHO $l->{group}.$dlo.$l->{name}.$dlo.$l->{status}."\n";
	}
	close($FHO);
	sendOK("Successful validation for Project Somatic file: <b>". $project_name.".somatic</b>" );
}

sub logrotate_File {
	my ($sub,$dir_backup) = @_;
	my $file_out = $dir_backup.'/'.$sub;
	if (-e $file_out) {
		my $merge_rotate = new Logfile::Rotate (
				File  => $file_out,
				Count => 9,
				Dir	  => $dir_backup,
				Gzip  => 'no',
				 );		
		$merge_rotate->rotate();
		unlink $file_out;
	}
}

########################################################################################

sub messageOK {
        my ($title) = @_;
        print "$title \n\n";
}

sub messageError {
        my ($title) = @_;
        print "$title \n\n";
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
	exit(0);
}

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}

exit(0);

