#!/usr/bin/perl
########################################################################
###### statRun.pl opt=
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

#ce script est utilisé pour inserer des données dans la BD à partir de l'interface.
#use GenBoWriteNgs;
#use GenBoQueryNgs;
#use GenBoRelationWrite;
#use GenBoProjectWriteNgs;
use GenBoPatient;
use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use Getopt::Long;
use List::Util qw[min max];
#use Switch;
use Tabix;
use GBuffer;
use connect;
use Data::Dumper;
use Carp;
use JSON;
use queryRun;

#use Text::CSV;

#my $project;
# my $patient;
my $run;

=mod
GetOptions(
        'run=s' => \$run,
        
);

unless ($run) {
        confess ("usage :\n
          $0 
          -in=coverage_infile\n" );
}
=cut

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $opt = $cgi->param('opt');
	
if ( $opt eq "cov" ) {
	CovSection();
} elsif ( $opt eq "runcov" ) {
	RunCovSection();
} elsif ( $opt eq "runstat" ) {
	RunStatSection();
} elsif ( $opt eq "runlist" ) {
	RunListSection();
} elsif ( $opt eq "splitlist" ) {
	SplitListSection();
} elsif ( $opt eq "machine" ) {
	MachineSection();
} elsif ( $opt eq "plateform" ) {
	PlateformSection();
} elsif ( $opt eq "project" ) {
	ProjectSection();
} elsif ( $opt eq "run" ) {
	RunSection();
}


sub RunCovSection {
	my $runs_input = $cgi->param('run');
	my @listRun = split(/,/,$runs_input);
	my $type="cov";
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="RunId";
	foreach my $r (@listRun){
		my $sumCov5=0;
		my $sumCov15=0;
		my $sumCov30=0;
		my $sumCov99=0;
		my $nbpatrun;
		my @uniqList;
		my $runList = queryRun::getRunInfoFromRun($buffer->dbh,$r);	
		my $projectIdList = queryRun::getProjectIdfromPatient($buffer->dbh,$r);	
		my $res=RunCov($projectIdList,$r,$type,$runList->[0]->{pltRun});
		push(@data,$res);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub RunListSection {
	my $runid = $cgi->param('run');
	my $listrun = $cgi->param('listrun');
	my $macName = $cgi->param('mac');
	my $gmacName = $cgi->param('gmac');
	my $plateformName = $cgi->param('plateform');	
	my $type="list";
    my $machineList = queryRun::getMachineFromName($buffer->dbh,$macName);
    my $macId=$machineList->{machineId};
	$runid=~ s/ /,/g;
	my $runListId;
	$runid=$listrun if defined $listrun;
	$runListId = queryRun::getRunfromPatient($buffer->dbh,$runid) unless defined $macName;
	$runListId = queryRun::getRunfromPatientMac($buffer->dbh,$macId,$runid) if defined $macName;
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="RunId";
	foreach my $r (@$runListId){
		my %s;
		my $runInfo= queryRun::getRunInfo($buffer->dbh,$r->{run_id});
#		warn Dumper $runInfo;
		next if $runInfo->[0]->{plateformName} eq "ROCKFELLER";
		if (defined $macId) {
			next unless $runInfo->[0]->{macId}==$macId;
		}
		if (defined $gmacName) {
			next unless $runInfo->[0]->{gMachine} eq $gmacName;
		}
		if (defined $plateformName) {
			next unless $runInfo->[0]->{plateformName} eq $plateformName;
		}
		my @datec = split(/ /,$runInfo->[0]->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		my $plateform= queryRun::getPlateformFromRun($buffer->dbh,$r->{run_id});
		$s{plateform} =$plateform->[0]->{name};
		my $machine= queryRun::getSequencingMachines($buffer->dbh,$r->{run_id});
		$s{machine} =$machine;
		$s{cDate} = $mydate;
		$s{description} = $runInfo->[0]->{description};	
		$s{gRun} = $runInfo->[0]->{gRun};
		$s{gMachine} = $runInfo->[0]->{gMachine};
		$s{macId} = $runInfo->[0]->{macId};
		$s{RunId} = $r->{run_id};
		$s{pltRun} = $runInfo->[0]->{pltRun};		
		$s{Row} = $row++;
		
		my $nbpatrun;
		my @uniqList;
		my $projectIdList = queryRun::getProjectIdfromPatient($buffer->dbh,$r->{run_id});
		my $res=RunCov($projectIdList,$r->{run_id},$type,$s{pltRun},$s{plateform},$s{machine},$s{cDate},$s{description},$s{gRun},$s{gMachine},$s{macId},$s{Row});
		push(@data,$res);
	}
	my @result_sorted=sort { $b->{RunId} <=> $a->{RunId} } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub SplitListSection {
	my $split = $cgi->param('split');
	my $runid = $cgi->param('run');
	my $macName = $cgi->param('mac');
	my $pltName = $cgi->param('plt');
    my $machineList = queryRun::getMachineFromName($buffer->dbh,$macName);
    my $macId=$machineList->{machineId};
	my $pltId = queryRun::getPlateformFromName($buffer->dbh,$pltName);
    my $runListId;
	if (defined $macName ) {
		if (defined $pltName) {
			$runListId = queryRun::getRunfromPatientMacPlt($buffer->dbh,$macId,$pltId->{id},$runid);
		} else {
			$runListId = queryRun::getRunfromPatientMac($buffer->dbh,$macId,$runid);
		}
	}
#	my $runListId = queryRun::getRunfromPatientMac($buffer->dbh,$macId,$runid) if defined $macName;
	my $gr=1;
	my $cpt=1;
	my $row=1;
	my @data;
	my %hdata;
	my $runlist;
	my $runInfo;
	my $mydate;
	my $begin;
	my $end;
	$hdata{label}="Row";
	foreach my $r (@$runListId){
		my %s;
		$runlist.=$r->{run_id}.',';
		if ($gr==1) {
			$runInfo= queryRun::getRunInfoFromRun($buffer->dbh,$r->{run_id});
			$begin=$r->{run_id};
			$s{runBegin} = $r->{run_id};
			my @datec = split(/ /,$runInfo->[0]->{cDate});
			my ($YY, $MM, $DD) = split("-", $datec[0]);
			$mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		}	
		elsif ($gr>=$split) {
			$s{Row} = $row++;
			$end=$r->{run_id} if($gr==$split);
			chop $runlist;
			$s{runlist} = $runlist;
			$runInfo= queryRun::getRunInfoFromRun($buffer->dbh,$r->{run_id});
			$s{cDate} = $mydate;
			$s{nbrun} = $split;
			$s{runBegin} = $begin if($gr==$split);
			$s{runEnd} = $end if($gr==$split);
			$s{runRange} = $begin." : ".$end;
			$runlist="";
			push(@data,\%s);
			$gr=0;
		}
		$gr++;
		$cpt++;		
	}
	if ($runlist) {
		chop $runlist;
		my @lastlist = split(/,/,$runlist);
		my $cpt=1;
		foreach my $l (@lastlist){
			if ($cpt==1 ) {
				$runInfo= queryRun::getRunInfoFromRun($buffer->dbh,$l);
				$begin=$l;
				my @datec = split(/ /,$runInfo->[0]->{cDate});
				my ($YY, $MM, $DD) = split("-", $datec[0]);
				$mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
			}
			$end=$l;
			$cpt++
		}
		my %s;
		$s{Row} = $row++;
		$s{runlist} = $runlist;
		$s{cDate} = $mydate;
		$s{nbrun} = scalar @lastlist;
		$s{runBegin} = $begin;
		$s{runEnd} = $end;
		$s{runRange} = $begin.":".$end;
		push(@data,\%s);		
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	
}

=mod
=cut
# ./statRun.pl opt=runcov run=557

sub RunCov {
	my ($projectIdList,$run,$type,$pltRun,$plateform,$machine,$cDate,$description,$gRun,$gMachine,$macId,$Row)= @_;
	my $sumCov5=0;
	my $sumCov15=0;
	my $sumCov30=0;
	my $sumCov99=0;
	my $ctrlpat=0;
	my $sflagstat=0;
	my $nbpatrun;
	my @uniqList;
	my %s;
	foreach my $p (@$projectIdList){
			$s{RunId} = $p->{run_id};
			$s{project} = "";
			$s{patient} = "";
			$s{cov5} = "";
			$s{cov15} = "";
			$s{cov30} = "";
			$s{cov99} = "";
			my $projectName = queryRun::getProjectName($buffer->dbh,$p->{project_id});
			my $project =$buffer->newProject(-name=>$projectName);
			next unless ($p->{run_id} !~ /^[1|2]$/);
			my $patients = $project->getPatients();
			foreach my $a (@$patients){
				my %child;
				my $ctrlRun=queryRun::getRunIdfromProjectPatientId($buffer->dbh,$a->{project_id},$a->{patient_id});
				if ($run == $ctrlRun) {
					$child{patient} = $a->{name} if $type eq "cov";
					my $proj=queryRun::getProjectNamefromPatientId($buffer->dbh,$p->{run_id},$a->{id}) if $a->{id};
					$child{project} = $proj->{name} if ($a->{id} && $type eq "cov");
					#warn $a->getCoverageFile();
					next unless -e $a->getCoverageFile();
					#warn $a->getCoverageFile();
					my $filecov = $a->getCoverageFile();
					my @testfile = glob($a->getCoverageFile()."*" );
					my @testfiletbi = glob($a->getCoverageFile()."*.tbi" );
					#next unless @testfile;
					#next unless @testfiletbi;
					my $cov=queryRun::get_coverage_patient($filecov);
					next unless defined $cov;
					$child{cov5}  ="";
					$child{cov15} ="";
					$child{cov30} ="";
					$child{cov99} ="";
					foreach my $c (@$cov){
						$child{RunId} ="";
						$child{cov5} =$c->{cov5} if ($c->{cov5} && $type eq "cov");
						$child{cov15} =$c->{cov15} if ($c->{cov15} && $type eq "cov");
						$child{cov30} =$c->{cov30} if ($c->{cov30} && $type eq "cov");
						$child{cov99} =$c->{cov99} if( $c->{cov99} && $type eq "cov");
						$sumCov5+=$c->{cov5} if $c->{cov5};
						$sumCov15+=$c->{cov15} if $c->{cov15};
						$sumCov30+=$c->{cov30} if $c->{cov30};
						$sumCov99+=$c->{cov99} if $c->{cov99};
						my $ctrl= 0;
						if ($c->{cov15} && $type eq "list"){
							if ($c->{cov15}< 85 && $c->{cov15}> 80) {
								$ctrl= 1;
							} elsif ($c->{cov15} <= 80){
								$ctrl= 2;								
							}						
							$ctrlpat = max($ctrlpat,$ctrl);
						}
					}
					$nbpatrun++;
					my $rootdir = $project->getRootDir();
					my $dirStat=$rootdir."align/"."stats";
					my $file = $dirStat."/".$a->{name}.".stats";
					$child{flagStat}=0;#green
					$child{flagStat}=1 unless -e $file;#red	
					$sflagstat=1 unless -e $file;#red
					$s{ctrl} = $ctrlpat if $type eq "list";
					$s{ctrl} = 2 if (scalar @$cov<=1 && $type eq "list" );
					push(@uniqList,\%child) if $type eq "cov";				
					push(@uniqList,\%s) if $type eq "list";	
				}
			}
	}
	if (! defined $nbpatrun) {$s{ctrl} = 2};
	$s{children}=\@uniqList if $type eq "cov";
	$nbpatrun=0 unless defined $nbpatrun;
	$s{nbpatient} =$nbpatrun;
	$s{cov5} = sprintf("%2.2f",$sumCov5/$nbpatrun) unless $nbpatrun==0;
	$s{cov15} = sprintf("%2.2f",$sumCov15/$nbpatrun) unless $nbpatrun==0;
	$s{cov30} = sprintf("%2.2f",$sumCov30/$nbpatrun) unless $nbpatrun==0;
	$s{cov99} = sprintf("%2.2f",$sumCov99/$nbpatrun) unless $nbpatrun==0;
	$s{flagStat}=$sflagstat;
	$s{pltRun} = $pltRun if $type eq "list";	
	$s{pltRun} = $pltRun if $type eq "cov";	
	$s{plateform} = $plateform if $type eq "list";	
	$s{machine} = $machine if $type eq "list";
	$s{cDate} = $cDate if $type eq "list";
	$s{description} = $description if $type eq "list";	
	$s{gRun} = $gRun if $type eq "list";
	$s{gMachine} = $gMachine if $type eq "list";
	$s{macId} = $macId if $type eq "list";
	$s{Row} = $Row if $type eq "list";
	return \%s;
}

sub messageOK {
	my ($title) = @_;
	print "$title \n\n";
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
	exit(0);
}

sub message {
	my ($title) = @_;
	print $cgi->header('text/plain');
	print "$title \n\n";
#	exit(0);
}

#Statistics
sub RunStatSectionOld {
	my $runs_input = $cgi->param('run');
	my @listRun = split(/,/,$runs_input);
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="patient";
	foreach my $r (@listRun){
		my $projectIdList = queryRun::getProjectIdfromPatient($buffer->dbh,$r);
		foreach my $p (@$projectIdList){
			my $projectName = queryRun::getProjectName($buffer->dbh,$p->{project_id});
			my $project =$buffer->newProject(-name=>$projectName);
			my $patients = $project->getPatients();
			foreach my $a (@$patients){
				my %s;
				my $ctrlRun=queryRun::getRunIdfromProjectPatientId($buffer->dbh,$a->{project_id},$a->{patient_id});
				if ($r == $ctrlRun) {
					my $rootdir = $project->getRootDir();
					my $dirStat=$rootdir."align/"."stats";
					#warn Dumper $dirStat;
					my $file = $dirStat."/".$a->{name}.".stats";
					next unless -e $file;
					$s{RunId}=$r;
					my $runList = queryRun::getRunInfoFromRun($buffer->dbh,$s{RunId});
					$s{pltRun}=$runList->[0]->{pltRun};
					$s{patient}=$a->{name};
					my $proj=queryRun::getProjectNamefromPatientId($buffer->dbh,$r,$a->{id}) if $a->{id};
					$s{project} = $proj->{name};
					my @restat=loadStatFile($file);
					my $count=1;
					foreach my $c (@restat){
						$s{baitset} =  $c->{baitset};
						$s{genomesize} =  $c->{genomesize};
						$s{baitterritory} =  $c->{baitterritory};
#						warn Dumper $c->{baitterritory};
						$s{targetterritory} =  $c->{targetterritory};
						$s{baitdesignefficiency} =  $c->{baitdesignefficiency};
						$s{totalreads} =  $c->{totalreads};
						$s{pfreads} =  $c->{pfreads};
						$s{pfuniquereads} =  $c->{pfuniquereads};
						$s{pctpfreads} = pct($c->{pctpfreads}*100);
						$s{pctpfuqreads} = pct($c->{pctpfuqreads}*100);
						$s{pfuqreadsaligned} =  $c->{pfuqreadsaligned};
						$s{pctpfuqreadsaligned} = pct($c->{pctpfuqreadsaligned}*100);
						$s{pfbasesaligned} =  $c->{pfbasesaligned};
						$s{pfuqbasesaligned} =  $c->{pfuqbasesaligned};
						$s{onbaitbases} =  $c->{onbaitbases};
						$s{nearbaitbases} =  $c->{nearbaitbases};
						$s{offbaitbases} =  $c->{offbaitbases};
						$s{ontargetbases} =  $c->{ontargetbases};
						$s{pctselectedbases} = pct($c->{pctselectedbases}*100);
						$s{pctoffbait} =  pct($c->{pctoffbait}*100);
						$s{onbaitvsselected} =  $c->{onbaitvsselected};
						$s{meanbaitcoverage} =  $c->{meanbaitcoverage};
						$s{meantargetcoverage} =  $c->{meantargetcoverage};
						$s{mediantargetcoverage} =  $c->{mediantargetcoverage};#
						$s{pctusablebasesonbait} = pct($c->{pctusablebasesonbait}*100);
						$s{pctusablebasesontarget} = pct($c->{pctusablebasesontarget}*100);
						$s{foldenrichment} =  $c->{foldenrichment};
						$s{zerocvgtargetspct} = pct($c->{zerocvgtargetspct}*100);
						$s{pctexcdupe} = pct($c->{pctexcdupe}*100);###
						$s{pctexcmapq} = pct($c->{pctexcmapq}*100);###
						$s{pctexcbaseq} = pct($c->{pctexcbaseq}*100);###
						$s{pctexcoverlap} = pct($c->{pctexcoverlap}*100);###
						$s{pctexcofftarget} = pct($c->{pctexcofftarget}*100);###
						$s{fold80basepenalty} =  $c->{fold80basepenalty};
						$s{pcttargetbases1x} =  pct($c->{pcttargetbases1x}*100);#
						$s{pcttargetbases2x} =  pct($c->{pcttargetbases2x}*100);
						$s{pcttargetbases10x} = pct($c->{pcttargetbases10x}*100);
						$s{pcttargetbases20x} = pct($c->{pcttargetbases20x}*100);
						$s{pcttargetbases30x} = pct($c->{pcttargetbases30x}*100);
						$s{pcttargetbases40x} = pct($c->{pcttargetbases40x}*100);#
						$s{pcttargetbases50x} = pct($c->{pcttargetbases50x}*100);#
						$s{pcttargetbases100x} = pct($c->{pcttargetbases100x}*100);#
						$s{hslibrarysize} =  $c->{hslibrarysize};
						$s{hspenalty10x} =  $c->{hspenalty10x};
						$s{hspenalty20x} =  $c->{hspenalty20x};
						$s{hspenalty30x} =  $c->{hspenalty30x};
						$s{hspenalty40x} =  $c->{hspenalty40x};#
						$s{hspenalty50x} =  $c->{hspenalty50x};#
						$s{hspenalty100x} =  $c->{hspenalty100x};#
						$s{atdropout} =  $c->{atdropout};
						$s{gcdropout} =  $c->{gcdropout};
						$s{hetsnpsensitivity} =  $c->{hetsnpsensitivity};#
						$s{hetsnpq} =  $c->{hetsnpq};#
						$s{sample} =  $c->{sample};
						$s{library} =  $c->{library};
						$s{readgroup} =  $c->{readgroup};
						#$s{pctoffbait}
						$s{ctrlstat} = 1 if ($s{pctoffbait}>40);
						$s{ctrlstat} = 1 unless ($s{pctoffbait}<40);
						#warn Dumper \%s if $count==1;
					#die;
						#next unless $count==1;
						#push(@data,\%s) if $count==1;
						#$count++;
					}
#					warn Dumper $count;
#					push(@data,\%s) if $count<= 2;
					push(@data,\%s);
				}
			}
		}
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

my %header;

sub RunStatSection {
	my $runs_input = $cgi->param('run');
	my @listRun = split(/,/,$runs_input);
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="patient";
	foreach my $r (@listRun){
		my $projectIdList = queryRun::getProjectIdfromPatient($buffer->dbh,$r);
		foreach my $p (@$projectIdList){
			my $projectName = queryRun::getProjectName($buffer->dbh,$p->{project_id});
			my $project =$buffer->newProject(-name=>$projectName);
			my $patients = $project->getPatients();
			foreach my $a (@$patients){
				my %s;
				my $ctrlRun=queryRun::getRunIdfromProjectPatientId($buffer->dbh,$a->{project_id},$a->{patient_id});
				if ($r == $ctrlRun) {
					my $rootdir = $project->getRootDir();
					my $dirStat=$rootdir."align/"."stats";
#					warn Dumper $dirStat;
					my $file = $dirStat."/".$a->{name}.".stats";
					next unless -e $file;
					$s{RunId}=$r;
					my $runList = queryRun::getRunInfoFromRun($buffer->dbh,$s{RunId});
					$s{pltRun}=$runList->[0]->{pltRun};
					$s{patient}=$a->{name};
					my $proj=queryRun::getProjectNamefromPatientId($buffer->dbh,$r,$a->{id}) if $a->{id};
					$s{project} = $proj->{name};
					
					my $res_file = loadStatFile($file);
#					warn ref($res_file);
#					warn Dumper $res_file;
#					$s{pctusablebasesonbait} = pct($c->{pctusablebasesonbait}*100);
					
					foreach my $k (keys %$res_file) {
	#					warn Dumper $k;
						$s{$k} = $res_file->{$k};
#						if ($k =~ /^PCT/) {
						if ($k =~ /PCT/) {
							#warn Dumper $res_file->{$k};
							#warn Dumper pct($res_file->{$k});
							#$s{$k} =pct($res_file->{$k}*100) ;							
							$s{$k} =pct($res_file->{$k}) ;							
						}
					}
#					die;
					#TODO: here
					push(@data,\%s);
				}
			}
		}
	}
#	warn Dumper @data;
	$hdata{items}=\@data;
	printJson(\%hdata);
}


sub pctOld {
	my ($val) = @_;
#$s{pctpfuqreadsaligned} = sprintf("%.2f",$c->{pctpfuqreadsaligned}*100);
	return sprintf("%.2f",$val);
}

sub pct {
	my ($val) = @_;
#$s{pctpfuqreadsaligned} = sprintf("%.2f",$c->{pctpfuqreadsaligned}*100);
	return sprintf("%.2f",$val*100);
}


=mod
=cut
# ancien        run95      2959 toto
# nouveau     run107  2998
sub loadStatFile {
	my ($filename) = @_;
	my $FH;
	open( $FH, '<', $filename ) or die("Can't read this file: $filename\n");
 	my $restat = getStatFile($FH,$filename);
 	close($FH);
	return $restat;
}

#my %header;
sub getStatFile {
	my ($FH,$filename) = @_;
	%header=getHeader($FH);
#	warn Dumper %header;
	my $cpt=1;
		#refaire Marche pas car filename????????
	my $FH2;
	open( $FH2, '<', $filename ) or die("Can't read this file: $filename\n");
		
	my $rline=0;
	while ( my $Line = <$FH2> ) {
		next if $Line =~ "#";
		$rline=1  if $Line =~ /^BAIT_SET/;
#		next if $Line =~ /^BAIT_SET/;
#		warn Dumper $Line;
#		my @data = split( /\s+/, $Line );
		my @tab;
#		warn Dumper $Line if $rline==2  ;
		if ($rline==2) {
			my @mydata;
				my @tab = split( /\t|\s+/, $Line );
			my %s;
			for (my $i = 0; $i< scalar(@tab); $i++) {
					my $toc=getFieldname($i,%header);
					$s{$toc}=chgnum($tab[$i]);
			}
#			push(@mydata,\%s);
#			return @mydata;
#warn Dumper %s ;
			return \%s ;
		}
#		if ($cpt==1) { warn "totottotototo"; warn Dumper $tab[1]};
		$rline++;
#		$cpt++;
		
	}	
}

sub getFieldname {
	my ($value,%h) = @_;
#	warn Dumper $value;

	foreach my $k (keys(%h)) {
		if ($h{$k}== $value) {
			#warn $k;
			#warn $h{$k};
			return $k;
		}
	#	if ($header{$k}==1 ){warn $k};
	}
}


sub getHeader {
	my ($FH) = @_;
	my @data;
	while ( my $Line = <$FH> ) {
		next if $Line =~ "#";
		if ($Line =~ /^BAIT_SET/) {
			@data = split( /\s+/, $Line );
		}
	}
		
	my $cpt=0;
	my %f;
	foreach my $p (@data){
		$f{$p}=$cpt;
		$cpt++;
	}
	return %f;
}
=mod
 		$s{baitset} = chgnum($tab[0]);

{"label":"patient","items":[{"library":"","baitset":"Twist_plus","atdropout":"3.451376","RunId":"2959","genomesize":"3095693983","readgroup":"","baitdesignefficiency":"1","pctexcmapq":"5.20","pctpfreads":"100.00","onbaitbases":"4373438202","fold80basepenalty":"1.427546","nearbaitbases":"2901456803","hspenalty100x":"4.605838","project":"NGS2011_0057","pcttargetbases100x":"30.49","pctexcbaseq":"0.34","pfbasesaligned":"9101327370","meanbaitcoverage":"118.988825","pctpfuqreads":"88.05","hspenalty20x":"3.782563","pctexcoverlap":"8.74","pctoffbait":"20.07","pfuqbasesaligned":"8012053896","pctpfuqreadsaligned":"99.80","pctusablebasesonbait":"47.60","pfuniquereads":"80104018","pcttargetbases10x":"97.08","hetsnpq":"17","mediantargetcoverage":"84","targetterritory":"36755033","hspenalty50x":"4.043247","pcttargetbases1x":"98.36","onbaitvsselected":"0.601169","patient":"NOU_Ine","baitterritory":"36755033","pctselectedbases":"79.93","zerocvgtargetspct":"1.39","pcttargetbases40x":"92.87","foldenrichment":"40.472447","offbaitbases":"1826432365","hslibrarysi
	
=cut
sub getStatFileOld {
	my ($FH) = @_;
	my @mydata;
	my $lng;
	while ( my $Line = <$FH> ) {
		my %s;
		next if $Line =~ "#";
		$lng=1 if $Line =~ /PF_BASES_ALIGNED/;
		next if $Line =~ /^BAIT_SET/;
		my @data = split( /\s+/, $Line );
		my @tab = split( /\t|\s+/, $Line );
		next unless length($tab[0]);
		if ($lng) {
			%s=filldata55(@tab);			
		} else {
			%s=filldata45(@tab);			
		}
		push(@mydata,\%s);
		last;
	}
	return @mydata;
}

sub chgnum {
        my ($var) = @_;
		$var =~ s/,/\./g;
		return $var;
}

sub filldata55 {
        my (@tab) = @_;
		my %s;
 		$s{baitset} = chgnum($tab[0]);
		$s{genomesize} = chgnum($tab[1]);
		$s{baitterritory} = chgnum($tab[2]);
		$s{targetterritory} = chgnum($tab[3]);
		$s{baitdesignefficiency} = chgnum($tab[4]);
		$s{totalreads} = chgnum($tab[5]);
		$s{pfreads} = chgnum($tab[6]);
		$s{pfuniquereads} = chgnum($tab[7]);
		$s{pctpfreads} = chgnum($tab[8]);
		$s{pctpfuqreads} = chgnum($tab[9]);		
		$s{pfuqreadsaligned} = chgnum($tab[10]);
		$s{pctpfuqreadsaligned} = chgnum($tab[11]);
		$s{pfbasesaligned} = chgnum($tab[12]);#
		$s{pfuqbasesaligned} = chgnum($tab[13]);
		$s{onbaitbases} = chgnum($tab[14]);
		$s{nearbaitbases} = chgnum($tab[15]);
		$s{offbaitbases} = chgnum($tab[16]);
		$s{ontargetbases} = chgnum($tab[17]);
		$s{pctselectedbases} = chgnum($tab[18]);
		$s{pctoffbait} = chgnum($tab[19]);
		$s{onbaitvsselected} = chgnum($tab[20]);
		$s{meanbaitcoverage} = chgnum($tab[21]);
		$s{meantargetcoverage} = chgnum($tab[22]);
		$s{mediantargetcoverage} = chgnum($tab[23]);#
		$s{pctusablebasesonbait} = chgnum($tab[24]);
		$s{pctusablebasesontarget} = chgnum($tab[25]);
		$s{foldenrichment} = chgnum($tab[26]);
		$s{zerocvgtargetspct} = chgnum($tab[27]);
		$s{pctexcdupe} = chgnum($tab[28]);###
		$s{pctexcmapq} = chgnum($tab[29]);###
		$s{pctexcbaseq} = chgnum($tab[30]);###
		$s{pctexcoverlap} = chgnum($tab[31]);###
		$s{pctexcofftarget} = chgnum($tab[32]);###		
		$s{fold80basepenalty} = chgnum($tab[33]);
		$s{pcttargetbases1x} = chgnum($tab[34]);#
		$s{pcttargetbases2x} = chgnum($tab[35]);
		$s{pcttargetbases10x} = chgnum($tab[36]);
		$s{pcttargetbases20x} = chgnum($tab[37]);
		$s{pcttargetbases30x} = chgnum($tab[38]);
		$s{pcttargetbases40x} = chgnum($tab[39]);
		$s{pcttargetbases50x} = chgnum($tab[40]);
		$s{pcttargetbases100x} = chgnum($tab[41]);
		$s{hslibrarysize} = chgnum($tab[42]);
		$s{hspenalty10x} = chgnum($tab[43]);
		$s{hspenalty20x} = chgnum($tab[44]);
		$s{hspenalty30x} = chgnum($tab[45]);
		$s{hspenalty40x} = chgnum($tab[46]);
		$s{hspenalty50x} = chgnum($tab[47]);
		$s{hspenalty100x} = chgnum($tab[48]);
		$s{atdropout} = chgnum($tab[49]);
		$s{gcdropout} = chgnum($tab[50]);
		$s{hetsnpsensitivity} = chgnum($tab[51]);#
		$s{hetsnpq} = chgnum($tab[52]);#
		$tab[53]= "" unless defined $tab[53];
		$tab[54]= "" unless defined $tab[54];
		$tab[55]= "" unless defined $tab[55];
		$s{sample} = chgnum($tab[53]);
		$s{library} = chgnum($tab[54]);
		$s{readgroup} = chgnum($tab[55]);
		return %s;
}


sub filldata45() {
        my (@tab) = @_;
        my %s;
 		$s{baitset} = chgnum($tab[0]);
		$s{genomesize} = chgnum($tab[1]);
		$s{targetterritory} = chgnum($tab[3]);
		$s{baitterritory} = chgnum($tab[2]);
		$s{baitdesignefficiency} = chgnum($tab[4]);
		$s{totalreads} = chgnum($tab[5]);
		$s{pfreads} = chgnum($tab[6]);
		$s{pfuniquereads} = chgnum($tab[7]);
		$s{pctpfreads} = chgnum($tab[8]);
		$s{pctpfuqreads} = chgnum($tab[9]);		
		$s{pfuqreadsaligned} = chgnum($tab[10]);
		$s{pctpfuqreadsaligned} = chgnum($tab[11]);
		$s{pfbasesaligned} = "";#
		$s{pfuqbasesaligned} = chgnum($tab[12]);
		$s{onbaitbases} = chgnum($tab[13]);
		$s{nearbaitbases} = chgnum($tab[14]);
		$s{offbaitbases} = chgnum($tab[15]);
		$s{ontargetbases} = chgnum($tab[16]);
		$s{pctselectedbases} = chgnum($tab[17]);
		$s{pctoffbait} = chgnum($tab[18]);
		$s{onbaitvsselected} = chgnum($tab[19]);
		$s{meanbaitcoverage} = chgnum($tab[20]);
		$s{meantargetcoverage} = chgnum($tab[21]);
		$s{mediantargetcoverage} = "";#
		$s{pctusablebasesonbait} = chgnum($tab[22]);
		$s{pctusablebasesontarget} = chgnum($tab[23]);
		$s{foldenrichment} = chgnum($tab[24]);
		$s{zerocvgtargetspct} = chgnum($tab[25]);
		$s{fold80basepenalty} = chgnum($tab[26]);
		$s{pcttargetbases1x} = "";#
		$s{pcttargetbases2x} = chgnum($tab[27]);
		$s{pcttargetbases10x} = chgnum($tab[28]);
		$s{pcttargetbases20x} = chgnum($tab[29]);
		$s{pcttargetbases30x} = chgnum($tab[30]);
		$s{pcttargetbases40x} = chgnum($tab[31]);
		$s{pcttargetbases50x} = chgnum($tab[32]);
		$s{pcttargetbases100x} = chgnum($tab[33]);
		$s{hslibrarysize} = chgnum($tab[34]);
		$s{hspenalty10x} = chgnum($tab[35]);
		$s{hspenalty20x} = chgnum($tab[36]);
		$s{hspenalty30x} = chgnum($tab[37]);
		$s{hspenalty40x} = chgnum($tab[38]);
		$s{hspenalty50x} = chgnum($tab[39]);
		$s{hspenalty100x} = chgnum($tab[40]);
		$s{atdropout} = chgnum($tab[41]);
		$s{gcdropout} = chgnum($tab[42]);
		$s{hetsnpsensitivity} = "";#
		$s{hetsnpq} = "";#
		$tab[43]= "" unless defined $tab[43];
		$tab[44]= "" unless defined $tab[44];
		$tab[45]= "" unless defined $tab[45];
		$s{sample} = chgnum($tab[43]);
		$s{library} = chgnum($tab[44]);
		$s{readgroup} = chgnum($tab[45]);
		return %s;
}


=mod
sub filldata40 {
        my (@tab) = @_;
		my %s;
 		$s{baitset} = chgnum($tab[0]);
		$s{genomesize} = chgnum($tab[1]);
		$s{targetterritory} = chgnum($tab[3]);
		$s{baitterritory} = chgnum($tab[2]);
		$s{baitdesignefficiency} = chgnum($tab[4]);
		$s{totalreads} = chgnum($tab[5]);
		$s{pfreads} = chgnum($tab[6]);
		$s{pfuniquereads} = chgnum($tab[7]);
		$s{pctpfreads} = chgnum($tab[8]);
		$s{pctpfuqreads} = chgnum($tab[9]);		
		$s{pfuqreadsaligned} = chgnum($tab[10]);
		$s{pctpfuqreadsaligned} = chgnum($tab[11]);
		$s{pfbasesaligned} = chgnum($tab[12]);
		$s{pfuqbasesaligned} = chgnum($tab[13]);
		$s{onbaitbases} = chgnum($tab[14]);
		$s{nearbaitbases} = chgnum($tab[15]);
		$s{offbaitbases} = chgnum($tab[16]);
		$s{ontargetbases} = chgnum($tab[17]);
		$s{pctselectedbases} = chgnum($tab[18]);
		$s{pctoffbait} = chgnum($tab[19]);
		$s{onbaitvsselected} = chgnum($tab[20]);
		$s{meanbaitcoverage} = chgnum($tab[21]);
		$s{meantargetcoverage} = chgnum($tab[22]);
		$s{pctusablebasesonbait} = chgnum($tab[23]);
		$s{pctusablebasesontarget} = chgnum($tab[24]);
		$s{foldenrichment} = chgnum($tab[25]);
		$s{zerocvgtargetspct} = chgnum($tab[26]);
		$s{fold80basepenalty} = chgnum($tab[27]);
		$s{pcttargetbases2x} = chgnum($tab[28]);
		$s{pcttargetbases10x} = chgnum($tab[29]);
		$s{pcttargetbases20x} = chgnum($tab[30]);
		$s{pcttargetbases30x} = chgnum($tab[31]);
		$s{hslibrarysize} = chgnum($tab[32]);
		$s{hspenalty10x} = chgnum($tab[33]);
		$s{hspenalty20x} = chgnum($tab[34]);
		$s{hspenalty30x} = chgnum($tab[35]);
		$s{atdropout} = chgnum($tab[36]);
		$s{gcdropout} = chgnum($tab[37]);
		$tab[37]= "" unless defined $tab[38];
		$tab[38]= "" unless defined $tab[39];
		$tab[39]= "" unless defined $tab[40];
		$s{sample} = chgnum($tab[38]);
		$s{library} = chgnum($tab[39]);
		$s{readgroup} = chgnum($tab[40]);
		return %s;
}


sub filldata39 {
        my (@tab) = @_;
        my %s;
 		$s{baitset} = chgnum($tab[0]);
		$s{genomesize} = chgnum($tab[1]);
		$s{targetterritory} = chgnum($tab[3]);
		$s{baitterritory} = chgnum($tab[2]);
		$s{baitdesignefficiency} = chgnum($tab[4]);
		$s{totalreads} = chgnum($tab[5]);
		$s{pfreads} = chgnum($tab[6]);
		$s{pfuniquereads} = chgnum($tab[7]);
		$s{pctpfreads} = chgnum($tab[8]);
		$s{pctpfuqreads} = chgnum($tab[9]);		
		$s{pfuqreadsaligned} = chgnum($tab[10]);
		$s{pctpfuqreadsaligned} = chgnum($tab[11]);
		$s{pfbasesaligned} = 0;
		$s{pfuqbasesaligned} = chgnum($tab[12]);
		$s{onbaitbases} = chgnum($tab[13]);
		$s{nearbaitbases} = chgnum($tab[14]);
		$s{offbaitbases} = chgnum($tab[15]);
		$s{ontargetbases} = chgnum($tab[16]);
		$s{pctselectedbases} = chgnum($tab[17]);
		$s{pctoffbait} = chgnum($tab[18]);
		$s{onbaitvsselected} = chgnum($tab[19]);
		$s{meanbaitcoverage} = chgnum($tab[20]);
		$s{meantargetcoverage} = chgnum($tab[21]);
		$s{pctusablebasesonbait} = chgnum($tab[22]);
		$s{pctusablebasesontarget} = chgnum($tab[23]);
		$s{foldenrichment} = chgnum($tab[24]);
		$s{zerocvgtargetspct} = chgnum($tab[25]);
		$s{fold80basepenalty} = chgnum($tab[26]);
		$s{pcttargetbases2x} = chgnum($tab[27]);
		$s{pcttargetbases10x} = chgnum($tab[28]);
		$s{pcttargetbases20x} = chgnum($tab[29]);
		$s{pcttargetbases30x} = chgnum($tab[30]);
		$s{hslibrarysize} = chgnum($tab[31]);
		$s{hspenalty10x} = chgnum($tab[32]);
		$s{hspenalty20x} = chgnum($tab[33]);
		$s{hspenalty30x} = chgnum($tab[34]);
		$s{atdropout} = chgnum($tab[35]);
		$s{gcdropout} = chgnum($tab[36]);
		$tab[37]= "" unless defined $tab[37];
		$tab[38]= "" unless defined $tab[38];
		$tab[39]= "" unless defined $tab[39];
		$s{sample} = chgnum($tab[37]);
		$s{library} = chgnum($tab[38]);
		$s{readgroup} = chgnum($tab[39]);
		return %s;
}
=cut


=mod
=cut

=mod
=cut

=mod
=cut


###### Machine #####################################################################
sub MachineSection {
	my $machineListId = queryRun::getMachineId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="macName";
	$hdata{label}="macName";
	foreach my $c (@$machineListId){
		my %s;
		$s{machineId} = $c->{machineId};
		$s{machineId} += 0;
		$s{macName} = $c->{macName};
		$s{macType} = $c->{macType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
###### Plateform ###################################################################
sub PlateformSection {
	my $plateformListId = queryRun::getPlateformId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="plateformName";
	$hdata{label}="plateformName";
	foreach my $c (@$plateformListId){
		my %s;
		next if $c->{plateformName} eq "ROCKFELLER";
		$s{plateformId} = $c->{plateformId};
		$s{plateformId} += 0;
		$s{plateformName} = $c->{plateformName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
###### Project  ###################################################################

sub ProjectSection	{
	my $projectList= queryRun::getProject($buffer->dbh);
	my @init1;
	my @init2;
	foreach my $c (@$projectList){
		my %s;
		my $runList = queryRun::getRunfromProject($buffer->dbh,$c->{id});
		if($runList->{RunId}) {
			$s{projectName} = $c->{name};
			$s{RunId} = $runList->{RunId};
			push(@init1,\%s);			
		}
	}
	my %seen;
	foreach my $c (@$projectList){
		my %s;
		my $runList = queryRun::getRunfromProject($buffer->dbh,$c->{id});
		if($runList->{RunId}) {
			$s{RunId} = $runList->{RunId};
			push(@init2,\%s) unless $seen{$s{RunId}}++;
		}
	}
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@init2){
		my %s;
		$s{Row} = $row++;
		$s{RunId}=$c->{RunId};
		my $runList = queryRun::getRunInfoFromRun($buffer->dbh,$c->{RunId});
		$s{pltRun}=$runList->[0]->{pltRun};
		my @pList;
		foreach my $d (@init1){
			if	($c->{RunId} eq $d->{RunId})	{
				push(@pList,$d->{projectName});
			}
		}
		$s{projectName}=join ' ', sort{$b cmp $a} keys %{{map{$_=>1}@pList}};
		push(@data,\%s);			
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
###### Run  ###################################################################

sub RunSection	{
	my $runIdList= queryRun::getRunId($buffer->dbh);
#	warn Dumper $runIdList;
	my @data;
	my %hdata;
	$hdata{label}="RunId";
	foreach my $r (@$runIdList){
		my %s;
		my $runInfo= queryRun::getRunInfo($buffer->dbh,$r->{run_id});
#		warn Dumper $runInfo;
#		die;
		next if $runInfo->[0]->{plateformName} eq "ROCKFELLER";
#		warn Dumper $runInfo;
		$s{RunId} = $r->{run_id};
		$s{pltRun} = $runInfo->[0]->{pltRun};
		$s{plateformName} = $runInfo->[0]->{plateformName};
		$s{machine} = $runInfo->[0]->{macName};
		$s{gMachine} = $runInfo->[0]->{gMachine};
		$s{gRun} = $runInfo->[0]->{gRun};
		my @datec = split(/ /,$runInfo->[0]->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;		
		push(@data,\%s);		
	}
	$hdata{items}=\@data;
#	my @result_sorted=sort { $b->{RunId} <=> $a->{RunId} } @data;
	$hdata{items}=\@data;
	printJson(\%hdata);
}

###################################################################################

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}





exit(0);

