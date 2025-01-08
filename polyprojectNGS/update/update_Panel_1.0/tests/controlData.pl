#!/usr/bin/perl
########################################################################
###### 
########################################################################
use strict;
use Data::Dumper;
use Carp;
use warnings;
use Getopt::Long;
use Cwd;
use JSON;
#use JSON::Parse 'parse_json';
use FindBin qw($Bin);
use lib "$Bin/../../../..";
use lib "$Bin/../../../../GenBo";
use lib "$Bin/../../../../GenBo/lib/GenBoDB";
use lib "$Bin/../../../../GenBo/lib/obj-nodb";
use lib "$Bin/../../../../GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/../../../../packages"; 
use lib "$Bin/../../../../polymorphism-cgi/packages/export";
use export_data;
use feature qw/switch/; 

my ($help,$h);
my $prog;
my $opt;
my $out;

my $cdir=cwd();
my @dir_sp = split(/polyprojectNGS/,$cdir);
my $dir=$dir_sp[0]."polyprojectNGS/cgi-bin";

GetOptions(
	'help' => \$help,
 	'prog=s' => \$prog,
 	'opt=s' => \$opt,
 	'out'=> \$out,
 );

if ($help||$h) {
	confess ("Usage ControlData:"."\n".
			"$0 -h"."\n".
			"$0 -prog=all"."\n".
			"$0 -prog=program_name.pl"."\n".
			"$0 -prog=program_name.pl"." -opt=schemas"." -out"."\n".
			"\tprogram_name:\tmanagePanel.pl, manageProjectPanel.pl"."\n".
			"\t-out"."\t\tshow json output"."\n".
	"\n");
}
unless ($prog eq "all" || $prog eq "manageData.pl" || $prog eq "managePanel.pl"|| $prog eq "manageProjectPanel.pl")
 {
	confess ("usage :"."\n".
			"$0 -h"."\n".
			"$0 -prog=all"."\n".
			"$0 -prog=program_name.pl"."\n".
			"$0 -prog=program_name.pl"." -opt=schemas"." -out"."\n".
			"\tprogram_name:\tmanagePanel.pl, manageProjectPanel.pl"."\n".
			"\t-out"."\t\tshow json output"."\n".
			"\n"
			);
}
#"bundleTranscripts BunSel=1"
my @prog_option=(
["managePanel.pl","capture","panel","captureName","panelCaptureName",
"capturePanel","gpatient","patientProject","allRun","bundlePan_target","bundlePan_exome"],
["manageProjectPanel.pl numAnalyse=1",""],
["manageProjectPanel.pl numAnalyse=2",""],
["manageProjectPanel.pl numAnalyse=3",""]
);

=mod
my @prog_option=(["manageData.pl","schemas",
"captureMethName","Project","methodAln","methodCall","plateform","machine","methodSeq",
"runtype","methSeqName","machineName","gpatientProjectDest","groupName",
"database","release","bundle","bundleTranscripts"],

["managePanel.pl","capture","panel","captureName","panelCaptureName",
"capturePanel","gpatient","patientProject","allRun","bundlePan_target","bundlePan_exome"],

["manageProjectPanel.pl",""]);
=cut

my @new;
unless ($prog eq "all") {
	foreach my $t (@prog_option) {
		if ($t->[0] eq $prog) {
			foreach my $ct (@$t) {
				push(@new,$ct);
			}
		}
	}
	@prog_option=\@new;
}

my @newlng;
if ($opt) {
	foreach my $t (@prog_option) {
		push(@newlng,$t->[0]);
		foreach my $ct (@$t) {
			if ($opt eq $ct) {
				push(@newlng,$ct);
			}
		}
	}
	@prog_option=\@newlng;
}

my $cpt=0;
print "========== BEGIN TEST ============================\n";
foreach my $r (@prog_option) {	
	my $cpt=0;
	my $cprog;
	my $optionList;
	foreach my $c (@$r) {
		if ($cpt==0) {	
			$cprog=$c;
		} else {
			$optionList.=$c.",";
		}
		$cpt++;
	}
	my @coption = split(/,/,$optionList);
	print "****** BEGIN Program $cprog **************\n";
	run_prog($dir,$cprog,'')unless scalar(@coption);
	for (my $i = 0; $i< scalar(@coption); $i++) {
		run_prog($dir,$cprog,$coption[$i]);
	}
	print "****** END Program $cprog ****************\n";
}
print "========== END TEST   ============================\n";

