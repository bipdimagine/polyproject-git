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
use queryRna;
use connect;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
use List::Util qw/ max min /;
use File::Basename;
use JSON;
my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $numAnalyse = 5; #rnaseq analyse
my $option = $cgi->param('option');
if ( $option eq "info" ) {
	infoProjectSection();
} 

=mod
###########HG38#NGS2021_4038###################### at ./manageRnaProject.pl line 167.
###########HG38#NGS2021_3883###################### at ./manageRnaProject.pl line 167.
###########HG38#NGS2021_3882###################### at ./manageRnaProject.pl line 167.
###########HG38#NGS2021_3754###################### at ./manageRnaProject.pl line 167.
=cut
######################################################################################
sub infoProjectSection {
	my $projid = $cgi->param('ProjSel');
	my $projList = queryRna::getProjectAll($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{label}="name";
	$hdata{identifier}="name";
#	$hdata{identifier}="id";
	my $buffer = GBuffer->new(-verbose=>1);
	foreach my $c (sort {$b->{id} <=> $a->{id}}@$projList){
		my $patientList = queryPolyproject::getPatientInfoFromProject($buffer->dbh,$numAnalyse,$c->{id});
		next unless scalar @$patientList;
#		next unless $c->{name} =~ /(NGS2020_2841)/;
#		next unless $c->{name} =~ /(NGS2019_2368)/;
#		next unless $c->{name} =~ /(NGS2021_4038)/;
#		next unless $c->{name} =~ /(NGS2020_3446)/;
#		next unless $c->{name} =~ /(NGS2021_4491)/;
#		next unless $c->{name} =~ /(NGS2021_4061)/;
		my %s;
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		if ($YY=="0000") {
			$mydate =""
		}
		next unless $mydate;
		
		# Calling method: Only featureCounts
		my @snpList= split(/ /, join(" ",map{$_->{methCall}}@$patientList));
		my $all_snpList=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@snpList}};
		next unless $all_snpList =~ "featureCounts";
		
		#Alignment method: Only hisat2
		my @alnList= split(/ /, join(" ",map{$_->{methAln}}@$patientList));
		my $all_alnList=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@alnList}};	
		next unless $all_alnList =~ "hisat2";
		
		# Sequencing Machine: not NEXTSEQ	
		my @macnameList= split(/ /, join(" ",map{$_->{macName}}@$patientList));
		my $all_macnameList=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@macnameList}};		
		next if $all_macnameList =~ "NEXTSEQ";
		
		
		my $newbuffer = GBuffer->new(-verbose=>1);
		my $project = $newbuffer->newProject(-name=>$c->{name});
		my $patients = $project->getPatients();
		$s{id} = $project->id();
		$s{name} = $project->name();
		#toto
#NGS2021_4218:2021_09_30_HG38_NGS2021_4218  2021_09_30_HG38_NGS2021_4218.zip  AnalyseGO  ListesIngenuity  Venn.diagrams  Venn.diagrams.zip
#NGS2021_3928:align  analysis  Comps.txt  count  deja_vu  Echs.txt  NSanalysis  NSanalysis_All  tracking
#NGS2021_3928:2021_05_19_HG38_NGS2021_3928.zip  2021_06_10_HG38_NGS2021_3928  2021_06_10_HG38_NGS2021_3928.zip  Genes of interest.xlsx  Ingenuity  Ingenuity.zip  ResIngenuity  Venn.diagrams  Venns
#NGS2020_3448#NGS2020_3206#NGS2020_3029#NGS2019_2689#NGS2019_2524#NGS2018_2235#NGS2017_1569#NGS2017_1414
		#next if $s{name} =~ /(NGS2021_4218)|(NGS2021_3928)|(NGS2020_3448)|(NGS2020_3206)|(NGS2020_3029)|(NGS2019_2689)|(NGS2019_2524)|(NGS2018_2235)|(NGS2017_1569)|(NGS2017_1414)/;
		#next unless  $s{name} =~ /(NGS2021_4196)/;		
	#	next unless $s{name} =~ /(NGS2021_4460)|(NGS2021_4447)|(NGS2021_3882)/;
	#	next unless $s{name} =~ /(NGS2021_4460)|(NGS2021_4447)|(NGS2021_3882)|(NGS2021_0643)|(NGS2021_0642)|(NGS2021_0641)/;
	#	next unless $s{name} =~ /(NGS2021_0643)/;
	#	next unless $s{name} =~ /(NGS2021_3928)/;
	#	next unless $s{name} =~ /(NGS2020_2841)/;
		$s{cDate} = $mydate;
		# Release, Release Annotation and Database
		$s{Rel} = $c->{relname};
		my @d_ppversion=split( / /, $c->{ppversionid});
		my @d_relGene=split( / /, $c->{relGene});
		# Run
		my @runidList=split(/ /,join(" ",map{$_->{run_id}}@$patientList));
		$s{runId}=join ' ', sort{$b <=> $a} keys %{{map{$_=>1}@runidList}};
