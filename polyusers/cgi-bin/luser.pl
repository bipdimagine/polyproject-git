#!/usr/bin/perl
########################################################################
###### luser.pl
#./polyusers.pl 
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/../../GenBo";
use lib "$Bin/../../GenBo/lib/GenBoDB";
use lib "$Bin/../../GenBo/lib/obj-nodb";

use Time::Local;
use connect;
use export_data;
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);
#use queryUser;
use JSON;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

warn "luser.pl";

=mod
my $userid = $cgi->param('UserId');
#warn Dumper $userid;
my $sql2 = qq {where u.user_id='$userid'};
$sql2 = "" unless $userid;

my $sql = qq{select u.user_id as id
	from bipd_users.USER u 
	$sql2 
	order by u.user_id
};

my $sth = $buffer->dbh->prepare($sql) || die();
$sth->execute();
my $res = $sth->fetchall_hashref("id");
my @result;
foreach my $id (sort keys %$res){
	my $item;
	$item->{id} = $id; 
	my $user_info = queryUser::getUserInfo($buffer->dbh,$id);
	$item->{name} = join(" ",map{$_->{name}}@$user_info);
	$item->{firstname} = join(" ",map{$_->{Firstname}}@$user_info);	
	$item->{email} = join(" ",map{$_->{Email}}@$user_info);
	my @datec =  split(/ /,join(" ",map{$_->{cDate}}@$user_info));
	my ($YY, $MM, $DD) = split("-", $datec[0]);
	my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
	$item->{cDate} = $mydate;
	my $tid=join(" ",map{$_->{equipe_id}}@$user_info);
	$item->{hgmd} = join(" ",map{$_->{hgmd}}@$user_info);
	my $team_info = queryUser::getTeamInfo($buffer->dbh,$tid);
	$item->{team} = join(" ",map{$_->{Team}}@$team_info);
	$item->{responsable} = join(" ",map{$_->{Responsable}}@$team_info);
	my $lid=join(" ",map{$_->{unite_id}}@$team_info);
	my $unit_info = queryUser::getUnitInfo($buffer->dbh,$lid);
#	$item->{Unit} = join(" ",map{$_->{unit}}@$unit_info);
	$item->{unit} = join(" ",map{$_->{unit}}@$unit_info);
#	$item->{Institute} = join(" ",map{$_->{organisme}}@$unit_info);
	$item->{organisme} = join(" ",map{$_->{organisme}}@$unit_info);
#	$item->{Site} = join(" ",map{$_->{site}}@$unit_info);
	$item->{site} = join(" ",map{$_->{site}}@$unit_info);
	$item->{director} = join(" ",map{$_->{director}}@$unit_info);	
	my $log= queryUser::getLoginFromUserId($buffer->dbh,$id);
	$item->{login} = $log->{login};
	my $pass= queryUser::getPwFromUserId($buffer->dbh,$id);
	$item->{pw} = $pass->{pw};
	
	push(@result,$item);

}

my @result_sorted=sort { $b->{Unit} cmp $a->{Unit} || $a->{name} cmp $b->{name}} @result;
#my @result_sorted=sort { $b->{Site} cmp $a->{Site} || $a->{Unit} cmp $b->{Unit} || $a->{name} cmp $b->{name}} @result;
#export_data::print(undef,$cgi,\@result);
export_data::print(undef,$cgi,\@result_sorted);
exit(0)
#sub printJson {
#        my ($data)= @_;
#                print $cgi->header('text/json-comment-filtered');
#                print encode_json $data;
#        exit(0)
#}
=cut