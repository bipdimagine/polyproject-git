package queryPolyproject;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

sub getCaptureId{
        my ($dbh)=@_;
        my $sql = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes
			from capture_systems C;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getMethodId{
        my ($dbh)=@_;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
			from methods M order by M.name;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getMachineId{
        my ($dbh)=@_;
        my $sql = qq{
			select  S.machine_id as machineId,S.name as macName,
			S.type as macType
			from sequencing_machines S;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getReleaseId{
        my ($dbh)=@_;
        my $sql = qq{
			select  R.release_id as releaseId,R.name as relName
			from releases R;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getDatabaseId{
        my ($dbh)=@_;
        my $sql = qq{
			select  D.db_id as dbId,D.name as dbName
			from polydb D Order by dbname asc;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getTypeId{
        my ($dbh)=@_;
        my $sql = qq{
			select  T.type_project_id as typeId,T.name as typeName
			from project_types T;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getPlateformId{
	my ($dbh)=@_;
	my $sql = qq{
		select  f.plateform_id as plateformId,f.name as plateformName
		from plateform f;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getPlateformFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select f.name as name, f.plateform_id as id  
		FROM plateform f
		where  f.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getProjectFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT p.project_id as projectId
		FROM projects p 
		where  p.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getDiseaseFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT d.disease_id as diseaseId
		FROM disease d 
		where  d.description='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getProjectUserLink{
	my ($dbh,$projNAME)=@_;
	my $sql2 = qq {where P.name='$projNAME'};
	$sql2 = "" unless $projNAME;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.name as projName,
		P.description as projDes,
		P.creation_date as cDate,
		C.name as capName,
		T.name as typName,
		PS.project_id,
		S.name as macName,
		PR.project_id,
		R.name as relName,
		DP.project_id,
		D.name as dbName,
		PM.method_id,
		M.type as typeName,
		M.name as methName,
    		if(M.type="align",M.name,"") as MethAln,
    		if(M.type="snp",M.name,"") as MethSnp,
		U.project_id,
		UP.user_id as UserId,
		UP.nom_responsable as userName,
		UP.prenom_u as Firstname,
		PL.name as plateformName,
		EP.description as Disease,
		EP.abbreviations as abbDis
		from
		(
		projects P
		left join capture_systems C
		using (capture_id)
		left join project_types T
		using (type_project_id)
		left join project_methods PM
		using (project_id)
		left join methods M
		using (method_id)
		left join projects_machines PS
		using (project_id)
		left join sequencing_machines S
		using (machine_id)
		left join project_release PR
		using (project_id)
		left join releases R
		using (release_id)
		left join databases_projects DP
		using (project_id)
		left join polydb D
 		using (db_id)
		left join user_projects U
		using (project_id)
		left join bipd_users.`USER` UP
		using (user_id)
 		left join projects_plateform L
		using (project_id)
		left join plateform PL
		using (plateform_id)
 		left join project_disease E
		using (project_id)
		left join disease EP
		using (disease_id)		
    		)
		$sql2;
	};
	my @res;
	my $sth = $dbh->prepare_cached($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getProjectUser{
	my ($dbh)=@_;
 	my $sql = qq{
		select
		U.user_id as UserId,
		U.nom_responsable as Name,
		U.prenom_u as Firstname,
		N.unite_id,
		N.code_unite as Code,
		U.equipe_id,
		E.libelle as Team
		from
		bipd_users.`USER` U ,
		bipd_users.UNITE N,
		bipd_users.EQUIPE E
		where
		U.equipe_id=E.equipe_id and
		E.unite_id=N.unite_id
		order by Name;	
	};
#		order by Code Desc,
#		Name Asc;	
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
 	return \@res;
}

sub getProjectTeamLink{
 	my ($dbh,$projNAME)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.name as projName,
		UB.user_id as UserId,
		UB.nom_responsable as Name,
		UB.prenom_u as Firstname,
		UB.email as Email,
		UB.equipe_id,
		E.libelle as Team,
		E.responsables as Responsable,
		N.code_unite as Code,
		N.organisme as Organisme,
		N.site as Site,
		N.directeur as Director
		from
		projects P,
		user_projects UP,
		bipd_users.`USER` UB,
		bipd_users.EQUIPE E,
		bipd_users.UNITE N
		where
		P.project_id=UP.project_id and
		UP.user_id=UB.user_id and
		UB.equipe_id=E.equipe_id and
		E.unite_id=N.unite_id and
		P.name='$projNAME';
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getProjectDiseaseLink{
	my ($dbh,$projNAME)=@_;
	my $sql2 = qq {where P.name='$projNAME'};
	my $sql = qq{
		select
		P.project_id as projId,
		P.name as projName,
		EP.disease_id as diseaseId,
		EP.description as Disease,
		EP.abbreviations as abbDis
		from
		(
		projects P
 		left join project_disease E
		using (project_id)
		left join disease EP
		using (disease_id)
    	)		
    	$sql2;   	
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getDiseaseId{
	my ($dbh)=@_;
	my $sql = qq{
		select  d.disease_id as diseaseId,d.description as diseaseName, d.abbreviations as diseaseAbb
		from disease d order by d.description;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub ctrlDiseaseId {
	my ($dbh,$id) = @_;
	my $query = qq{
		SELECT d.disease_id as diseaseId
		FROM disease d
		where  d.disease_id='$id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getProjectName{
	my ($dbh,$projID)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.name as projName
		from
		projects P
		where
		P.project_id='$projID';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{projName};
}

########################################################################
sub addUser2poly {
        my ($dbh,$userid,$projectid) = @_;
        my $sql = qq{    
                insert into user_projects (user_id,project_id) values ($userid,$projectid);
        };
        return ($dbh->do($sql));
}
# delete from project_methods where project_id=1111 and method_id=4;
sub addMeth2poly {
        my ($dbh,$methodid,$projectid) = @_;
        my $sql = qq{    
                insert into project_methods (method_id,project_id) values ($methodid,$projectid);
        };
        return ($dbh->do($sql));
}
# delete from projects_plateform where project_id=1111;
sub addPlateform2poly {
        my ($dbh,$plateformid,$projectid) = @_;
        my $sql = qq{    
                insert into projects_plateform (plateform_id,project_id) values ($plateformid,$projectid);
        };
        return ($dbh->do($sql));
} 
# delete from project_disease where project_id=1120
sub addDisease2poly {
        my ($dbh,$diseaseid,$projectid) = @_;
		my $sql = qq{    
			insert into project_disease (disease_id,project_id) values ($diseaseid,$projectid);
		};
		return ($dbh->do($sql));
}
sub delDisease2poly {
        my ($dbh,$diseaseid,$projectid) = @_;
		my $sql = qq{    
			delete from project_disease 
			where project_id=$projectid
			and disease_id=$diseaseid;
		};
		return ($dbh->do($sql));
}


# delete from disease where disease_id=1120
sub newDisease2poly {
        my ($dbh,$disease,$abb) = @_;
        warn $disease;
        warn $abb;
 		my $sql = qq{    
 			insert into disease (description,abbreviations) values ('$disease','$abb');
 		};
 		return ($dbh->do($sql));
}

sub getCacheVariationsFilekct {
	my ($self,$chr_name) = @_;
	my $dir = $self->getCacheDir();
	confess("give a chromosome name for variations cache") unless $chr_name;
#	my $file_name = $dir."/variations.$chr_name.".$self->name().".store.gz";
	my $file_name = $dir."/variations.$chr_name.".$self->name().".kct";
}


1;
