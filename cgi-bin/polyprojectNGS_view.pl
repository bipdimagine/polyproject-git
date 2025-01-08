#!/usr/bin/perl
########################################################################
###### polyprojectNGS_view.pl
#./polyprojectNGS_view.pl ProjSel="1192"
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use Time::Local;
use queryPolyproject;
use connect;
use export_data;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);

use JSON;
my $cgi    = new CGI;
my $buffer = GBuffer->new;
   
my $projid = $cgi->param('ProjSel');
#warn Dumper $projid;#	and p.project_id not in(999,919)"

#my $sql2 = qq {where p.project_id='$projid'};	where p.project_id not in(999,919)

my $sql2 = qq {and p.project_id='$projid'};
$sql2 = "" unless $projid;

my $sql = qq{select p.project_id as id , p.name as name, 
	p.creation_date as cDate
	from PolyprojectNGS.projects p 
	where p.type_project_id=3
	$sql2 
	order by p.project_id
};

my $sth = $buffer->dbh->prepare($sql) || die();
$sth->execute();
my $res = $sth->fetchall_hashref("name");
#warn Dumper $res;
my @result;
my $row=1;
foreach my $name (sort keys %$res){
	my $buffer = GBuffer->new(-verbose=>1);
	my $project = $buffer->newProject(-name=>$name);
=pod	
=cut
	my $item;
	# project
	$item->{id} = $project->id(); 
	$item->{name} = $project->name();
	$item->{Row} = $row++;
	foreach my $k (keys %{$res->{$name} }){
	 	if ($k eq "cDate") {
			my @datec = split(/ /,$res->{$name}->{$k});
			my ($YY, $MM, $DD) = split("-", $datec[0]);
			my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
			$item->{cDate} = $mydate;
	 	}
	 }
	
	$item->{description} = $project->getDescription();
	

	# Diseases
	my $diseases = queryPolyproject::getDiseasesFromProject($buffer->dbh,$project->id());
	$item->{diseases}=join(";",map{$_->{description}}@$diseases);
	# Users
	my $users = queryPolyproject::getUsersFromProject($buffer->dbh,$project->id());
#	warn Dumper $users;
	$item->{Users}=join(" ",map{$_->{name}}@$users);
	# UsersInfo
	my $usersinfo = queryPolyproject::getUsersInfoFromProject($buffer->dbh,$project->id());
	#warn Dumper $usersinfo;
	$item->{Unit}=join(" ",map{$_->{unit}}@$usersinfo);
	my %seen;
	my @uniqList;
	foreach my $r (@$usersinfo){
		push(@uniqList,$r->{site}) unless $seen{$r->{site}}++;
	}
	$item->{Site}=join(" ",map{$_}@uniqList);
	#	$item->{Site}=join(" ",map{$_->{site}}@$usersinfo);
	# Release GoldenPath database
	$item->{Rel} = $project->getGoldenPath();
	# Database
	my @db = split(/_/,$project->getDataBase());
	$item->{database} = @db[0];
	# Patients
	my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$project->id());
