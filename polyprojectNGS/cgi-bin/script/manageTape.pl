#!/usr/bin/perl
########################################################################
###### manageTape.pl
########################################################################
#use CGI;
#use CGI qw/:standard :html3/;
use strict;
use Time::Local;
use FindBin qw($Bin);
use lib "$Bin/";
use vconnect;
use lib "$Bin/..";
use lib "$Bin/../GenBo";
use lib "$Bin/../GenBo/lib/GenBoDB";
use lib "$Bin/../GenBo/lib/obj-nodb";
use GBuffer;
#use connect;
use queryTape;
use Data::Dumper;
use Carp;
use Getopt::Long;
use warnings;
use File::Basename;
use DBI; 
use DBD::mysql;
use Config::Std;


#my $cgi    = new CGI;
my $buffer = GBuffer->new;

 
my ($help,$h);
my $opt="";
my $tapenum;
my $pltrun;
my $patient;
my $lrun;
my $frun;
my $plt;
my $type;
my $mac;
my $cid;
my $match;

#my $config = getConfig($Bin.'/dbconfig.cfg');
my $config = $buffer->config();

#warn Dumper $config;
#die;

my $dbh = vconnect::getdbh($config);

my @args=@ARGV;

GetOptions(
	'help' => \$help,
 	'opt=s' => \$opt,
 	#Tape
	'tapenum=i' => \$tapenum,
	#Contents
	'cid=s' => \$cid,
	'pltrun=s' => \$pltrun,
	'patient=s' => \$patient,
	'run=s' => \$lrun ,
	'plateform=s' => \$plt,
	'type=s' => \$type,	
	'machine=s' => \$mac,
	'match' => \$match,	
);

if ($help||$h) {
	confess ("Usage for Tape and Content:"."\n".
			"\n".
"-------------------------- Tape ---------------------------------------"."\n".			
			"$0 -opt=newTapeId "."\n".
			"\t"."\t"."Provides a new tape Id as tapenum"."\n".
			"\t"."\t"."This tape Id is stored in a empty file name as"."\n".
			"\t"."\t"."<tape_id>.serial placed at /tape folder of the Backup Server"."\n".
			
			"\n".
			"$0 -opt=listTape"."\n".
			"\n".
"-------------------------- Content ------------------------------------"."\n".			
			"$0 -opt=newContent "."\n".
			"\t"."\t"."Create/Replace an new/old content of the tape with tapenum"."\n".
			"\t"."\t"."The Backup Server must be mounted on /tape with "."\n".
			"\t"."\t"."the following path syntax:"."\n".
			"\t"."\t"."/tape/<tape_id>.serial"."\n".
			"\t"."\t"."/tape/<type-machine>/<machine>/<plateform>/<pltrun>/file"."\n".
			"\n".
			"$0 -opt=listContent"."\n".
			"\t"."[-tapenum=tape_number] "."\n".
			"\t"."[-pltrun=plateform_run_name] "."\n".
			"\t"."[-cid=contentid1,contentid2,...] "."\n".
			"\t"."[-run=run_id] "."\n".
			"\t"."[-plateform=plateform_name] "."\n".
			"\t"."[-type=type_machine] "."\n".
			"\t"."[-machine=sequencing_machine_name] "."\n".
			"\t"."[-patient=patient_name1,patient_name2,...]         ==> "."List Files"."\n".
			"\t"."[-patient=patient_name1,patient_name2,...] -match  ==> "."Exact matching List Files"."\n".
			
			"\t"."[-tapenum=tape_number][-pltrun=plateform_run_name] ==> "."List Files"."\n".
			"\t"."[-tapenum=tape_number][-cid=contentid1,contentid2,...] ==> "."List Files"."\n".
				"\n".  
	"\n");
}

unless ($opt eq "newTapeId" || $opt eq "listTape" ||
		$opt eq "newContent" || $opt eq "upContent" || $opt eq "listContent")
 {
	confess ("usage :"."\n".
			"$0 -h"."\n".
			"$0 -opt=newTapeId"."\n".
			"$0 -opt=listTape"."\n".
			"$0 -opt=newContent"."\n".
			"$0 -opt=upContent"."\n".
			"$0 -opt=listContent"."\n".
			"\n"
			);
}

if( $opt eq "newTapeId" ) {
	newTapeIdSection();
} elsif( $opt eq "listTape" ) {
	listTapeSection();
} elsif( $opt eq "newContent" ) {
	newContentSection();
} elsif( $opt eq "upContent" ) {
	upContentSection();
} elsif( $opt eq "listContent" ) {
	listContentSection();
}

