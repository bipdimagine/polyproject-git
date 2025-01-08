#!/usr/bin/perl
########################################################################
#./script_changeReleaseProject.pl
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

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


my $list;
my $change;
my $project;
my $rel;

GetOptions(
	'list'  => \$list,
	'change'  => \$change,
	'project=s' => \$project,
	'rel=s' => \$rel,
);

my $message ="Usage :
 		$0 -rel=<release_name>
		$0 -project=<project_name1,..,project_nameN>  NGS Name project
 
   		$0 -list
  		or 
  		$0 -change  		
";

unless ($rel && $project && ($list || $change)) {
	confess ($message);
}


my $i_rel=queryPolyproject::getReleaseFromName($buffer->dbh,$rel);

die( "ERROR: Unknown Release : " . $rel."\n") unless $i_rel->[0]->{release_id};
print "Release Id: ".$i_rel->[0]->{release_id}." Name: ". $i_rel->[0]->{name}."\n\n" if $list;
my @fieldP= split(/,/,$project) if $project;
for (my $i = 0; $i< scalar(@fieldP); $i++) {
	my $projid = queryPolyproject::getProjectFromName($buffer->dbh,$fieldP[$i]);
	next unless $projid->{projectId};
	my $prel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$projid->{projectId});
	print "Project Id: ".$projid->{projectId}." Name: ". $fieldP[$i]." ==> Project Release: ".$prel."\n" if $list;
	
	if ($change) {
		queryPolyproject::upProjectRelease($buffer->dbh,$projid->{projectId},$i_rel->[0]->{release_id}) if $change;
		my $c_prel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$projid->{projectId});
		print "Project Id: ".$projid->{projectId}." Name: ". $fieldP[$i]." ==> Project Release: ".$c_prel."\n";
		
	}
}
print "To change Project Release, use option -change\n" if $list;


exit(0);

