#!/usr/bin/perl
########################################################################
###### polyusers_up.pl
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
use GBuffer;
use Data::Dumper;
use File::Glob qw(:globally :nocase);

use queryUser;
use JSON;
my $cgi    = new CGI;
my $buffer = GBuffer->new;
my $option = $cgi->param('option');

#print $cgi->header();
if ( $option eq "unit" ) {
	UnitSection();
} elsif ( $option eq "Newunit" ) {
	newUnitSection();
} elsif ( $option eq "upUnit" ) {
	upUnitSection();
} elsif ( $option eq "unitId" ) {
	getUnitSection();
}  elsif ( $option eq "unitName" ) {
	UnitNameSection();
}  elsif ( $option eq "institute" || $option eq "organisme") {
	InstituteUnitSection();
}  elsif ( $option eq "instituteName") {
	InstituteNameSection();
} elsif ( $option eq "site" ) {
	SiteUnitSection();
}  elsif ( $option eq "siteName" ) {
	SiteNameUnitSection();
} elsif ( $option eq "teamUnitName" ) {
	TeamUnitNameSection();
} elsif ( $option eq "teamName" ) {
	getTeamSection();
} elsif ( $option eq "Newteam" ) {
	newTeamSection();
} elsif ( $option eq "upTeam" ) {
	upTeamSection();
} elsif ( $option eq "teamUnit" ) {
	teamUnitSection();
} elsif ( $option eq "lastUser" ) {
	lastUserSection();
} elsif ( $option eq "Newuser" ) {
	newUserSection();
} elsif ( $option eq "upUser" ) {
	upUserSection();
} elsif ( $option eq "chgLog" ) {
	chgLogSection();
} elsif ( $option eq "initLog" ) {
	initLogSection();
} elsif ( $option eq "hideUser" ) {
	hideUserSection();
} elsif ( $option eq "userGroup" ) {
	userGroupSection();
} elsif ( $option eq "group" ) {
	groupSection();
} elsif ( $option eq "groupName" ) {
	groupNameSection();
} elsif ( $option eq "lastGroup" ) {
	lastGroupSection();
} elsif ( $option eq "addGroup" ) {
	addUserGroupSection();
} elsif ( $option eq "remGroup" ) {
	remUserGroupSection();
} elsif ( $option eq "newGroup" ) {
	newGroupSection();
}

###### Unit ###################################################################
sub UnitSection {
	my $unitListId = queryUser::getUnitId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="unitId";
	$hdata{label}="unitID";
	foreach my $c (@$unitListId){
		my %s;
		$s{unitId} = $c->{unitId};
		$s{unitId} += 0;
		$s{unit} = $c->{unit};
		$s{organisme} = $c->{organisme};
		$s{site} = $c->{site};
		$s{director} = $c->{director};
		
		push(@data,\%s);
	}
	my @data_sorted=sort { $b->{site} cmp $a->{site} || $a->{unit} cmp $b->{unit}} @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);
	exit(0);
}

