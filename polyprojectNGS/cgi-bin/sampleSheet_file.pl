#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_sampleSheet.pl
#./script_sampleSheet.pl -opt=create -fcId="sdsdsd" -sampleId=pat1,pat2 -index=sdqsq,dsdsddsds
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

#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;
use POSIX qw(strftime);

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;
#use warnings;

use File::Basename;
use File::Find::Rule;
use Logfile::Rotate; 

my $opt;
my $fcId;
my $sampleId;
my $index;
my $description;
my $project;
my $lane;
my $index2;

my $cgi    = new CGI;
my $buffer = GBuffer->new;
$opt = $cgi->param('opt');
$fcId = $cgi->param('fcId');
$sampleId= $cgi->param('sampleId');
$index = $cgi->param('index');
my $BCindex = $cgi->param('BCindex');
my $des = $cgi->param('des');
$project = $cgi->param('project');
$lane = $cgi->param("lane");
$index2 = $cgi->param('index2');
my $BCindex2 = $cgi->param('BCindex2');

GetOptions(
		'opt=s' => \$opt,
        'fcId=s' => \$fcId,
        'sampleId=s'  => \$sampleId,
        'index=s' => \$index,
        'des=s' => \$description,
        'project=s' => \$project,
        'lane=s' => \$lane,
		'BCindex=s' => \$BCindex,
        'index2=s' => \$index2,
		'BCindex2=s' => \$BCindex2,
        
);