#		# Sequencing Machine	
#		my @macnameList= split(/ /, join(" ",map{$_->{macName}}@$patientList));
#		$s{macName}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@macnameList}};
		$s{macName}=$all_macnameList;
		# Sequencing Method
	#	my @methseqList= split(/ /, join(" ",map{$_->{methSeqName}}@$patientList));
	#	$s{MethSeq}=join ' ',sort{lc $a cmp lc $b} keys %{{map{$_=>1}@methseqList}};
		#Alignment method
		$s{MethAln}=$all_alnList;	
		# Calling method		
		$s{MethSnp}=$all_snpList;
		# Capture Analyse
		my @capnameList= split(/ /, join(" ",map{$_->{capName}}@$patientList));
		$s{capName}=join ' ', sort{lc $a cmp lc $b} keys %{{map{$_=>1}@capnameList}};	
		# Bam / bai
		my @bams;
		my $nbbai=0;
		foreach my $p (@$patients){
			my $alltest= $p->getBamFiles();
			my $bam;
			if (scalar(@$alltest)){
				eval {$bam = $p->getBamFile;};
				if ($@) {
					warn "no Bam Files";
				} else {
					$nbbai++ if -e $bam.".bai";
					push(@bams,$bam);
				}						
			}
		}	
		$s{nbPat} = scalar @$patients;
		$s{nbBai} =$nbbai;
		$s{nbBam} = 0;
		$s{nbBam} = scalar @bams if scalar @bams;
		$s{diffPatBam}= 0;
		$s{diffPatBam}= 1 if $s{nbPat} != $s{nbBam};#PB
		$s{nbBamBai} = 0;
		# /data-isilon/sequencing/ngs/NGS2019_2735/MM38/align/bwa/  ==> 1
		$s{diffBamBai} = 1 if ($s{nbBam}!= $s{nbBai} || $s{nbBam}==0 );#BB
		# featureCounts
		my $dir_count="";
		$dir_count= $project->getCountingDir("featureCounts");
 		my @type_count_file=(".exons.txt",".exons.txt.summary",".genes.txt",".genes.txt.summary");
		my $file_ofcount=1;
		my $stat_count=0;
		foreach my $f (@type_count_file) {
				$file_ofcount=0 unless -e $dir_count.$s{name}.".count".$f;
				$stat_count++ if -e $dir_count.$s{name}.".count".$f;
		}
		$s{featurecounts} = "";#no method featurecount used
		if ($s{MethSnp}=~ "featureCounts") {
			$s{featurecounts} = 0;
			$s{featurecounts} = 1 if $stat_count!=4;			
		}

		my $dirproject=$project->getRootDir();
 		my @type_analyse=("analysis","NSanalysis","Analysis_".$s{name});
  		my $stat_analyse=0;# pas D'analyse
  		##########################
		#g2 analyse################################################################
