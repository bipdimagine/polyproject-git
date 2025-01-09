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
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use feature qw/switch/; 



my ($help,$h);
my $prog;
my $opt;
my $out;

my $dir=cwd();
#my $dir='/data-xfs/dev/plaza/polyprojectNGS/cgi-bin';

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
			"\tprogram_name:\tmanageData.pl, manageProject.pl"."\n".
			"\t-out"."\t\tshow json output"."\n".
	"\n");
}
unless ($prog eq "all" || $prog eq "manageData.pl" || $prog eq "manageProject.pl")
 {
	confess ("usage :"."\n".
			"$0 -h"."\n".
			"$0 -prog=all"."\n".
			"$0 -prog=program_name.pl"."\n".
			"$0 -prog=program_name.pl"." -opt=schemas"." -out"."\n".
			"\tprogram_name:\tmanageData.pl, manageProject.pl"."\n".
			"\t-out"."\t\tshow json output"."\n".
			"\n"
			);
}
#"bundleTranscripts BunSel=1"
my @prog_option=(["manageData.pl","schemas","schemasName","captureMeth",
"captureMethName","Project","methodAln","methodCall","plateform","machine","methodSeq",
"runtype","docRun","freeRun","methSeqName","machineName","captureName",
"gpatientProjectDest","groupName","capture",
"database","release","bundle","bundleTranscripts","gpatient"],
["manageProject.pl",""]);
#my @prog_option=(["manageData.pl","schemas","schemasName","captureMeth"],
#["manageProject.pl",""],["manageOther.pl","titi"]);
#my @prog_option=(["manageData.pl","schemas","schemasNames","captureMeth"],
#["manageProject.pl",""]);

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
#			if ($opt =~ $ct) {
#			if ($ct =~ $opt) {
#			if ($ct eq $opt) {
			if ($opt eq $ct) {
				push(@newlng,$ct);
			}
		}
	}
	@prog_option=\@newlng;
}

my $cpt=0;
#print scalar @prog_option;
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
#	print $rdir."/".$rprog."\n";
#	print $roption."\n";
	
	my $res;
	given($roption) {
		when ("bundleTranscripts") {
			my $res_1=`$dir/$rprog option=bundle`;
			$res_1=~ s/^Content-Type.*//;
			$res_1=~ s/\s*//;
    		if ($res_1=~ "bundleId") {
     			my $string= from_json($res_1);
    			my $bunsel=$string->{items}[0]{bundleId};
    			$roption = "bundleTranscripts BunSel=$bunsel";
    			$res =`$dir/$rprog option=$roption`;
    		}
		}
		when ("gpatient") {
			my $res_1=`$dir/$rprog option=docRun`;
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
	if ($res eq "") {
		print "===============================================================\n";
		print "======>   NOT OK for: option=$option  <======\n";
		print "===============================================================\n";
		exit;
	} else {
		print "OK for: option=$option\n";
	}
	
}
