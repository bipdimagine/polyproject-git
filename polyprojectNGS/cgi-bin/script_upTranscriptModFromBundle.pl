#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_upTranscriptModFromBundle.pl
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
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#use GenBoWriteNgs;
#use GenBoQueryNgs;
#use GenBoRelationWrite;
#use GenBoProjectWriteNgs;
#use GenBoProjectQueryNgs;
#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use queryPanel;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $add;
my $info;
my $force;
my $bundle;
my $bunid;
my $btrans;
my $mode;
my $bundle_mode;
my $gene;
my $is_gene;
my $enst;
my $is_enst;
my $nomode;
my $filename;


# Faire -force
print "-------------------------\n";
print "$0 @ARGV\n";
print "-------------------------\n";


# ./script_upTranscriptModFromBundle.pl -opt=add -bundle=IdFix_v2_AR -mode=AR
my $res_opt=GetOptions(
	'add'  => \$add,
	'info'  => \$info,
	'force'  => \$force,
	'bundle=s' => \$bundle,
	'bunid=i' => \$bunid,
	'btrans'  => \$btrans,
        'mode:s' => \$mode,
        'modeBun=s' => \$bundle_mode,
        'gene=s' => \$gene,
        'is_gene' => \$is_gene,
        'enst=s' => \$enst,
        'is_enst' => \$is_enst,
 	'filename=s' => \$filename,
	    
);

my $message ="usage :
	Add Transmission Mode for all Transcripts in Gene
	$0 -add -bundle=Bundle_name -mode=mode_name [-force] [-btrans] // Same Mode for all transcripts in Bundle
						or -bunid=Bundle_id
						-mode=[AD,AR,XL,XLR,XLD,print,...], -mode= for empty mode,
						-force Replace old mode by new mode
						-bundle=Bundle_name -bunid=Bundle_id Tansmisssion mode for Bundles
						-btrans if -bundle or -bunid. Only for Bundle Transcript

	$0 -add -gene=gene_name -mode=mode_name [-bundle=Bundle_name] [-btrans]
						or [-bunid=Bundle_id]
						-bundle=Bundle_name -bunid=Bundle_id Tansmisssion mode for Bundles
						-btrans if -bundle or -bunid . Only for Bundle Transcript
						-mode=[AD,AR,XL,XLR,XLD,print,...], -mode= for empty mode,
						-force Replace old mode by new mode

	$0 -add -enst=ensembl_id -mode=mode_name [-force]
						-mode=[AD,AR,XL,XLR,XLD,print,...], -mode= for empty mode,
						-force Replace old mode by new mode

	$0 -add -filename=file_name -is_gene [-bundle=Bundle_name] [-btrans] [-force]
						or -is_enst
						-force Replace old mode by new mode
						-btrans if -bundle or -bunid . Only for Bundle Transcript
						Gene Tabulated File :       -is_gene mode [' ',AD,AR,XL,XLR,XLD,...]
						ENSEMBL Id Tabulated File : -is_enst mode [' ',AD,AR,XL,XLR,XLD,...]

	Display Transmission Mode for all Transcripts in Gene
 	$0 -info -bundle=Bundle_name [-btrans] 
						or -bunid=Bundle_id 
						-btrans if -bundle or -bunid. Only for Bundle Transcript

	$0 -info -gene=gene_name [-bundle=Bundle_name] [-btrans]
						or [-bunid=Bundle_id]
						-bundle=Bundle_name -bunid=Bundle_id Tansmisssion mode for Bundles
						-btrans if -bundle or -bunid. Only for Bundle Transcript

 	$0 -info -enst=ensembl_id [-bundle=Bundle_name] [-btrans]
						or [-bunid=Bundle_id]
						-bundle=Bundle_name -bunid=Bundle_id Tansmisssion mode for Bundles
						-btrans if -bundle or -bunid. Only for Bundle Transcript

	$0 -info -filename=file_name -is_gene [-bundle=Bundle_name] [-btrans]
 	                                        or -is_enst  or [-bunid=Bundle_id]

						Gene Tabulated File :       -is_gene mode [' ',AD,AR,XL,XLR,XLD,print,...]
	                                        ENSEMBL Id Tabulated File : -is_enst mode [' ',AD,AR,XL,XLR,XLD,print,...]
						-bundle=Bundle_name -bunid=Bundle_id Tansmisssion mode for Bundles
						-btrans if -bundle or -bunid. Only for Bundle Transcript
  	\n
";

die "$message\n" unless $res_opt;
unless ($add || $info) {
	confess ($message);
}
if ($add && $info) {
	confess ($message);
}
$btrans=0 if ! $btrans;
my $bun_info;

