#!/usr/bin/perl
########################################################################
###### upPoly.pl
########################################################################
use CGI;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#ce script est utilisé pour inserer des données dans la BD à partir de l'interface.
use GenBoWrite;
use GenBoQuery;
use GenBoTrace;
use GenBoRelationWrite;
use GenBoProjectWrite;
use util_file qw(readXmlVariations);
use insert;

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON::XS;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;

#paramètre passés au cgi
my $type = $cgi->param('type');

#print $cgi->header();


if ( $type eq "addUserpoly" ) {
	UserSection();
} elsif ( $type eq "addMethpoly" ) {
	MethodSection();
} elsif ( $type eq "addPlateformpoly" ) {
	PlateformSection();
} elsif ( $type eq "addDiseasepoly" ) {
	ProjectDiseaseSection();
} elsif ( $type eq "newDiseasepoly" ) {
	DiseaseSection();
} elsif ( $type eq "delDiseasepoly" ) {
	removeProjectDiseaseSection();
}


sub UserSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $projid = $cgi->param('ProjSel');
        my $listUser = $cgi->param('User');
        my @field = split(/,/,$listUser);
	my $allUser="";
	foreach my $u (@field) {
		my $userid = queryPolyproject::addUser2poly($buffer->dbh, $u, $projid);
		$allUser.=$userid;
	}
	if ($allUser =="") {
		sendError("User number: " . $listUser . " already linked to project ID: " . $projid);
	}else 	{
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Successful validation for project ID: ". $projid);	
	}
	exit(0);
}

sub MethodSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listMeth = $cgi->param('Mcall');
	my $projectName = queryPolyproject::getProjectName($buffer->dbh,$projid);
	my @field = split(/,/,$listMeth);
	my $allMeth="";
	foreach my $u (@field) {
		my $methid = queryPolyproject::addMeth2poly($buffer->dbh, $u, $projid);
		$allMeth.=$methid;	
	}
	if ($allMeth =="") {
		sendError("Method number: " . $listMeth . " already linked to project ID: " . $projid);
	}else 	{
### End Autocommit dbh ###########
		$dbh->commit();
#		my $buffer = GBuffer->new();
		my $projectG = $buffer->newProject(-name=>$projectName);
		# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
		$projectG->makePath();
		sendOK("Successful validation for project ID: ". $projid);	
	}
	exit(0);
}


sub PlateformSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listPlateform = $cgi->param('Fcall');
	my @field = split(/,/,$listPlateform);
	my $allPlateform="";
	foreach my $u (@field) {
		my $plateformid = queryPolyproject::addPlateform2poly($buffer->dbh, $u, $projid);
		$allPlateform.=$plateformid;	
	}
	if ($allPlateform =="") {
		sendError("Plateform number: " . $listPlateform . " already linked to project ID: " . $projid);
	}else 	{
#### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Successful validation for project ID: ". $projid);	
	}
	exit(0);
}

sub ProjectDiseaseSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $projname = $cgi->param('ProjSel');
        my $listDisease = $cgi->param('Disease');
        my @field = split(/,/,$listDisease);
		my $projid = queryPolyproject::getProjectFromName($buffer->dbh,$projname);
		my $allDisease="";
		foreach my $u (@field) {
			my $diseaseid = queryPolyproject::addDisease2poly($buffer->dbh, $u, $projid->{projectId});
			$allDisease.=$diseaseid;
		}
		if ($allDisease =="") {
			sendError("Disease number: " . $listDisease . " already linked to project ID: " . $projid->{projectId});
		}else 	{
### End Autocommit dbh ###########
			$dbh->commit();
			sendOK("Successful validation for project ID: ". $projid->{projectId});	
		}
		exit(0);
}


sub removeProjectDiseaseSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $projid = $cgi->param('ProjSel');
	my $listDisease = $cgi->param('Disease');
	my @field = split(/,/,$listDisease);
	if($listDisease) {
		foreach my $u (@field) {
			my $diseaseid = queryPolyproject::delDisease2poly($buffer->dbh, $u, $projid);
		}
	}
	if($listDisease) {
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("Diseases removed from project ID: ". $projid);	
	} else {
		sendError("Diseases Not removed from project ID: ". $projid);
	}
	exit(0);
}



sub DiseaseSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
        my $disease = $cgi->param('disease');
        my $abb = $cgi->param('abb');
        $abb="" unless defined $abb;
 		$disease=~ s/'/ /g;
        my $diseaseid = queryPolyproject::getDiseaseFromName($buffer->dbh,$disease);
		if (exists $diseaseid ->{diseaseId}) {
			sendError("Disease Name: " . $disease ."...". " already in Disease database");
		} else 	{
### End Autocommit dbh ###########
			my $mydiseaseid = queryPolyproject::newDisease2poly($buffer->dbh,$disease,$abb);
			$dbh->commit();
			sendOK("Successful validation for Disease : ". $disease);	
		}
		exit(0);
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

