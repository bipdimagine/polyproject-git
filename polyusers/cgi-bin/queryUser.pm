package queryUser;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

############ USERS #####################
sub getUserInfo {
	my ($dbh,$uid) = @_;
	my $query = qq{
		SELECT u.nom_responsable as name,
		u.prenom_u as Firstname,
		u.email as Email,
		if (u.PASSWORD_TXT='X',0,1) as 'active',
		u.ukey,	
		u.hgmd,
		u.creation_date as cDate,
		u.equipe_id
		FROM bipd_users.`USER` u
		where u.user_id='$uid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getLastUserId {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(USER_ID) as user_id FROM bipd_users.`USER`
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUserIdFromName {
	my ($dbh,$fname,$lname) = @_;
	my $query = qq{
		SELECT u.user_id as userId,
		u.prenom_u as Firstname,
		u.nom_responsable as Lastname
		FROM bipd_users.`USER` u
		where u.prenom_u='$fname'
		and u.nom_responsable='$lname';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getUserIdFromLogin {
	my ($dbh,$login) = @_;
	my $query = qq{
		SELECT u.user_id as userId
		FROM bipd_users.`USER` u
		where u.login='$login';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getLoginFromUserId {
	my ($dbh,$userid) = @_;
	my $query = qq{
		SELECT u.login
		FROM bipd_users.`USER` u
		where u.user_id='$userid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getUserIdFromPw {
	my ($dbh,$pw) = @_;
	my $query = qq{
		SELECT u.user_id as userId
		FROM bipd_users.`USER` u
		where u.pw='$pw';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPwFromUserId {
	my ($dbh,$userid) = @_;
	my $query = qq{
		SELECT u.pw
		FROM bipd_users.`USER` u
		where u.user_id='$userid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newUserData {
	my ($dbh,$firstname,$lastname,$email,$login,$pw,$teamid,$hgmd,$exp_date) = @_;
 	my $query = qq{    
 		insert into bipd_users.`USER` (prenom_u,nom_responsable,email,login,password_txt,equipe_id,creation_date,pw,hgmd,pw_date) 
 		values ('$firstname','$lastname','$email','$login',PASSWORD('$pw'),'$teamid',now(),'$pw','$hgmd','$exp_date');
  	};
 	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from bipd_users.`USER`;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upUserData {
	my ($dbh,$userid,$firstname,$lastname,$email,$teamid,$hgmd) = @_;
 	my $sql = qq{    
		update bipd_users.`USER`
		set prenom_u=?, nom_responsable=?, email=?, equipe_id=?, hgmd=?
		where user_id ='$userid'
 	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($firstname,$lastname,$email,$teamid,$hgmd);
	$sth->finish;

	return;
}

sub upUserCData {
	my ($dbh,$userid,$login,$pw) = @_;
	my $sql = qq{    
		update bipd_users.`USER` 
		set login='$login',password_txt=PASSWORD('$pw'),pw='$pw'
		where user_id='$userid';
	};
	return ($dbh->do($sql));
}

sub upUserExpPWData {
	my ($dbh,$userid,$login,$pw,$exp_date) = @_;
	my $sql = qq{    
		update bipd_users.`USER` 
		set login='$login',password_txt=PASSWORD('$pw'),pw='$pw',pw_date='$exp_date'
		where user_id='$userid';
	};
	return ($dbh->do($sql));
}

sub upUserPWData {
	my ($dbh,$userid) = @_;
	my $sql = qq{    
		update bipd_users.`USER` 
		set pw=concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', rand()*26+1, 1),
              substring('abcdefghijklmnoqrstuvwxyz', rand()*26+1, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
              substring('abcdefghijklmnoqrstuvwxyz0123456789', rand()*36+1, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1),
              substring('0123456789', rand()*10+1, 1),
              substring('abcdefghijklmnoqrstuvwxyz0123456789', rand()*36+1, 1),
              substring('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnoqrstuvwxyz0123456789', rand()*36+1, 1)
             )
		where user_id='$userid';
	};
	return ($dbh->do($sql));
}

sub upInactivatePW {
	my ($dbh,$userid,$value) = @_;
	my $sql = qq{
		UPDATE bipd_users.`USER`
		SET PASSWORD_TXT='$value',PW='$value'
		WHERE USER_ID='$userid';
	};
	return ($dbh->do($sql));
}

############ Unit #####################
sub getUnits{
	my ($dbh)=@_;
	my $sql = qq{
		SELECT DISTINCT
		l.code_unite as unit
		FROM bipd_users.UNITE l;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getUnitId{
	my ($dbh)=@_;
	my $sql = qq{
		SELECT 
		l.unite_id as unitId ,
		l.code_unite as unit ,
		l.organisme as organisme ,
		l.site as site,
		l.directeur as director
		FROM bipd_users.UNITE l;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getUnitIdFromName{
	my ($dbh,$name)=@_;
	my $sql = qq{
		SELECT 
		l.unite_id as unitId ,
		l.code_unite as unit ,
		l.organisme as organisme ,
		l.site as site,
		l.directeur as director
		FROM bipd_users.UNITE l;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getInstitutes{
	my ($dbh)=@_;
	my $sql = qq{
		SELECT DISTINCT
		l.organisme as organisme
		FROM bipd_users.UNITE l;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getSites{
	my ($dbh)=@_;
	my $sql = qq{
		SELECT DISTINCT
		l.site as site
		FROM bipd_users.UNITE l;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getUnitInfo {
	my ($dbh,$lid) = @_;
	my $query = qq{
		SELECT l.code_unite as unit ,
		l.organisme as organisme ,
		l.site as site,
		l.directeur as director
		FROM bipd_users.UNITE l
		where l.unite_id='$lid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUnitIdFromCode {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT 
		l.unite_id as unitId ,
		l.code_unite as unit
		FROM bipd_users.UNITE l
		where l.code_unite='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCodeFromUnitId {
	my ($dbh,$uid) = @_;
	my $query = qq{
		SELECT 
#		l.unite_id as unitId ,
		l.code_unite as unit
		FROM bipd_users.UNITE l
		where l.unite_id='$uid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newUnitData {
        my ($dbh,$code,$organisme,$site,$director) = @_;
 		my $sql = qq{    
 			insert into bipd_users.UNITE (code_unite,organisme,site,directeur) 
 			values ('$code','$organisme','$site','$director');
  		};
 		return ($dbh->do($sql));
}

sub upUnitData {
        my ($dbh,$uid,$code,$organisme,$site,$director) = @_;
 		my $sql = qq{    
 			update bipd_users.UNITE
 			set code_unite=?, organisme=?, site=? , directeur=?
 			where unite_id ='$uid'
  		};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($code,$organisme,$site,$director);
	$sth->finish;

	return;
}

sub upRunDesName {
	my ($dbh,$rid,$name,$description,$pltrun) = @_;
	my $sql = qq{
		update PolyprojectNGS.run
		set name=?, description=?, plateform_run_name=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($name,$description,$pltrun);
	$sth->finish;

	return;
} 

############ Team #####################
sub getTeamInfo {
	my ($dbh,$tid) = @_;
	my $query = qq{
		SELECT e.libelle as Team, 
		e.responsables as Responsable,
		e.unite_id
		FROM bipd_users.EQUIPE e
		where e.equipe_id='$tid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getTeamId{
	my ($dbh)=@_;
	my $sql = qq{
		SELECT 
		t.equipe_id as teamId ,
		t.libelle as name ,
		t.responsables as leaders,
		t.unite_id as unitId
		FROM bipd_users.EQUIPE t;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getTeamIdFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT 
		t.equipe_id as teamId ,
		t.libelle as name
		FROM bipd_users.EQUIPE t
		where t.libelle='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newTeamData {
        my ($dbh,$name,$leaders,$unitid) = @_;
        warn $unitid;
 		my $sql = qq{    
 			insert into bipd_users.EQUIPE (libelle,responsables,unite_id) 
 			values ('$name','$leaders','$unitid');
  		};
 		return ($dbh->do($sql));
}

sub upTeamData {
        my ($dbh,$tid,$name,$leaders,$unitid) = @_;
 		my $sql = qq{    
 			update bipd_users.EQUIPE
 			set libelle=?, responsables=?, unite_id=?
 			where equipe_id ='$tid'
  		};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($name,$leaders,$unitid);
	$sth->finish;

	return;
}

############ Team Unit #####################
sub getTeamUnit {
	my ($dbh)=@_;
	my $sql = qq{
		SELECT 
		t.equipe_id as teamId ,
		t.libelle as name ,
		t.responsables as leaders,
		t.unite_id as unitId,
        l.code_unite as unit,
		l.organisme as organisme,
		l.site as site,
		l.directeur as director

		FROM bipd_users.EQUIPE t
        LEFT JOIN bipd_users.UNITE l
        ON t.unite_id=l.unite_id
        order by l.code_unite desc
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

##################### UGroup #############################
sub getGroupId{
	my ($dbh,$groupid)=@_;
	my $sql2 = qq {where ugroup_id='$groupid'};
	$sql2 = "" unless $groupid;
	my $sql = qq{
		SELECT 
		*
		FROM bipd_users.UGROUP
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

sub getGroupFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT 
		*
		FROM bipd_users.UGROUP
		where NAME='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getLastGroup {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(ugroup_id) as ugroup_id from bipd_users.UGROUP;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub newGroup {
	my ($dbh,$name) = @_;
	my $query = qq{    
 		insert into bipd_users.UGROUP (NAME) 
 		values ("$name");
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from bipd_users.UGROUP;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub getGroupInfoFromUser {
	my ($dbh,$uid) = @_;
	my $query = qq{
		SELECT 
		uu.user_id,
		uu.ugroup_id,
		g.name
		FROM bipd_users.UGROUP_USER uu
		LEFT JOIN bipd_users.UGROUP g
		ON uu.ugroup_id=g.ugroup_id
		where uu.user_id='$uid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUserGroupInfoFromUsers {
	my ($dbh,$uid) = @_;
	my @uid=$uid;
	my $query = qq{
		SELECT DISTINCT
		uu.user_id,
		uu.ugroup_id,
		u.nom_responsable as name,
		u.prenom_u as Firstname,
		#g.ugroup_id,
		g.name as 'group'
		FROM bipd_users.UGROUP_USER uu
		LEFT JOIN bipd_users.USER u
		ON uu.user_id=u.user_id
		LEFT JOIN bipd_users.UGROUP g
		ON uu.ugroup_id=g.ugroup_id
		where uu.user_id in (@uid)
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub isGroupUser {
	my ($dbh,$groupid,$userid) = @_;
	my $query = qq{
		SELECT 
		uu.user_id,
		uu.ugroup_id
		FROM bipd_users.UGROUP_USER uu
		where uu.ugroup_id ='$groupid'
		and uu.user_id ='$userid'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub addGroup2User {
	my ($dbh,$groupid,$userid) = @_;
	my $sql = qq{    
		insert into bipd_users.UGROUP_USER (ugroup_id,user_id) values ($groupid,$userid);
	};
	return ($dbh->do($sql));
}

sub delGroup2User {
	my ($dbh,$groupid,$userid) = @_;
	my $sql = qq{    
		delete from bipd_users.UGROUP_USER
 		where ugroup_id ='$groupid'
		and user_id ='$userid'
		;
	};
	return ($dbh->do($sql));
}

sub delUser2group {
	my ($dbh,$userid,$groupid) = @_;
	my $sql2 = qq {and ugroup_id='$groupid'};
	$sql2 = "" unless $groupid;
	my $sql = qq{    
		delete from bipd_users.UGROUP_USER
 		where user_id ='$userid'
		$sql2
		;
	};
	return ($dbh->do($sql));
}


1;