if ($filename) {
	if (! $is_gene && ! $is_enst) {
		confess ($message);
	}
	if ($bundle && $bunid ) {confess ($message)};
	if (defined $mode) {confess ($message)};
	$bun_info = queryPolyproject::getBundleFromName($buffer->dbh,$bundle) if $bundle;
	die( "ERROR: Unknown Bundle: " . $bundle."\n") unless ($bun_info->{bundleId} || !$bundle);

	$bun_info=queryPanel::getBundle($buffer->dbh,$bunid) if $bunid;
	die( "ERROR: Unknown Bundle Id: " . $bunid."\n") unless ($bun_info->{bundleId} || !$bunid);
	open (FILE, $filename) or die("Can't read this file: $filename\n");

	if ($btrans && (!$bundle && !$bunid) ) {confess ($message)};
	$force=0 unless $force;
	$btrans=0 unless ($bundle||$bunid);
	print "File Name: $filename\n";
	my $ln=1;
	while (<FILE>) {
		my $line = $_;
		chomp($line);
		my @sp_line=split("\t",$line);
		last if not @sp_line;
		my $gene=$sp_line[0] if $is_gene;
		my $enst=$sp_line[0] if $is_enst;
		my $mode=$sp_line[1];
		print "\n";
		print "$ln $gene $mode\n" if $is_gene;
		print "$ln $enst $mode\n" if $is_enst;
		print "======================\n";
		if ($enst !~ /^(ENST)/ && $is_enst) { print "ERROR: Not an ENST Id Transcript File from ENSEMBL\n";exit};
		if ($gene =~ /^(ENST)/ && $is_gene) { print "ERROR: Not an GENE File\n";exit};
		my $tr_info;
		if ($is_gene) {
			$tr_info=getTranscriptFromGene($buffer->dbh,$gene) unless ($bundle||$bunid);
			# gene=>1,enst=>0
			$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$gene,1) if ($bundle||$bunid);
			die( "\nERROR: Gene $gene Not in Bundle\n") unless (scalar @$tr_info);
		}
		my $tr_id;
		if ($is_enst) {
			$tr_id = queryPolyproject::getTranscriptId($buffer->dbh,$enst);
			$tr_info=queryPolyproject::getTranscript($buffer->dbh,$tr_id) unless ($bundle||$bunid);
			# gene=>1,enst=>0
			$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$tr_id,0) if ($bundle||$bunid);
			die( "\nERROR: Ensembl Id $enst Not in Bundle\n") unless (scalar @$tr_info);
		}
		my @sp_mode = split( /[ ,\/]/, $mode );
		if (scalar(@sp_mode) ) {

			my $m_force=$force;
			for (my $i = 0; $i< scalar(@sp_mode); $i++) {
				next unless $sp_mode[$i];
				$nomode=0 if $sp_mode[$i];	
				updateTranscriptMode($tr_info,$sp_mode[$i],$btrans,$nomode,$force);
				if ($is_gene) {
					$tr_info=getTranscriptFromGene($buffer->dbh,$gene) unless ($bundle||$bunid);
					# gene=>1,enst=>0
					$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$gene,1) if ($bundle||$bunid);
				}

				if ($is_enst) {
					$tr_id = queryPolyproject::getTranscriptId($buffer->dbh,$enst);
					$tr_info=queryPolyproject::getTranscript($buffer->dbh,$tr_id) unless ($bundle||$bunid);
					# gene=>1,enst=>0
					$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$tr_id,0) if ($bundle||$bunid);
				}
				$force=0 if $i==0;
			}
			$force=$m_force;
		} else {
			updateTranscriptMode($tr_info,$mode,$btrans,$nomode,$force);
		}
		$ln++;
	}	
	close (FILE);	
	exit;
}

if ((!$gene && !$enst) && ($bundle || $bunid)) {
	if (! defined $mode && $add ) {confess ($message)};
	if ($bundle && $bunid ) {confess ($message)};
	$force=0 unless $force;	
		
	$bun_info = queryPolyproject::getBundleFromName($buffer->dbh,$bundle) if $bundle;
	die( "ERROR: Unknown Bundle: " . $bundle."\n") unless ($bun_info->{bundleId} || !$bundle);
	$bun_info=queryPanel::getBundle($buffer->dbh,$bunid) if $bunid;
	die( "ERROR: Unknown Bundle Id: " . $bunid."\n") unless ($bun_info->{bundleId} || !$bunid);
	my $bundleTransIdList = queryPolyproject::getBundleTranscriptId($buffer->dbh,$bun_info->{bundleId});
	print "Bundle: $bun_info->{bundleId} $bundle\n";
	my @sp_mode = split( /[ ,\/]/, $mode );
	my $count=1;
	if (scalar(@sp_mode) ) {
		my $m_force=$force;
		for (my $i = 0; $i< scalar(@sp_mode); $i++) {
			next unless $sp_mode[$i];
			print "\n     $count Transmission Mode: $sp_mode[$i]\n";
			transmissionFromBundle($bundleTransIdList,$sp_mode[$i],$btrans,$nomode,$force) if $bun_info->{bundleId};
			$force=0 if $i==0;
			$count++;
		} 
		$force=$m_force;
	} else {
		print "\n     Transmission Mode: $mode\n";
		transmissionFromBundle($bundleTransIdList,$mode,$btrans,$nomode,$force) if $bun_info->{bundleId};
	}
}

