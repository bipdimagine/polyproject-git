#!/usr/bin/perl
########################################################################
###### progress_projects.pl
#./progress_projects.pl ProjSel="NGS2011_0025"
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
#use lib "$Bin/../GenBo";
#use lib "$Bin/../GenBo/lib/GenBoDB";
#use lib "$Bin/../GenBo/lib/obj";
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use Time::Local;
use queryPolyproject;

use export_data;
use connect;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
my $buffer1 = GBuffer->new(); 
my $cgi    = new CGI();

my $projNAME = $cgi->param('ProjSel');
my $sql2 = qq {and p.name='$projNAME'};
$sql2 = "" unless $projNAME;
#s.name as seqName,
#left join sequencing_machines s
#using (machine_id)

my $sql = qq{select p.name as name,p.project_id as id ,p.type_project_id as ptype,
p.creation_date as cdate,
f.name as plateformName
from
(
projects p
left join projects_machines ps
using (project_id)
left join projects_plateform pf
using (project_id)
left join plateform f
using (plateform_id)
)
where p.type_project_id=3 $sql2;};

my $sth = $buffer1->dbh->prepare($sql) || die();
$sth->execute();
my $res = $sth->fetchall_hashref("name");
my @res;
foreach my $name (keys %$res){
	my $buffer = GBuffer->new(-verbose=>1);
	my $project = $buffer->newProject(-name=>$name);
	my $nb_progress;
	my $item;
	$item->{id} = $project->id(); 
	$item->{name} = $project->name();
	foreach my $k (keys %{$res->{$name} }){
		if($k eq "ptype"){
			my $idtype=$res->{$name}->{$k};
			my $sql3 = qq{select name as ptypename from Polyproject.project_types where type_project_id='$idtype'};
			my $sth2 = $buffer->dbh->prepare($sql3) || die();
			$sth2->execute();
			my $ptypeName = $sth2->fetchrow_array();
			$item->{ptype} = $ptypeName;
		} elsif($k eq "cdate"){
			my @datec = split(/ /,$res->{$name}->{$k});
#			if ($datec[0] =~ m/^(\d{4})-(\d\d)-(\d\d)$/) {
			my ($YY, $MM, $DD) = split("-", $datec[0]);
			my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
			$item->{cdate} = $mydate;
#		} elsif($k eq "seqName"){
#			$item->{seqName} = $res->{$name}->{$k};
		} elsif($k eq "plateformName"){
			$item->{plateform} = $res->{$name}->{$k};
		}
	}
	my $seqNames = $project->queryPolyproject::getSequencingMachines_v2();
	
	#warn Dumper $seqNames;
	my @q_seq;
	foreach my $q (@$seqNames){
		push(@q_seq,$q)
	}
	$item->{seqName} = join(" ",@q_seq);
	
	# warn Dumper $project->getDataBase();
	$item->{database} = $project->getDataBase();
	#$item->{goldenPath} = $project->getGoldenPath();
	$item->{description} = $project->getDescription();
	my $patients = $project->getPatients();
#	warn Dumper $patients;
	$item->{patients} = join(" ",map{$_->name()}@$patients);
	my $nb_patients = scalar(@$patients);
	$nb_patients = -1 if $nb_patients ==0;
	$item->{nbpatients} = $nb_patients;
	#
	# check seq
	#		
	my $dirs = $project->getSequencesDirectories();
	my $nb_seq=0;
	my @p_seq;
	foreach my $p (@$patients){
		my @alltest;
		foreach my $dir (@$dirs) {
			my @testfile = glob($dir."/*".$p->name."*" );
			@alltest=@testfile if @testfile;
		}
		#warn Dumper @alltest;
		$nb_seq++ if @alltest;
		push(@p_seq,$p->name) unless @alltest;
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
	foreach my $p (@$patients){
		#my @alltest;
		#foreach my $a (@$Align){
	#		#my @testfile = glob($p->getBamFile($a));
#			# with obj-lite
#			my @testfile = glob($p->getBamFile());
#			@alltest=@testfile if @testfile;
#		}
#			# with obj-lite
		my @alltest= glob($p->getBamFile());


#		warn Dumper @alltest;
		$nb++ if -@alltest;
		push(@p_bam,$p->name) unless @alltest;

#		$nb++ if -e $p->getBamFile();
#		push(@p_bam,$p->name) unless -e $p->getBamFile();
	}
#	warn Dumper $Align;
	$item->{nb} = $nb;
	$item->{align} = $nb."/".$nb_patients." ".join(" ",@p_bam);
	$item->{alignDes} = $item->{align};
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
			my @testfile = glob($p->getVariationsFile($m)."*" );
			@alltest=@testfile if @testfile;
		}
		push(@pp,$p->name) unless @alltest;
		$nb_variations++ if @alltest;
	#	my @testfile = glob($p->getVariationsFile($methods->[0])."*" );
	#	$nb_variations++ if @testfile;
	#	push(@pp,$p->name) unless @testfile;
	}
	$item->{calling_var} = $nb_variations."/".$nb_patients." ".join(" ",@pp);
	@pp= ();
	$item->{calling_varDes} = $item->{calling_var};
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
	my $nb_indels=0;
	foreach my $p (@$patients){
		my @alltest;
		foreach my $m (@$methods){
			 my @testfile = glob($p->getIndelsFile($m)."*" );
			@alltest=@testfile if @testfile;
		}
		push(@pp,$p->name) unless @alltest;
		$nb_indels++ if @alltest;
#		my @testfile = glob($p->getIndelsFile($methods->[0])."*" );
#		$nb_indels++ if @testfile;
#		push(@pp,$p->name) unless @testfile;
	}
	$item->{calling_indel} = $nb_indels."/".$nb_patients." ".join(" ",@pp);
	$item->{calling_indelDes} = $item->{calling_indel};
	$item->{calling_indelDes} = 1 if $nb_indels ==  $nb_patients;
	
	# Progress for nb calling indels
	if ($item->{calling_indelDes}==1) {
		$nb_progress.="1:"
	} else 	{
		$nb_progress.="0:"
	}
	#
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
	push(@res,$item);
}
export_data::print(undef,$cgi,\@res);
 