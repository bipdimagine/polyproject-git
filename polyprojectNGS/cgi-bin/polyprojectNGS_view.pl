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
### TODO: replace obj-lite to obj-nodb
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";
#use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
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
my $sql2 = qq {and p.project_id='$projid'};
$sql2 = "" unless $projid;

my $sql = qq{select p.project_id as id , p.name as name, 
	p.creation_date as cDate
	from PolyprojectNGS.projects p ,
    PolyprojectNGS.databases_projects dp
	where p.type_project_id=3
    and p.project_id =dp.project_id
    and dp.db_id !=2
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
	 
	### TODO: replace getDescription to description
	$item->{description} = $project->description();
	
	# Diseases
	my $diseases = queryPolyproject::getDiseasesFromProject($buffer->dbh,$project->id());
	$item->{diseases}=join(";",map{$_->{description}}@$diseases);
	# Users
	my $users = queryPolyproject::getUsersFromProject($buffer->dbh,$project->id());
	$item->{Users}=join(" ",map{$_->{name}}@$users);
	# UsersInfo
	my $usersinfo = queryPolyproject::getUsersInfoFromProject($buffer->dbh,$project->id());
	$item->{Unit}=join(" ",map{$_->{unit}}@$usersinfo);
	my %seen;
	my @uniqList;
	foreach my $r (@$usersinfo){
		push(@uniqList,$r->{site}) unless $seen{$r->{site}}++;
	}
	$item->{Site}=join(" ",map{$_}@uniqList);

	### TODO: replace getGoldenPath to getVersion()
	$item->{Rel} = $project->getVersion();
	# Database
	my @db = split(/_/,$project->getDataBase());
	$item->{database} = @db[0];
	# Patients
	my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$project->id());
	$item->{patName}=join(" ",map{$_->{name}}@$patientsP);
	$item->{nbPat}= scalar(@$patientsP);	
	# Run
	my $runP = queryPolyproject::getRunFromPatientProject($buffer->dbh,$project->id());
	my %seen;
	my %seen2;
	my %seen3;
	my %seenC;
	my %seenR;
	my %seenP;
	my @uniqList;
	my @machineList;
	my @plateformList;
	my @captureList;
	my @analyseList;
	my @methseqList;
	my @patList;
	my @runList;
	my @alnList;
	my @snpList;
	my $Child=0;
	foreach my $r (@$runP){
		my %child;
		$child{id} = $project->id();
		$child{name} = $project->name();
		# Run
		$child{runId} = $r->{run_id};
		push(@runList,$child{runId})unless $seenR{$child{runId}}++;
		my $runR = queryPolyproject::getRunId($buffer->dbh,$child{runId});
		$child{nbRun}=scalar(@$runR);		
		# Patient
		my $patientR = queryPolyproject::getPatientsFromRun($buffer->dbh,$child{runId},$child{id});		
		$child{nbPat}=scalar(@$patientR);
		# Run Type
		my $type = queryPolyproject::getType($buffer->dbh,$child{runId});
		$child{Type}=$type;
		# Capture
		my $capture = queryPolyproject::getCapture($buffer->dbh,$child{runId},$child{id});
		$child{capName}=join(" ",map{$_->{name}}@$capture);
		push(@captureList,$child{capName})unless $seenC{$child{capName}}++;
		# Capture Analyse
		my $analyse = queryPolyproject::getCaptureAnalyse($buffer->dbh,$child{runId},$child{id});
		$child{capAnalyse}=join(" ",map{$_->{analyse}}@$analyse);
		push(@analyseList,$child{capAnalyse})unless $seenC{$child{capAnalyse}}++;
		# Plateform
		my $plateform = queryPolyproject::getPlateform($buffer->dbh,$child{runId});	
		$child{plateform}=join(" ",map{$_->{name}}@$plateform);
		push(@plateformList,$child{plateform})unless $seen3{$child{plateform}}++;
		# Machine
		my $machine=queryPolyproject::getSequencingMachines($buffer->dbh,$child{runId});
		$child{macName}=$machine;
		push(@machineList,$machine)unless $seen{$machine}++;
		#Alignment method
		my $methaln = queryPolyproject::getAlnMethodName($buffer->dbh,$child{runId},$child{id});
		$child{MethAln}=join(" ",map{$_->{methAln}}@$methaln);
		push(@alnList,$child{MethAln}) unless $seen2{$child{MethAln}}++;
		# Calling method
		my $methcall = queryPolyproject::getCallMethodName($buffer->dbh,$child{runId},$child{id});
		$child{MethSnp}=join(" ",map{$_->{methCall}}@$methcall);
		push(@snpList,$child{MethSnp})unless $seen2{$child{MethSnp}}++;		
		# Method seq
		my $methseq = queryPolyproject::getMethSeq($buffer->dbh,$child{runId});
		$child{MethSeq}=$methseq;
		push(@methseqList,$methseq)unless $seen{$methseq}++;
		
		push(@uniqList,\%child) unless $seen{$r->{run_id}}++;
	}
	my @pltList= split(/ /, join(" ",map{$_}@plateformList));
	$item->{plateform}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@pltList}};
	$item->{macName}=join(" ",map{$_}@machineList);
	$item->{MethSeq}=join(" ",map{$_}@methseqList);
	my @capList= split(/ /, join(" ",map{$_}@captureList));
	$item->{capName}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@capList}};
	
	my @anaList= split(/ /, join(" ",map{$_}@analyseList));
	$item->{capAnalyse}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@anaList}};
	
	
	
	
	my @alnList= split(/ /, join(" ",map{$_}@alnList));
	$item->{MethAln}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@alnList}};
	my @snpList= split(/ /, join(" ",map{$_}@snpList));
	$item->{MethSnp}=join ' ', sort{$a cmp $b} keys %{{map{$_=>1}@snpList}};
	
	$item->{runId}=join(" ",map{$_}@runList);
		
	$item->{children}=\@uniqList unless scalar(@uniqList)<2;
	$item->{nbRun}=scalar(@uniqList);
	if (@uniqList){
		# Run
		$item->{runId}=@uniqList[0]->{runId}  if scalar(@uniqList)<2;

		# Run Type
		$item->{Type}=@uniqList[0]->{Type}  if scalar(@uniqList)<2;
	
		# Capture
		$item->{capName}= @uniqList[0]->{capName}  if scalar(@uniqList)<2;

		# Capture Analyse
		$item->{capAnalyse}= @uniqList[0]->{capAnalyse}  if scalar(@uniqList)<2;

		# Plateform
		$item->{plateform}=@uniqList[0]->{plateform}  if scalar(@uniqList)<2;
	
		# Machine
		$item->{macName}=@uniqList[0]->{macName} if scalar(@uniqList)<2;
	
		# Method Aln
		$item->{MethAln}=@uniqList[0]->{MethAln} if scalar(@uniqList)<2;
	
		# Method Snp
		$item->{MethSnp}=@uniqList[0]->{MethSnp} if scalar(@uniqList)<2;

		# Method seq
		$item->{MethSeq}=@uniqList[0]->{MethSeq} if scalar(@uniqList)<2;
	}
	#status
	if(scalar(@$users)>0) {
		$item->{statut}= qq{<img src='icons/bullet_green.png'>};
	} else {
		$item->{statut}= qq{<img src='icons/bullet_orange.png'>};
	}
	
	if(scalar(@$patientsP)<1) {	
		$item->{statut}= qq{<img src='icons/bullet_red.png'>};
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