if ($gene) {
	if ($info && $add ) {confess ($message)};
	if (! defined $mode && $add ) {confess ($message)};
	if ($bundle && $bunid ) {confess ($message)};
	if ($btrans && (!$bundle && !$bunid) ) {confess ($message)};

	$bun_info = queryPolyproject::getBundleFromName($buffer->dbh,$bundle) if $bundle;
	die( "ERROR: Unknown Bundle: " . $bundle."\n") unless ($bun_info->{bundleId} || !$bundle);
	$bun_info=queryPanel::getBundle($buffer->dbh,$bunid) if $bunid;
	die( "ERROR: Unknown Bundle Id: " . $bunid."\n") unless ($bun_info->{bundleId} || !$bunid);

	my $tr_info;
	$tr_info=getTranscriptFromGene($buffer->dbh,$gene) unless ($bundle||$bunid);
	# gene=>1,enst=>0
	$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$gene,1) if ($bundle||$bunid);
	die( "ERROR: Gene $gene Not in Bundle\n") unless (scalar @$tr_info);
	$nomode=1 unless $mode;
	$nomode=0 if $mode;
	$force=0 unless $force;
	$btrans=0 unless ($bundle||$bunid);
	my @sp_mode = split( /[ ,\/]/, $mode );
	my $count=1;

	if (scalar(@sp_mode) ) {
		my $m_force=$force;
		for (my $i = 0; $i< scalar(@sp_mode); $i++) {
			next unless $sp_mode[$i];
			print "\n     $count Transmission Mode: $sp_mode[$i]\n";
			updateTranscriptMode($tr_info,$sp_mode[$i],$btrans,$nomode,$force);
			$tr_info=getTranscriptFromGene($buffer->dbh,$gene) unless ($bundle||$bunid);
			# gene=>1,enst=>0
			$tr_info=getTranscriptFromBundle($buffer->dbh,$bunid,$gene,1) if ($bundle||$bunid);
			$force=0 if $i==0;
			$count++;
		}
		$force=$m_force;
	} else {
		updateTranscriptMode($tr_info,$mode,$btrans,$nomode,$force);
	}
}

if ($enst) {
	if ($info && $add ) {confess ($message)};
	if (! defined $mode && $add ) {confess ($message)};
	if ($bundle && $bunid ) {confess ($message)};
	if ($btrans && (!$bundle && !$bunid) ) {confess ($message)};

	$bun_info = queryPolyproject::getBundleFromName($buffer->dbh,$bundle) if $bundle;
	die( "ERROR: Unknown Bundle: " . $bundle."\n") unless ($bun_info->{bundleId} || !$bundle);

	$bun_info=queryPanel::getBundle($buffer->dbh,$bunid) if $bunid;
	die( "ERROR: Unknown Bundle Id: " . $bunid."\n") unless ($bun_info->{bundleId} || !$bunid);
	$nomode=1 unless $mode;
	$nomode=0 if $mode;
	$btrans=0 unless ($bundle||$bunid);

	my $tr_id = queryPolyproject::getTranscriptId($buffer->dbh,$enst);
	my $tr_info;
	$tr_info=queryPolyproject::getTranscript($buffer->dbh,$tr_id) unless ($bundle||$bunid);
	$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$tr_id,0) if ($bundle||$bunid);
	die( "\nERROR: Ensembl Id $enst Not in Bundle\n") unless (scalar @$tr_info);
	my @sp_mode = split( /[ ,\/]/, $mode );
	my $count=1;
	if (scalar(@sp_mode) ) {
		my $m_force=$force;
		for (my $i = 0; $i< scalar(@sp_mode); $i++) {
			next unless $sp_mode[$i];
			print "\n     $count Transmission Mode: $sp_mode[$i]\n";
			updateTranscriptMode($tr_info,$sp_mode[$i],$btrans,$nomode,$force);
			$tr_id = queryPolyproject::getTranscriptId($buffer->dbh,$enst);
			$tr_info=queryPolyproject::getTranscript($buffer->dbh,$tr_id) unless ($bundle||$bunid);
			$tr_info=getTranscriptFromBundle($buffer->dbh,$bun_info->{bundleId},$tr_id,0) if ($bundle||$bunid);
			$force=0 if $i==0;
			$count++;
		}
		$force=$m_force;
	} else {
		updateTranscriptMode($tr_info,$mode,$btrans,$nomode,$force);
	}
}

