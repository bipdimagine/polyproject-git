#!/usr/bin/perl
########################################################################
###### manageCapture.pl
########################################################################
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
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";

use Time::Local;
use File::Basename;

use GBuffer;
use connect;
use queryPolyproject;
use queryValidationDB;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Bio::DB::HTS::Tabix;
=mod 	
#use feature qw/switch/; 
given/when deprecated => change for :
given => for
when => if & elsif
default => else
=cut

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $option = $cgi->param('option');

if ( $option eq "transcriptsCapture" ) {
	TranscriptsCaptureSection();
} elsif ( $option eq "captureTranscripts" ) {
	CaptureTranscriptsSection();
} elsif ( $option eq "capture" ) {
	CaptureSection();
} elsif ( $option eq "Newcapture" ) {
	newCaptureSection();
} elsif ( $option eq "upCapture" ) {
	upCaptureSection();
} elsif ( $option eq "captureRef" ) {
	#not used
	CaptureRefSection();
}

########################## Capture ####################################
sub CaptureSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $capid = $cgi->param('capid');
	my $caprel = $cgi->param('caprel');
	my $captureListId = queryPolyproject::getCaptureBundleInfo($buffer->dbh,$numAnalyse,$capid);
	my @data;
	my %hdata;
	$hdata{identifier}="capName";
	$hdata{label}="capName";
	foreach my $c (@$captureListId){
		my %s;
		$s{rel}="";
		my $rel = queryPolyproject::getReleaseNameFromCapture($buffer->dbh,$c->{captureId});
		$rel=join(" ",map{$_->{name}}@$rel) if defined $rel ;
		if (defined $caprel ) {
			if ($caprel eq "None") {$caprel=""};
			next unless $caprel eq $rel;
		}
		my $speciesid = queryPolyproject::getSpeciesIdFromCapture($buffer->dbh,$c->{captureId});
		my $sp="";
		if (defined $speciesid) {
			foreach my $s (@$speciesid) {
				my $inf_species=queryPolyproject::getSpecies($buffer->dbh,$s->{species_id});
				$sp=join(" ",map{$_->{code}}@$inf_species) if $s->{species_id};
			}
			$speciesid = join(" ",map{$_->{species_id}}@$speciesid);			
		}
		$s{capRelGene}="";
		my $caprelGene = queryPolyproject::getReleaseGeneNameFromCapture($buffer->dbh,$c->{captureId});
		$caprelGene=join(" ",map{$_->{name}}@$caprelGene) if defined $caprelGene;
		$s{rel}=$rel if defined $rel;
		$s{speciesId}=$speciesid if defined $speciesid;	
		$s{sp}="" if defined $speciesid;
		$s{sp}=$sp if $sp;
		$s{capRelGene}=$caprelGene if defined $caprelGene;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{capName} = $c->{capName};
		$s{capDes} =  $c->{capDes};
		$s{capFile} = $c->{capFile};
		$s{capVs} = $c->{capVs};
		$s{capType} = $c->{capType};
		$s{capD} = $c->{capType};
		$s{capAnalyse} = $c->{capAnalyse};
		$s{capMeth} =  $c->{capMeth};
		$s{capValidation} = $c->{capValidation};
		unless ($c->{capValidation}) {$s{capValidation} =""};
		$s{umi} = "";
		$s{umi} = $c->{UMI} if  $c->{UMI};
		$s{umiId} = $c->{umi_id};
		$s{def} = $c->{def};
		$s{capFilePrimers} = $c->{capFilePrimers};
		$s{capPrimers} = $c->{capType};
		unless ($c->{capFilePrimers}) {$s{capFilePrimers} =""};
		$s{nbTr}=queryPolyproject::countTranscriptFromCaptureBundle($buffer->dbh,$c->{captureId});
		$s{nbTr} ="" if $s{nbTr} eq "0";
		$s{nbBun}=queryPolyproject::countBundleFromCaptureBundle($buffer->dbh,$c->{captureId});
		$s{nbBun} ="" if $s{nbBun} eq "0";
		$s{bunName} ="";		
		$s{bunName} =up_RedundantBun($c->{bunName}) if $c->{bunName};
		#$s{bunName} = $c->{bunName};
		#$s{bunName} ="" unless  $c->{bunName};		
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = ""; 
		$s{cDate} = $mydate unless ($mydate =~ "00/00/   0");
		$s{FreeCap} = 1;
		$s{FreeCap} = 0 if $s{capFile};
		$s{FreeCap} = 3 if (($s{capAnalyse} !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/) && ! $s{capFilePrimers} && $s{capFile});
		push(@data,\%s);
	}
