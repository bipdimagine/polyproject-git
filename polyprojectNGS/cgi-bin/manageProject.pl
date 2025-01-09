#!/usr/bin/perl
########################################################################
#./manageProject.pl 
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/packages"; 
use Time::Local;
use queryPolyproject;
use queryPerson;
use connect;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
use List::Util qw/ max min /;

use JSON;
my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $numAnalyse = $cgi->param('numAnalyse');
my $projid = $cgi->param('ProjSel');
my $projList;
my $super_unit = queryPolyproject::getCodeUnitFromTeamId($buffer->dbh,6);#BIP-D
# group "STAFF"
my $s_group = queryPolyproject::getGroupFromName($buffer->dbh,"STAFF");
my $super_grp=$s_group->{UGROUP_ID};
#my $s1=time();
$projList = queryPolyproject::getProjectAll($buffer->dbh,$super_unit,$projid);
#my $e1=time();
#my $r1=$e1 - $s1;
#print "\nstart 1: $s1 end: $e1 diff: $r1\n";
my @data;
my %hdata;
my $row=1;
$hdata{label}="name";
$hdata{identifier}="name";
$buffer = GBuffer->new(-verbose=>1);
#my $s2=time();
foreach my $c (@$projList){
	my %s;
	#my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
	my $patientList = queryPerson::getPatientInfoPersonFromProject($buffer->dbh,$numAnalyse,$c->{id});
	next unless scalar @$patientList;
	$s{id} = $c->{id};
	$s{id} += 0;
	$s{name} = $c->{name};
	$s{Row} = $row++;
	$s{description} = $c->{description};	
	$s{dejaVu} = $c->{dejaVu};	
	$s{somatic} = $c->{somatic};	
	my @datec = split(/ /,$c->{cDate});
	my ($YY, $MM, $DD) = split("-", $datec[0]);
	my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
	if ($YY=="0000") {
		$mydate =""
	}
	$s{cDate} = $mydate;
	# Release, Release Annotation and Database
	$s{Rel} = $c->{relname};
	my @d_ppversion=split( / /, $c->{ppversionid});
	my @d_relGene=split( / /, $c->{relGene});
	$s{projRelAnnot} ="";
	$s{projRelAnnot} = (max @d_relGene).".".(max @d_ppversion) if scalar @d_relGene;
	$s{database} = $c->{dbname};
		
	# Users && User group
	$s{UserGroups} ="";
	$s{UserGroups} = $c->{usergroup} if $c->{usergroup};	
	$s{UserGroupsId} = $c->{usergroupId} if $c->{usergroupId};	
	my (@userAll,@unitAll,@siteAll);	
	my @ugp=split(' ',$s{UserGroupsId});
	foreach my $u (@ugp) {
		# filtrer staff
	#	my $usergroupList = queryPolyproject::getUserGroupInfoFromUgroup($buffer->dbh,$u);
		my $usergroupList = queryPolyproject::getUserGroupInfoFromUgroup($buffer->dbh,$u,$super_grp);
		my @usertmp=sort{lc $a cmp lc $b} keys %{{map{$_->{name}=>1}@$usergroupList}};
		my @usercum;
		my @user;
		foreach my $c (@usertmp){
			push(@usercum,$c.":$u");
		}
		@user=join ',',@usercum if scalar @usercum;
		push(@userAll,@user);
		my @unit=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_->{unit}=>1}@$usergroupList}};
		push(@unitAll,@unit);
		my @site=sort{lc $a cmp lc $b} keys %{{map{$_->{site}=>1}@$usergroupList}};
		push(@siteAll,@site);
	}
	if (scalar @ugp) {
		push(@userAll,$c->{username});
		$s{Users}=join ',',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@userAll}};
		$s{Users} =~ s/^,//;
		push(@unitAll,$c->{unit});
		$s{Unit}=join ' ',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@unitAll}};
		push(@siteAll,$c->{site});
		$s{Site}=join ' ',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@siteAll}};
	} else {
		$s{Users}=$c->{username};
		$s{Site}=$c->{site};
		$s{Unit}=$c->{unit};
	}
	# Patients
	$s{patName}=join(" ",map{$_->{name}}@$patientList);
	$s{patBC}=join(" ",map{$_->{patBC}}@$patientList);	
	$s{nbPat}=scalar(split(' ',$s{patName}));
	$s{nbPat}=~ s/,//g;
#		$s{sp} = $c->{spCode};
#	$s{sp}=join(" ",map{$_->{name}}@$patientList);
	$s{sp}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_->{spCode}=>1}@$patientList}};	
	# Person
	$s{persId}=join(" ",map{$_->{person_id}}@$patientList);
	$s{persName}=join(" ",map{$_->{person}}@$patientList);
	# Run
	my @runidList=split(/ /,join(" ",map{$_->{run_id}}@$patientList));
	$s{runId}=join ' ', sort{$b <=> $a} keys %{{map{$_=>1}@runidList}};
	$s{nbRun}=scalar(split(' ',$s{runId}));;
	$s{nbRun}=~ s/,//g;
	# Plateform
	my @plateformList= split(/ /, join(" ",map{$_->{plateformName}}@$patientList));
	$s{plateform}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@plateformList}};
	# Sequencing Machine	
	my @macnameList= split(/ /, join(" ",map{$_->{macName}}@$patientList));
	$s{macName}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@macnameList}};
	# Sequencing Method
	my @methseqList= split(/ /, join(" ",map{$_->{methSeqName}}@$patientList));
	$s{MethSeq}=join ' ',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@methseqList}};
	#Alignment method
	my @alnList= split(/ /, join(" ",map{$_->{methAln}}@$patientList));
	$s{MethAln}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@alnList}};	
	# Calling method		
	my @snpList= split(/ /, join(" ",map{$_->{methCall}}@$patientList));
	$s{MethSnp}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@snpList}};
	# Others method	from Pipeline Methods	
	my @pipeList= split(/ /, join(" ",map{$_->{methPipe}}@$patientList));
	$s{MethPipe}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@pipeList}};
	# Capture Analyse
	my @capnameList= split(/ /, join(" ",map{$_->{capName}}@$patientList));
	$s{capName}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@capnameList}};
	my @capanalyseList= split(/ /, join(" ",map{$_->{capAnalyse}}@$patientList));
	$s{capAnalyse}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@capanalyseList}};
	my @capvalidationList= split(/ /, join(" ",map{$_->{capValidation}}@$patientList));
	$s{capValidation}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@capvalidationList}};
	
	my @capRelList= split(/ /, join(" ",map{$_->{capRel}}@$patientList));
	$s{capRel}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@capRelList}};
	
	#Phenotype Project
	$s{phenotype}="";
	my $projPhenotype = queryPolyproject::getProjectPhenotype($buffer->dbh,$c->{id});
	$s{phenotype}=join(",",map{$_->{name}}@$projPhenotype) if defined $projPhenotype;

	$s{luser} = 1;
	if (scalar(split(/ /,$s{Users}))>0) {
		$s{luser}= 0;
	}
	$s{statut} = 0;	
	if($s{nbPat}<1) {	
		$s{statut}= 1;
	}
#	warn Dumper \%s;
#	die;
	push(@data,\%s);
	
}
#print "\nstart 1: $s1 end: $e1 diff: $r1\n";
#my $E2=time();
#my $r2=$E2 - $s2;
#my $R=$E2 - $s1;
#print "start 2: $s2 end: $E2 diff: $r2 Tot: $R\n";
my @result_sorted=sort { $b->{id} <=> $a->{id} } @data;
$hdata{items}=\@result_sorted;
printJson(\%hdata);

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0);
}

exit(0);