#		warn "###########$s{Rel}#$s{name}######################"if (-e $dirproject."Analysis_".$s{name});
		my $r_Pfiles=getDirAnalyse($dirproject."Analysis_".$s{name}."/*","P");
		my @sp_PFiles=split(/#/,$r_Pfiles);
		#g1 NSanalyse################################################################
		my $r_NSfiles=getDirAnalyse($dirproject."NSanalysis/*","NS");
		my @sp_NSFiles=split(/#/,$r_NSfiles);
#  pb identifier name Venn.diagrams:S		
		#g1 analyse terminal#######################################################
		my $r_files=getDirAnalyse($dirproject."analysis/*","S");
		my @sp_SFiles=split(/#/,$r_files);
		my @childList;
		my @mergedFiles = (@sp_PFiles,@sp_NSFiles, @sp_SFiles);
#		warn Dumper @mergedFiles;
		my $globalS0;
		my $globalS1;
		my $globalP0="";
		my $globalNS0="";
		my $globalNS1="";
		my ($nbS,$nbNS);
		foreach my $f (@mergedFiles){
			next unless $f =~ ":";
			my @dirp=split(',',$f);
			foreach my $d (@dirp){
				my %child;
				my @dira=split(':',$d);
				if ($dira[1] =~ /(NS)|(S)/) {
					#warn "tototo $dira[0]";
					next if $dira[0] =~ "bak";
					next unless $dira[0] =~ "$s{name}";
				}
#				warn Dumper "ok $dira[0] $dira[1]";
				$child{id} = $s{id};
				$child{name} = $d;
				$child{name} =  "Analysis_$s{name}:P" if ($d =~ "Analysis_");
				my $pz=findzipfile($dirproject,$dira[0],$dira[1]);
				$child{nbg1NSanalyse} ="";
				$child{g1NSanalyse} = "";
				$nbNS++ if ($dira[1] eq "NS");
				$child{g1NSanalyse} = 0 if ($dira[1] eq "NS" && $pz);
				$child{g1NSanalyse} = 1 if ($dira[1] eq "NS" && !$pz);
#				$child{g1NSanalyse} = 0 if ($dira[1] eq "NS");
#				$child{g1NSanalyse} = 1 unless $child{name};
				
#				$child{g1NSanalyse} = 0 if $child{name};
#				$child{g1NSanalyse} = 1 unless $child{name};
				
				
				
				$child{g1analyse} = "";
				$nbS++ if ($dira[1] eq "S");
				$child{nbg1analyse} ="";
				$child{g1analyse} = 0 if ($dira[1] eq "S" && $pz);
				$child{g1analyse} = 1 if ($dira[1] eq "S" && !$pz);
#				warn Dumper $child{g1analyse};
#				$child{g1NSanalyse} = 0 if $child{name};
#				$child{g1NSanalyse} = 1 unless $child{name};
#				$child{g1analyse} = 0 if ($dira[1] eq "S");
				
				$child{g2analyse} = "";
				$child{g2analyse} = 0 if ($dira[1] eq "P");
#				warn "bbbbbbbb $dira[0] $dira[1]";
#				warn Dumper $child{g2analyse};
#				warn Dumper $globalP0;
#				warn "bbbbbbbbe $dira[0] $dira[1]";
				
				$child{nbTanalyse} ="";
				$child{runId} = "";
				$child{MethSnp} = "";
				$child{MethAln} = "";
				$child{macName} = "";
				$child{capName} = "";
				$child{Bam} = "";
				$child{nbPat} = "";
				$child{nbBam} = "";
				$child{Rel} = "";
				$child{cDate} ="";
				$child{statAnalyse}="";
#				warn "A0  child g1analyse $child{g1analyse}";
#				warn "A  S0 $globalS0 S1 $globalS1";
				$globalS1++ if $child{g1analyse};	# S1 if error: means no zip file			
				$globalS0++ if $child{g1analyse} eq '0';# SO  no error : zip file
#				$globalS0++ unless $child{g1analyse}==0;# SO  no error : zip file
#				warn "B  S0 $globalS0 S1 $globalS1";
				$globalNS1++ if $child{g1NSanalyse};
				$globalNS0++ if $child{g1NSanalyse} eq '0';
				$globalP0++ if ($child{g2analyse} eq '0');
#				warn "dddddd $dira[0] $dira[1]";
#				warn Dumper $child{g2analyse};
#				warn Dumper $globalP0;
#				warn "dddddde $dira[0] $dira[1]";
				push(@childList,\%child);
			}
		}
		$s{children}=\@childList;
		$s{Bam} = "";
#		$s{Bam}=getBasename(join(",",sort(@bams))) if scalar @bams;
#		$s{Bam}=getBasename(join(",",sort { $a cmp $b } @bams)) if scalar @bams;
#@new = sort { no warnings; $a <=> $b || $a cmp $b } @old;
#my @y = sort { (($a =~ /(\d+)/)[0] || 0) <=> 
#               (($b =~ /(\d+)/)[0] || 0) } @x;
# my @y = sort { ($a =~ /(\d+)/)[0] <=> ($b =~ /(\d+)/)[0] } @x;

	#	$s{Bam}=getBasename(join(",", sort { (($a =~ /(\d+)/)[0] || 0) <=> (($b =~ /(\d+)/)[0] || 0) } @bams)) if scalar @bams;
	#	$s{Bam}=getBasename(join(",", sort { (($a =~ /(\d+)/)[0]) <=> (($b =~ /(\d+)/)[0]) } @bams)) if scalar @bams;


		$s{Bam}=getBasename(join(",",sort { $a <=> $b || $a cmp $b } @bams)) if scalar @bams;
		#$s{Bam}=getBasename(join(",",sort { number_strip($a) <=> number_strip($b) } @bams)) if scalar @bams;
#warn Dumper $s{Bam}	;	
		$s{nbg1NSanalyse} =0;
		$s{nbg1analyse} =0;
		$s{nbg1NSanalyse} =$nbNS if $nbNS;
		$s{nbg1analyse} =$nbS if $nbS;
		$s{g1NSanalyse} = "";
		$s{g1analyse} = "";
#		warn "S0 $globalS0 S1 $globalS1";
		$s{g1analyse} =0 if $globalS0;
		$s{g1analyse} =1 if $globalS1;
#		warn Dumper $s{g1analyse};
		$s{g1NSanalyse} =0 if $globalNS0;
		$s{g1NSanalyse} =1 if $globalNS1;
		$s{g2analyse} = "";
#		warn "eeeeeeeeee";
#		warn Dumper $globalP0;
		$s{g2analyse} =0 if $globalP0;
		$s{nbg2analyse} =0;
		$s{nbg2analyse} =1 if $globalP0;
		$s{nbTanalyse} =0;
		$s{nbTanalyse} =$s{nbg1NSanalyse}+$s{nbg1analyse}+$s{nbg2analyse};
		$s{statAnalyse}=1;
#		$s{statAnalyse}=0 if (!$s{g1analyse} && $s{g1analyse} ne "");
#		$s{statAnalyse}=0 if $nbS;
		$s{statAnalyse}=0 if ($nbS||$s{g2analyse} eq '0');
#		$s{Bam}="fic1.bam,fic2.bam,fic3.bam";# if local

		push(@data,\%s);
	}
	$hdata{items}=\@data;	
	printJson(\%hdata);
}

sub findzipfile {
	my ($dir,$data,$lib)= @_;
	my $dirzip="";
	$dirzip=$dir."analysis/" if $lib eq "S";
	$dirzip=$dir."NSanalysis/" if $lib eq "NS";
	my $fi=0;
	$fi=1 if -e $dirzip.$data.".zip";
	return $fi;
}
#NGS2021_4218:2021_09_30_HG38_NGS2021_4218  2021_09_30_HG38_NGS2021_4218.zip  AnalyseGO  ListesIngenuity  Venn.diagrams  Venn.diagrams.zip
#NGS2021_3928:align  analysis  Comps.txt  count  deja_vu  Echs.txt  NSanalysis  NSanalysis_All  tracking
#NGS2021_3928:2021_05_19_HG38_NGS2021_3928.zip  2021_06_10_HG38_NGS2021_3928  2021_06_10_HG38_NGS2021_3928.zip  Genes of interest.xlsx  Ingenuity  Ingenuity.zip  ResIngenuity  Venn.diagrams  Venns
#NGS2020_3448#NGS2020_3206#NGS2020_3029#NGS2019_2689#NGS2019_2524#NGS2018_2235#NGS2017_1569#NGS2017_1414
sub getDirAnalyse {
	my ($data,$lib)= @_;
	$data =~ s/\*// if $lib eq "P";
#	warn Dumper "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx $data" if $data =~ "Venn";
	my $zip=0;
	my @analyse=glob($data);
	my @rfile;
	foreach my $f (@analyse) {
		$zip++ if ($f =~ "zip");
		next if ($f =~ "zip");
		if ($lib eq "P") {
			push(@rfile,$f) if -d $f;
		} else {
			push(@rfile,$f) if -e $f;			
		}
	}
	return join(",",map basename($_).":".$lib, @rfile)."#".$zip;
}

sub getBasename {
	my ($data)= @_;
	my @bamfile=split(/,/,$data);
	return join(",",map basename($_), @bamfile);
}

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0);
}

exit(0);