sub updateTranscriptMode {
	my ($trList,$mode,$btrans,$no,$force) = @_;
	my $count=1;
	foreach my $t (@$trList) {
		my $tr_mode_old="";
		my $tr_mode_new="";

		$tr_mode_new=$mode unless $no;		
		my $b_mode;
		if ($btrans) {
			$b_mode=queryPolyproject::getBundleTranscriptId($buffer->dbh,$t->{bundle_id},$t->{id});
			$tr_mode_old=$b_mode->[0]->{transmission} unless $no;
		} else {
			$tr_mode_old=$t->{transmission} unless $no;
		}
		if ($tr_mode_old) {
			my @sp_old=split(/\//,$tr_mode_old);
			my $res=0;
			$res=find_Oldmode($tr_mode_new,@sp_old) if $tr_mode_new;
			if ($tr_mode_new) {
				$tr_mode_new=$tr_mode_old if $res;
				$tr_mode_new=$tr_mode_old."/".$mode unless $res;
			}			
			$tr_mode_old="(old:$tr_mode_old)";
		};
		if ($btrans) {
			$tr_mode_new=$b_mode->[0]->{transmission} if $info;
		} else {
			$tr_mode_new=$t->{transmission} if $info;
		}
		$tr_mode_old="" if $info;
		if ($add) {
			$tr_mode_new=$mode if $force;
			$tr_mode_new=caseXL($tr_mode_new);
			queryPolyproject::upTranscriptTransmission($buffer->dbh,$t->{id},$tr_mode_new) unless $btrans;
			queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bun_info->{bundleId},$t->{id},$tr_mode_new) if  $btrans;
		}
		print "$count Transcript: $t->{id} $t->{ensembl_id} Gene: $t->{gene} => Transcript Mode: $tr_mode_new $tr_mode_old\n" unless $btrans;
		print "$count Transcript: $t->{id} $t->{ensembl_id} Gene: $t->{gene} => Bundle Transcript Mode: $tr_mode_new $tr_mode_old \n" if  $btrans;
		$count++;
	}
}

sub caseXL {
	my ($mode) = @_;
	return $mode if ($mode !~ /^(XL)/);
	my @sp_mode = split( /[ ,\/]/, $mode );
	my $nbXL=0;
	for (my $i = 0; $i< scalar(@sp_mode); $i++) {
		$nbXL++ if $sp_mode[$i]=~"XL";
	}
	return $mode="XLR/XLD" if ($nbXL==3);
	return $mode;	
}

sub find_Oldmode {
	my ($mode,@old) = @_;
	my $find=0;
	foreach my $o (@old) {
		$find=1 if $mode eq $o;
	}
	return $find;
}

sub transmissionFromBundle {
	my ($bunList,$mode,$btrans,$no,$force) = @_;
	my $count=1;
	foreach my $t (@$bunList) {
		my $tr=queryPolyproject::getTranscript($buffer->dbh,$t->{transcript_id});
		my $tr_info=getTranscriptFromGene($buffer->dbh,$tr->[0]->{gene});
		print "  $count Bundle Transcript ID: $t->{transcript_id}\n" if $btrans;
		print "  $count Bundle Transcript ID: $t->{transcript_id} And all Transcripts from Gene \n" unless $btrans;
		updateTranscriptMode($tr,$mode,$btrans,$no,$force) if $btrans;
		updateTranscriptMode($tr_info,$mode,$btrans,$no,$force) unless $btrans;
		$count++;
	}
}

sub getTranscriptFromGene {
        my ($dbh,$gene)=@_;
        my $sql = qq{        	
			SELECT t.id, t.ensembl_id, t.gene, t.transmission
			FROM PolyprojectNGS.transcripts t
			where gene='$gene';
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getTranscriptFromBundle{
        my ($dbh,$bunid,$val,$valB)=@_;
	my $sql2;
  	$sql2 = qq {and t.gene='$val'} if $valB;
  	$sql2 = qq {and t.id='$val'} unless $valB;	
 	$sql2 = "" unless $val;
	my $sql = qq{        	
		SELECT distinct 
		t.id, t.ensembl_id, t.gene, t.transmission,
		bt.bundle_id
		FROM PolyprojectNGS.transcripts t
		LEFT JOIN PolyprojectNGS.bundle_transcripts bt
		ON bt.transcript_id=t.id
		where bt.bundle_id='$bunid'
		$sql2
		;
	};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

exit(0);