sub InstituteUnitSection {
	my $institutesList = queryUser::getInstitutes($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="organisme";
	$hdata{label}="organisme";
	foreach my $c (@$institutesList){
		my %s;
		$s{organisme} = $c->{organisme};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub InstituteNameSection {
	my $institutesList = queryUser::getInstitutes($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$institutesList){
		my %s;
		$s{name} = $c->{organisme};
		$s{value} = $c->{organisme};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub UnitNameSection {
	my $unitsList = queryUser::getUnitId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$unitsList){
		my %s;
		$s{unitId} = $c->{unitId};
		$s{unitId} += 0;
		$s{name} = $c->{unit}." | ".$c->{site}." | ".$c->{director};
		$s{value} = $c->{unit};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub SiteUnitSection {
	my $sitesList = queryUser::getSites($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="site";
	$hdata{label}="site";
	foreach my $c (@$sitesList){
		my %s;
		$s{site} = $c->{site};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub SiteNameUnitSection {
	my $sitesList = queryUser::getSites($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="name";
	$hdata{label}="value";
	foreach my $c (@$sitesList){
		my %s;
		$s{name} = $c->{site};
		$s{value} = $c->{site};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub getUnitSection {
	my $unitList = queryUser::getUnitId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="unitId";
	$hdata{label}="unit";
	foreach my $c (@$unitList){
		my %s;
		$s{unitId} = $c->{unitId};
		$s{unitId} += 0;
		$s{title} = $c->{unit}." | ".$c->{site}." | ".$c->{director};
		push(@data,\%s);
	}
	my @data_sorted=sort { $b->{title} cmp $a->{title} } @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);
	exit(0);
}

sub newUnitSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Mcode = $cgi->param('code');
	my $Morganisme = $cgi->param('organisme');
	my $Msite = $cgi->param('site');
	my $Mdirector = $cgi->param('director');
	my $unitid = queryUser::getUnitIdFromCode($buffer->dbh,uc($Mcode));

	if (exists $unitid ->{unitId}) {
		sendError("Lab Code: " . $Mcode ."...". " already in Unit database");
	} else 	{
### End Autocommit dbh ###########
		my $myunitid = queryUser::newUnitData($buffer->dbh,uc($Mcode),uc($Morganisme),uc($Msite),$Mdirector);
		$dbh->commit();
		sendOK("Successful validation for Lab Code : ". uc($Mcode));	
	}
	exit(0);
}

sub upUnitSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Muid = $cgi->param('selUid');
	my $Mcode = $cgi->param('code');
	my $Morganisme = $cgi->param('organisme');
	my $Msite = $cgi->param('site');
	my $Mdirector = $cgi->param('director');
### End Autocommit dbh ###########
	queryUser::upUnitData($buffer->dbh,$Muid,uc($Mcode),uc($Morganisme),uc($Msite),$Mdirector);
	$dbh->commit();
	sendOK("Successful validation for Lab Code : ". uc($Mcode));	
	exit(0);
}

###### Team ###################################################################
sub getTeamSection {
	my $teamList = queryUser::getTeamId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="teamId";
	$hdata{label}="name";
	foreach my $c (@$teamList){
		my %s;
		$s{teamId} = $c->{teamId};
		$s{teamId} += 0;
		$s{name} = $c->{name};
		$s{unitId} = $c->{unitId};
		my $uid = queryUser::getCodeFromUnitId($buffer->dbh,$c->{unitId});
		$s{unit} = $uid->{unit};
		$s{nameId} = $c->{teamId}." | ".$c->{name}." | ".$c->{leaders};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub newTeamSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Mname = $cgi->param('name');
	my $Mleaders = $cgi->param('leaders');
	my $Munitid = $cgi->param('unit');
	my $teamid = queryUser::getTeamIdFromName($buffer->dbh,$Mname);
	if (exists $teamid ->{teamId}) {
		sendError("Team name: " . $Mname ."...". " already in Team database");
	} else 	{
### End Autocommit dbh ###########
		my $myteamid = queryUser::newTeamData($buffer->dbh,$Mname,$Mleaders,$Munitid);
		$dbh->commit();
		sendOK("Successful validation for Team Name : ". $Mname);	
	}
	exit(0);
}

sub upTeamSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Mtid = $cgi->param('selTid');
	my $Mname = $cgi->param('name');
	my $Mleaders = $cgi->param('leaders');
	my $Mcode = $cgi->param('ucode');
	
### End Autocommit dbh ###########
	my $Unit = queryUser::getUnitIdFromCode($buffer->dbh,$Mcode);
	queryUser::upTeamData($buffer->dbh,$Mtid,$Mname,$Mleaders,$Unit->{unitId});
	$dbh->commit();
	sendOK("Successful validation for Team Name : ". $Mname);	
	exit(0);
}

sub TeamUnitSection {
	my $teamListId = queryUser::getTeamId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="teamId";
	$hdata{label}="teamID";
	foreach my $c (@$teamListId){
		my %s;
		$s{teamId} = $c->{teamId};
		$s{teamId} += 0;
		$s{name} = $c->{name};
		$s{Leaders} = $c->{leaders};
		$s{unitId} = $c->{unitId};
		my $unit_info = queryUser::getUnitInfo($buffer->dbh,$s{unitId});
		$s{Unit} = join(" ",map{$_->{unit}}@$unit_info);
		$s{Institute} = join(" ",map{$_->{organisme}}@$unit_info);
		$s{Site} = join(" ",map{$_->{site}}@$unit_info);
		push(@data,\%s);
	}
	my @data_sorted=sort { $b->{Site} cmp $a->{Site} || $a->{Unit} cmp $b->{Unit}} @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);
	exit(0);
}

sub TeamUnitNameSection {
	my $teamUnitList = queryUser::getTeamUnit($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$teamUnitList){
		my %s;
		$s{value} = $c->{name};		
		$s{unit} = $c->{unit};
		$s{name} = ((length($c->{name})>100) ? substr($c->{name},0,100) ."..." : $c->{name})." | ".$c->{unit}." | ".$c->{site}." | ".$c->{organisme}." | ".$c->{leaders};
		push(@data,\%s);	
	}
	my @data_sorted=sort { $b->{unit} cmp $a->{unit} || "\U$a->{value}" cmp "\U$b->{value}"} @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);	
	exit(0);
}

sub teamUnitSection {
	my $listTeamUnit = queryUser::getTeamUnit($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="teamId";
	$hdata{label}="teamID";
	foreach my $c (@$listTeamUnit){
		my %s;
		$s{teamId} = $c->{teamId};
		$s{teamId} += 0;
		$s{name} = $c->{name};
		$s{Leaders} = $c->{leaders};
		$s{unitId} = $c->{unitId};
		$s{Unit} =  $c->{unit};
		$s{Institute} = $c->{organisme};
		$s{Site} =  $c->{site};
		$s{Director} = $c->{director};		
		push(@data,\%s);		
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);	
}

############### User ###############
sub newUserSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Mfirstname = $cgi->param('firstname');
	my $Mlastname = $cgi->param('lastname');
	my $Mgroup = $cgi->param('group');
	my $Memail = $cgi->param('email');
	my $Mlogin = $cgi->param('login');
	my $Mpw = $cgi->param('pw');
	my $Mteamid = $cgi->param('teamid');
	my $Mhgmd = $cgi->param('hgmd');
	my $control_name = queryUser::getUserIdFromName($buffer->dbh,$Mfirstname,uc($Mlastname));
	my $control_login = queryUser::getUserIdFromLogin($buffer->dbh,$Mlogin);
	my $control_pw = queryUser::getUserIdFromPw($buffer->dbh,$Mpw);
	my $control_grp = queryUser::getGroupFromName($buffer->dbh,$Mgroup);

	my $o_datec= POSIX::strftime('%Y-%m-%d %H:%M:%S', localtime);
	my @sp_datec=split(" ",$o_datec);
	my @sp_date=split("-",$sp_datec[0]);
	my $year=$sp_date[0]+1;
	my $month=$sp_date[1];
	my $day=$sp_date[2];
	if ($month eq "02" && $day eq "29") {$day="28"};
	my $expiry_date="$year-$month-$day $sp_datec[1]";	

	my $team_info = queryUser::getTeamInfo($buffer->dbh,$Mteamid);
	my $unitId=$team_info->[0]->{unite_id};
	my $unit_info = queryUser::getUnitInfo($buffer->dbh,$unitId);
	my $lab_code=$unit_info->[0]->{unit};
	my $instute=$unit_info->[0]->{organisme};

	if (exists $control_name ->{userId}) {
		sendError("User name: " . $Mfirstname ." ".uc($Mlastname)."....". " already in User database");
	} elsif (exists $control_login ->{userId}) {
		sendError("Login: " . $Mlogin ."....". " already exists in User database");
	}	 elsif (exists $control_pw ->{userId}) {
		sendError("password: " . $Mpw ."....". " already exists in User database");
	} else 	{
		if ($instute eq "APHP" &&  $lab_code eq "CEDI" ) {
			my $rand=getRandomChar();
			$Mpw=$Mpw.$rand;
		} else {
			#$expiry_date=undef;
			$expiry_date="0000-00-00 00:00:00";
		}
		warn Dumper $expiry_date;
		my $last_userid = queryUser::newUserData($buffer->dbh,$Mfirstname,uc($Mlastname),$Memail,$Mlogin,$Mpw,$Mteamid,$Mhgmd,$expiry_date);
		my $newuserid= $last_userid->{'LAST_INSERT_ID()'} if defined $last_userid;
		my $message="";
		if ($control_grp ne "0000-00-00 00:00:00") {
			warn "titi";
			$message=" with the User Group: $Mgroup";
			queryUser::addGroup2User($buffer->dbh, $control_grp->{UGROUP_ID}, $newuserid) if defined $last_userid;
		}
### End Autocommit dbh ###########
		$dbh->commit();
#		if ($expiry_date) {
		if ($expiry_date ne "0000-00-00 00:00:00") {
			warn "titi";
			sendOK("User created: ".$newuserid." ". $Mfirstname ." ".uc($Mlastname)."<br><b>Email: </b>".$Memail."<br><b>Login: </b>".$Mlogin."<br><b>PW: </b>".$Mpw."<br><b>Expiry Date: </b>".$expiry_date."<br>".$message);
		} else {
			sendOK("User created: ".$newuserid." ". $Mfirstname ." ".uc($Mlastname)."<br><b>Email: </b>".$Memail."<br><b>Login: </b>".$Mlogin."<br><b>PW: </b>".$Mpw."<br>".$message);
			warn "toti";
		}
	}
	exit(0);
}

sub upUserSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Muserid = $cgi->param('selUid');
	my $Mfirstname = $cgi->param('firstname');
	my $Mlastname = $cgi->param('lastname');
	my $Memail = $cgi->param('email');
	my $Mteam = $cgi->param('team');
	my $Mhgmd = $cgi->param('hgmd');
	my $Mgroup = $cgi->param('group');
	my $team = queryUser::getTeamIdFromName($buffer->dbh,$Mteam);
	my @fieldG = split(/ /,$Mgroup);
	foreach my $g (@fieldG) {
		if ($g) {
			my $r_group = queryUser::getGroupFromName($buffer->dbh,$g);
			my $ctrl=queryUser::isGroupUser($buffer->dbh, $r_group->{UGROUP_ID}, $Muserid);
			if (!$ctrl && $r_group->{UGROUP_ID}) {
				my $userid = queryUser::addGroup2User($buffer->dbh, $r_group->{UGROUP_ID}, $Muserid);
			}
			if ($g eq "No_Group") {
				queryUser::delUser2group($buffer->dbh, $Muserid);
			}
		}
	}
	queryUser::upUserData($buffer->dbh, $Muserid, $Mfirstname,$Mlastname,$Memail,$team->{teamId},$Mhgmd);
	
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("OK:Updated User: ". $Mfirstname ." ".uc($Mlastname));	
	exit(0);
}

sub lastUserSection {
	my $lastId = queryUser::getLastUserId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="userId";
	$hdata{label}="userId";
	foreach my $c (@$lastId){
		my %s;
		$s{userId} = $c->{user_id};
		$s{userId} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub chgLogSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $userId = $cgi->param('userid');
	my $Mlogin = $cgi->param('login');
	my $Mpw = $cgi->param('pw');
	queryUser::upUserCData($buffer->dbh,$userId,$Mlogin,$Mpw);
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for Login : ". $Mlogin);	
	exit(0);
}

sub initLogSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $userId = $cgi->param('userid');
	my $Mlogin = $cgi->param('login');
	my $Mpw = $cgi->param('pw');
	my $u_pw = queryUser::getPwFromUserId($buffer->dbh,$userId);
	my $rand=getRandomChar();
	$Mpw=$Mpw.$rand;
	if ($Mpw eq $u_pw->{pw}) {
		sendError("Error: PassWord not changed. Please retry....");	
	}
	my $u_info = queryUser::getUserInfo($buffer->dbh,$userId);
	my $u_lname=$u_info->[0]->{name};
	my $u_fname=$u_info->[0]->{Firstname};
	my $u_email=$u_info->[0]->{Email};
	
	my $o_datec= POSIX::strftime('%Y-%m-%d %H:%M:%S', localtime);
	my @sp_datec=split(" ",$o_datec);
	my @sp_date=split("-",$sp_datec[0]);
	my $year=$sp_date[0]+1;
	my $month=$sp_date[1];
	my $day=$sp_date[2];
	if ($month eq "02" && $day eq "29") {$day="28"};
	my $expiry_date="$year-$month-$day $sp_datec[1]";	
	#print "$userId   $Mlogin  $Mpw   $expiry_date\n";	
	queryUser::upUserExpPWData($buffer->dbh,$userId,$Mlogin,$Mpw,$expiry_date);
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("$userId $u_lname $u_fname<br><b>Email: </b>$u_email<br><b>Login: </b>$Mlogin<br><b>New PW: </b>$Mpw<br><b>Expiry Date: </b>$expiry_date");	
	exit(0);
}

sub getRandomChar {
	my $i=10;
	my $char;
	while (1) {
		#$char=substr('*!$%,:', rand()*9+1, 1);
		$char=substr('!$%,:', rand()*9+1, 1);
		return $char if $char;		
	}
}

sub hideUserSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $Mlogin = $cgi->param('login');
	my $userId = $cgi->param('userid');
#	queryPolyproject::upInactivatePW($buffer->dbh,$s_u->{USER_ID},"X") if $remove;
	queryUser::upInactivatePW($buffer->dbh,$userId,"X");
#	queryUser::upUserCData($buffer->dbh,$userId,$Mlogin,$Mpw);
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Ok: User inactivate for Login: ". $Mlogin);	
	exit(0);
}

###### Group && User-Group ###################################################################
sub userGroupSection {
	my $userids = $cgi->param('UserSel');
	my $usergroupList = queryUser::getUserGroupInfoFromUsers($buffer->dbh,$userids);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	foreach my $c (@$usergroupList){
		my %s;
		$s{Row} = $row++;
		$s{UserId} = $c->{user_id};
		$s{UserId} += 0;
		$s{Name} = $c->{name};
		$s{Firstname} = $c->{Firstname};
		$s{Group} = $c->{group};
		$s{GroupId} = $c->{ugroup_id};
		$s{GroupId} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub lastGroupSection {
	my $lastGroupId = queryUser::getLastGroup($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="ugroup_id";
	$hdata{label}="ugroup_id";
	foreach my $c (@$lastGroupId){
		my %s;
		$s{ugroup_id} = $c->{ugroup_id};
		$s{ugroup_id} += 0;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
	exit(0);
}

sub addUserGroupSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $userids = $cgi->param('UserSel');
	my $listGroup = $cgi->param('Group');
	
	my @field = split(/,/,$listGroup);
	my @fieldU = split(/,/,$userids );	
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="Row";
	
	my ($m_user,$m_user_is);
	my ($m_group,$m_group_is);
	my (%seenG,%seenGis);
	my $allUser="";
	foreach my $u (@fieldU) {
		foreach my $g (@field) {
			my $ctrl=queryUser::isGroupUser($buffer->dbh, $g, $u);
			my $userid;
			my $u_info = queryUser::getUserInfo($buffer->dbh,$u);
			my $g_info = queryUser::getGroupId($buffer->dbh,$g);
			if ($ctrl) {
				$m_user_is.=$u_info->[0]->{name}.",";
				$m_group_is.=$g_info->[0]->{NAME}."," unless $seenGis{$g_info->[0]->{NAME}}++;
				
			} else {
				$userid = queryUser::addGroup2User($buffer->dbh, $g, $u);
				$m_user.=$u_info->[0]->{name}.",";
				$m_group.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
				$allUser.=$userid;				
			}
		}		
	}	
	chop($m_user,$m_user_is);
	chop($m_group,$m_group_is);
	if ($allUser eq "") {
		sendError("Error: Group : " . $m_group_is . " already linked to User: " . $m_user_is);
	} else {
### End Autocommit dbh ###########
		$dbh->commit();
		sendOK("OK: Group ".$m_group." added to Users : ".$m_user) ;	
	}
	exit(0);
}

sub remUserGroupSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $userids = $cgi->param('UserSel');
	my $groupids = $cgi->param('GroupSel');
	
	my @fieldU = split(/,/,$userids );	
	my @fieldG = split(/,/,$groupids);
	my $m_user;
	my $m_group;
	my %seenG;
	for (my $i = 0; $i< scalar(@fieldU); $i++) {
		queryUser::delUser2group($buffer->dbh, $fieldU[$i], $fieldG[$i]);
		my $u_info = queryUser::getUserInfo($buffer->dbh,$fieldU[$i]);
		$m_user.=$u_info->[0]->{name}.",";
		my $g_info = queryUser::getGroupId($buffer->dbh,$fieldG[$i]);
		$m_group.=$g_info->[0]->{NAME}."," unless $seenG{$g_info->[0]->{NAME}}++;
	}
	chop($m_user);
	chop($m_group);
### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("OK: Group ".$m_group." removed from Users : ".$m_user) ;	
}

sub groupSection {
	my $groupList = queryUser::getGroupId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="groupId";
	$hdata{label}="groupId";
	foreach my $c (@$groupList){
		my %s;
		$s{groupId} = $c->{UGROUP_ID};
		$s{groupId} += 0;
		$s{group} = $c->{NAME};
		push(@data,\%s);
	}
	my @data_sorted=sort { $a->{group} cmp $b->{group}} @data;
	$hdata{items}=\@data_sorted;
	printJson(\%hdata);
	exit(0);
}

sub groupNameSection {
	my $groupList = queryUser::getGroupId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{label}="name";
	$hdata{identifier}="value";
	foreach my $c (@$groupList){
		my %s;
		$s{value} = $c->{NAME};		
		$s{name} = $c->{NAME};
		push(@data,\%s);	
	}
	my @data_nogrp;
	my %hash_nogrp=("name"=>"No_Group","value"=>"No_Group");
	push(@data_nogrp,\%hash_nogrp);
	
	my @data_sorted=sort { $a->{name} cmp $b->{name} } @data;
	my @result_sorted=(@data_nogrp,@data_sorted);
	
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);	
	exit(0);
}

sub newGroupSection {
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $group = $cgi->param('group');
	my $r_group = queryUser::getGroupFromName($buffer->dbh,$group);
	if ($r_group->{NAME}) {
		sendError("Error: Group : " . $r_group->{NAME} . " already created.");
	 } else {
### End Autocommit dbh ###########
	my $last_groupid = queryUser::newGroup($buffer->dbh,$group);
	my $groupid= $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
	$dbh->commit();
	sendOK("OK: Group ".$groupid." ".$group." created.") ;	
			
	}
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

exit(0)
