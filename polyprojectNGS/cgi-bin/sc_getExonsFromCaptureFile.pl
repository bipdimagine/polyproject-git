#!/usr/bin/perl
########################################################################
###### manageData.pl
########################################################################
#use CGI;
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

use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
#use DateTime;
#use DateTime::Duration;
use File::Basename;

use GBuffer;
use connect;
use queryPolyproject;
use queryValidationDB;
use Data::Dumper;
use Carp;
use JSON;

#for given/when
use feature qw/switch/;

use GenBoNoSqlAnnotation;
use Getopt::Long qw(:config no_auto_abbrev);
use List::Util qw/ max min /;

my $sep;
my $CapSel;
my $RelSel;
my $widePos;
my $matched;

my $capid;
my $rel;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $message ="Usage :
    	$0 -sep=<separator>   '\\t' or ';'  
   		$0 -CapSel=<capture Id>
   		$0 -RelSel=<Release Genome>
   		$0 -widePos=<Wide Position>
   		$0 -matched=<0 or 1>
\n";



GetOptions(
	'sep=s'  => \$sep,
	'CapSel=i'  => \$capid,
#	'RelSel=s'  => \$RelSel,
	'RelSel=s'  => \$rel,
	'widePos=s'  => \$widePos,
	'matched=i'  => \$matched,
) or confess($message);


my $version=$rel;
my $publicdir = $buffer->config()->{public_data}->{root}.$version."/";

TranscriptsCaptureSection($capid,$rel,$sep);


sub TranscriptsCaptureSection {
	warn Dumper $sep;
    my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir."capture/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};
	warn Dumper $filename;
	my ( $name_o, $path_o, $extension_o ) = fileparse($filename, '\.[^\.]*');	
	emptyFileTC() unless $name_o;	
	if (!(-e $path_o."/".$name_o. $extension_o)) {
		$name_o="";
		emptyFileTC() unless $name_o;
	}
	if (!(-e $path_o."/".$name_o.".bed")) {
		$name_o="";
		emptyFileTC() unless $name_o;
	}
 	my $trList = queryPolyproject::getTranscriptFromCapture($buffer->dbh,$captureInfo ->{captureId});
	my $projectname = lastExomeProject();
	#my $projectname ="NGS2020_2992";
	#warn Dumper $projectname;
	#die;
	my $project = $buffer->newProject(-name=>$projectname);
	my @data;
	my %hdata;
	my %seenT;	
	my $longdata=0;
	$hdata{identifier}="trId";
	my $cpt=1;
	my $colmax;
	foreach my $c (@$trList) {
		my %s;
		next unless $c->{ensembl_id};
#		next unless $c->{gene} eq "ALG8";
#		next unless ($c->{gene} eq "ALG8"||$c->{gene} eq "GPR56");
#		next unless ($c->{gene} eq "ALG8"||$c->{gene} eq "GPR56"||$c->{gene} eq "SCN2A");
		#warn Dumper $c->{ensembl_id};
		warn Dumper $c->{gene};
		if ($c->{ensembl_id} =~ 'ENST00000397345') {
			warn  "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			warn Dumper $c->{gene};
			warn Dumper	$c->{ensembl_id};
		}
		if ($name_o) {
			my $dataTr=getAllExons($c->{ensembl_id},$project,$widePos,$filename,$matched);
			next unless defined $dataTr;
			my $col=1;
			foreach my $e (@$dataTr) {
				$col++;
			}
			$s{nbExon} = $col-1;
			my $max=$col-1;
			my $col=1;
			$longdata=0;
			$s{trId} = $c->{ensembl_id};
			$s{gene} = $c->{gene};
			$s{nbSub} = "";
			foreach my $e (@$dataTr) {
				my @tr_l = split( /,/, $e);
				my @ex=split( /_/, $tr_l[0]);
				my ($chrTr)=split("ex", $ex[1]);
				$s{chr}=$chrTr;
				$s{"col_".$col}=$tr_l[1].":".$ex[1].":".$tr_l[2].":".$tr_l[3];
				$col++;
			}
		}
		push(@data,\%s) unless ($seenT{$c->{ensembl_id}}++ || $s{nbExon}<=0 || $longdata);
	}
#	warn Dumper @data;
	my @result_sorted=sort my_chr_sort @data;
	my @lFiltered;
#	warn Dumper @result_sorted;
	my @lFiltered;
	foreach my $u (@result_sorted) {
		#warn Dumper $u;
		foreach my $key (keys %$u) {
			if ($key =~ /col_/) {
				my $value = $u->{$key};
				if ($value =~ /^U:.+$/) {
					push(@lFiltered, $u);
					last;
				} 
			}
		}
	}
	$hdata{items}=\@result_sorted if $matched;
	$hdata{items}=\@lFiltered unless $matched;
	foreach my $t (keys (%hdata)) {
		if ($t eq "items"){
			my @maxcol;
			my @line_file;
			foreach my $r (@{$hdata{'items'}}) {
				my $h_gene="";
				my $h_tr="";
				my $h_nb="";
				my %tcol;
				while (my ($k, $v) = each %$r) {
             		if ($k eq "gene"){$h_gene=$v}
               		if ($k eq "trId"){$h_tr=$v}
                	if ($k eq "nbExon"){$h_nb=$v;push(@maxcol,$v)}
                	if ($k =~ "col_"){
                		my $e=(split(/_/,$k))[1];
                		$tcol{$e}=((split(/:/,$v))[0] eq "M"?"V":"R");
                	}
				}
				my $line_col="";
				foreach my $v (sort{$a <=> $b}(keys(%tcol))){
#					$line_col.=$tcol{$v}."\t";
					$line_col.=$tcol{$v}.$sep;
				}
				chop($line_col);
#				my $l_file="$h_tr\t$h_gene\t$h_nb\t$line_col";
				my $l_file="$h_tr".$sep."$h_gene".$sep."$h_nb".$sep."$line_col";
				push(@line_file,$l_file);
			}
			my $headerfile=getHeader(max(@maxcol));
			print "$headerfile\n";
			for (my $i = 0; $i< scalar(@line_file); $i++) {
					print "$line_file[$i]\n";
			}
		}
	}
}