#	$hdata{items}=\@data;
#	my @result_sorted=sort { "\L$a->{capName}" cmp "\L$b->{capName}" || $b->{capVs} <=> $a->{capVs}} @data;
	my @result_sorted=sort { $b->{captureId} <=> $a->{captureId}} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}
 #redondance
 sub up_RedundantBun {
	my ($namerel) = @_;
	my %max_values;
	for my $entry (split ' ', $namerel) {
		my ($name, $value) = split /:/, $entry;
		$max_values{$name} = $value if !exists $max_values{$name} || $value > $max_values{$name};
	}
	my $namerel_mod = join ' ', map { "$_:$max_values{$_}" } sort {
		index($namerel, "$a:") <=> index($namerel, "$b:")
	} keys %max_values;
	return $namerel_mod;
}
 
#not used
sub CaptureRefSection {
	my $numAnalyse = $cgi->param('numAnalyse');
	my $capid = $cgi->param('capid');
	my $caprel = $cgi->param('caprel');
	my $captureListId = queryPolyproject::getCaptureBundleInfo($buffer->dbh,$numAnalyse,$capid);
	my @data;
	my %hdata;
	$hdata{identifier}="capName";
	$hdata{label}="capName";
	foreach my $c (@$captureListId){
		my %s;
		$s{rel}="";
		my $rel = queryPolyproject::getReleaseRefFromCapture($buffer->dbh,$c->{captureId});
		$rel=join(" ",map{$_->{reference}}@$rel) if defined $rel ;
		if (defined $caprel ) {
			if ($caprel eq "None") {$caprel=""};
			next unless $caprel eq $rel;
		}
		$s{relversion}="";
		my $relversion = queryPolyproject::getReleaseVersionFromCapture($buffer->dbh,$c->{captureId});
		$relversion=join(" ",map{$_->{version}}@$relversion) if defined $relversion ;
		
		$s{capRelGene}="";
		my $caprelGene = queryPolyproject::getReleaseGeneNameFromCapture($buffer->dbh,$c->{captureId});
		$caprelGene=join(" ",map{$_->{name}}@$caprelGene) if defined $caprelGene;
		$s{rel}=$rel if defined $rel;
		$s{relversion}=$relversion if defined $relversion;
		$s{capRelGene}=$caprelGene if defined $caprelGene;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{capName} = $c->{capName};
		$s{capDes} =  $c->{capDes};
		$s{capFile} = $c->{capFile};
		$s{capVs} = $c->{capVs};
		$s{capType} = $c->{capType};
		$s{capD} = $c->{capType};
		$s{capAnalyse} = $c->{capAnalyse};
		$s{capMeth} =  $c->{capMeth};
		$s{capValidation} = $c->{capValidation};
		unless ($c->{capValidation}) {$s{capValidation} =""};
		$s{capFilePrimers} = $c->{capFilePrimers};
		$s{capPrimers} = $c->{capType};
		unless ($c->{capFilePrimers}) {$s{capFilePrimers} =""};
		$s{nbTr}=queryPolyproject::countTranscriptFromCaptureBundle($buffer->dbh,$c->{captureId});
		$s{nbTr} ="" if $s{nbTr} eq "0";
		$s{nbBun}=queryPolyproject::countBundleFromCaptureBundle($buffer->dbh,$c->{captureId});
		$s{nbBun} ="" if $s{nbBun} eq "0";		
		$s{bunName} = $c->{bunName};
		$s{bunName} ="" unless  $c->{bunName};		
		my @datec = split(/ /,$c->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = ""; 
		$s{cDate} = $mydate unless ($mydate =~ "00/00/   0");
		$s{FreeCap} = 1;
		$s{FreeCap} = 0 if $s{capFile};
		$s{FreeCap} = 3 if (($s{capAnalyse} !~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/) && ! $s{capFilePrimers} && $s{capFile});
		push(@data,\%s);
	}
	my @result_sorted=sort { $b->{captureId} <=> $a->{captureId}} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub newCaptureSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $capture = $cgi->param('capture');
	my $capDes = $cgi->param('capDes');
	my $capVs = $cgi->param('capVs');
	my $capFile = $cgi->param('capFile');
	my $capType = $cgi->param('capType');
	my $capUMI = $cgi->param('capUMI');
	my $capMeth = $cgi->param('capMeth');
	my $golden_path = $cgi->param('golden_path');
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
	my $capAnalyse = $cgi->param('capAnalyse');
	my $capValidation = $cgi->param('capValidation');
	my $capRelGene = $cgi->param('capRelGene');
	my $caprelgeneid=0;
	$caprelgeneid=queryPolyproject::get_relGeneIdfromName($buffer->dbh,$capRelGene) unless ($capAnalyse=~ m/(exome)|(genome)|(rnaseq)|(singlecell)|(amplicon)|(other)/);
	my $capFilePrimers = $cgi->param('capFilePrimers');
	# capTypeVal=exome old new
	my $capTypeVal = $cgi->param('capTypeVal');
	
	my $captureid = queryPolyproject::getCaptureFromName($buffer->dbh,$capture);
	if (exists $captureid ->{captureId}) {
		sendError("Capture Name: " . $capture ."...". " already in Capture database");
	} else 	{
### End Autocommit dbh ###########
 		if($capTypeVal eq "new") {
 			my @validationList = queryPolyproject::getSchemasValidation($buffer->dbh,"validation_".$capAnalyse);
			my @val_name;
			foreach my $r (@validationList) {
				my %s;
				next unless scalar @$r;
				push(@val_name,values %{$r->[0]}) if values  %{$r->[0]} ne "";
			}
			sendError("Error Database Validation: " . "@val_name" . " already created") if @val_name ;
 #			dropValidationDB("validation_".$capAnalyse);
 			createValidationDB("validation_".$capAnalyse);
 			$capValidation = $capAnalyse;
  		}
 		# UMI
 		my $capUmi =0;
 		if ($capUMI){
 			my $t_capUmi = queryPolyproject::getUmiFromName($buffer->dbh,$capUMI); 		
 			$capUmi = $t_capUmi->{umi_id};
 		}
#		my $mycaptureid = queryPolyproject::newCaptureData($buffer->dbh,$capture,$capVs,$capDes,$capFile,$capType,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers); 		 
		my $mycaptureid = queryPolyproject::newCaptureData($buffer->dbh,$capture,$capVs,$capDes,$capFile,$capType,$capUmi,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers);
		$dbh->commit();
		sendOK("Successful validation for Capture : ". $capture);	
	}
	exit(0);
}

sub upCaptureSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $capid = $cgi->param('capId');
	my $capture = $cgi->param('capture');
	my $capDes = $cgi->param('capDes');
	my $capVs = $cgi->param('capVs');
	my $capType = $cgi->param('capType');
	my $capUMI = $cgi->param('capUMI');
	my $capMeth = $cgi->param('capMeth');
	my $golden_path = $cgi->param('golden_path');
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
		
	my $capAnalyse = $cgi->param('capAnalyse');
	my $capValidation = $cgi->param('capValidation');
	my $capRelGene = $cgi->param('capRelGene');
	my $caprelgeneid=0;
	$caprelgeneid=queryPolyproject::get_relGeneIdfromName($buffer->dbh,$capRelGene) unless ($capAnalyse=~ m/(exome)|(genome)|(rnaseq)|(singlecell)/);
	# capTypeVal=exome old new
	my $capTypeVal = $cgi->param('capTypeVal');

	my $capFile = $cgi->param('capFile');
	my $capFilePrimers = $cgi->param('capFilePrimers');
	
### End Autocommit dbh ###########
 	if($capTypeVal eq "new") {
 		my @validationList = queryPolyproject::getSchemasValidation($buffer->dbh,"validation_".$capAnalyse);
		my @val_name;
		foreach my $r (@validationList) {
			my %s;
			next unless scalar @$r;
			push(@val_name,values  %{$r->[0]}) if values  %{$r->[0]} ne "";
		}
		sendError("Error Database Validation: " . "@val_name" . " already created") if @val_name ;
 	} 
 	# UMI
 	my $capUmi =0;
 	if ($capUMI){
 		my $t_capUmi = queryPolyproject::getUmiFromName($buffer->dbh,$capUMI); 		
 		$capUmi = $t_capUmi->{umi_id};
 	}
 	queryPolyproject::upCaptureData($buffer->dbh,$capid,$capture,$capVs,$capDes,$capFile,$capType,$capUmi,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers);

 	if($capTypeVal eq "new") {
 #		dropValidationDB("validation_".$capAnalyse);
 		createValidationDB("validation_".$capAnalyse);
 		queryPolyproject::upCaptureValidation($buffer->dbh,$capid,$capAnalyse);
 	} 

	$dbh->commit();
	sendOK("Successful validation for Capture : ". $capture);	
	exit(0);
}
  
 sub dropValidationDB {
	my ($name_DB) = @_;
	queryValidationDB::dropSchemasValidation($buffer->dbh,$name_DB) or 
	die "SchemasValidation not dropped";
 }
 
 sub createValidationDB {
	my ($name_DB) = @_;
	queryValidationDB::createSchemasValidation($buffer->dbh,$name_DB) or 
	die "SchemasValidation not created";
	queryValidationDB::createExonValidation($buffer->dbh,$name_DB) or 
	die "ExonValidation not created";         
 }