sub run_prog {
	my($rdir,$rprog,$roption)=@_;
	print "----------------------------------------------------------"."\n";
	
	my $res;
	given($roption) {
		when (/(bundlePan)/) {
 			print "-->".$roption."\n"; 			
			my $type="";
			$type=(split("_",$roption))[1];
			$roption=(split("_",$roption))[0];
			my $res_1=`$dir/$rprog option=capture`;
			$res_1=~ s/^Content-Type.*//;
			$res_1=~ s/\s*//;
    		if ($res_1=~ "capAnalyse") {
       			my $string= from_json($res_1);
       			my @items =@{$string->{'items'}};
       			my $capid=0;
       			my $panid=0;
      			foreach my $i (@items) {
       				if ($type eq "target" || $type eq "") {
         				if ($i->{capAnalyse} eq "target") {
        					$capid=$i->{captureId};
							$panid=(split(" ",$i->{panId}))[0];
        					last;
        				} 
       				} else {
         				if ($i->{capAnalyse} eq "exome") {
         					$capid=$i->{captureId};
							$panid=(split(" ",$i->{panId}))[0];
        					last;
         				}
       				}
      			}
				if ($type eq "target" || $type eq "") {
     				$roption = "bundlePan CapSel=$capid PanSel=$panid exclude=0";
				} else {
       			     $roption = "panel CapSel=$capid PanSel=$panid";
				}
    			$res =`$dir/$rprog option=$roption`;
    		}
		}
 		when ("bundleTranscripts") {
			my $res_1=`$dir/$rprog option=bundle`;
			$res_1=~ s/^Content-Type.*//;
			$res_1=~ s/\s*//;
    		if ($res_1=~ "bundleId") {
     			my $string= from_json($res_1);
    			my $bunsel=$string->{items}[0]{bundleId};
 #   			my $bunsel=$string->{items}[6]{bundleId};    			
    			$roption = "bundleTranscripts BunSel=$bunsel";
    			$res =`$dir/$rprog option=$roption`;
    		}
		}
		when ("gpatient") {
			my $res_1=`$dir/$rprog option=allRun`;
			$res_1=~ s/^Content-Type.*//;
			$res_1=~ s/\s*//;
    		if ($res_1=~ "RunId") {
     			my $string= from_json($res_1);
    			my $runsel=$string->{items}[0]{RunId};
    			$roption = "gpatient RunSel=$runsel";
    			$res =`$dir/$rprog option=$roption`;   				
    		}
		}
		when ("gpatientProjectDest") {
    		$roption = "gpatientProjectDest Sex=1";
    		$res =`$dir/$rprog option=$roption`;
		}
		default {
			if ($rprog =~ "manageProjectPanel.pl" ) {
				if ($rprog =~ "numAnalyse=1") {
					print "manageProjectPanel For Exome, Genome"."\n";
				}
				if ($rprog =~ "numAnalyse=2") {
					print "manageProjectPanel For Target"."\n";
				}
				if ($rprog =~ "numAnalyse=3") {
					print "manageProjectPanel For RNAseq"."\n";
				}
			}
			$res =`$dir/$rprog option=$roption`;
		}
	}
    print $res."\n\n" if $out;
	print $rdir."/".$rprog."\n";
    print $roption."\n";
	test_res($res,$roption);
}

sub test_res {
	my($res,$option)=@_;
	$res=~ s/^Content-Type.*//;
	$res=~ s/\s*//;
	my $string= from_json($res);
 	my @items =@{$string->{'items'}};	
	if ($res eq "" || ! scalar @items) {
		print "===============================================================\n";
		print "======>   NOT OK for: option=$option  <======\n";
		print "===============================================================\n";
		exit;
	} else {
		print "OK for: option=$option\n";
	}	
}