sub newTapeIdSection {
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
##############################
	my $lastTapeId = queryTape::getLastTape($dbh);
	my $newTapeId=$lastTapeId+1;
	queryTape::newTapeId($dbh,$newTapeId);
	$dbh->commit();
	my $del_serial=`rm -f /tape/*.serial`;
	my $touch_serial=`touch /tape/$newTapeId.serial`;
	messageOK("New Tape number : ". $newTapeId."\n");	
}

sub listTapeSection {
	print "Tape List\n";
	my $tapeList = queryTape::getTape($dbh);
	my $dl="\t";
	print "id".$dl."tapenum".$dl."date"."\n";
	foreach my $c (@$tapeList){	
		$c->{tapeDes}="" unless defined $c->{tapeDes};
		print $c->{tape_id}.$dl.$c->{tapeNum}.$dl.fdate($c->{cDate})."\n";
	}
	exit(0);
}

sub newContentSection {
	print "New Content\n";	
#	my $tapelist_in=`ssh root\@10.200.27.94 find /tape -type f|egrep 'serial|gz|xsq'`|| die messageError("no device found ....!!!");
#	my $tapelist_in=`find /tape -type f|egrep 'serial|gz|xsq'`|| die messageError("no device found ....!!!");
	my $tapelist_in=`find /tape -type f|egrep 'serial|fastq.gz|xsq'`|| die messageError("no device found ....!!!");
#	warn Dumper $tapelist_in;
#die;
#	my $dircat="/data-xfs/dev/plaza/polyprojectNGS/cgi-bin/script/RESULT/";
#	my $tapelist_in=`cat $dircat/List_run61-78`
#	|| die messageError("no device found ....!!!");	
	my @tapelist=split('\n',$tapelist_in);
	my $file_tapenum;
	my %runl;
	foreach my $r (@tapelist){
		my($file, $dir, $ext) = fileparse($r);
		$file_tapenum=$file if $file =~ "serial";
		my @dirlist=split('/',$dir);
		my $d=scalar @dirlist;
#		$runl{$dirlist[$d-4].";".$dirlist[$d-3].";".$dirlist[$d-2].";".$dirlist[$d-1]}.=$file."\n" if $d>=6;
		$runl{$dirlist[$d-5].";".$dirlist[$d-4].";".$dirlist[$d-3].";".$dirlist[$d-2].",".$dirlist[$d-1]}.=$file."\n" if $d>=6;
		$runl{$dirlist[$d-4].";".$dirlist[$d-3].";".$dirlist[$d-2].";".$dirlist[$d-1]}.=$file."\n" if $d<=5;
	}
	$file_tapenum=0 unless defined $file_tapenum;
	if ($file_tapenum) {
		my @tapeA=split('\.',$file_tapenum);
		$tapenum=$tapeA[0];
		$tapenum += 0 ;
	}
	unless ($tapenum) {
		confess ("usage : $0 -opt=newContent -tapenum=tape_number "."\n".
			"\n".
			"\t"."#### Warning: ==> File:/tape/<tape_id>.serial not Found ########"."\n".
			"\n"
			);
	}
#die;
	my $tape=queryTape::getIdfromTapeNumber($dbh,$tapenum);
	die messageError("Error => Tape Number : " . $tapenum ."...". " not created") unless $tape->{tape_id};
	my $tapecontents=queryTape::getTapeContents($dbh,$tapenum);
	if (@$tapecontents) {
		foreach my $c (@$tapecontents){
			queryTape::delContent($dbh,$c->{content_id});
		}		
	}	
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
##############################
	foreach my $v (sort(keys(%runl))){
		my $line=$v.";".$runl{$v};
		my @list=split(';',$line);
		my $typemac=$list[0];
		my $mac=$list[1];
		my $plt=$list[2];
		my $pltrun=$list[3];
		my $listfiles=$list[4];
		next if ($listfiles =~ "serial");
		$typemac="" if $list[0] eq "tape";
		if ($list[0] eq "tape" && $typemac eq "") {
			if ($mac){
				my $machineid = queryTape::getMachineFromName($dbh,$mac);
				$typemac=$machineid ->{macType} if (exists $machineid ->{machineId});
			}
		}
		if ($pltrun =~ ",") {
			my @fieldR = split(/,/,$pltrun);	
			$pltrun=$fieldR[0];
		}
		my $run=queryTape::getRunIdfromPltRun($dbh,$pltrun);
		my $runList=join(" ",map{$_->{run_id}}@$run);

		my $last_content_id=queryTape::newContent($dbh,$pltrun,$listfiles,$typemac,$mac,$plt,$runList);
		my $contentid = $last_content_id->{'LAST_INSERT_ID()'};
		if ($contentid) {
			print $tapenum."\t".$contentid."\t".$typemac."\t".$mac."\t".$plt."\t".$pltrun."\t".$runList."\n";
			queryTape::newTapeContent($dbh,$tapenum,$contentid);
		}
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	messageOK("OK => Creation Content for Tape Number :".$tapenum );	
}

sub upContentSection {
	print "Update Content (Backup Server not required)\n";	
	my $err;
	my $valid="";
	my $param="";
	foreach my $p (@args) {
		my @sargs=split('=',$p);		
		$valid.="P" if ($sargs[0] eq "-pltrun");
		$valid.="T" if ($sargs[0] eq "-tapenum");
#		warn Dumper $p;
		next if $sargs[0] eq "-opt";		
		next if $sargs[0] eq "-pltrun";
		next if $sargs[0] eq "-tapenum";
		$param.=$sargs[0].";" if ($sargs[0] eq "-run");
		next if $sargs[0] eq "-run";
		$param.=$sargs[0].";" if ($sargs[0] eq "-plateform");
		next if $sargs[0] eq "-plateform";
#		next if $sargs[0] eq "-machine";		
		$param.=$sargs[0].";" if ($sargs[0] eq "-machine");
		next if $sargs[0] eq "-machine";		
		next if $sargs[0] eq "-type";
#		$param.=$sargs[0].";" if ($sargs[0] eq "-type");
		die syntaxUpList($err=0) unless $tapenum;
	}
	chop $param;
	die syntaxUpList($err=0) unless ($valid=~/^(PT|TP)$/);
	die syntaxUpList($err=0) unless ($param);
	syntaxUpList($err=1);
	ArgList();
	my $contentid=queryTape::getContentIdfromPltRun($dbh,$pltrun);
#	my @contentidList=split(/,/,join(",",map{$_->{content_id}}@$contentid));
	my $contentidList=join(",",map{$_->{content_id}}@$contentid);
#	warn Dumper $contentid->{content_id};
	my $tapecontents=queryTape::getTapeContents($dbh,$tapenum,$contentidList);
	my $run=queryTape::getRunIdfromPltRun($dbh,$pltrun);
	my $runList=join(" ",map{$_->{run_id}}@$run);
	my $contentList="";
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
##############################
	if (@$tapecontents) {
		foreach my $c (@$tapecontents){
			next unless($param=~/run/);
			my $run_res=queryTape::upContent_run($dbh,$c->{content_id},$runList);
			if ($param =~ 'plateform') {
				my $plateform=queryTape::getPlateform($dbh,$runList);
				queryTape::upContent_plateform($dbh,$c->{content_id},$plateform->[0]->{name});
			}
			if ($param =~ 'machine') {
				my $machine=queryTape::getSequencingMachines($dbh,$runList);
				queryTape::upContent_machine($dbh,$c->{content_id},$machine->[0]->{name},$machine->[0]->{type});
			}
			$contentList.=$c->{content_id}.",";
		}		
	}
	chop $contentList;	
#### End Autocommit dbh ###########
	$dbh->commit();
	messageOK("OK => updated Run for Content :".$contentList.", Tape Number :".$tapenum );	
}

sub upContentSectionOld {
	print "Update Content (Backup Server not required)\n";	
	my $err;
	my $valid="";
	my $param="";
	foreach my $p (@args) {
		my @sargs=split('=',$p);		
		$valid.="P" if ($sargs[0] eq "-pltrun");
		$valid.="T" if ($sargs[0] eq "-tapenum");
#		warn Dumper $p;
		next if $sargs[0] eq "-opt";		
		next if $sargs[0] eq "-pltrun";
		next if $sargs[0] eq "-tapenum";
		$param.=$sargs[0].";" if ($sargs[0] eq "-run");
		next if $sargs[0] eq "-run";
#		next if $sargs[0] eq "-plateform";
		$param.=$sargs[0].";" if ($sargs[0] eq "-plateform");
#		next if $sargs[0] eq "-machine";		
		$param.=$sargs[0].";" if ($sargs[0] eq "-machine");
		next if $sargs[0] eq "-machine";		
		next if $sargs[0] eq "-type";
#		$param.=$sargs[0].";" if ($sargs[0] eq "-type");
		die syntaxUpList($err=0) unless $tapenum;
	}
	chop $param;
	die syntaxUpList($err=0) unless ($valid=~/^(PT|TP)$/);
	die syntaxUpList($err=0) unless ($param);
	syntaxUpList($err=1);
	ArgList();
			warn "TTTTTTTTTTTTTTTTTTTTTA\n";
	warn Dumper $pltrun;
	my $contentid=queryTape::getContentIdfromPltRun($dbh,$pltrun);
	warn Dumper $contentid;
	warn Dumper $tapenum;
	warn Dumper $contentid->{content_id};
	my $tapecontents=queryTape::getTapeContents($dbh,$tapenum,$contentid->{content_id});
	warn Dumper $tapecontents;
	my $run=queryTape::getRunIdfromPltRun($dbh,$pltrun);
	my $runList=join(" ",map{$_->{run_id}}@$run);
	my $contentList="";
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
##############################
			warn "TTTTTTTTTTTTTTTTTTTTT\n";
			warn Dumper $tapecontents;
	if (@$tapecontents) {
			warn "TTTTTTTTTTTTTTTTTTTTT\n";
		foreach my $c (@$tapecontents){
			warn "TTTTTTTTTTTTTTTTTTTTT\n";
			next unless($param=~/run/);
			warn "TTTTTTTTTTTTTTTTTTTTT\n";
			my $run_res=queryTape::upContent_run($dbh,$c->{content_id},$runList);
			warn Dumper $run_res;
			if ($param =~ 'plateform') {
				my $plateform=queryTape::getPlateform($dbh,$runList);
				queryTape::upContent_plateform($dbh,$c->{content_id},$plateform->[0]->{name});
			}
			if ($param =~ 'machine') {
				my $machine=queryTape::getSequencingMachines($dbh,$runList);
				queryTape::upContent_machine($dbh,$c->{content_id},$machine->[0]->{name},$machine->[0]->{type});
			}
			$contentList.=$c->{content_id}.",";
		}		
	}
	chop $contentList;	
#### End Autocommit dbh ###########
	$dbh->commit();
	messageOK("OK => updated Run for Content :".$contentList.", Tape Number :".$tapenum );	
}

####################################################################################
sub listContentSection {
	my $err;
	foreach my $p (@args) {
		my @sargs=split('=',$p);		
		next if $sargs[0] eq "-opt";
		next if $sargs[0] eq "-pltrun";
		next if $sargs[0] eq "-patient";
		next if $sargs[0] eq "-run";
		next if $sargs[0] eq "-plateform";
		next if $sargs[0] eq "-machine";		
		next if $sargs[0] eq "-type";		
		next if $sargs[0] eq "-cid";		
		next if $sargs[0] eq "-match";		
		die syntaxList($err=0) unless $tapenum;
	}
	syntaxList($err=1);
	ArgList();
	print "Content List\n";
	my $tapeList = queryTape::getTape($dbh,$tapenum);
	my $dl="\t";
	print "tapenum".$dl."contentid".$dl.
	"Type".$dl."Machine".$dl."Plateform".$dl.
	"Run".$dl."pltrun".$dl.
	"date_tape".$dl."date_Content".
	"\n";
	foreach my $t (@$tapeList){
		my $queryfilter="";
		$queryfilter.="pltrun=$pltrun"."," if defined $pltrun;
		$queryfilter.="run=$lrun"."," if defined $lrun;
		$queryfilter.="plateform=$plt"."," if defined $plt;
		$queryfilter.="type=$type"."," if defined $type;		
		$queryfilter.="machine=$mac"."," if defined $mac;
		$cid =~ s/,/;/gm if defined $cid;
		$queryfilter.="cid=$cid"."," if defined $cid;
		chop($queryfilter);
		my $content=queryTape::getContentsFromTapeIdByFilters($dbh,$t->{tape_id},$queryfilter);
		foreach my $c (@$content){
			next unless $c->{content_id};
			next unless (defined $c->{pltRun});
			print $t->{tapeNum}.$dl.$c->{content_id}.$dl.
			$c->{type_machine}.$dl.$c->{machine}.$dl.$c->{plateform}.$dl.
			$c->{run}.$dl.$c->{pltRun}.$dl.
			$dl.fdate($t->{cDate}).$dl.fdate($c->{cDate}).
			"\n" unless defined $patient;
			
			my $cFile=queryTape::getFilesListFromContentId($dbh,$c->{content_id});
			my $mcFile=$cFile->{filesRun};
			$mcFile =~ s/ /\n/gm;
			$mcFile =~ s/^\n//gm;
			my @lcFile = split(/\n/,$mcFile);
			my $nb=0;
			if (defined $patient) {
				my @pat=split(/,/,$patient);
				my $nbv=0;
				foreach my $t (sort(@lcFile)) {
					foreach my $p (@pat){
#						$nbv++ if ($t =~ $p);
						$nbv++ if ($t =~ /^$p+_/ && $match);
						$nbv++ if ($t =~ $p && ! $match);
					}
				}
				print $t->{tapeNum}.$dl.$c->{content_id}.$dl.
				$c->{type_machine}.$dl.$c->{machine}.$dl.$c->{plateform}.$dl.
				$c->{run}.$dl.$c->{pltRun}.$dl.
				$dl.fdate($t->{cDate}).$dl.fdate($c->{cDate}).
				"\n" if $nbv;
				print "List Files Name: (contentid: ".$c->{content_id}." pltrun: ".$c->{pltRun}.")\n" if $nbv;
				print "----------------------------------"."\n" unless $nb==0;
				foreach my $t (sort(@lcFile)) {
					foreach my $p (@pat){
						#print $t."\n" if ($t =~ $p);
						#next unless ($t =~ $p);
						print $t."\n" if ($t =~ /^$p+_/ && $match);
						print $t."\n" if ($t =~ $p && ! $match);
						
						next unless ($t =~ /^$p+_/ && $match);
						next unless ($t =~ $p && ! $match);
						$nb++;
					}
				}
				print "----------------------------------"."\n" unless $nb==0;
			} else {
				next unless (defined $tapenum);
				next unless (defined ($cid || $pltrun));
				print "List Files Name: (contentid: ".$c->{content_id}." pltrun: ".$c->{pltRun}.")\n";
				print "----------------------------------"."\n";
				foreach my $t (sort(@lcFile)) {
					print $t."\n";
						$nb++;
				}
				print "----------------------------------"."\n";
			}				
			print "Total: ".$nb."\n" unless $nb==0;									
		}
	}
}

sub syntaxList {
	my ($err) = @_;	
	print "usage :"."\n";
	print "$0 -opt=listContent"."\t"."[-tapenum=tape_number] "."\n";
	print "\t"."\t"."\t"."\t"."\t"."[-pltrun=plateform_run_name] "."\n";
	print "\t"."\t"."\t"."\t"."\t"."[-patient=patient_name1,patient_name2,...] "."\n";
	print "\t"."\t"."\t"."\t"."\t"."[-cid=contentid1,contentid2,...] "."\n";
	print "\t"."\t"."\t"."\t"."\t"."[-run=run_id] "."\n".
		"\t"."\t"."\t"."\t"."\t"."[-plateform=plateform_name] "."\n".
		"\t"."\t"."\t"."\t"."\t"."[-machine=sequencing_machine_name] "."\n".
		"\t"."\t"."\t"."\t"."\t"."[-type=type_machine] "."\n".
		"\n";
	print "Warning ==> List Files:"."\n".
		"\t"."-tapenum=tape_number -pltrun=plateform_run_name "."\n".
		"\t"."OR"."\n".
		"\t"."-tapenum=tape_number -cid=contentid1,contentid2,... "."\n".
		"\t"."OR"."\n".
		"\t"."-patient=patient_name1,patient_name2,.. "."\n".
		"\n"."\n";
	exit(0) unless $err;
}

sub syntaxUpList {
	my ($err) = @_;	
	print "usage :"."\n";
	print "$0 -opt=upContent"."\t"."-tapenum=tape_number -pltrun=plateform_run_name "."\n";
	print "\t"."\t"."\t"."\t"."\t"."[-run] [plateform] [-machine]"."\n".
		"\n";
	exit(0) unless $err;
}

####################################################################################
sub getConfig {
	my $filename = shift;
	read_config $filename => my %config;
	return \%config;
}

sub ArgList {
	print "$0 ";
	foreach (@args) {
  		print "$_ ";
	}
	print "\n";
}

sub fdate {
	my ($vdate) = @_;
	my @datec = split(/ /,$vdate);
	my ($YY, $MM, $DD) = split("-", $datec[0]);
	my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
	return $mydate;
}

sub messageOK {
	my ($title) = @_;
	print "$title \n\n";
	exit(0);
}

sub messageError {
	my ($title) = @_;
	print "$title \n\n";
	exit(0);
}

exit(0);