########################## Transcripts Capture #######################

sub TranscriptsCaptureSection {
	my $capid = $cgi->param('CapSel');
	my $rel = $cgi->param('RelSel');
	my $widePos = $cgi->param('widePos');
	my $matched = $cgi->param('matched');
	my $version=$rel;
	my $publicdir = $buffer->config()->{public_data}->{root}."/capture/";
    my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$cap->[0]->{capName});
	my $captureDir=$publicdir.$version."/".$captureInfo ->{capType};
	my $filename=$captureDir."/".$captureInfo ->{capFile};

	my $bundleList = queryPolyproject::getBundleFromCapture($buffer->dbh,$capid,0);	
	emptyFileTC() unless scalar @$bundleList;

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
	
	my $project = $buffer->newProject(-name=>$projectname);
	my @data;
	my %hdata;
	my %seenT;	
	my %seenV;	
	my $longdata=0;
	$hdata{identifier}="trId";
	foreach my $c (@$trList) {
		my %s;
		next unless $c->{ensembl_id};		
		my $ver;
		if ($name_o) {
			my $dataTr=getAllExons($c->{ensembl_id},$project,$widePos,$filename,$matched);
			my $col=1;
			foreach my $e (@$dataTr) {
				$col++;
			}
			$s{nbExon} = $col-1;
			my $max=$col-1;
			for ($s{nbExon}) {
				if ( $_ >= 100 ) {
					$longdata=1;
					my $f;
					my $col=1;
					#my $ver=1;
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
				} elsif ( $_ < 100 ) {
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
=mod 	
given => for
when => if & elsif
default => else
			
			given ($s{nbExon}) {
				when ( $_ >= 100 ) {
					$longdata=1;
					my $f;
					my $col=1;
					#my $ver=1;
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
#							push(@data,$f);
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
#						push(@data,$f);
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
=cut
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
	printJson(\%hdata);
}

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
	#warn Dumper $last_pid;
	#$last_pid=4371;
	$last_pid += 0;
	my $projectname;
	my $count=0;
	while (1) {
		$projectname = queryPolyproject::getProjectName($buffer->dbh,$last_pid);
		my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$last_pid);
		if ($rel =~ "HG19") {
			my $patientsP = queryPolyproject::getPatientsFromProject($buffer->dbh,$last_pid);
			return $projectname if $patientsP->[0]->{name};
		}
		$last_pid--;
		if ($count>20) {last};
		$count++;
	}
}

########################## capture Transcripts #######################tototo
sub CaptureTranscriptsSection {
	my $capid = $cgi->param('CapSel');
	my $rel = $cgi->param('RelSel');
	my $widePos = $cgi->param('widePos');
	my $threshold = $cgi->param('threshold');
	my $projectname = lastExomeProject();
	my $bundleList = queryPolyproject::getBundleFromCapture($buffer->dbh,$capid,0);	
	emptyFile() unless scalar @$bundleList;
	my ($hash_trans, $hash_obj);
	my $project = $buffer->newProject(-name=>$projectname);
	$project->{captures_object}->{$capid} = undef;
	my $capture = $project->getCaptures->[0];
	my $captureFileName;
	eval {$captureFileName =  $capture->gzFileName();};
	if ($@) { emptyFile();return; }
	$captureFileName =  $capture->gzFileName();
	my $tabix = Bio::DB::HTS::Tabix->new( filename => $captureFileName );
	foreach my $chr (@{$project->getChromosomes()}) {
		my $capture_intspan_cov =  $capture->getIntSpanForChromosome($chr);
		my $res = $tabix->query($chr->fasta_name);
		next unless $res;
		while (my $line = $res->next) {
			my @lCol = split(" ", $line);
			my $start = $lCol[1];
			my $end = $lCol[2];
			foreach my $gene (@{$chr->getGenesByPosition($start, $end)}) {
				my $intspan_gene = Set::IntSpan::Fast->new( $gene->start().'-'.$gene->end() );
				my $intspan_inter = $intspan_gene->intersection($capture_intspan_cov);
				unless ($intspan_inter->is_empty()) {
					foreach my $tr (@{$gene->getTranscripts()}) {
						next unless ($tr->protein());
						my $intspan_tr = Set::IntSpan::Fast->new( $tr->start().'-'.$tr->end() );
						my $intspan_inter2 = $intspan_tr->intersection($capture_intspan_cov);
						unless ($intspan_inter2->is_empty()) {
							my $length_exons = 0;
							foreach my $exon (@{$tr->getExons()}) {
								my $length = $exon->end() - $exon->start() + 1;
								$length_exons += $length;
							}
							my $nb_common_pos = 0;
							foreach my $pos (split(',', $intspan_inter2->as_string())) {
								my @lpos = split('-', $pos);
								if (scalar(@lpos) == 2) {
									my $nb_pos_interval = $lpos[1] - $lpos[0] + 1;
									$nb_common_pos += $nb_pos_interval;
								}
								else { $nb_common_pos++; }
							}
							my $perc = ($nb_common_pos / $length_exons) * 100;
							next if ($perc <= $threshold);
							$hash_obj->{$gene->id()}->{$tr->id()}++;
						}
					}
				}
			}
	  	}
	
=mod
	my $tabix = new Tabix(-data  => $captureFileName);	
	foreach my $chr (@{$project->getChromosomes()}) {
		my ($find) = grep {$_ eq $chr->ucsc_name} $tabix->getnames();
		next unless ($find);
		my $capture_intspan_cov =  $capture->getIntSpanForChromosome($chr);
		my $res = $tabix->query($chr->ucsc_name);
		while(my $line = $tabix->read($res)){
			my @lCol = split(" ", $line);
			my $start = $lCol[1];
			my $end = $lCol[2];
			foreach my $gene (@{$chr->getGenesByPosition($start, $end)}) {
				my $intspan_gene = Set::IntSpan::Fast->new( $gene->start().'-'.$gene->end() );
				my $intspan_inter = $intspan_gene->intersection($capture_intspan_cov);
				unless ($intspan_inter->is_empty()) {
					foreach my $tr (@{$gene->getTranscripts()}) {
						next unless ($tr->protein());
						my $intspan_tr = Set::IntSpan::Fast->new( $tr->start().'-'.$tr->end() );
						my $intspan_inter2 = $intspan_tr->intersection($capture_intspan_cov);
						unless ($intspan_inter2->is_empty()) {
							my $length_exons = 0;
							foreach my $exon (@{$tr->getExons()}) {
								my $length = $exon->end() - $exon->start() + 1;
								$length_exons += $length;
							}
							my $nb_common_pos = 0;
							foreach my $pos (split(',', $intspan_inter2->as_string())) {
								my @lpos = split('-', $pos);
								if (scalar(@lpos) == 2) {
									my $nb_pos_interval = $lpos[1] - $lpos[0] + 1;
									$nb_common_pos += $nb_pos_interval;
								}
								else { $nb_common_pos++; }
							}
							my $perc = ($nb_common_pos / $length_exons) * 100;
							next if ($perc <= $threshold);
							$hash_obj->{$gene->id()}->{$tr->id()}++;
						}
					}
				}
			}
	  	}
=cut
	}
	
 	my $trList = queryPolyproject::getTranscriptFromCapture($buffer->dbh, $capid);
 	emptyFile() unless scalar @$trList>1;
	my $hash_gene;
 	foreach my $h (@$trList) {
		$hash_gene->{$h->{'gene'}} = 1;
 		$hash_trans->{$h->{'ensembl_id'}} = undef;
 	}
  	
	foreach my $gene_id (keys %$hash_obj) {
		my $ok;
		foreach my $trans_id (keys %{$hash_obj->{$gene_id}}) {
			next if ($ok);
			if (exists $hash_trans->{$trans_id}) {
				delete $hash_trans->{$trans_id};
				$ok = 1;
			}
		}
		if ($ok) {
			delete $hash_obj->{$gene_id};
		}
	}
	my @data;
	my %hdata;
	$hdata{identifier}="geneId";
	$hdata{label}="geneId";
	my $row=1;
	foreach my $gene (sort keys %$hash_obj) {
		my $item;
		my ($gene_id, $this_chr) = split("_", $gene);

		my $mygene=$project->newGene($gene);
#		warn ref($mygene).' -> '.$mygene->id().' - '.$mygene->start().' - '.$mygene->end();
		$item->{geneId}=$mygene->id();
		$item->{gene}=$mygene->external_name();
		$item->{un}=0;
		$item->{un}=1 unless $hash_gene->{$item->{gene}};		
		$item->{chr}=$mygene->getChromosome->ucsc_name();		
		$item->{loc}=0;
		$item->{loc}=$mygene->start().' - '.$mygene->end();
		$item->{nbseen}="";
		my %seenTr;
		my @childList;
		foreach my $trans (keys %{$hash_obj->{$gene}}) {
			my %child;
			my $transcript;
			eval { $transcript = $project->newTranscript($trans); };
			if ($@) { last; }
			my ($tr_id, $this_chr) = split("_", $transcript->id());
			$child{geneId} = $tr_id;
			$child{gene} ="";
			$child{chr} = $transcript->getChromosome->ucsc_name();
			$child{loc} = $transcript->start().' - '.$transcript->end();
			$child{nbseen} =${$hash_obj->{$gene}}{$trans};
			$item->{nbseen}=${$hash_obj->{$gene}}{$trans};
#			warn ref($transcript).' - '.$transcript->id().' - '.$transcript->start().' - '.$transcript->end();
			push(@childList,\%child);
		}
		$item->{children}=\@childList;
		push(@data,$item);
		$row++;
	}
	my @result_sorted=sort my_chr_sort @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}


=mod
sub CaptureTranscriptsSection {
	my $capid = $cgi->param('CapSel');
	my $rel = $cgi->param('RelSel');
	my $widePos = $cgi->param('widePos');
	my $threshold = $cgi->param('threshold');
	my $projectname = lastExomeProject();
	my $bundleList = queryPolyproject::getBundleFromCapture($buffer->dbh,$capid,0);	
	emptyFile() unless scalar @$bundleList;
	my ($hash_trans, $hash_obj);
	my $project = $buffer->newProject(-name=>$projectname);
	$project->{captures_object}->{$capid} = undef;
	my $capture = $project->getCaptures->[0];
	my $captureFileName;
	eval {$captureFileName =  $capture->gzFileName();};
	if ($@) { emptyFile();return; }
	$captureFileName =  $capture->gzFileName();
	my $tabix = new Tabix(-data  => $captureFileName);	
	foreach my $chr (@{$project->getChromosomes()}) {
		my ($find) = grep {$_ eq $chr->ucsc_name} $tabix->getnames();
		next unless ($find);
		my $capture_intspan_cov =  $capture->getIntSpanForChromosome($chr);
		my $res = $tabix->query($chr->ucsc_name);
		while(my $line = $tabix->read($res)){
			my @lCol = split(" ", $line);
			my $start = $lCol[1];
			my $end = $lCol[2];
			foreach my $gene (@{$chr->getGenesByPosition($start, $end)}) {
				my $intspan_gene = Set::IntSpan::Fast->new( $gene->start().'-'.$gene->end() );
				my $intspan_inter = $intspan_gene->intersection($capture_intspan_cov);
				unless ($intspan_inter->is_empty()) {
					foreach my $tr (@{$gene->getTranscripts()}) {
						next unless ($tr->protein());
						my $intspan_tr = Set::IntSpan::Fast->new( $tr->start().'-'.$tr->end() );
						my $intspan_inter2 = $intspan_tr->intersection($capture_intspan_cov);
						unless ($intspan_inter2->is_empty()) {
							my $length_exons = 0;
							foreach my $exon (@{$tr->getExons()}) {
								my $length = $exon->end() - $exon->start() + 1;
								$length_exons += $length;
							}
							my $nb_common_pos = 0;
							foreach my $pos (split(',', $intspan_inter2->as_string())) {
								my @lpos = split('-', $pos);
								if (scalar(@lpos) == 2) {
									my $nb_pos_interval = $lpos[1] - $lpos[0] + 1;
									$nb_common_pos += $nb_pos_interval;
								}
								else { $nb_common_pos++; }
							}
							my $perc = ($nb_common_pos / $length_exons) * 100;
							next if ($perc <= $threshold);
							$hash_obj->{$gene->id()}->{$tr->id()}++;
						}
					}
				}
			}
	  	}
	}
	
 	my $trList = queryPolyproject::getTranscriptFromCapture($buffer->dbh, $capid);
 	emptyFile() unless scalar @$trList>1;
	my $hash_gene;
 	foreach my $h (@$trList) {
		$hash_gene->{$h->{'gene'}} = 1;
 		$hash_trans->{$h->{'ensembl_id'}} = undef;
 	}
  	
	foreach my $gene_id (keys %$hash_obj) {
		my $ok;
		foreach my $trans_id (keys %{$hash_obj->{$gene_id}}) {
			next if ($ok);
			if (exists $hash_trans->{$trans_id}) {
				delete $hash_trans->{$trans_id};
				$ok = 1;
			}
		}
		if ($ok) {
			delete $hash_obj->{$gene_id};
		}
	}
	my @data;
	my %hdata;
	$hdata{identifier}="geneId";
	$hdata{label}="geneId";
	my $row=1;
	foreach my $gene (sort keys %$hash_obj) {
		my $item;
		my ($gene_id, $this_chr) = split("_", $gene);

		my $mygene=$project->newGene($gene);
#		warn ref($mygene).' -> '.$mygene->id().' - '.$mygene->start().' - '.$mygene->end();
		$item->{geneId}=$mygene->id();
		$item->{gene}=$mygene->external_name();
		$item->{un}=0;
		$item->{un}=1 unless $hash_gene->{$item->{gene}};		
		$item->{chr}=$mygene->getChromosome->ucsc_name();		
		$item->{loc}=0;
		$item->{loc}=$mygene->start().' - '.$mygene->end();
		$item->{nbseen}="";
		my %seenTr;
		my @childList;
		foreach my $trans (keys %{$hash_obj->{$gene}}) {
			my %child;
			my $transcript;
			eval { $transcript = $project->newTranscript($trans); };
			if ($@) { last; }
			my ($tr_id, $this_chr) = split("_", $transcript->id());
			$child{geneId} = $tr_id;
			$child{gene} ="";
			$child{chr} = $transcript->getChromosome->ucsc_name();
			$child{loc} = $transcript->start().' - '.$transcript->end();
			$child{nbseen} =${$hash_obj->{$gene}}{$trans};
			$item->{nbseen}=${$hash_obj->{$gene}}{$trans};
#			warn ref($transcript).' - '.$transcript->id().' - '.$transcript->start().' - '.$transcript->end();
			push(@childList,\%child);
		}
		$item->{children}=\@childList;
		push(@data,$item);
		$row++;
	}
	my @result_sorted=sort my_chr_sort @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}
=cut
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

####################################################################################
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

