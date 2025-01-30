#!/usr/bin/perl
########################################################################
###### unassignedProjects.pl
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
#use insert;
#use File::stat;
use GBuffer;
use connect;
use queryPolyproject;
use queryValidationDB;
use Data::Dumper;
use Carp;
use JSON;
use Time::Local;
use POSIX 'strftime';
#use DateTime;
use export_data;
use File::Glob qw(:globally :nocase);

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $nbweeks = $cgi->param('nbweeks');
my $projid = $cgi->param('ProjSel');
my $nbweeks_init=1; # 1 week
my $todate=time();
my $todate_s =strftime "%Y-%m-%d %H:%M:%S", localtime($todate);
my $dateBegin=$todate - $nbweeks_init * 7 * 24 * 60 * 60;
my $dateBegin_s =strftime "%Y-%m-%d %H:%M:%S", localtime($dateBegin);

my $dateEnd=$todate - $nbweeks * 7 * 24 * 60 * 60;
my $dateEnd_s =strftime "%Y-%m-%d %H:%M:%S", localtime($dateEnd);
#my $super_unit = queryPolyproject::getCodeUnitFromTeamId($buffer->dbh,6);#BIP-D
#warn Dumper $dateBegin_s;
#warn Dumper $dateEnd_s;
my $projList = queryPolyproject::getProjectNoUnitWithDate($buffer->dbh,$dateEnd_s,$dateBegin_s,$projid);
my @data;
my %hdata;
my $row=1;
$hdata{label}="name";
$hdata{identifier}="id";
$buffer = GBuffer->new(-verbose=>1);
foreach my $c (sort {$b->{id} <=> $a->{id}}@$projList){
#	my %s;
	my @datec = split(/ /,$c->{cDate});
	my ($YY, $MM, $DD) = split("-", $datec[0]);
	my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
	if ($YY=="0000") {
		$mydate =""
	}
	next unless $mydate;
	my $user_selected=0;
	$user_selected=getUserSelection($c->{username});
	next if $user_selected;
	my $group_selected=0;
	$group_selected=getGroupSelection($c->{groupname});
	next if $group_selected;
	
	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$c->{id});
#	warn Dumper $patientList;
#	warn Dumper scalar(@$patientList);
	next unless scalar(@$patientList);
#	die;
	my %s;
	my $newbuffer = GBuffer->new(-verbose=>1);
	my $project = $newbuffer->newProject(-name=>$c->{name});
	my $patients = $project->getPatients();
	foreach my $p (@$patients){
		my $runid=$p->getRunId();
		my $res = queryPolyproject::getCaptureAnalyse($buffer->dbh,$runid,$c->{id});
		next unless ($res->[0]->{analyse} ne "rnaseq");
		my $alltest= $p->getBamFiles();
		next unless (scalar(@$alltest));
#		warn "OOOOOOOOOOOOOOOOOOOOOKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK";
		$runid=$p->getRunId();
		my $file=join('',@$alltest);
		my $ls_res = `ls -la $file`;
		#warn Dumper $ls_res;
		my $uid=(split(" ",$ls_res))[2];
		#warn Dumper $uid;
#		my $sb=lstat($file) or die "No $file:$!";
		my ($dev,$ino,$mode,$nlink,$uid2,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat($file);
##		my $user_uid2=getpwuid($uid2);
#		my $sb=stat($file) or die "No $file:$!";
#		my $user_uid=getpwuid($sb->uid);
		my $user_uid=getpwuid($uid);
#		my $user_gid=getgrgid($sb->gid);
#		my $user_info= queryPolyproject::getUserInfoFromLogin($buffer->dbh,$user_uid);
#		warn Dumper $user_info;	 
		$s{id} = $project->id();
		$s{name} = $project->name();
#		$s{login} =$user_uid;
		$s{login} = $s{userName} = $s{userMail}  = "unknown";
		$uid=getLocalUid($uid) if ( $uid eq $uid+0);
		my $user_info= queryPolyproject::getUserInfoFromLogin($buffer->dbh,$uid);
		$s{userName}  = $user_info->{name};
		$s{userMail}  = $user_info->{Email};		
		if ( $uid ne $uid+0) {
			$s{login} =$uid; 
			$s{userName}  = $user_info->{name};
			$s{userMail}  = $user_info->{Email};
		}
		
		$s{cDate} = $mydate;
		$s{file}= $file;
		$s{dfile}=$ls_res;
		$s{uid} = $uid if ( $uid eq $uid+0);
#		$s{user_uid} =$user_uid2;
		$s{CaptureAnalyse}=$res->[0]->{analyse};
		push(@data,\%s);
#		die;
		last;
	}
}
#my @result_sorted=sort { $b->{cdate} <=> $a->{cdate} } @data;
# date=> 22/11/2019 ==> 20191122<-sort
my @result_sorted=sort { join('', (split '/', $b->{cDate})[2,1,0]) cmp join('', (split '/', $a->{cDate})[2,1,0]) } @data;
$hdata{items}=\@result_sorted;
printJson(\%hdata);


sub getUserSelection {
	my ($user) = @_;
	if (not defined $user) {return 0};
	my @user=split(/,/,$user);
	my $list_U = my $list_I ="";	
	for my $u (@user) {
		my $res_U = queryPolyproject::getUserInfo($buffer->dbh,$u);
		$list_U.=$res_U->[0]->{Code}."," unless $res_U->[0]->{equipe_id} eq "6";
		$list_I.=$res_U->[0]->{Code}."," if $res_U->[0]->{equipe_id} eq "6";
		
	}
	chop $list_U;
	chop $list_I;
	
	if (scalar(split(/,/,$list_U))) {return 1};
}

sub getGroupSelection {
	my ($group) = @_;
	if (not defined $group) {return 0};
	my @group=split(/,/,$group);
	my $list_G = my $list_I ="";	
	for my $g (@group) {
		$list_I.=$g."," if $g eq "STAFF";
		$list_G.=$g."," unless $g eq "STAFF";
	}
	chop $list_G;
	chop $list_I;
	if (scalar(split(/,/,$list_G))) {return 1};
}

sub getLocalUid {
	my ($uid) = @_;
	if ($uid==1000) {$uid="pnitschk"}
	if ($uid==1004) {$uid="masson"}
	if ($uid==1023) {$uid="cfourrag"}
	if ($uid==1026) {$uid="eollivie"}
	if ($uid==1033) {$uid="shanein"}
	if ($uid==1041) {$uid="mperin"}
	return $uid;
}

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0);
}
exit(0);

 