sub getHeader {
	my ($nbcol)=@_;
	my $line_col;
	for (my $i = 1; $i< $nbcol+1; $i++) {
		$line_col.=$i.$sep;
	}
	chop($line_col);
	$line_col="Transcript".$sep."Gene".$sep."#Ex".$sep.$line_col;
	return $line_col;
}

#U=unMatched
#M=Matched
sub getAllExons {
		my ($tr,$project,$widePos,$filename,$matched)=@_;
		my $chr_trans;
		my $transcript;
		#warn Dumper $tr;
#		die;
		eval { $transcript = $project->newTranscript($tr); };
		if ($@) {return; } 
#die;
		my $hExons;
		foreach my $exon (sort @{$transcript->getExons()}) {
			$chr_trans = $transcript->getChromosome->ucsc_name();
			my $start = $exon->start();
			my $end = $exon->end();
			$hExons->{$exon->id()}->{start} = $start;
			$hExons->{$exon->id()}->{end} = $end;
		}
		my @lOk;
		my @lnotOk;
		my $hash_match;
		open (FILE, $filename) or die("Can't read this file: $filename\n");
		while (<FILE>) {
			next if m/^$/;
			my $line = $_;
			chomp($line);
			my @lFields = split(' ', $line);
			my $chr_name = $lFields[0];
			next unless ($chr_name eq $chr_trans);
			my $start_bed = $lFields[1] - $widePos;
			my $end_bed = $lFields[2] + $widePos;
			foreach my $exon_id (keys %$hExons) {				
				my $start_exon = $hExons->{$exon_id}->{start};
				my $end_exon = $hExons->{$exon_id}->{end};

				push(@lnotOk, $exon_id.",U,$start_exon-$end_exon,$start_bed-$end_bed") if ($start_exon > $end_bed); #U=unMatched
				next if ($start_exon > $end_bed);
				
				push(@lnotOk, $exon_id.",U,$start_exon-$end_exon,$start_bed-$end_bed") if ($end_exon < $start_bed); #U=unMatched
				next if ($end_exon < $start_bed);
				
				push(@lOk, $exon_id.",M,$start_exon-$end_exon,$start_bed-$end_bed"); #M=Matched
				$hash_match->{$exon_id} = 1;			
				delete $hExons->{$exon_id};
			} 
		}
		close (FILE);
		my @notOk;
		my %seen;
		foreach my $h (sort @lnotOk) {
			my ($tr, $M,$pos,$probe) = split(",", $h);
			next if $hash_match->{$tr};#when matched in @lOk
			push(@notOk,$h) unless $seen{$tr.",".$M.",".$pos}++;
		}
		my @all=sort{
			(split 'ex',$a)[1] <=> (split 'ex',$b)[1]
		
		} (@lOk,@notOk);		
		return \@all;
}


sub my_chr_sort{
	my ($num_a) = give_chr_index($a->{chr});
	my ($num_b) = give_chr_index($b->{chr});
	return $num_a <=> $num_b;
}

sub give_chr_index {
	my ($c) = @_;
	$c =~ s/chr//;
	if ($c eq  'X'){
		return 23;
	}
	if ($c eq 'Y'){
		return 24;
	}
	if ($c eq "MT" || $c eq "M"){
		return 25;
	}
	return $c;
}

sub emptyFileTC {
	my @data;
	my %hdata;
	$hdata{identifier}="trId";
	my %s;
	$s{trId}="No Capture File found";
	$s{gene}="Parsing: NameFile.bed";
	$s{nbExon}="";
	push(@data,\%s);
	$hdata{items}=\@data;
	printJson(\%hdata);
}

#A faire Last project avec utilisateur 
sub lastExomeProject {
		my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
		my $last_pid=$lastProjectId->[0]->{project_id};
		$last_pid += 0;
		my $projectname;
		my $count=0;
		while (1) {
			$projectname = queryPolyproject::getProjectName($buffer->dbh,$last_pid);
			my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$last_pid);
			if ($rel =~ "HG19") {
#A faire Last project avec utilisateur ==> voir utilisateur
				return $projectname;
			}
			$last_pid--;
			if ($count>20) {last};
			$count++;
		}
}

