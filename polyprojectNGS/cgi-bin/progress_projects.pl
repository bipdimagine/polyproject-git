#!/usr/bin/perl
########################################################################
###### progress_projects.pl
#./progress_projects.pl ProjSel="NGS2011_0025"
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
#use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#use GenBoQueryNgs;
#use GenBoProjectQueryNgs;
#use GenBoPatientNgs;


use Time::Local;
use queryPolyproject;
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";
use export_data;
use connect;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
my $buffer1 = GBuffer->new(); 
my $cgi    = new CGI();

my $projNAME = $cgi->param('ProjSel');
my $yearNAME = $cgi->param('yearSel');

my $sql2 = qq {and p.name='$projNAME'};
$sql2 = "" unless $projNAME;

my $sql3 = qq {and p.name REGEXP '$yearNAME'};
$sql3 = "" unless $yearNAME;

my $sql = qq{
SELECT p.name as name,p.project_id as id ,p.type_project_id as ptype,
p.creation_date as cdate
FROM PolyprojectNGS.projects p,
PolyprojectNGS.databases_projects dp
WHERE p.type_project_id=3 
and p.project_id =dp.project_id
and dp.db_id !=2
$sql2
$sql3;
};
my $sth = $buffer1->dbh->prepare($sql) || die();
$sth->execute();
my $res = $sth->fetchall_hashref("name");
my @result;
foreach my $name (keys %$res){
	my $buffer = GBuffer->new(-verbose=>1);
	my $project = $buffer->newProject(-name=>$name);
	my $nb_progress;
	my $item;
	$item->{id} = $project->id(); 
	$item->{name} = $project->name();
 	$item->{description} = $project->getDescription();
	$item->{database} = $project->getDataBase();
	foreach my $k (keys %{$res->{$name} }){
		if($k eq "cdate"){
			my @datec = split(/ /,$res->{$name}->{$k});
			my ($YY, $MM, $DD) = split("-", $datec[0]);
			my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
			$item->{cdate} = $mydate;
		}
	}
	# Patients
	my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$project->id());
	$item->{patients} = join(" ",map{$_->{name}}@$patientsP);
	$item->{nbPat}= scalar(@$patientsP);	

	# Run
	my $runP = queryPolyproject::getRunFromPatientProject($buffer->dbh,$project->id());
	my %seen;
 	my %seen2;
 	my %seen3;
 	my @machineList;
 	my @plateformList;
 	my @runList;
 	foreach my $r (@$runP){
 		my $machine=queryPolyproject::getSequencingMachines($buffer->dbh,$r->{run_id}) unless $seen{$r->{run_id}}++;
 		push(@machineList,$machine)unless $seen{$machine}++;
		# Plateform
		my $plateformL = queryPolyproject::getPlateform($buffer->dbh,$r->{run_id})unless $seen2{$r->{run_id}}++;
		my $plateform=join(" ",map{$_->{name}}@$plateformL) unless $seen2{$plateformL}++;
 		push(@plateformList,$plateform) unless $seen2{$plateform}++;
 		# run
  		my $run = $r->{run_id};
 		push(@runList,$r->{run_id}) unless $seen3{$r->{run_id}}++;
 	}
 	$item->{macName}=join(" ",map{$_}@machineList);
  	$item->{plateform}=join(" ",map{$_}@plateformList);
  	$item->{Run}=join(" ",map{$_}@runList);
  	$item->{nbRun}=scalar(@runList);
	#
	# check seq
	#		
	my $dirs = $project->getSequencesDirectories();
	# il faut changer le répertoire ex '/data-xfs/plaza/sequencing/ngs/NGS2012_0115/sequences//solid5500/'
	my $nb_seq=0;
	my @p_seq;
	my $nb_patients = scalar(@$patientsP);
	foreach my $p (@$patientsP){
		my @alltest;
		foreach my $dir (@$dirs) {
			my @testfile = glob($dir."/*".$p->{name}."*" );
			@alltest=@testfile if @testfile;
		}
		$nb_seq++ if @alltest;
		push(@p_seq,$p->{name}) unless @alltest;
	}	
	$item->{seq} =0;
	$item->{seq} = $nb_seq."/".$nb_patients." ".join(" ",@p_seq);
	$item->{seq} = "0/0" if $item->{plateform} eq "ROCKFELLER";
	$item->{seqDes} = 1 if $nb_seq ==  $nb_patients;
	$item->{seqDes} = 1 if $item->{plateform} eq "ROCKFELLER";
	#	$item->{seqDes} = 1 if $item->{plateform} eq "INTEGRAGEN";
	if ($item->{seqDes} == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}

	#
	# check seq align bam files
	#
	my $Align = $project->getAlignmentMethods();
	my $nb=0;
	my @p_bam;
	my $patients = $project->getPatients();
	foreach my $p (@$patients){
		#my @alltest= glob($p->getBamFiles());
		my @alltest= $p->getBamFiles();
#		$nb++ if -@alltest;
		$nb++ if scalar(join("",map{$_->[0]}@alltest));
#		push(@p_bam,$p->name) unless @alltest;
		push(@p_bam,$p->name) unless scalar(join("",map{$_->[0]}@alltest));
	}
	$item->{nb} = $nb;
	$item->{align} = $nb."/".$nb_patients." ".join(" ",@p_bam);
	warn Dumper $item->{align};
	$item->{alignDes} = $nb."/".$nb_patients;
	$item->{alignDes} = 1 if $nb ==  $nb_patients;
	# Progress for nb seq align
	if ($item->{alignDes} == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	#
	# check calling var
	#
	my $methods = $project->getCallingMethods();
	my $nb_variations=0;
	my @pp;
	foreach my $p (@$patients){
		my @alltest;
		foreach my $m (@$methods){
#			my @testfile = glob($p->getVariationsFile($m)."*" );
			my @testfile = $p->getVariationsFiles($m);
			@alltest=@testfile if scalar(join("",map{$_->[0]}@testfile));
		}
		push(@pp,$p->name) unless @alltest;
		$nb_variations++ if @alltest;
	}
	$item->{calling_var} = $nb_variations."/".$nb_patients." ".join(" ",@pp);
	$item->{calling_varDes} = $nb_variations."/".$nb_patients;	
	$item->{calling_varDes} = 1 if $nb_variations ==  $nb_patients;
	# Progress for nb calling variations
	if ($item->{calling_varDes} == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	#
	# check calling indels
	#
	@pp= ();
	my $nb_indels=0;
	foreach my $p (@$patients){
		my @alltest;
		foreach my $m (@$methods){
			#my @testfile = glob($p->getIndelsFiles($m)."*" );
			my @testfile = $p->getIndelsFiles($m);
			@alltest=@testfile if scalar(join("",map{$_->[0]}@testfile));
#			@alltest=@testfile if @testfile;
		}
		push(@pp,$p->name) unless @alltest;
		$nb_indels++ if @alltest;
	}

	$item->{calling_indel} = $nb_indels."/".$nb_patients." ".join(" ",@pp);
	$item->{calling_indelDes} = $nb_indels."/".$nb_patients;
	$item->{calling_indelDes} = 1 if $nb_indels ==  $nb_patients;

	
	# Progress for nb calling indels
	if ($item->{calling_indelDes}==1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
=pod	
=cut
	####
	# check insert 
	#
	my $query = qq{SELECT r2.type_relation_id, count(r2.genbo2_id) as nb
		FROM RELATION r, RELATION r2 /*7-16-17 Polyproject.type_relation */
		WHERE r.genbo_id = ? /* num patient 6253853*/
		AND r.genbo2_id=r2.genbo_id
		GROUP BY r2.type_relation_id
	};
	my $sthq = $buffer->dbh->prepare_cached($query);	
	my @ppV;
	my @ppI;
	my @ppD;
	my $tag_insert_var=1; # green
	my $tag_insert_ins=1; # green
	my $tag_insert_del=1; # green
	my $ln;
	foreach my $p (@$patients){
 		my @all;
		$sthq->execute($p->id);	
		while (my $idall = $sthq->fetchrow_hashref ) {
                push(@all,$idall);
        }
 		my $types =["variation","insertion","deletion"];
 		foreach my $t (@$types){
 			my ($strand,$type_id,$type_name ) = $buffer->getRelationType("trace",$t);
 			foreach my $c (@all){
 				if ($c->{type_relation_id} == $type_id && $type_name =~ "variation") {   # variation
 					push(@ppV,$p->name.":".$c->{nb});
					$item->{insert_variation} = join(" ",map{$_}@ppV);
					$item->{insert_variationDes} = 1 ;last;
				}	
  				elsif ($c->{type_relation_id} == $type_id && $type_name =~ "insertion") { # insertion
 					push(@ppI,$p->name.":".$c->{nb});
 					$item->{insert_insertion} = join(" ",map{$_}@ppI);
					$item->{insert_insertionDes} = 1 ;last;
 				}
 				elsif ($c->{type_relation_id} == $type_id && $type_name =~ "deletion") { # insertion
  					push(@ppD,$p->name.":".$c->{nb});
 					$item->{insert_deletion} = join(" ",map{$_}@ppD);
					$item->{insert_deletionDes} = 1;last;
 				}
			} 
  		}	
 	}
	if (scalar(@ppV)==0) {$tag_insert_var=0}
	if (scalar(@ppI)==0) {$tag_insert_ins=0}
	if (scalar(@ppD)==0) {$tag_insert_del=0}
	$tag_insert_var=0 if $nb_patients <= 0; # red
	$tag_insert_ins=0 if $nb_patients <= 0; # red
	$tag_insert_del=0 if $nb_patients <= 0; # red
		
	if ($tag_insert_var == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	if ($tag_insert_ins == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	if ($tag_insert_del == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	#
	# check cache 
	#
	my $file_cache_genes = $project->getCacheGenesFile();
 	my $chrs = $project->getChromosomes();
	my $nb_chrs = scalar(@$chrs);
	my @chr_names = map {$_->name} @{$project->getChromosomes()};
	my $types_cache= ["genes","variations"];
	my $nb_cache_gen=0;
	my $nb_cache_var=0;
	my $tag_cache_var=1; #green
	foreach my $type_name (@$types_cache){
		if ($type_name eq "genes") {
			if (-e $file_cache_genes){
				$item->{"cache_".$type_name}=1;
				$nb_cache_gen=1;
			} else {
				$item->{"cache_".$type_name}=0;
			}
			$item->{"cache_".$type_name."Des"} = $item->{"cache_".$type_name};
		} elsif ($type_name eq "variations") {
			my @p_var;			
			foreach my $chr (@chr_names) {
			 	my $file_cache_variation = $project->getCacheVariationsFile($chr);
			 	my $file_cache_variationkct = $project->queryPolyproject::getCacheVariationsFilekct($chr);
			 	
#	warn Dumper $file_cache_variation;
        		if (-e $file_cache_variation){
 					$nb_cache_var++;
			 	}
			 	elsif (-e $file_cache_variationkct) {
					$nb_cache_var++;			 		
			 	}
			 	else {
			 		$tag_cache_var=0;
			 		push(@p_var,"chr".$chr)
			 	}
			}
#	warn Dumper @p_var;
			$tag_cache_var=0 if $nb_patients == -1; # red
			$tag_cache_var=0 if $nb_chrs == 0; # red
			$item->{"cache_".$type_name}= $nb_cache_var."/".$nb_chrs." ".join(" ",@p_var);
			if ($tag_cache_var == 1) {
				$item->{"cache_".$type_name."Des"}=1;
			} else 	{
				$item->{"cache_".$type_name."Des"}=0;
			}	
		}	
	}	
	if ($nb_cache_gen > 0) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	if ($tag_cache_var == 1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}



	#Last progress 
	chop($nb_progress);
	$item->{progress} = $nb_progress;
 	$buffer->dbh->disconnect();
	push(@result,$item);
}
export_data::print(undef,$cgi,\@result);	

=pod	
=cut
 