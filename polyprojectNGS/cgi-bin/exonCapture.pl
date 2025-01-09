#!/usr/bin/perl
########################################################################
###### exonCapture.pl
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
use Time::Local;
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
use Getopt::Long qw(:config no_auto_abbrev);

#$| =1;

my $cgi = new CGI;
my $buffer = GBuffer->new;

my $option;
my $CapSel;
my $capid;
my $RelSel;
my $rel;
my $widePos;
my $matched;


GetOptions(
	'option=s'  => \$option,
	'CapSel=i'  => \$capid,
	'RelSel=s'  => \$rel,
	'widePos=i'  => \$widePos,
	'matched=i'  => \$matched,
) or confess ("not OK options");

if ( $option eq "deposeExons" ) {
	deposeExonsSection();
} 

sub deposeExonsSection {
	my $version=$rel;
	my $publicdir = $buffer->config()->{public_data}->{root}."/".$version."/";
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir."capture/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};
	my ( $name_o, $path_o, $extension_o ) = fileparse($filename, '\.[^\.]*');	

	my $old_exonfile=$path_o.$name_o.".exons*";
	system("rm -f $old_exonfile");
	
 	my $trList = queryPolyproject::getTranscriptFromCapture($buffer->dbh,$captureInfo ->{captureId});
	my $projectname = lastExomeProject();
	my $project = $buffer->newProject(-name=>$projectname);
	
	my $filetmp_out;
	$filetmp_out=$path_o.$name_o.".exonstmp_".$widePos."_".$matched;
	open( my $FHO, '>', $filetmp_out ) or die("Can't create file: $filetmp_out\n");
	my @data;
	my %hdata;
	my %seenT;	
	my %seenV;	
	my $longdata=0;
	$hdata{identifier}="trId";
	foreach my $c (@$trList) {
		my %s;
		my $ver;
		next unless $c->{ensembl_id};		
		if ($name_o) {
			my $dataTr=getAllExons($c->{ensembl_id},$project,$widePos,$filename,$matched);
			my $col=1;
			foreach my $e (@$dataTr) {
				$col++;
			}
			$s{nbExon} = $col-1;
			my $max=$col-1;
			given ($s{nbExon}) {
				when ( $_ >= 100 ) {
					$longdata=1;
					my $f;
					my $col=1;
					$ver=1;
					foreach my $e (@$dataTr) {
						my @tr_l = split( /,/, $e);
						my @ex=split( /_/, $tr_l[0]);
						my ($chrTr)=split("ex", $ex[1]);
						$f->{chr}=$chrTr;
						$f->{gene} = $c->{gene};
						$f->{"col_".$col}=$tr_l[1].":".$ex[1].":".$tr_l[2].":".$tr_l[3];
						if ($col==100) {
							$f->{trId} = $c->{ensembl_id}."_".$ver;
							$f->{nbExon} = $col;
							$f->{nbSub} = $max;
							push(@data,$f) unless ($seenV{$c->{ensembl_id}."_".$ver}++);
							$col=0;
							$f = undef;
						}
						$col++;
						$ver++;
					}
					if ($col >= 1) {
						$ver--;
						$f->{trId} = $c->{ensembl_id}."_".$ver;
						$f->{nbExon} = $col-1;
						$f->{nbSub} = $max;
						push(@data,$f) unless ($seenV{$c->{ensembl_id}."_".$ver}++);
					}
				}
				when ( $_ < 100 ) {
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
			}
		}
		push(@data,\%s) unless ($seenT{$c->{ensembl_id}}++ || $s{nbExon}<=0|| $longdata);
	}
	# matched=0;	
	my @result_sorted=sort my_chr_sort @data;
	my @lFiltered;
	foreach my $u (@result_sorted) {
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
	printFileJson($FHO,\%hdata);

	chmod(0777,$FHO);
	close($FHO);
	my $file_out;
	$file_out=$path_o.$name_o.".exons_".$widePos."_".$matched;
	run("mv $filetmp_out $file_out");	
}

sub printFileJson {
 	my ($FHO,$data)= @_;
#	print $cgi->header('text/json-comment-filtered');
	print $FHO encode_json $data;
#	print encode_json $data;
}

	
############################
	


########################## Transcripts Capture #######################

sub getAllExons {
		my ($tr,$project,$widePos,$filename,$matched)=@_;
		my $chr_trans;
		my $transcript;
		eval { $transcript = $project->newTranscript($tr); };
		if ($@) { return; }
#		warn ref($transcript).' -> '.$transcript->id();
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
				return $projectname;
			}
			$last_pid--;
			if ($count>20) {last};
			$count++;
		}
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

sub run {
	my ($cmd) = @_;
	my $return = system($cmd);
	if ($return ne 0){
		confess("error : $cmd");
	}
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

sub emptyFile {
	my @wdata;
	my %hwdata;
	$hwdata{identifier}="geneId";
	$hwdata{label}="geneId";
	my %s;
	$s{geneId}="No Capture File found";
	$s{gene}="Parsing: NameFile.bed";
	$s{chr}="";
	$s{loc}="";
	$s{nbseen}="";
	push(@wdata,\%s);
	$hwdata{items}=\@wdata;
	printJson(\%hwdata);
}


####################################################################################
sub justsendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
#	exit(0);
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

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}
#./manageCapture.pl option=transcriptsCapture CapSel=372 RelSel=HG19 widePos=0 matched=0

sub sendFormOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendFormError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