#	my $patientsP = $project->getPatientsFromProject();
	$item->{nbPat}= scalar(@$patientsP);	
	# Run
	my $runP = queryPolyproject::getRunFromPatientProject($buffer->dbh,$project->id());
	my %seen;
	my @uniqList;
	my @machineList;
	my @plateformList;
	my @captureList;
	my @methseqList;
	my @alnList;
	my @snpList;
	my $Child=0;
	foreach my $r (@$runP){
		my %child;
		$child{id} = $project->id();
		$child{name} = $project->name();
		# Run
		$child{runId} = $r->{run_id};
#		my $runR = queryPolyproject::getPatientsFromRun($buffer->dbh,$child{runId});
		my $runR = queryPolyproject::getRunId($buffer->dbh,$child{runId});
		$child{nbRun}=scalar(@$runR);
		#$item->{nbRun}=scalar(@uniqList);
		# Patient
		my $patientR = queryPolyproject::getPatientsFromRun($buffer->dbh,$child{runId});
		$child{nbPat}=scalar(@$patientR);
		#my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$project->id());
		#$item->{nbPat}= scalar(@$patientsP);	
		
		# Run Type
		my $type = queryPolyproject::getType($buffer->dbh,$child{runId});
		$child{Type}=$type;
		# Capture
		my $capture = queryPolyproject::getCapture($buffer->dbh,$child{runId});
		$child{capName}=$capture;
		push(@captureList,$capture)unless $seen{$capture}++;
		# Plateform
		my $plateform = queryPolyproject::getPlateform($buffer->dbh,$child{runId});	
		$child{plateform}=join(" ",map{$_->{name}}@$plateform);
		#$child{plateform}=$plateform;
		push(@plateformList,$child{plateform})unless $seen{$child{plateform}}++;
		# Machine
		my $machine=queryPolyproject::getSequencingMachines($buffer->dbh,$child{runId});
		$child{macName}=$machine;
		push(@machineList,$machine)unless $seen{$machine}++;
		#Alignment method
		my $methaln = queryPolyproject::getAlnMethodName($buffer->dbh,$child{runId});
		$child{MethAln}=join(" ",map{$_->{methAln}}@$methaln);
		push(@alnList,$child{MethAln})unless $seen{$child{MethAln}}++;
		# Calling method
		my $methcall = queryPolyproject::getCallMethodName($buffer->dbh,$child{runId});
		$child{MethSnp}=join(" ",map{$_->{methCall}}@$methcall);
		push(@snpList,$child{MethSnp})unless $seen{$child{MethSnp}}++;
		# Method seq
		my $methseq = queryPolyproject::getMethSeq($buffer->dbh,$child{runId});
		$child{MethSeq}=$methseq;
		push(@methseqList,$methseq)unless $seen{$methseq}++;
		
		push(@uniqList,\%child) unless $seen{$r->{run_id}}++;
	}
	$item->{plateform}=join(" ",map{$_}@plateformList);
	$item->{macName}=join(" ",map{$_}@machineList);
	$item->{MethSeq}=join(" ",map{$_}@methseqList);
	$item->{capName}=join(" ",map{$_}@captureList);
	my @alnList= split(/ /, join(" ",map{$_}@alnList));
	$item->{MethAln}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@alnList}};
	my @snpList= split(/ /, join(" ",map{$_}@snpList));
	$item->{MethSnp}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@snpList}};
	$item->{children}=\@uniqList unless scalar(@uniqList)<2;
	$item->{nbRun}=scalar(@uniqList);
	if (@uniqList){
		# Run
		$item->{runId}=@uniqList[0]->{runId}  if scalar(@uniqList)<2;

		# Run Type
		$item->{Type}=@uniqList[0]->{Type}  if scalar(@uniqList)<2;
	
		# Capture
		$item->{capName}= @uniqList[0]->{capName}  if scalar(@uniqList)<2;

		# Plateform
		$item->{plateform}=@uniqList[0]->{plateform}  if scalar(@uniqList)<2;
	
		# Machine
		$item->{macName}=@uniqList[0]->{macName} if scalar(@uniqList)<2;
	
		# Method Aln
		$item->{MethAln}=@uniqList[0]->{MethAln} if scalar(@uniqList)<2;
	
		# Method Aln
		$item->{MethSnp}=@uniqList[0]->{MethSnp} if scalar(@uniqList)<2;

		# Method seq
		$item->{MethSeq}=@uniqList[0]->{MethSeq} if scalar(@uniqList)<2;
	}
	#status
	if(scalar(@$users)>0) {
		$item->{statut}= qq{<img src='/icons/Polyicons/bullet_green.png'>};
	} else {
		$item->{statut}= qq{<img src='/icons/Polyicons/bullet_orange.png'>};
	}
	
	if(scalar(@$patientsP)<1) {	
		$item->{statut}= qq{<img src='/icons/Polyicons/bullet_red.png'>};
	}
	
	push(@result,$item);

}

#my @sorted =  sort { $a->{price} <=> $b->{price} } @data;
my @result_sorted=sort { $b->{id} <=> $a->{id} } @result;
#export_data::print($projid,$cgi,\@result);
export_data::print(undef,$cgi,\@result_sorted);
exit(0)

#sub printJson {
#        my ($data)= @_;
#                print $cgi->header('text/json-comment-filtered');
#                print encode_json $data;
#        exit(0)
#}