unless ($opt eq "create") {
	confess ("usage :
		$0 -opt=extract -project=project_name [-dirped]
		-dirped : extract a pedfile into a project directory\n
		$0 -opt=insert -pedfile=NGS*.ped \n");
}

if ($opt eq "create") {
	createSection();
}

sub createSection {
	### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
	##############################
	
#	my $publicdir = $buffer->config()->{public_data}->{root};
#	my @dir_sp = split(/public-data/,$publicdir);
#	my $sampledir=$dir_sp[0]."sequencing/SampleSheet/";
#	my $sampledir="/data-xfs/sequencing/SampleSheet/";
my $publicdir;
my @dir_sp;
my $sampledir;
if (exists $buffer->config()->{public_data}->{root}) {
	warn "Docker";
	$publicdir = $buffer->config()->{public_data}->{root};
	@dir_sp = split(/public-data/,$publicdir);
	$sampledir=$dir_sp[0]."sequencing/SampleSheet/";
}
else {
	warn "Not Docker";
	$publicdir = $buffer->hash_config_path()->{root}->{project_data};
	@dir_sp = split(/public-data/,$publicdir);
	$sampledir=$dir_sp[0]."/SampleSheet/";
}

warn Dumper $sampledir;
warn "fcid";
warn Dumper $fcId;

	my $file_out;
	if (-d $sampledir.$fcId) {
		$file_out=$sampledir.$fcId."/"."SampleSheet_".$fcId.".csv";		
	} else {
		$file_out=$sampledir."SampleSheet_".$fcId.".csv";		
	}
	my @data;
	my @fieldS = split(/,/,$sampleId);
	my @fieldI = split(/,/,$index);
	my @fieldD = split(/,/,$des);
	my @fieldP = split(/,/,$project);
	my @fieldL = split(/,/,$lane);
	my @fieldBCI = split(/,/,$BCindex) if $BCindex;
	my @fieldI2 = split(/,/,$index2);
	my @fieldBCI2 = split(/,/,$BCindex2) if $BCindex2;
	my $i;
	foreach my $a (@fieldS) {
		my $j;
		foreach my $b (@fieldI) {
			if ($i==$j) {
				my @fieldLs = split(/_/,$fieldL[$j]);
				foreach my $c (@fieldLs) {
					my %s;
					$s{fcid}=$fcId;
					$s{patient} = $a;
					$s{bc} = $b;
					$s{bc2} = $fieldI2[$j];
					$s{bcindex} =$fieldBCI[$j] if $BCindex;
					$s{bcindex2} =$fieldBCI2[$j] if $BCindex2;
					$s{description} =$fieldD[$j];
					$s{project} =$fieldP[$j];						
					$s{lane}=$c;
					push(@data,\%s);
				}
			}
			$j++;
		}
		$i++;
	}
	my @result_sorted=sort {$a->{lane} cmp $b->{lane}||$a->{project} cmp $b->{project}} @data;
	my $dlo=",";
	my $rel="Hg19";
	#Control,Recipe,Operator => Normal
	my $CRO="N,,";
	#Sample_Name,Sample_Plate,Sample_Well => Rapid
	#Sample_Name,Sample_Plate,Sample_Well => Rapid
	my $SMP=",,";
	my $header="FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject";
	my $headerRF="Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description";
	my $headerDF="Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,I5_Index_ID,index2,Sample_Project,Description";
	my $footer="#_IEMVERSION_3_TruSeq LT";
	
	my $file_out2;
	$file_out2="SampleSheet_".$fcId.".csv";	
	if (-d $sampledir.$fcId) {
		logrotate_File("$file_out2",$sampledir.$fcId."/");
	} else {
		logrotate_File("$file_out2",$sampledir);		
	}	
		
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	print $FHO $header."\r\n" unless $BCindex;
	print $FHO $headerRF."\r\n" if ($BCindex && !$BCindex2);
	print $FHO $headerDF."\r\n" if ($BCindex2);
	my $f;	
	foreach my $s (@result_sorted) {
		$f->{$s->{bc}."-".$s->{bc2}} = 1 if ($BCindex2);			
	}
	
	foreach my $l (@result_sorted) {
		print $FHO $l->{fcid}.$dlo.$l->{lane}.$dlo.$l->{patient}.$dlo.$rel.$dlo.$l->{bc}.$dlo.$l->{description}.$dlo.$CRO.$dlo.$l->{project}."\r\n" unless $BCindex;
		print $FHO $l->{lane}.$dlo.$l->{patient}.$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" if ($BCindex && !$BCindex2);
		print $FHO $l->{lane}.$dlo.$l->{patient}.$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{bcindex2}.$dlo.$l->{bc2}.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" if ($BCindex2);

		if ($BCindex2) {
			my $rev = BioTools::complement_sequence($l->{bc2});
			print $FHO $l->{lane}.$dlo.$l->{patient}."_RC".$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{bcindex2}.$dlo.$rev.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" unless ($f->{$l->{bc}."-".$rev});
		}
	}		
	print $FHO $footer."\r\n" unless $BCindex;
	close($FHO);
	
	if (-d $sampledir.$fcId) {
		system("chmod -R 777 $sampledir$fcId");
	}	
	
	
	my %hwdata;
	$hwdata{identifier}="patient";
	$hwdata{items}=\@result_sorted;
	my $datestring =strftime "%e/%m/%Y", localtime;
   	my $headerRF0="[Data]"."\r\n";
	my $headerDF0="[Header]"."\r\n"."IEMFileVersion,5"."\r\n"."Date,".$datestring.
	"\r\n"."Workflow,GenerateFASTQ"."\r\n"."Application,HiSeq FASTQ Only".
	"\r\n"."Instrument Type,HiSeq 1500/2500".
	"\r\n"."Assay,Nextera XT Index Kit(24 Indexes, 96 Samples)"."\r\n"."Description,".
	"\r\n"."Chemistry,Amplicon".
	"\r\n".""."\r\n"."[Reads]"."\r\n"."125"."\r\n"."125".
	"\r\n"."[Settings]"."\r\n"."ReverseComplement,0"."\r\n"."".
	"\r\n"."#"."\r\n";
	my $allLines="";
	if ($BCindex2) {
		$allLines=$headerDF0.$headerRF0.$headerDF."\r\n";
	} elsif ($BCindex && !$BCindex2) {
		$allLines=$headerRF0.$headerRF."\r\n";		
	} else {
		$allLines=$header."\r\n";
	}
	foreach my $l (@result_sorted) {
		$allLines.=$l->{fcid}.$dlo.$l->{lane}.$dlo.$l->{patient}.$dlo.$rel.$dlo.$l->{bc}.$dlo.$l->{description}.$dlo.$CRO.$dlo.$l->{project}."\r\n" unless $BCindex;
		$allLines.=$l->{lane}.$dlo.$l->{patient}.$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" if ($BCindex && !$BCindex2);
		$allLines.=$l->{lane}.$dlo.$l->{patient}.$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{bcindex2}.$dlo.$l->{bc2}.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" if $BCindex2;
		if ($BCindex2) {
			my $rev = BioTools::complement_sequence($l->{bc2});
			$allLines.=$l->{lane}.$dlo.$l->{patient}."_RC".$dlo.$SMP.$dlo.$l->{bcindex}.$dlo.$l->{bc}.$dlo.$l->{bcindex2}.$dlo.$rev.$dlo.$l->{project}.$dlo.$l->{description}."\r\n" unless ($f->{$l->{bc}."-".$rev});
		}
	}
	$allLines.=$footer."\r\n" unless $BCindex;
	printData($allLines);
	#### End Autocommit dbh ###########
	$dbh->commit();
}

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}

sub printData {
        my ($data)= @_;
                print $cgi->header('text/plain');
        		print "$data\n";
        exit(0)
}

sub logrotate_File {
	my ($sub,$dir_backup) = @_;
	my $file_out = $dir_backup."SampleSheet_".$fcId.".csv";
	if (-e $file_out) {
		my $merge_rotate = new Logfile::Rotate (
				File  => $file_out,
				Count => 9,
				Dir	  => $dir_backup,
				Gzip  => 'no',
				 );		
		$merge_rotate->rotate();
		unlink $file_out;
	}
}

sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
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
	exit(0);
}

exit(0);

