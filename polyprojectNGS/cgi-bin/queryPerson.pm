package queryPerson;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

# Patient

sub getPatientPersonInfoProjectDest {
	my ( $dbh, $rid, $pid ) = @_;
	my $query2 = qq {AND a.project_id_dest='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select distinct
        a.name as name, a.patient_id,
        a.g_project,
 --       pe.patient_id,pe.person_id,
        e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.major_project_id,e.creation_date as eDate,
        a.project_id_dest,a.run_id,a.capture_id,
		a.family,a.father,a.mother,a.flowcell,
		a.control,a.type,
		a.bar_code,a.bar_code2,a.identity_vigilance,a.identity_vigilance_vcf,
		a.sex,a.status,a.description,a.creation_date as cDate,
		a.project_id,a.profile_id,a.species_id

		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id

		WHERE a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

# patient_person
sub getPatientPersonProjectInfo {
	my ( $dbh, $pid, $rid ) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT distinct a.project_id,a.run_id,a.name,a.patient_id,
		a.project_id_dest,a.family,a.father,a.mother,a.sex,a.status,
		a.bar_code,a.bar_code2,a.identity_vigilance,a.identity_vigilance_vcf,
		a.flowcell,a.control,a.type,a.profile_id,a.species_id,
		a.creation_date as cDate,
		a.g_project,
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.major_project_id,e.creation_date as eDate,		
		r.description as desRun, r.document,r.name as nameRun,
		r.file_name as FileName,r.file_type as FileType,		
		S.name as macName,
       	GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		ms.name as methSeqName,
		C.name as capName,
		C.analyse as capAnalyse
		FROM PolyprojectNGS.patient a

		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_machine rm
		ON r.run_id = rm.run_id
		LEFT JOIN PolyprojectNGS.sequencing_machines S
		ON rm.machine_id = S.machine_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
		ON r.run_id = rp.run_id
		LEFT JOIN PolyprojectNGS.plateform f
		ON rp.plateform_id = f.plateform_id
		LEFT JOIN PolyprojectNGS.run_method_seq rs
		ON r.run_id = rs.run_id
		LEFT JOIN PolyprojectNGS.method_seq ms
		ON rs.method_seq_id = ms.method_seq_id
		LEFT JOIN PolyprojectNGS.capture_systems C
		ON a.capture_id = C.capture_id

		where a.project_id='$pid'
		$query2		
       	group by a.patient_id
		order by a.run_id;	
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getPatientInfoPersonFromProject {
	my ($dbh,$numAnalyse,$pid) = @_;
#	my ($dbh,$pid) = @_;
	my $query2;
	#all 1
	$query2 = qq {where C.analyse not in ("")} if $numAnalyse == 1;
	#exome 2
	$query2 = qq {where C.analyse in ("exome")} if $numAnalyse == 2;
	#genome 3
	$query2 = qq {where C.analyse in ("genome")} if $numAnalyse == 3;
	#target 4
	$query2 = qq {where C.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $numAnalyse == 4;
	#rnaseq 5
	$query2 = qq {where C.analyse ="rnaseq"} if $numAnalyse == 5;
	#singlecell 6
	$query2 = qq {where C.analyse ="singlecell"} if $numAnalyse == 6;
	#singlecell 7
	$query2 = qq {where C.analyse ="amplicon"} if $numAnalyse == 7;
	#singlecell 8
	$query2 = qq {where C.analyse ="other"} if $numAnalyse == 8;
	
	my $query3 = qq {and  a.project_id='$pid'};
	$query3 = "" unless $pid;
	my $query = qq{
        SELECT
        a.patient_id,
        a.name as name,
        
        e.person_id,e.name as 'person',
        
		a.bar_code as patBC,
        r.run_id,
 		C.name as capName,
 		C.analyse as capAnalyse,
 		C.validation_db as capValidation,
 		R.name as capRel,
 		GROUP_CONCAT(DISTINCT sp.code ORDER BY sp.code ASC SEPARATOR ' ') as 'spCode',		
        GROUP_CONCAT(DISTINCT S.name ORDER BY S.name ASC SEPARATOR ' ') as 'macName',
        GROUP_CONCAT(DISTINCT f.name ORDER BY f.name ASC SEPARATOR ' ') as 'plateformName',
        GROUP_CONCAT(DISTINCT ms.name ORDER BY ms.name ASC SEPARATOR ' ') as 'methSeqName',
        GROUP_CONCAT(DISTINCT case M.type when 'ALIGN' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methAln',
        GROUP_CONCAT(DISTINCT case M.type when 'SNP' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methCall',
 		GROUP_CONCAT(DISTINCT case when (M.type!='SNP' and M.type!='ALIGN') THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methPipe'		
        FROM PolyprojectNGS.patient a
        
        LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
        
        
        
        LEFT JOIN PolyprojectNGS.run r
        ON a.run_id = r.run_id
        LEFT JOIN PolyprojectNGS.run_machine rm
        ON r.run_id = rm.run_id
        LEFT JOIN PolyprojectNGS.sequencing_machines S
        ON rm.machine_id=S.machine_id
        LEFT JOIN PolyprojectNGS.run_plateform rp
        ON r.run_id=rp.run_id
        LEFT JOIN PolyprojectNGS.plateform f
        ON rp.plateform_id=f.plateform_id
        LEFT JOIN PolyprojectNGS.run_method_seq rs
        ON r.run_id=rs.run_id
        LEFT JOIN PolyprojectNGS.method_seq ms
        ON rs.method_seq_id=ms.method_seq_id
        LEFT JOIN PolyprojectNGS.patient_methods pm
        ON a.patient_id = pm.patient_id
        LEFT JOIN PolyprojectNGS.methods M
        ON pm.method_id=M.method_id
        LEFT JOIN PolyprojectNGS.species sp
        ON a.species_id = sp.species_id
     
        LEFT JOIN PolyprojectNGS.capture_systems C
        ON a.capture_id=C.capture_id        
        LEFT JOIN PolyprojectNGS.releases R
        ON C.release_id=R.release_id
		$query2
		$query3
        GROUP BY patient_id
        ORDER BY name
        ;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}




sub getPatientPersonInfo_byPatientId_Run {
	my ($dbh,$patid,$runid) = @_;
	my $query2 = qq {and a.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query = qq{		
		select distinct 
        a.patient_id,a.project_id,a.run_id,a.capture_id,a.name,a.sex,a.status,a.family,a.father,a.mother,a.species_id,a.creation_date,
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.creation_date as eDate
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		where a.patient_id='$patid'
		$query2
		order by a.patient_id
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getPatientPersonInfo_byPatientName_Run {
	my ($dbh,$name,$runid) = @_;
	my $query2 = qq {and a.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query = qq{		
		select distinct 
        a.patient_id,a.project_id,a.run_id,a.capture_id,a.name,a.sex,a.status,a.family,a.father,a.mother,a.species_id,a.creation_date,
        C.analyse as 'capAnalyse',
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.major_project_id,e.creation_date as eDate
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		LEFT JOIN PolyprojectNGS.capture_systems C
		ON a.capture_id=C.capture_id
		where a.name='$name'
		$query2
		order by a.patient_id
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;		
}

sub getPatientPersonInfo_byPatientName_byProjectId {
	my ($dbh,$name,$projid) = @_;
	my $query2 = qq {and a.project_id='$projid'};
	$query2 = "" unless $projid;
	my $query = qq{		
		select distinct 
        a.patient_id,a.project_id,a.run_id,a.capture_id,a.name,a.sex,a.status,a.family,a.father,a.mother,a.species_id,a.creation_date,
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.creation_date as eDate
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		where a.name='$name'
		$query2
		order by a.patient_id
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;		
}

sub getPatientPersonInfo_byPersonName_Run {
	my ($dbh,$name,$runid) = @_;
	my $query2 = qq {and a.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query = qq{		
		select distinct 
        a.patient_id,a.project_id,a.run_id,a.capture_id,a.name,a.sex,a.status,a.family,a.father,a.mother,a.identity_vigilance_vcf, a.species_id,a.creation_date,
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.creation_date as eDate
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		where e.name='$name'
		$query2
		order by a.patient_id
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;		
}

sub getPatientPersonInfo_Startwith_PersonName {
	my ($dbh,$name,$runid) = @_;
	my $query2 = qq {and a.run_id='$runid'};
	$query2 = "" unless $runid;
	my $l_name=$name."__";
	my $query = qq{		
		select distinct 
        a.patient_id,a.project_id,a.run_id,a.capture_id,a.name,a.sex,a.status,a.family,a.father,a.mother,a.identity_vigilance_vcf, a.creation_date,
		if (a.project_id >0,p.name,"") as 'project',
		C.analyse as 'capAnalyse',
		e.person_id,e.name as 'person',e.family_id,e.sex as 'esex',e.status as 'estatus',e.father_id,e.mother_id,e.creation_date as eDate
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_person pe
		ON a.patient_id = pe.patient_id
		LEFT JOIN PolyprojectNGS.person e
		ON pe.person_id = e.person_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id=p.project_id
		LEFT JOIN PolyprojectNGS.capture_systems C
		ON a.capture_id=C.capture_id
		where e.name like '$name' or e.name like '$l_name%'
		$query2
		order by a.patient_id
	};
#	warn Dumper $query;
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientPerson_byPersonId {
	my ($dbh,$personid) = @_;
	my $query = qq{		
		select *
		FROM PolyprojectNGS.patient_person pe
		where pe.person_id='$personid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;		
}

sub getPatientPerson_byPatientId {
	my ($dbh,$patientid) = @_;
	my $query = qq{		
		select *
		FROM PolyprojectNGS.patient_person pe
		where pe.patient_id='$patientid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;		
}

sub insertPatientPerson {
	my ( $dbh, $patientid, $personid ) = @_;
	my $sql = qq{    
		insert into PolyprojectNGS.`patient_person` (patient_id,person_id) values ($patientid,$personid);
	};
	return ( $dbh->do($sql) );
}

sub delPatientPerson {
	my ( $dbh, $patientid, $personid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.`patient_person`  WHERE patient_id='$patientid' AND person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

#person
sub getPerson_fromId {
	my ( $dbh, $personid ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.person e
		where e.person_id='$personid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPersonName_fromId {
	my ( $dbh, $personid ) = @_;
	my $query = qq{
		select e.name
		FROM PolyprojectNGS.person e
		where e.person_id='$personid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{name};
}

sub getPersonName_fromName {
	my ( $dbh, $name ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.person e
		where e.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;

}

sub upPersonInfo {
	my ( $dbh,$personid,$name,$sex,$status,$familyid,$fatherid,$motherid ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
		set name='$name',sex='$sex',status='$status',family_id='$familyid',father_id='$fatherid',mother_id='$motherid'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub upPersonName {
	my ( $dbh,$personid,$name ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
		set name='$name'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub upPerson_fromId {
	my ($dbh,$personid,$param) = @_;
	my @opt = split(/ /,$param);
	my $set;
	my $v0;
	my $v1;
	my $v2;
	my $v3;
	my $v4;
	my $v5;

	my $nb;
	for (my $i = 0; $i< scalar(@opt); $i++) {
		my @val = split(/=/,$opt[$i]);
		$set.=$val[0]."=?,";
		$v0=$val[1] if $i==0;
		$v0="" if ($i==0 && !defined $val[1]);
		$v1=$val[1] if $i==1;
		$v1="" if ($i==1 && !defined $val[1]);
		$v2=$val[1] if $i==2;
		$v2="" if ($i==2 && !defined $val[1]);
		$v3=$val[1] if $i==3;
		$v3="" if ($i==3 && !defined $val[1]);
		$v4=$val[1] if $i==4;
		$v4="" if ($i==4 && !defined $val[1]);
		$v5=$val[1] if $i==5;
		$v5="" if ($i==5 && !defined $val[1]);
		$nb++;
	};
	chop($set);
	my $sql = qq{
		update PolyprojectNGS.person
		set $set
		where person_id='$personid';
	};
	my $sth= $dbh->prepare($sql);				

	$sth->execute($v0) if $nb==1;
	$sth->execute($v0,$v1) if $nb==2;
	$sth->execute($v0,$v1,$v2) if $nb==3;
	$sth->execute($v0,$v1,$v2,$v3) if $nb==4;
	$sth->execute($v0,$v1,$v2,$v3,$v4) if $nb==5;
	$sth->execute($v0,$v1,$v2,$v3,$v4,$v5) if $nb==6;
}

sub insertPerson {
	my ( $dbh, $name, $sex, $status, $familyid, $fatherid, $motherid,$mjprojectid) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.person (name,sex,status,family_id,father_id,mother_id,major_project_id)
 		values ('$name','$sex','$status','$familyid','$fatherid','$motherid','$mjprojectid')
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.person;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upPerson_inFamilyId {
	my ( $dbh, $personid, $familyid ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
		set family_id='$familyid'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub upPerson_inFatherId {
	my ( $dbh, $personid, $fatherid ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
		set father_id='$fatherid'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub upPerson_inMotherId {
	my ( $dbh, $personid, $motherid ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
		set mother_id='$motherid'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub delPersonId {
        my ($dbh,$personid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.person
			WHERE person_id='$personid';
 		};
 		return ($dbh->do($sql));
}

# Family
sub getFamily {
	my ( $dbh, $familyid ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.family f
		where f.family_id='$familyid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getFamily_FromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.family f
		where f.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
	
}

sub insertFamily {
	my ($dbh,$family) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.family (name)
 		values ('$family')
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.family;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

# MajorProject
sub getMajorProject {
	my ( $dbh, $mjprojectid ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.major_project mj
		where mj.major_project_id='$mjprojectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;

}

sub getMajorProject_FromName {
	my ( $dbh, $name ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.major_project mj
		where mj.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;

}

##################################################



####################### From Old querySample.pm : A supprimer ###########################
##################################################

############ Species ########################
sub getSpecies_FromName {
	my ( $dbh, $name ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.species s
		where s.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSpecies_FromId {
	my ($dbh,$id) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.species s
		where s.species_id='$id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;		
}
################## Person ##############################

sub getPersonInfo {
	my ( $dbh, $personid ) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.person p
		where p.person_id='$personid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSampleFrom_SexPerson_ProjectId {
	my ( $dbh, $sex, $projid ) = @_;
	my $query2 = qq {WHERE (p.sex='$sex' OR p.sex=0)};
	my $query3 = qq {AND s.project_id='$projid'};
	$query3 = "" unless $projid;
	my $query = qq{
		SELECT DISTINCT
		s.person_id as id,s.name,p.sex,
        s.sample_id,s.run_id,s.project_id,s.project_id_dest,
		( case  when s.project_id>0 && s.project_id_dest = 0 then ps.name
                when s.project_id>0 && s.project_id_dest > 0 then ps.name
                when s.project_id=0 && s.project_id_dest > 0 then pd.name
                when s.project_id=0 && s.project_id_dest = 0 then 'NGSRun'
                else 'NGSRun'
 		end ) as 'projname'

		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.person p
		ON s.person_id = p.person_id
  		LEFT JOIN PolyprojectNGS.projects ps
		ON s.project_id = ps.project_id
		LEFT JOIN PolyprojectNGS.projects pd
		ON s.project_id_dest = pd.project_id
		$query2
		$query3
		;
 	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getSamplePersonInfo_fromProject {
	my ( $dbh, $projid, $rid ) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT DISTINCT	
			s.project_id,s.run_id,s.project_id_dest,s.bar_code,s.bar_code_2,
        	s.identity_vigilance,s.identity_vigilance_vcf,s.status,s.name,s.family,
			s.flowcell,s.control,s.lane,s.capture_id,s.sample_id,s.creation_date,
        	p.person_id,p.code_name,p.father,p.mother,p.sex,
			r.description as desRun, r.document,r.name as nameRun,
			r.file_name as FileName,r.file_type as FileType		

        FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.person p
		ON s.person_id = p.person_id
		LEFT JOIN PolyprojectNGS.run r
		ON s.run_id=r.run_id


		WHERE s.project_id='$projid'
--       	group by p.person_id
		order by s.run_id	
		;
 	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getPersonProjectFrom_Project {
	my ( $dbh, $projid, $rid ) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT DISTINCT	
			s.project_id,s.run_id,s.project_id_dest,s.bar_code,s.bar_code_2,
        	s.identity_vigilance,s.identity_vigilance_vcf,
			s.flowcell,s.control,s.lane,s.capture_id,s.sample_id,s.creation_date,
        	p.person_id,p.code_name,s.name,s.family,p.father,p.mother,s.sex,p.status,
			r.description as desRun, r.document,r.name as nameRun,
			r.file_name as FileName,r.file_type as FileType		

        FROM PolyprojectNGS.person p
		LEFT JOIN PolyprojectNGS.sample s
		ON p.person_id = s.person_id
		LEFT JOIN PolyprojectNGS.run r
		ON s.run_id=r.run_id

		WHERE s.project_id='$projid'
       	group by p.person_id
		order by s.run_id	
		;
 	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getProjectNamefromPerson {
	my ( $dbh, $rid, $projid ) = @_;
	my $query = qq{
		SELECT distinct ps.name
        FROM PolyprojectNGS.person p
		LEFT JOIN PolyprojectNGS.sample s
		ON p.person_id = s.person_id		
		LEFT JOIN PolyprojectNGS.projects ps
		ON s.project_id = ps.project_id

		where s.run_id='$rid'
		and s.project_id='$projid'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#sub ctrlPersonNameInRun {
sub getSamplePersonFrom_Name_Run {
	my ( $dbh, $personname, $runid ) = @_;
	my $query2 = qq {and s.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query = qq{
		SELECT  DISTINCT
		s.person_id,s.name, s.project_id,s.run_id,s.sample_id
        FROM PolyprojectNGS.sample s
		where s.name like '$personname'
		$query2
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getSamplePersonDateFrom_Name_Run {
	my ( $dbh, $personname, $runid ) = @_;
	my $query2 = qq {and s.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query = qq{
		SELECT  DISTINCT
		s.person_id,s.name, s.project_id,s.run_id,s.sample_id,s.creation_date
        FROM PolyprojectNGS.sample s
		where s.name like '$personname'
		$query2
		order by s.creation_date desc
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getSampleInfo_fromPersonId {
	my ( $dbh, $personid ) = @_;

	#	warn Dumper $personid;
	my $query = qq{
		SELECT  *
		FROM PolyprojectNGS.sample
		where person_id='$personid'
	};

	#	warn Dumper $query;
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getSamplePersonFrom_Name_Project {
	my ( $dbh, $personname, $projid ) = @_;
	my $query2 = qq {and s.project_id='$projid'};
	$query2 = "" unless $projid;
	my $query = qq{
		SELECT  DISTINCT
		s.person_id,s.name, s.project_id,s.run_id,s.sample_id
		FROM PolyprojectNGS.sample s
		where s.name like '$personname'
		$query2
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub ctrlSamplePersonName_ProjectId {
	my ( $dbh, $projectid, $patname ) = @_;
	$patname =~ s/\s+//;
	my $query = qq{
		SELECT DISTINCT
		s.person_id
		FROM PolyprojectNGS.sample s
		WHERE s.project_id='$projectid'
		AND s.name like '$patname'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub insertPersonWith_Id_Date {
	my ( $dbh, $personid, $codename, $speciesid, $sex, $father, $mother, $date ) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.person (person_id,code_name,species_id,sex,father,mother,creation_date)
		values ('$personid','$codename','$speciesid','$sex','$father','$mother','$date')
	};
	return ( $dbh->do($query) );
}

sub delPerson {
	my ( $dbh, $personid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.person
		WHERE person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub upPerson_inSex {
	my ( $dbh, $personid, $sex ) = @_;
	my $sql = qq{
			update PolyprojectNGS.person
			set sex='$sex'
			where person_id='$personid';
        };
	return ( $dbh->do($sql) );
}

sub upPersonCodeName {
	my ( $dbh, $personid, $codename ) = @_;
	my $sql = qq{
		update PolyprojectNGS.person
 		set code_name='$codename'
		where person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

#Phenotype person
sub getPhenotypePerson {
	my ( $dbh, $pheid, $personid ) = @_;
	my $sql2 = qq {and ha.person_id='$personid'};
	$sql2 = "" unless $personid;
	my $sql = qq{        	
			SELECT ha.phenotype_id,ha.person_id
			FROM PolyPhenotypeDB.`phenotype_person` ha
			where ha.phenotype_id='$pheid'
			$sql2;
			;
		};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getPersonPhenotype {
	my ( $dbh, $personid ) = @_;
	my $sql2 = qq {where  ha.person_id='$personid'};
	$sql2 = "" unless $personid;
	my $sql = qq{
		SELECT distinct
-- 		ha.phenotype_id,
-- 		ha.patient_id,
		hh.name
		FROM PolyPhenotypeDB.phenotype_person ha
		LEFT JOIN PolyPhenotypeDB.phenotype hh
		ON ha.phenotype_id =hh.phenotype_id		
     	$sql2
    	;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub newPhenotypePerson {
	my ( $dbh, $pheid, $personid ) = @_;
	my $sql = qq{    
		insert into PolyPhenotypeDB.`phenotype_person` (phenotype_id,person_id) values ($pheid,$personid);
	};
	return ( $dbh->do($sql) );
}

sub removePhenotypePersonByPerson {
	my ( $dbh, $personid ) = @_;
	my $sql = qq{
		DELETE FROM PolyPhenotypeDB.`phenotype_person`
		where person_id='$personid'
	};
	return ( $dbh->do($sql) );
}

################## End Person ##############################

################## Sample #################################

sub getCaptureFromSamples {
	my ( $dbh, $sampleid ) = @_;
	my @sampleid = $sampleid;
	my $query    = qq{
		SELECT DISTINCT 
			GROUP_CONCAT(DISTINCT C.capture_id ORDER BY C.capture_id ASC SEPARATOR ' ') as 'capId',
			GROUP_CONCAT(DISTINCT C.name ORDER BY C.name ASC SEPARATOR ' ') as 'capName',
			GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ' ') as 'capAnalyse',
			GROUP_CONCAT(DISTINCT a.analyse_id ORDER BY a.analyse_id ASC SEPARATOR ' ') as 'AnalyseId',
			GROUP_CONCAT(DISTINCT C.validation_db ORDER BY C.validation_db ASC SEPARATOR ' ') as 'capValidation',
			GROUP_CONCAT(DISTINCT C.method ORDER BY C.method ASC SEPARATOR ' ') as 'capMeth',
			GROUP_CONCAT(DISTINCT R.name ORDER BY R.name ASC SEPARATOR ' ') as 'capRel'
		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.capture_systems C
		ON s.capture_id=C.capture_id
		LEFT JOIN PolyprojectNGS.releases R
		ON C.release_id=R.release_id
  		LEFT JOIN PolyprojectNGS.capture_analyse ca
		ON s.capture_id=ca.capture_id
   		LEFT JOIN PolyprojectNGS.analyse a
		ON ca.analyse_id=a.analyse_id
		WHERE
		s.sample_id in (@sampleid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCaptureAnalyse {
	my ( $dbh, $rid, $pid ) = @_;
	my $query2 = qq {and t.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		SELECT DISTINCT
		a.name as 'analyse'
		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON s.capture_id=cs.capture_id
  		LEFT JOIN PolyprojectNGS.capture_analyse ca
		ON cs.capture_id=ca.capture_id        
   		LEFT JOIN PolyprojectNGS.analyse a
		ON ca.analyse_id=a.analyse_id
		WHERE s.run_id='$rid'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

#
sub getSampleFrom_SampleId {
	my ( $dbh, $sampleid ) = @_;
	my @sampleid = $sampleid;
	my $query    = qq{
		SELECT DISTINCT
		*
		FROM PolyprojectNGS.sample s
        WHERE
		s.sample_id in (@sampleid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSampleFrom_PersonId {
	my ( $dbh, $personid ) = @_;
	my @personid = $personid;
	my $query    = qq{
		SELECT DISTINCT
		*
		FROM PolyprojectNGS.sample s
        WHERE
		s.person_id in (@personid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delSamplePerson {
	my ( $dbh, $sampleid, $personid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.sample_person
		WHERE sample_id='$sampleid'
		AND person_id='$personid';
	};
	return ( $dbh->do($sql) );
}

sub getGroupIdFromSampleGroups {
	my ( $dbh, $sampleid ) = @_;
	my $query = qq{
			select sg.group_id
			from PolyprojectNGS.sample_groups sg
			where sg.sample_id='$sampleid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub searchSampleGroup {
	my ($dbh) = @_;
	my $query = qq{
		select * from PolyprojectNGS.sample_groups sg;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getGroupIdFromPatientGroupsOld {
	my ( $dbh, $patid ) = @_;
	my $query = qq{
			select pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.patient_id='$patid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub getSamplesfrom_Run {
	my ( $dbh, $rid ) = @_;
	my $query = qq{
		SELECT *
		FROM PolyprojectNGS.sample s
        WHERE s.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getSamplesfrom_Project {
	my ( $dbh, $projectid ) = @_;
	my $query = qq{
		SELECT *
		FROM PolyprojectNGS.sample s
        WHERE s.project_id='$projectid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getFreeRunIdfromSample {
	my ( $dbh, $rid ) = @_;
	my $query = qq{
		SELECT s.run_id
		FROM PolyprojectNGS.sample s
		WHERE s.project_id=0
        AND s.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getFreeSampleIdFrom_Person {
	my ( $dbh, $rid, $personid ) = @_;
	my $query = qq{
		SELECT DISTINCT
		s.person_id,s.name,
        s.sample_id,s.run_id
		FROM PolyprojectNGS.sample s
		WHERE s.project_id=0
        AND s.run_id='$rid'
		AND s.person_id = '$personid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getRunIdfrom_Person {
	my ( $dbh, $rid ) = @_;
	my $query = qq{
		SELECT DISTINCT
		s.run_id
		FROM PolyprojectNGS.person p
		LEFT JOIN PolyprojectNGS.sample s
		ON p.person_id = s.person_id
		WHERE s.run_id='$rid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub upSampleInfo {
	my (
		$dbh, $sampleid, $personname, $status,   $family,
		$bc,  $bc2,      $iv,         $flowcell, $capid
	) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set name='$personname',status='$status',family='$family',bar_code='$bc',bar_code_2='$bc2',identity_vigilance='$iv',flowcell='$flowcell',capture_id='$capid'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSampleNameStatusFamily_FromPersonId {
	my ( $dbh, $personid, $personname, $status, $family ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set name='$personname',status='$status',family='$family'
        	where person_id='$personid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inPersonId {
	my ( $dbh, $sampleid, $personid ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set person_id='$personid'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inInitName {
	my ( $dbh, $sampleid, $initname ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set init_name='$initname'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inProject {
	my ( $dbh, $sampleid, $projectid ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set project_id='$projectid'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inProjectDest {
	my ( $dbh, $sampleid, $projectid ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set project_id_dest='$projectid'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inStatus {
	my ( $dbh, $sampleid, $status ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set status='$status'
        	where sample_id='$sampleid';
        };

	#        warn Dumper $sql;
	return ( $dbh->do($sql) );
}

sub upSample_inIV {
	my ( $dbh, $sampleid, $iv ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set identity_vigilance='$iv'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSampleGroup {
	my ( $dbh, $sampleid, $groupid ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample_groups
        	set group_id='$groupid'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub upSample_inControl {
	my ( $dbh, $sampleid, $control ) = @_;
	my $sql = qq{
        	update PolyprojectNGS.sample
        	set control='$control'
        	where sample_id='$sampleid';
        };
	return ( $dbh->do($sql) );
}

sub addGroup2sample {
	my ( $dbh, $sampleid, $groupid ) = @_;
	my $sql = qq{    
		insert into PolyprojectNGS.sample_groups (sample_id,group_id) values ($sampleid,$groupid);
	};
	return ( $dbh->do($sql) );
}

sub removeGroup2sample {
	my ( $dbh, $sampleid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.sample_groups
		where sample_id='$sampleid';
	};
	return ( $dbh->do($sql) );
}

sub isSampleMeth {
	my ( $dbh, $sampleid, $methodid ) = @_;
	my $query = qq{
		select sm.sample_id,sm.method_id
		from PolyprojectNGS.sample_methods sm
		where sm.sample_id='$sampleid'
		and sm.method_id='$methodid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub addMeth2sample {
	my ( $dbh, $sampleid, $methodid ) = @_;
	my $sql = qq{    
                insert into PolyprojectNGS.sample_methods (sample_id,method_id) values ($sampleid,$methodid);
        };
	return ( $dbh->do($sql) );
}

sub delMeth2sample {
	my ( $dbh, $sampleid, $methodid ) = @_;
	my $sql = qq{
        	DELETE FROM PolyprojectNGS.sample_methods
        	WHERE sample_id='$sampleid'
        	AND method_id='$methodid'
		};
	return ( $dbh->do($sql) );
}

sub insertSamplePerson {
	my ( $dbh, $sampleid, $personid ) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.sample_person (sample_id,person_id)
		values ('$sampleid','$personid')
	};
	return ( $dbh->do($query) );
}

sub insertSample {

#	my ($dbh,$runid,$projectid,$projectiddest,$captureid,$barcode,$fowcell,$identity_vigilance) = @_;#no bar_code_2 lane identity_vigilance_vcf
	my (
		$dbh,       $personid,      $runid,
		$projectid, $projectiddest, $captureid,
		$name,      $initname,      $family,
		$status,    $barcode,       $barcode2,
		$fowcell,   $identity_vigilance
	) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.sample (person_id,run_id,project_id,project_id_dest,capture_id,name,init_name,family,status,bar_code,bar_code_2,flowcell,identity_vigilance)
 		values ('$personid','$runid','$projectid','$projectiddest','$captureid','$name','$initname','$family','$status','$barcode','$barcode2','$fowcell','$identity_vigilance')
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.sample;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub insertSample_PersonName {
	my ( $dbh, $personid, $runid, $projectiddest, $name, $initname, $status ) =
	  @_;
	my $query = qq{
		insert into  PolyprojectNGS.sample (person_id,run_id,project_id_dest,name,init_name,status)
 		values ('$personid','$runid','$projectiddest','$name','$initname','$status')
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.sample;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

# used in sc_forUpadateTables

sub insertSampleWith_Date {
	my (
		$dbh,       $personid,           $runid,
		$projectid, $projectiddest,      $captureid,
		$name,      $initname,           $family,
		$status,    $barcode,            $barcode2,
		$fowcell,   $identity_vigilance, $identity_vigilance_vcf,
		$control,   $lane,               $date
	) = @_;
	my $query = qq{
		insert into  PolyprojectNGS.sample (person_id,run_id,project_id,project_id_dest,capture_id,name,init_name,family,status,bar_code,bar_code_2,flowcell,identity_vigilance,identity_vigilance_vcf,control,lane,creation_date)
 		values ('$personid','$runid','$projectid','$projectiddest','$captureid','$name','$initname','$family','$status','$barcode','$barcode2','$fowcell','$identity_vigilance','$identity_vigilance_vcf','$control','$lane','$date')
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.sample;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delFreeSample_FromRun {
	my ( $dbh, $runid, $sampleid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.sample
		WHERE project_id=0
		AND run_id='$runid'
		AND sample_id='$sampleid';
	};
	return ( $dbh->do($sql) );
}

############ End Sample ####################
############ Method Sample ########################
sub getMethodsNameFromSample {
	my ( $dbh, $meths, $sampleid ) = @_;
	my @sampleid = $sampleid;
	my $query    = qq{
		SELECT DISTINCT
		count(distinct if (sm.sample_id > 0,sm.sample_id,null)) as 'nbMeths',
		GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'meths'
		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.sample_methods sm
		ON s.sample_id=sm.sample_id
		LEFT JOIN PolyprojectNGS.methods M
		ON sm.method_id=M.method_id
		WHERE s.sample_id in (@sampleid)
		AND M.type='$meths';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub insertMeth2sample {
	my ( $dbh, $sampleid, $methodid ) = @_;
	my $sql = qq{    
                insert into PolyprojectNGS.sample_methods (sample_id,method_id) values ($sampleid,$methodid);
        };
	return ( $dbh->do($sql) );
}

sub delMeth2sample {
	my ( $dbh, $sampleid ) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.sample_methods
		WHERE sample_id='$sampleid';
	};
	return ( $dbh->do($sql) );
}

############ End Method ####################
############ Sample Groups########################

sub getGroupsFromSample {
	my ( $dbh, $sampleid ) = @_;
	my @sampleid = $sampleid;
	my $query    = qq{
		SELECT DISTINCT
		sg.sample_id,g.name,g.group_id
		FROM PolyprojectNGS.sample_groups sg
 		LEFT JOIN PolyprojectNGS.group g
		ON sg.group_id=g.group_id
		WHERE sg.sample_id in (@sampleid); 		
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSampleGroups_Id {
	my ( $dbh, $val, $valB ) = @_;
	my $query2;
	$query2 = qq {where sg.sample_id='$val'} unless $valB;
	$query2 = qq {where sg.group_id='$val'} if $valB;
	$query2 = "" unless $val;
	my $query = qq{
		select distinct
		*
		from PolyprojectNGS.sample_groups sg
		$query2
		;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();

	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

sub insertGroup2sample {
	my ( $dbh, $sampleid, $groupid ) = @_;
	my $sql = qq{    
                insert into PolyprojectNGS.sample_groups (sample_id,group_id) values ($sampleid,$groupid);
        };
	return ( $dbh->do($sql) );
}

sub delSampleGroup {
	my ( $dbh, $groupid, $sampleid ) = @_;
	my $sql2 = qq {and sample_id='$sampleid'};
	$sql2 = "" unless $sampleid;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.sample_groups
		where group_id='$groupid'
		$sql2;
	};
	return ( $dbh->do($sql) );
}

############ End Sample Groups ####################
############ Analyse ########################
sub getAnalyseIdFromName {
	my ( $dbh, $name ) = @_;
	my $query = qq{
		select a.analyse_id
		FROM PolyprojectNGS.analyse a
		where a.name='$name';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{analyse_id};

}

sub insertCaptureAnalyse {
	my ( $dbh, $captureid, $analyseid ) = @_;
	my $query = qq{
		insert into PolyprojectNGS.capture_analyse (capture_id,analyse_id) values ($captureid,$analyseid);
	};
	$dbh->do($query);
}

############ Run ########################
sub getAllqRunInfo {
	my ( $dbh, $rid ) = @_;
	my $query2 = qq {where r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SET SESSION group_concat_max_len = 1000000;
	};
	$dbh->do($query);

	$query = qq{
	SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient as 'nbpatRun',
		r.creation_date as cDate,r.plateform_run_name as pltRun,
 		GROUP_CONCAT(DISTINCT s.sample_id ORDER BY s.sample_id ASC SEPARATOR ',') as 'sampleId',
		GROUP_CONCAT(DISTINCT e.person_id ORDER BY e.person_id ASC SEPARATOR ',') as 'personId',
		GROUP_CONCAT(DISTINCT s.name ORDER BY s.name ASC SEPARATOR ',') as 'personName',
		GROUP_CONCAT(DISTINCT s.bar_code ORDER BY s.bar_code ASC SEPARATOR ',') as 'patBC',
		GROUP_CONCAT(DISTINCT s.bar_code_2 ORDER BY s.bar_code_2 ASC SEPARATOR ',') as 'patBC2',
		GROUP_CONCAT(DISTINCT s.lane ORDER BY s.lane ASC SEPARATOR ',') as 'lane',
		count(distinct if (s.project_id > 0,s.sample_id,null)) as 'nbPrjRun',
		GROUP_CONCAT(DISTINCT s.project_id ORDER BY s.project_id ASC SEPARATOR ',') as 'projectId',
		GROUP_CONCAT(DISTINCT s.project_id_dest ORDER BY s.project_id_dest ASC SEPARATOR ',') as 'projectDestId'

	FROM PolyprojectNGS.run r
	LEFT JOIN PolyprojectNGS.sample s
	ON r.run_id = s.run_id
	LEFT JOIN PolyprojectNGS.person e
	ON s.person_id = e.person_id
	
 	$query2    
	group by r.run_id
	order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		print ".";
		push( @res, $id );
	}
	return \@res;
}

sub getRunFromSamples {
	my ( $dbh, $sampleid ) = @_;
	my @sampleid = $sampleid;
	my $query    = qq{
		SELECT DISTINCT
    	GROUP_CONCAT(DISTINCT r.run_id ORDER BY r.run_id ASC SEPARATOR ' ') as 'runId',
   		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name ASC SEPARATOR ',') as 'plateformName',
    	GROUP_CONCAT(DISTINCT S.name ORDER BY S.name ASC SEPARATOR ',') as 'machineName',
    	GROUP_CONCAT(DISTINCT ms.name ORDER BY ms.name ASC SEPARATOR ',') as 'methSeqName'
 
 		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.run r
		ON s.run_id=r.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rf
		ON r.run_id=rf.run_id
		LEFT JOIN PolyprojectNGS.plateform f
		ON rf.plateform_id=f.plateform_id
		LEFT JOIN PolyprojectNGS.run_machine rm
		ON r.run_id=rm.run_id
		LEFT JOIN PolyprojectNGS.sequencing_machines S
		ON rm.machine_id=S.machine_id
		LEFT JOIN PolyprojectNGS.run_method_seq rs
		ON r.run_id=rs.run_id
		LEFT JOIN PolyprojectNGS.method_seq ms
		ON rs.method_seq_id=ms.method_seq_id

		WHERE s.sample_id in (@sampleid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#getRunfromProject
sub getRunfrom_sampleProject {
	my ( $dbh, $projectid ) = @_;
	my $query = qq{
		SELECT DISTINCT
		GROUP_CONCAT(DISTINCT s.run_id ORDER BY s.run_id DESC SEPARATOR ' ') as 'RunId'
		FROM PolyprojectNGS.sample s
		WHERE s.project_id='$projectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getRunfromProject {
	my ( $dbh, $pid ) = @_;
	my $query = qq{
		SELECT DISTINCT
		GROUP_CONCAT(DISTINCT a.run_id ORDER BY a.run_id DESC SEPARATOR ' ') as 'RunId'
		FROM 
		PolyprojectNGS.projects p,
		PolyprojectNGS.patient a
		WHERE
		p.project_id=a.project_id
		and p.project_id='$pid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#getRunfromProjectIdDest
sub getRunfrom_sampleProjectIdDest {
	my ( $dbh, $projectid ) = @_;
	my $query = qq{
		SELECT DISTINCT
		GROUP_CONCAT(DISTINCT s.run_id ORDER BY s.run_id DESC SEPARATOR ' ') as 'RunId'
		FROM PolyprojectNGS.sample s
		WHERE s.project_id_dest='$projectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSamplePersonsFrom_Run_Project_ProjectDest {
	my ( $dbh, $rid, $projid ) = @_;

	#	my $query2 = qq {and a.project_id_dest='$pid'};
	#	$query2 = "" unless $pid;
	my $query = qq{
		SELECT  DISTINCT
			s.sample_id, s.project_id,s.project_id_dest,s.run_id,s.capture_id,s.control,
			s.bar_code,s.bar_code_2,s.flowcell,s.identity_vigilance,s.identity_vigilance_vcf,
			s.flowcell,s.lane,s.creation_date as cDate,
			s.name,e.person_id,e.code_name,s.family,e.father,e.mother,e.sex,s.status
		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.person e
		ON s.person_id = e.person_id

		WHERE s.run_id='$rid'
		;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

sub getSamplePersonsFrom_PersonName {
	my ( $dbh, $pat_name ) = @_;
	$pat_name =~ s/\s+//;
	my $query = qq{
		SELECT DISTINCT
		s.run_id as runid, s.project_id as projid,
        s.project_id_dest as projiddest,		
		ps.name as ProjName
		FROM PolyprojectNGS.sample s
		LEFT JOIN PolyprojectNGS.projects ps
		ON s.project_id = ps.project_id
		WHERE 
		s.name REGEXP '^$pat_name\$' and 
		(s.project_id=ps.project_id or s.project_id_dest=ps.project_id);
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res if \@res;
}

############ End Run ####################
############ Project ########################
sub getProjectAll {
	my ( $dbh, $cunit, $projid ) = @_;
	my $sql2 = qq {and ps.project_id='$projid'};
	$sql2 = "" unless $projid;

	my $sql = qq{
		SET SESSION group_concat_max_len = 1000000;
	};
	$dbh->do($sql);

	$sql = qq{
	SELECT DISTINCT
	ps.project_id as id , 
	ps.name as name, 
	ps.description,
	ps.dejaVu,ps.somatic,
	ps.creation_date as cDate,
	GROUP_CONCAT(DISTINCT s.sample_id ORDER BY s.sample_id ASC SEPARATOR ',') as 'sampleId',
	GROUP_CONCAT(DISTINCT e.person_id ORDER BY e.person_id ASC SEPARATOR ',') as 'personId',
	GROUP_CONCAT(DISTINCT s.name ORDER BY s.name ASC SEPARATOR ',') as 'personName',
	GROUP_CONCAT(DISTINCT s.bar_code ORDER BY s.bar_code ASC SEPARATOR ',') as 'patBC',
	GROUP_CONCAT(DISTINCT s.bar_code_2 ORDER BY s.bar_code_2 ASC SEPARATOR ',') as 'patBC2',
	GROUP_CONCAT(DISTINCT s.lane ORDER BY s.lane ASC SEPARATOR ',') as 'lane',
	po.name as dbname

	FROM PolyprojectNGS.projects ps
	LEFT JOIN PolyprojectNGS.databases_projects dp
    ON ps.project_id =dp.project_id
    LEFT JOIN PolyprojectNGS.polydb po
    ON dp.db_id = po.db_id
	LEFT JOIN PolyprojectNGS.sample s
	ON ps.project_id = s.project_id
	LEFT JOIN PolyprojectNGS.person e
	ON s.person_id = e.person_id

	WHERE ps.type_project_id=3
    and dp.db_id !=2
  	$sql2
	group by ps.project_id
	order by ps.project_id desc
   	;
 	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while ( my $id = $sth->fetchrow_hashref ) {
		push( @res, $id );
	}
	return \@res;
}

############ End Project ####################

1;
