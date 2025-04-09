package queryPolyproject;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

############ Schemas Validation #####################
sub getSchemasValidation {
	my ($dbh,$name) = @_;
	my $sql;
	$sql = qq{show schemas like "%validation%"	} unless $name;
	$sql = qq{show schemas like "$name"	} if $name;
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

############ Plateform #####################
sub getPlateformId{
	my ($dbh,$pltid)=@_;
	my $sql2 = qq {where f.plateform_id='$pltid'};
	$sql2 = "" unless $pltid;
	my $sql = qq{
		SELECT DISTINCT
		f.plateform_id as plateformId,f.name as plateformName,f.def
		from PolyprojectNGS.plateform f
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

sub getPlateformFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select f.name as name, f.plateform_id as id  
		FROM PolyprojectNGS.plateform f
		where  f.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPlateform {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select f.name as name
		from PolyprojectNGS.run_plateform rf, PolyprojectNGS.plateform f
		where rf.run_id='$rid' and rf.plateform_id=f.plateform_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub newPlateformData {
        my ($dbh,$plateform) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.plateform (name) values ('$plateform');
 		};
 		return ($dbh->do($sql));
}

sub upPlateform_default {
	my ($dbh,$plateformid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.plateform 
		set def=?
		where plateform_id='$plateformid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}

sub addPlateform2run {
        my ($dbh,$plateformid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_plateform (plateform_id,run_id) values ($plateformid,$rid);
        };
        return ($dbh->do($sql));
} 

sub upPlateform2run {
	my ($dbh,$rid,$plateformid) = @_;
	my $sql = qq{
		update PolyprojectNGS.run_plateform
		set plateform_id=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($plateformid);
	$sth->finish;
	return;
} 

############ End Plateform #################
############ Machine #######################
sub getMachineId{
        my ($dbh,$macid)=@_;
 		my $sql2 = qq {where S.machine_id='$macid'};
		$sql2 = "" unless $macid;
        my $sql = qq{
			select  S.machine_id as machineId,S.name as macName,
			S.type as macType,S.def
			from PolyprojectNGS.sequencing_machines S
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

sub getMachineFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  S.machine_id as machineId,S.name as macName,
			S.type as macType
			from PolyprojectNGS.sequencing_machines S
			where S.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getSequencingMachines {
	my ($dbh,$rid) = @_;
	my $sql = qq{
		select S.name as name
		from PolyprojectNGS.run_machine rm, PolyprojectNGS.sequencing_machines S
		where rm.run_id='$rid' and rm.machine_id=S.machine_id;};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{name} if $res;
}

sub newMachineData {
        my ($dbh,$machine,$mactype) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.sequencing_machines (name,type) values ('$machine','$mactype');
  		};
 		return ($dbh->do($sql));
}

sub upMachine_default {
	my ($dbh,$macid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.sequencing_machines 
		set def=?
		where machine_id='$macid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}
############ End Machine ###################
############ Method ########################
sub getMethodId{
        my ($dbh,$methid)=@_;
 		my $sql2 = qq {where M.method_id='$methid'};
		$sql2 = "" unless $methid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType,M.def
			from PolyprojectNGS.methods M
			$sql2
			order by M.name;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getAlnMethodName{
        my ($dbh,$rid,$pid)=@_;
		my $query2 = qq {and a.project_id='$pid'};
		$query2 = "" unless $pid;
        my $sql = qq{
        	SELECT distinct a.run_id,M.name as methAln
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.run_id='$rid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type='ALIGN'
			$query2
			order by methAln;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getCallMethodName{
        my ($dbh,$rid,$pid)=@_;
		my $query2 = qq {and a.project_id='$pid'};
		$query2 = "" unless $pid;
        my $sql = qq{
        	SELECT distinct a.run_id,M.name as methCall
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.run_id='$rid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type='SNP'
			$query2
			order by methCall;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getMethodsNameFromPatient {
	my ($dbh,$meths,$patid)=@_;
	my @patid=$patid;
 	my $query = qq{
        	SELECT 
			count(distinct if (pm.patient_id > 0,pm.patient_id,null)) as 'nbMeths',
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'meths'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.patient_id in (@patid)
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type='$meths';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getOtherMethodsNameFromPatient {
	my ($dbh,$patid)=@_;
	my @patid=$patid;
 	my $query = qq{
        	SELECT 
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'meths'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.patient_id in (@patid)
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type not in ("SNP","ALIGN") ;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getnewAlnMethodName{
        my ($dbh,$rid,$pid,$patid)=@_;
		my $query2 = qq {and a.project_id='$pid'};
		$query2 = "" unless $pid;
		my $query3 = qq {and a.patient_id='$patid'};
		$query3 = "" unless $patid;
        my $sql = qq{
        	SELECT distinct a.run_id,
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'methAln'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.run_id='$rid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			$query2
			$query3			
			and M.type='ALIGN';
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getnewCallMethodName{
        my ($dbh,$rid,$pid,$patid)=@_;
		my $query2 = qq {and a.project_id='$pid'};
		$query2 = "" unless $pid;
		my $query3 = qq {and a.patient_id='$patid'};
		$query3 = "" unless $patid;
        my $sql = qq{
        	SELECT distinct a.run_id,
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'methCall'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.run_id='$rid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			$query2
			$query3			
			and M.type='SNP';
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getnewPipeMethodName {
        my ($dbh,$rid,$pid,$patid)=@_;
		my $query2 = qq {and a.project_id='$pid'};
		$query2 = "" unless $pid;
		my $query3 = qq {and a.patient_id='$patid'};
		$query3 = "" unless $patid;
        my $sql = qq{
        	SELECT distinct a.run_id,
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'methPipe'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.run_id='$rid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			$query2
			$query3			
			and M.type not in ("SNP","ALIGN");
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getMethodName{
		my ($dbh,$rid,$pid,$patid)=@_;
		my @pid=$pid ;
		my $query2 = qq {and a.project_id in (@pid)};
		$query2 = "" unless $pid;
		my $query3 = qq {and a.patient_id='$patid'};
		$query3 = "" unless $patid;
        my $sql = qq{
        	SELECT a.run_id,
        	a.patient_id,
			M.name,
			M.type
			FROM 
			PolyprojectNGS.patient a
			LEFT JOIN PolyprojectNGS.patient_methods pm
			ON a.patient_id = pm.patient_id
			LEFT JOIN PolyprojectNGS.methods M
			ON pm.method_id=M.method_id
			WHERE a.run_id='$rid'
			$query2
			$query3
			ORDER BY patient_id	
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

sub getAlnMethodId {
        my ($dbh,$methodid)=@_;
   		my $sql2 = qq {and M.method_id='$methodid'};
		$sql2 = "" unless $methodid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType,M.def
			from PolyprojectNGS.methods M 
			where M.type='ALIGN'
			$sql2			
			order by M.name;
			
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getCallMethodId {
        my ($dbh,$methodid)=@_;
   		my $sql2 = qq {and M.method_id='$methodid'};
		$sql2 = "" unless $methodid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType,M.def
			from PolyprojectNGS.methods M 
			where M.type='SNP'
			$sql2			
			order by M.name;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getOtherMethodId {
        my ($dbh,$methodid)=@_;
   		my $sql2 = qq {and M.method_id='$methodid'};
		$sql2 = "" unless $methodid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType,M.def
			from PolyprojectNGS.methods M 
			where (M.type!='SNP' && M.type!='ALIGN')
			$sql2			
			order by M.name;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getMethodFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
			from PolyprojectNGS.methods M
			where M.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCallMethodNameFromPatient{
	my ($dbh,$pid)=@_;
 	my $query = qq{
        	SELECT 
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'methCall'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.patient_id='$pid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type='SNP';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{methCall};
}

sub getAlnMethodNameFromPatient{
	my ($dbh,$pid)=@_;
 	my $query = qq{
        	SELECT 
			GROUP_CONCAT(DISTINCT M.name ORDER BY M.name DESC SEPARATOR ' ') as 'methAln'
			FROM 
			PolyprojectNGS.patient a,
			PolyprojectNGS.patient_methods pm,
			PolyprojectNGS.methods M
			WHERE a.patient_id='$pid'
			and a.patient_id=pm.patient_id
			and pm.method_id=M.method_id
			and M.type='ALIGN';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{methAln};
}

sub ctrlPatMeth {
	my ($dbh,$patid,$mid) = @_;
	my $query = qq{
		SELECT pm.method_id
		FROM PolyprojectNGS.patient_methods pm
		where pm.patient_id='$patid'
		and pm.method_id='$mid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delPatMeth {
	my ($dbh,$patid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.patient_methods
		where patient_id='$patid';
	};
 	return ($dbh->do($sql));
}

sub getMethodsFromName {
	my ($dbh,$name,$type) = @_;
	my $query2 = qq {and m.type='$type'};
	$query2 = "" unless $type;
	if ($type eq "other") {
		$query2 = qq {and m.type not in ('SNP','ALIGN')};
	}
	my $query = qq{
		select m.name as name, m.type as type, m.method_id as id  
		FROM PolyprojectNGS.methods m
		where  m.name='$name'
		$query2
			;
	};	
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newMethodData {
        my ($dbh,$method,$type) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.methods (name,type) values ('$method','$type');
  		};
 		return ($dbh->do($sql));
}

sub upMethods_default {
	my ($dbh,$methodid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.methods
		set def=?
		where method_id='$methodid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}

############ End Method ####################
############ Method Seq ####################
sub getMethSeq {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select ms.name as name
		from PolyprojectNGS.run_method_seq rs, PolyprojectNGS.method_seq ms
		where rs.run_id='$rid'
		and rs.method_seq_id=ms.method_seq_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{name} if $res;
}

sub getSeqMethodId {
        my ($dbh,$methseqid)=@_;
  		my $sql2 = qq {where ms.method_seq_id='$methseqid'};
		$sql2 = "" unless $methseqid;
        my $sql = qq{
			select  ms.method_seq_id as methodSeqId,ms.name as methSeqName,ms.def
			from PolyprojectNGS.method_seq ms
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

sub getMethSeqFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  ms.method_seq_id as methodSeqId,ms.name as methSeqName
			from PolyprojectNGS.method_seq ms
			where ms.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newMethSeqData {
        my ($dbh,$methseq) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.method_seq (name) values ('$methseq');
  		};
 		return ($dbh->do($sql));
}

sub upMethSeq_default {
	my ($dbh,$methseqid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.method_seq
		set def=?
		where method_seq_id='$methseqid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}

############ Analyse #########################################
sub getAnalyseFromPatients {
	my ($dbh,$patid)=@_;
	my @patid=$patid;
	my $query = qq{
		SELECT distinct
		GROUP_CONCAT(DISTINCT an.name ORDER BY an.name ASC SEPARATOR ' ') as 'Analyse'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.patient_analyse pa
		ON a.patient_id=pa.patient_id
		LEFT JOIN PolyprojectNGS.analyse an
		ON pa.analyse_id=an.analyse_id
		WHERE
		a.patient_id in (@patid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

############ End Analyse #####################################
############ End Method Seq ################
############ Group /Patient Groups ########################

sub getGroupId{
        my ($dbh,$groupid)=@_;
		my $sql2 = qq {where g.group_id='$groupid'};
		$sql2 = "" unless $groupid;
        my $sql = qq{
			select g.group_id,g.name as groupName
			from PolyprojectNGS.group g 
			$sql2		
			order by g.group_id;			
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

# select where case sensitive
sub getGroupIdFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select g.group_id,g.name as groupName
			from PolyprojectNGS.group g
			where binary g.name = '$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getGroupIdFromPatientGroups {
	my ($dbh,$patid) = @_;
	my $query = qq{
			select pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.patient_id='$patid';
	};
        my @res;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub isPatientGroup {
	my ($dbh,$patid,$groupid) = @_;
	my $query = qq{
			select pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.patient_id='$patid'
			and pg.group_id='$groupid';
	};
        my @res;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}


sub searchGroup {
	my ($dbh) = @_;
	my $query = qq{
		select * from PolyprojectNGS.group;
	};
        my @res;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub searchEmptyGroup {
	my ($dbh,$patid) = @_;
	my $query = qq{
	select g.group_id
		from PolyprojectNGS.group g
		where g.name='';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delGroup {
	my ($dbh,$groupid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.group
		where group_id='$groupid';
	};
 	return ($dbh->do($sql));
}

sub newGroup {
	my ($dbh,$name) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.group (name) 
 		values ("$name");
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.group;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub searchPatientGroup {
	my ($dbh) = @_;
	my $query = qq{
		select * from PolyprojectNGS.patient_groups pg;
	};
        my @res;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getPatientIdFromPatientGroups {
	my ($dbh,$groupid) = @_;
	my $query = qq{
			select pg.patient_id, pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.group_id='$groupid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upPatientGroup {
        my ($dbh,$patid,$groupid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient_groups
        	set group_id='$groupid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
} 

sub addGroup2patient {
	my ($dbh,$patid,$groupid) = @_;
	my $sql = qq{    
		insert into PolyprojectNGS.patient_groups (patient_id,group_id) values ($patid,$groupid);
	};
	return ($dbh->do($sql));
}

sub removeGroup2patient {
	my ($dbh,$patid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.patient_groups
		where patient_id='$patid';
	};
 	return ($dbh->do($sql));
}

sub delPatGroup {
	my ($dbh,$groupid,$patientid) = @_;
	my $sql2 = qq {and patient_id='$patientid'};
	$sql2 = "" unless $patientid;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.patient_groups
		where group_id='$groupid'
		$sql2;
	};
 	return ($dbh->do($sql));
}

############ End Group #####################
############ Capture #######################

sub getCaptureId{
        my ($dbh,$capid)=@_;
		my $query2 = qq {where C.capture_id='$capid'};
		$query2 = "" unless $capid;
        my $sql = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType,
			C.analyse as capAnalyse,C.validation_db as capValidation,
			C.method as capMeth,
			C.primers_filename as capFilePrimers
			from PolyprojectNGS.capture_systems C
			$query2			
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

sub upCapture_default {
	my ($dbh,$captureid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.capture_systems
		set def=?
		where capture_id='$captureid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}

=mod
AV			AP
1=> Exome		1=> All
2=> Genome		2=> Exome
3=> Target		3=> Genome
4=> RNAseq		4=> Target
5=> All			5=> RNAseq
6=>Amplicon
7=>Other
=cut
sub getCaptureBundleInfo{
	my ($dbh,$numAnalyse,$capid) = @_;
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
	#amplicon 7
	$query2 = qq {where C.analyse ="amplicon"} if $numAnalyse == 7;
	#oher 8
	$query2 = qq {where C.analyse ="other"} if $numAnalyse == 8;

	my $query3 = qq {and C.capture_id='$capid'};
	$query3 = "" unless $capid;
	my $sql = qq{
		SELECT		
		C.capture_id as captureId,C.name as capName,
		C.version as capVs, C.description as capDes,
		C.filename as capFile, C.type as capType,
		C.analyse as capAnalyse,C.validation_db as capValidation,
		C.method as capMeth,
		C.primers_filename as capFilePrimers,
		C.creation_date as cDate,
        C.umi_id,u.name as UMI,C.def,
        GROUP_CONCAT(DISTINCT CONCAT(b.name,":",rg.name) ORDER BY b.name ASC SEPARATOR ' ') as 'bunName'
		FROM PolyprojectNGS.capture_systems C
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON C.capture_id=cb.capture_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON cb.bundle_id=b.bundle_id
        
   		LEFT JOIN PolyprojectNGS.bundle_release_gene br
		ON br.bundle_id=b.bundle_id
		LEFT JOIN PolyprojectNGS.release_gene rg
		ON rg.rel_gene_id=br.rel_gene_id

		LEFT JOIN PolyprojectNGS.bundle_transcripts bt
 		ON b.bundle_id=bt.bundle_id

		LEFT JOIN PolyprojectNGS.umi u
		ON C.umi_id=u.umi_id
			
		$query2
		$query3
		GROUP BY C.capture_id
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

sub countTranscriptFromCaptureBundle {
        my ($dbh,$capid)=@_;
		my $query2 = qq {where cb.capture_id='$capid'};
		$query2 = "" unless $capid;
        my $sql = qq{
			SELECT 
			count(bt.transcript_id)
			FROM 
			PolyprojectNGS.capture_bundle cb
			LEFT JOIN PolyprojectNGS.bundle b
			ON cb.bundle_id=b.bundle_id
			LEFT JOIN PolyprojectNGS.bundle_transcripts bt
            ON b.bundle_id=bt.bundle_id
			$query2
			;		
		};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchrow_array;
	$sth->finish;
	return $res;
}

sub countBundleFromCaptureBundle {
        my ($dbh,$capid)=@_;
		my $query2 = qq {where cb.capture_id='$capid'};
		$query2 = "" unless $capid;
        my $sql = qq{
			SELECT 
			count(b.name)
			FROM PolyprojectNGS.capture_systems C
			LEFT JOIN PolyprojectNGS.capture_bundle cb
			ON C.capture_id=cb.capture_id
            LEFT JOIN PolyprojectNGS.bundle b
            ON cb.bundle_id=b.bundle_id

			$query2
			;		
		};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchrow_array;
	$sth->finish;
	return $res;
}

sub getCaptureName{
        my ($dbh,$capid)=@_;
        my $sql = qq{
			select  C.name as capName
			from PolyprojectNGS.capture_systems C
			where C.capture_id='$capid';
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getAllCaptureType {
        my ($dbh)=@_;
        my $sql = qq{
			SELECT distinct C.type as capType 
			FROM PolyprojectNGS.capture_systems C;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getCaptureFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType
			from PolyprojectNGS.capture_systems C
			where C.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCaptureFromRelease {
	my ($dbh,$relid)=@_;
	my @relid=$relid;
	my $query = qq{
		SELECT * FROM PolyprojectNGS.capture_systems
		WHERE release_id in (@relid)
		;			
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getCaptureFromPatients {
	my ($dbh,$patid)=@_;
	my @patid=$patid;
	my $query = qq{
		SELECT distinct
			GROUP_CONCAT(DISTINCT C.capture_id ORDER BY C.capture_id ASC SEPARATOR ' ') as 'capId',
			GROUP_CONCAT(DISTINCT C.name ORDER BY C.name ASC SEPARATOR ' ') as 'capName',
			GROUP_CONCAT(DISTINCT C.analyse ORDER BY C.analyse ASC SEPARATOR ' ') as 'capAnalyse',
			GROUP_CONCAT(DISTINCT C.validation_db ORDER BY C.validation_db ASC SEPARATOR ' ') as 'capValidation',
			GROUP_CONCAT(DISTINCT C.method ORDER BY C.method ASC SEPARATOR ' ') as 'capMeth',
			GROUP_CONCAT(DISTINCT R.name ORDER BY R.name ASC SEPARATOR ' ') as 'capRel'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems C
		ON a.capture_id=C.capture_id
		LEFT JOIN PolyprojectNGS.releases R
		ON C.release_id=R.release_id
		WHERE
		a.patient_id in (@patid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCapture {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and t.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select distinct 
		c.name as name,
		c.capture_id,
		c.analyse,
		c.method as capMeth
		from PolyprojectNGS.patient t, PolyprojectNGS.capture_systems c
		where t.run_id='$rid'
		$query2
		and t.capture_id=c.capture_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getCaptureAnalyse {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and t.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select distinct c.analyse as analyse
		from PolyprojectNGS.patient t, PolyprojectNGS.capture_systems c
		where t.run_id='$rid'
		$query2
		and t.capture_id=c.capture_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getCaptureMethod {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and t.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select distinct c.method as capMeth
		from PolyprojectNGS.patient t, PolyprojectNGS.capture_systems c
		where t.run_id='$rid'
		$query2
		and t.capture_id=c.capture_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getAllCaptureMethod {
	my ($dbh) = @_;
	my $query = qq{
			select  distinct C.method as capMeth
			from PolyprojectNGS.capture_systems C;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getLastCapture {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(capture_id) as capture_id from PolyprojectNGS.capture_systems;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub newCaptureData {
        my ($dbh,$capture,$capVs,$capDes,$capFile,$capType,$capUmi,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.capture_systems (name,version,description,filename,type,umi_id,method,release_id,rel_gene_id,analyse,validation_db,primers_filename)
 			values ('$capture','$capVs','$capDes','$capFile','$capType','$capUmi','$capMeth','$releaseid','$caprelgeneid','$capAnalyse','$capValidation','$capFilePrimers');
  		};
 		return ($dbh->do($sql));
}

sub upCaptureData {
        my ($dbh,$capid,$capture,$capVs,$capDes,$capFile,$capType,$capUmi,$capMeth,$releaseid,$caprelgeneid,$capAnalyse,$capValidation,$capFilePrimers) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set name='$capture',version='$capVs',description='$capDes',filename='$capFile',type='$capType',umi_id='$capUmi',method='$capMeth',release_id='$releaseid',rel_gene_id='$caprelgeneid',analyse='$capAnalyse',validation_db='$capValidation',primers_filename='$capFilePrimers'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

sub upCaptureValidation {
        my ($dbh,$capid,$capAnalyse) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set validation_db='$capAnalyse'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

sub upCaptureFileData {
        my ($dbh,$capid,$capFile) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set filename='$capFile'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

sub upPrimerFileData {
        my ($dbh,$capid,$primerFile) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set primers_filename='$primerFile'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

############ End Capture ###################
############ UMI #######################
sub getUmiId{
        my ($dbh,$umiid)=@_;
		my $query2 = qq {where m.umi_id='$umiid'};
		$query2 = "" unless $umiid;
        my $sql = qq{
			SELECT DISTINCT 
			* 
			FROM PolyprojectNGS.umi m
			$query2			
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

sub getUmiFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT DISTINCT 
		* 
		FROM PolyprojectNGS.umi m		
		where m.name='$name';
		
	};		
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newUMIData {
        my ($dbh,$umi,$mask) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.umi (name,mask) values ('$umi','$mask');
  		};
 		return ($dbh->do($sql));
}
############ End UMI ###################
###### Perspective ####################################################################
sub getPerspectiveId{
        my ($dbh,$persid)=@_;
		my $query2 = qq {where p.perspective_id='$persid'};
		$query2 = "" unless $persid;
        my $sql = qq{
			SELECT DISTINCT 
			* 
			FROM PolyprojectNGS.perspective p
			$query2			
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

sub getPerspectiveFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select p.name as name, p.perspective_id as id  
		FROM PolyprojectNGS.perspective p
		where  p.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newPerspectiveData {
        my ($dbh,$perspective) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.perspective (name) values ('$perspective');
 		};
 		return ($dbh->do($sql));
}
###### Technology ####################################################################
sub getTechnologyId{
        my ($dbh,$techid)=@_;
		my $query2 = qq {where t.technology_id='$techid'};
		$query2 = "" unless $techid;
        my $sql = qq{
			SELECT DISTINCT 
			* 
			FROM PolyprojectNGS.technology t
			$query2			
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

sub getTechnologyFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select t.name as name, t.technology_id as id  
		FROM PolyprojectNGS.technology t
		where  t.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newTechnologyData {
        my ($dbh,$technology) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.technology (name) values ('$technology');
 		};
 		return ($dbh->do($sql));
}

sub getPerspective_Technology {
	my ($dbh,$persid,$techid) = @_;
	my $query = qq{
			SELECT * FROM PolyprojectNGS.perspective_technology
			WHERE perspective_id=? and technology_id=?
			;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute($persid,$techid);
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub addPerspective_Technology {
        my ($dbh,$persid,$techid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.perspective_technology (perspective_id,technology_id) values ($persid,$techid);
        };
        return ($dbh->do($sql));
} 

###### Preparation ####################################################################
sub getPreparationId{
        my ($dbh,$prepid)=@_;
		my $query2 = qq {where r.preparation_id='$prepid'};
		$query2 = "" unless $prepid;
        my $sql = qq{
			SELECT DISTINCT 
			* 
			FROM PolyprojectNGS.preparation r
			$query2			
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

sub getPreparationFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select r.name as name, r.preparation_id as id  
		FROM PolyprojectNGS.preparation r
		where  r.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newPreparationData {
        my ($dbh,$preparation) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.preparation (name) values ('$preparation');
 		};
 		return ($dbh->do($sql));
}

sub getTechnology_Preparation {
	my ($dbh,$techid,$prepid) = @_;
	my $query = qq{
			SELECT * FROM PolyprojectNGS.technology_preparation
			WHERE technology_id=? and preparation_id=?
			;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute($techid,$prepid);
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub addTechnology_Preparation {
        my ($dbh,$techid,$prepid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.technology_preparation (technology_id,preparation_id) values ($techid,$prepid);
        };
        return ($dbh->do($sql));
} 

###### profile ####################################################################
sub getProfile_byId {
        my ($dbh,$profileid)=@_;
 		my $sql2 = qq {where o.profile_id='$profileid'};
 		$sql2 = "" unless $profileid;
        my $sql = qq{        	
			SELECT * FROM PolyprojectNGS.profile o
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

sub getProfile_byName {
	my ($dbh,$profilename) = @_;
	my $query = qq{
			SELECT * FROM PolyprojectNGS.profile
			WHERE name=?
			;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute($profilename);
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub upProfileName {
	my ($dbh,$profilename,$perspectiveid,$technologyid,$preparationid) = @_;
	my $sql = qq{
		update PolyprojectNGS.profile
		set profile.name=?
		where perspective_id='$perspectiveid'
		and technology_id='$technologyid'
		and preparation_id='$preparationid'		
		;
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($profilename);
	$sth->finish;
	return;
} 

sub newProfileData {
	my ($dbh,$persid,$techid,$prepid,$profile) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.profile (perspective_id,technology_id,preparation_id,name)
		values (?,?,?,?);
	};
	my $sthquery = $dbh->prepare($query);
	$sthquery->execute($persid,$techid,$prepid,$profile);
	$sthquery->finish;
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.profile;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub updateProfileData {
	my ($dbh,$persid,$techid,$prepid,$profile,$profileid) = @_;
	my $query = qq{    
		update PolyprojectNGS.profile
		set perspective_id=?, technology_id=?, preparation_id=?,name=?
		where profile_id='$profileid';
	};
	my $sthquery = $dbh->prepare($query);
	$sthquery->execute($persid,$techid,$prepid,$profile);
	$sthquery->finish;
	return;
}

############ Bundle #######################
#PolyprojectNGS.bundle
sub getBundle{
        my ($dbh,$bunid)=@_;
		my $query2 = qq {where b.bundle_id='$bunid'};
		$query2 = "" unless $bunid;
        my $sql = qq{        	
			select b.bundle_id as bundleId,b.name as bunName,
			b.version as bunVs, b.description as bunDes,
			b.creation_date as cDate, b.mesh_id as meshid
			from PolyprojectNGS.bundle b
			$query2;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getBundleFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select b.bundle_id as bundleId,b.name as bunName,
			b.version as bunVs, b.description as bunDes,
			b.creation_date as cDate, b.mesh_id as meshid
			from PolyprojectNGS.bundle b
			where b.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getLastBundle {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(bundle_id) as bundle_id from PolyprojectNGS.bundle;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub newBundleData {
        my ($dbh,$bundle,$bunVs,$bunDes,$meshid) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.bundle (name,version,description,mesh_id) 
 			values ('$bundle','$bunVs','$bunDes','$meshid');
  		};
 		return ($dbh->do($sql));
}

sub newBundle {
        my ($dbh,$bundle,$bunVs,$bunDes,$meshid) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.bundle (name,version,description,mesh_id) 
 			values ('$bundle','$bunVs','$bunDes','$meshid');
  		};
		$dbh->do($sql);
		my $sql2 = qq{    
			SELECT LAST_INSERT_ID() from PolyprojectNGS.bundle;
		};
		my $sth = $dbh->prepare($sql2);
		$sth->execute();
		my $s = $sth->fetchrow_hashref();
		return $s;
}

sub upBundleData {
        my ($dbh,$bunid,$bundle,$bunVs,$bunDes,$meshid) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.bundle
 			set name='$bundle',version='$bunVs',description='$bunDes',mesh_id='$meshid'
 			where bundle_id='$bunid';
  		};
 		return ($dbh->do($sql));
}

sub getBundleFromCapture {
	my ($dbh,$captureid,$exclude) = @_;
	my $query2;
	$query2 = qq {where (cs.capture_id!='$captureid' or cs.capture_id is null)} if $exclude;
	$query2 = qq {where cs.capture_id='$captureid'} unless $exclude;
	my $query = qq{
            select b.bundle_id as bundleId, b.name as bunName, 
            b.description as bunDes, b.version as bunVs,
  			b.creation_date as cDate, b.mesh_id as meshid,
            
            cs.name as capName, cs.capture_id as capId, cs.validation_db as capValidation, 
            cs.method as capMeth, cs.type as capType
			from 
			PolyprojectNGS.bundle b
            LEFT JOIN PolyprojectNGS.capture_bundle cb
            ON cb.bundle_id=b.bundle_id
            LEFT JOIN PolyprojectNGS.capture_systems cs
            ON cb.capture_id=cs.capture_id
            $query2
			GROUP BY b.bundle_id
			;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getBundleCapture {
	my ($dbh,$bundleid) = @_;
	my $query = qq{
			select cs.name, cs.validation_db, cs.method, cs.type
			from 
			PolyprojectNGS.capture_bundle cb,
			PolyprojectNGS.capture_systems cs
			where cb.bundle_id='$bundleid'
			and cb.capture_id=cs.capture_id
			;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub newBundleCapture {
        my ($dbh,$captureid,$bundleid)=@_;
        my $sql = qq{
        	insert into PolyprojectNGS.capture_bundle (capture_id,bundle_id) 
        	values ('$captureid','$bundleid');       	
		};
 		return ($dbh->do($sql));
}

sub delBundleCapture {
        my ($dbh,$captureid,$bundleid)=@_;
        my $sql = qq{
        	DELETE FROM PolyprojectNGS.capture_bundle
        	WHERE capture_id='$captureid'
        	AND bundle_id='$bundleid'
		};
 		return ($dbh->do($sql));
}

############ Bundle Transcript  #######################
sub getBundleTranscriptId {
        my ($dbh,$bunid,$transcriptid)=@_;
 		my $sql2 = qq {and bt.transcript_id='$transcriptid'};
 		$sql2 = "" unless $transcriptid;
        my $sql = qq{        	
			SELECT bt.transcript_id,bt.transmission
			FROM PolyprojectNGS.bundle_transcripts bt
			where bt.bundle_id='$bunid'
			$sql2;
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

sub controleEmptyGeneFromBundleTranscript {
        my ($dbh,$bunid)=@_;
        my $sql = qq{
			SELECT DISTINCT
			GROUP_CONCAT(DISTINCT t.ID ORDER BY t.ID ASC SEPARATOR ',') as 'trId'
			FROM PolyprojectNGS.bundle_transcripts bt
			LEFT JOIN PolyprojectNGS.transcripts t
			ON bt.transcript_id=t.ID
			WHERE bt.bundle_id='$bunid'  and (t.GENE is null or t.GENE="")
			GROUP BY bt.bundle_id
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

sub newBundleTranscript {
	my ($dbh,$transcriptid,$bundleid,$transmission,$btmod)=@_;
	if ($btmod) {
        my $sql = qq{
        	insert into PolyprojectNGS.bundle_transcripts (transcript_id,bundle_id,transmission) 
        	values ('$transcriptid','$bundleid','$transmission');       	
		};
 		return ($dbh->do($sql));
	} else {
        my $sql = qq{
        	insert into PolyprojectNGS.bundle_transcripts (transcript_id,bundle_id) 
        	values ('$transcriptid','$bundleid');       	
		};
 		return ($dbh->do($sql));
	}
}

sub upBunTranscriptTransmission {
        my ($dbh,$bundleid,$tid,$transmission) = @_;
        my $sql = qq{
        	update PolyprojectNGS.bundle_transcripts
 			set transmission='$transmission'
        	where bundle_id='$bundleid' 
        	and transcript_id='$tid';
        };
        return ($dbh->do($sql));
}

sub removeBundleTranscript {
#	my ($dbh,$tid) = @_;
	my ($dbh,$bunid,$tid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.bundle_transcripts
		where transcript_id='$tid'
		and bundle_id='$bunid';
	};
 	return ($dbh->do($sql));
}

############ Transcript  #######################
sub getTranscript {
        my ($dbh,$transcriptid)=@_;
        my $sql = qq{        	
			SELECT t.id, t.ensembl_id, t.gene, t.transmission
			FROM PolyprojectNGS.transcripts t
			where id='$transcriptid';
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}
sub getGeneTranscript {
        my ($dbh,$transcriptid)=@_;
        my $sql = qq{        	
			SELECT GENE FROM PolyprojectNGS.transcripts where ID = "$transcriptid";
		};
		return $dbh->selectrow_array($sql);
}

sub getTranscriptId {
        my ($dbh,$transcript)=@_;
        my $sql = qq{        	
			SELECT ID FROM PolyprojectNGS.transcripts where ENSEMBL_ID = "$transcript";
		};
		return $dbh->selectrow_array($sql);
}

sub getTranscriptFromCapture {
        my ($dbh,$capid)=@_;
        my $sql = qq{        	
		SELECT 
		t.ensembl_id,t.gene
		FROM PolyprojectNGS.capture_systems cs
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON cs.capture_id=cb.capture_id
		LEFT JOIN PolyprojectNGS.bundle_transcripts bt
		ON cb.bundle_id=bt.bundle_id
		LEFT JOIN PolyprojectNGS.transcripts t
		ON bt.transcript_id=t.ID
		WHERE
		cs.capture_id="$capid";		
        };
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub newTranscriptData {
	my ($dbh,$transcriptid,$transmission,$tmod) = @_;
	if ($tmod) {
        my $query = qq{
        	insert into  PolyprojectNGS.transcripts (ENSEMBL_ID,transmission)
        	values ('$transcriptid','$transmission')
        };
 		$dbh->do($query);
	} else {
        my $query = qq{
        	insert into  PolyprojectNGS.transcripts (ENSEMBL_ID)
        	values ('$transcriptid')
        };
 		$dbh->do($query);
	}    
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.transcripts;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upTranscriptTransmission {
        my ($dbh,$tid,$transmission) = @_;
        my $sql = qq{
        	update PolyprojectNGS.transcripts
 			set transmission='$transmission'
        	where id='$tid';
        };
        return ($dbh->do($sql));
} 

sub delTranscript {
	my ($dbh,$tid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.transcripts
		where id='$tid';
	};
 	return ($dbh->do($sql));
}

############# End Bundle ###################
########### Patient #######################

sub getPatientName {
	my ($dbh,$patid) = @_;
	my $query = qq{
		select a.name as name
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{name};	
}

sub getPatientId {
	my ($dbh,$patname) = @_;
	my $query = qq{
		select a.patient_id
		FROM PolyprojectNGS.patient a
		where a.name='$patname';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{patient_id};	
}

sub getPatient_byPatientId {
	my ($dbh,$patid) = @_;
	my $query = qq{
		select *
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getProjectPatientId {
	my ($dbh,$patname,$pid) = @_;
	my $query = qq{
		select a.patient_id
		FROM PolyprojectNGS.patient a
		where a.name='$patname'
		and a.project_id='$pid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{patient_id};	
}

sub getPatientInfo {
	my ($dbh,$patid) = @_;
	my $query = qq{
		select  *
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getPatientsFromProject {
	my ($dbh,$pid,$patid) = @_;
	my @patid=$patid;
	my $query2 = qq {and a.patient_id in (@patid)};
	$query2 = "" unless $patid;
	my $query = qq{
		select a.name as name, a.patient_id
		FROM PolyprojectNGS.patient a
		where a.project_id='$pid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatientInfoFromProjectWithDate {
	my ($dbh,$Edate,$Bdate,$pid) = @_;
	my $query = qq{
        SELECT
        a.patient_id,
        a.name as name,
        r.run_id,
 		C.name as capName,
 		C.analyse as capAnalyse,
        GROUP_CONCAT(DISTINCT S.name ORDER BY S.name ASC SEPARATOR ' ') as 'macName',
        GROUP_CONCAT(DISTINCT f.name ORDER BY f.name ASC SEPARATOR ' ') as 'plateformName',
        GROUP_CONCAT(DISTINCT ms.name ORDER BY ms.name ASC SEPARATOR ' ') as 'methSeqName',
        GROUP_CONCAT(DISTINCT case M.type when 'ALIGN' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methAln',
        GROUP_CONCAT(DISTINCT case M.type when 'SNP' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methCall'
        FROM PolyprojectNGS.patient a
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
     
        LEFT JOIN PolyprojectNGS.capture_systems C
        ON a.capture_id=C.capture_id

		WHERE a.project_id = '$pid'
		and r.creation_date between '$Edate' and DATE_ADD('$Bdate', INTERVAL 1 DAY)
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
=mod
AV			AP
1=> Exome		1=> All
2=> Genome		2=> Exome
3=> Target		3=> Genome
4=> RNAseq		4=> Target
5=> All			5=> RNAseq

	#all 1
	$query2 = qq {where C.analyse not in ("")} if $numAnalyse == 1;
	#exome 2
	$query2 = qq {where C.analyse in ("exome")} if $numAnalyse == 2;
	#genome 3
	$query2 = qq {where C.analyse in ("genome")} if $numAnalyse == 3;
	#target 4
	$query2 = qq {where C.analyse not in ("exome","genome","rnaseq")} if $numAnalyse == 4;
	#rnaseq 5
	$query2 = qq {where C.analyse ="rnaseq"} if $numAnalyse == 5;
=cut

#les 2 versions sont temporaireemnt conservé
sub getPatientInfoFromProject {
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

sub getPatientsFromRun {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatientIdFromRun {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.patient_id
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatName {
	my ($dbh,$pat_name) = @_;
	$pat_name =~ s/\s+//; 
	my $query2 = qq {where a.name REGEXP '$pat_name'};
	$query2 = "" unless $pat_name;
	my $query = qq{
		select distinct a.name as name
		FROM PolyprojectNGS.patient a
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}	
	return \@res if \@res;
}

sub getPatNameInfo {
	my ($dbh,$pat_name) = @_;
	$pat_name =~ s/\s+//; 
	my $query = qq{
		SELECT DISTINCT a.run_id as runid, a.project_id as projid,
		a.project_id_dest as projiddest,		
		P.name as ProjName
		FROM PolyprojectNGS.patient a,
		PolyprojectNGS.projects P
		WHERE 
		a.name REGEXP '^$pat_name\$' and 
		(a.project_id=P.project_id or a.project_id_dest=P.project_id);
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}	
	return \@res if \@res;
}

sub getPatNameNoProjInfo {
	my ($dbh,$pat_name) = @_;
	my $query = qq{
		SELECT DISTINCT a.run_id as runid, a.project_id as projid,
		a.project_id_dest		
		FROM PolyprojectNGS.patient a
		where
		a.name REGEXP '^$pat_name\$' and 
		a.project_id=0 and a.project_id_dest=0;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}	
	return \@res if \@res;
}

sub getPatientsInfoFromRunNoCapture {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id,a.project_id,a.run_id,a.capture_id,
		a.family,a.father,a.mother,a.flowcell,
		a.bar_code,a.sex,a.status,a.description,a.creation_date as cDate
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatientsInfoProjectDest {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id_dest='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id,a.project_id_dest,a.run_id,a.capture_id,
		a.family,a.father,a.mother,a.flowcell,
		a.control,a.type,a.grna,
		a.bar_code,a.identity_vigilance,a.identity_vigilance_vcf,
		a.sex,a.status,a.description,a.creation_date as cDate,
		a.project_id,a.profile_id,a.species_id
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPatientsInfoFromRun {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id,a.project_id,a.run_id,a.capture_id,
		a.bar_code,a.sex,a.status,a.description,a.creation_date as cDate,
		C.name as capName
		FROM PolyprojectNGS.patient a, PolyprojectNGS.capture_systems C
		where a.run_id='$rid'
		and a.capture_id=C.capture_id
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getProjectDest {
	my ($dbh,$rid,$patid) = @_;
	my $query2 = qq {and a.patient_id='$patid'};
	$query2 = "" unless $patid;
	my $query = qq{
		select distinct a.project_dest
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUniqProjectRunFromPatient {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select distinct a.project_id,a.run_id
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getRunFromPatientProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		select a.name as name, a.patient_id as id, a.run_id
		FROM PolyprojectNGS.patient a
		where a.project_id='$pid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientProject {
	my ($dbh,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id as id, a.run_id,a.project_id,
		a.project_id_dest, a.sex,
		( case  when a.project_id>0 && a.project_id_dest = 0 then p.name
                when a.project_id>0 && a.project_id_dest > 0 then p.name
                when a.project_id=0 && a.project_id_dest > 0 then pd.name
                when a.project_id=0 && a.project_id_dest = 0 then 'NGSRun'
                else 'NGSRun'
 		end ) as 'projname'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id=p.project_id
		LEFT JOIN PolyprojectNGS.projects pd
		ON a.project_id_dest=pd.project_id
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientProjectWithDate {
	my ($dbh,$Edate,$Bdate,$pid) = @_;
	my $query2 = qq {and a.project_id='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id as id, a.run_id,a.project_id,a.project_id_dest, a.sex
		FROM
		PolyprojectNGS.patient a,
		PolyprojectNGS.run r
        WHERE
        a.run_id=r.run_id
		and r.creation_date between '$Edate' and DATE_ADD('$Bdate', INTERVAL 1 DAY)
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientProjectDest {
	my ($dbh) = @_;
	my $query = qq{
		select a.name as name, a.patient_id as id, a.run_id,a.project_id,a.project_id_dest, a.sex
		FROM PolyprojectNGS.patient a
		where a.project_id_dest>0
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientProjectInfo {
	my ($dbh,$pid,$rid) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT distinct a.project_id,a.run_id,a.name,a.patient_id,
		a.project_id_dest,a.family,a.father,a.mother,a.sex,a.status,
		a.bar_code,a.identity_vigilance,a.identity_vigilance_vcf,
		a.flowcell,a.control,a.type,a.grna,a.profile_id,a.species_id,
		r.description as desRun, r.document,r.name as nameRun,
		r.file_name as FileName,r.file_type as FileType,		
		S.name as macName,
       	GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		ms.name as methSeqName,
		C.name as capName,
		C.analyse as capAnalyse,
		a.creation_date as cDate
		FROM PolyprojectNGS.patient a,
		PolyprojectNGS.run r,
		PolyprojectNGS.run_machine rm,
		PolyprojectNGS.sequencing_machines S,
		PolyprojectNGS.run_plateform rp,
		PolyprojectNGS.plateform f,
		PolyprojectNGS.run_method_seq rs,
		PolyprojectNGS.method_seq ms,
		PolyprojectNGS.capture_systems C
		where a.project_id='$pid'
		and a.run_id=r.run_id
		and r.run_id=rm.run_id
		and rm.machine_id=S.machine_id
		and r.run_id=rp.run_id
		and rp.plateform_id=f.plateform_id
		and r.run_id=rs.run_id
		and rs.method_seq_id=ms.method_seq_id
		and a.capture_id=C.capture_id
		$query2		
       	group by a.patient_id
		order by a.run_id;	
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientProjectRunInfo {
	my ($dbh,$pid,$rid) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT distinct a.project_id,a.run_id,
		r.name,r.description as desRun,r.ident_seq,r.nbrun_solid,
		r.creation_date as cDate
		FROM PolyprojectNGS.patient a,
		PolyprojectNGS.run r
		where a.project_id='$pid'
		and a.run_id=r.run_id
		$query2		
		order by a.run_id;	
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getPatientPhenotype {
	my ($dbh,$patid)=@_;
	my $sql2 = qq {where  ha.patient_id='$patid'};
	$sql2 = "" unless $patid;
	my $sql = qq{
		SELECT distinct
-- 		ha.phenotype_id,
-- 		ha.patient_id,
		hh.name
		FROM PolyPhenotypeDB.phenotype_patient ha
		LEFT JOIN PolyPhenotypeDB.phenotype hh
		ON ha.phenotype_id =hh.phenotype_id		
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

sub getPatientGroup {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT DISTINCT pg.patient_id,g.name,g.group_id
		FROM 
		PolyprojectNGS.patient_groups pg,
		PolyprojectNGS.group g
		where pg.patient_id='$patid'
		and pg.group_id=g.group_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upgRun {
        my ($dbh,$runid,$gmachine,$grun) = @_;
        my $sql = qq{
        	update PolyprojectNGS.run
        	set ident_seq='$gmachine', nbrun_solid='$grun' 
        	where run_id='$runid';
        };
        return ($dbh->do($sql));
} 

sub upPatientCapture {
        my ($dbh,$patid,$runid,$capid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set capture_id='$capid' 
        	where patient_id='$patid'
        	and run_id='$runid';
        };
        return ($dbh->do($sql));
} 

sub upPatientCaptureOnly {
        my ($dbh,$patid,$capid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set capture_id='$capid' 
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
} 

sub upPatientProject {
        my ($dbh,$patid,$pid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set project_id='$pid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientBCG {
        my ($dbh,$patid,$iv) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set identity_vigilance='$iv'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientControl {
        my ($dbh,$patid,$control) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set control='$control'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientProfile {
        my ($dbh,$patid,$profileid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set profile_id='$profileid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientSpecies {
        my ($dbh,$patid,$speciesid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set species_id='$speciesid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}


sub remPatientProject {
        my ($dbh,$patid,$pid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set project_id=0
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}
 
sub upPatientProjectDest {
        my ($dbh,$patid,$pid,$genboid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set project_id_dest='$pid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
} 

sub addPatientProjectDest {
        my ($dbh,$patname,$origin,$rid,$pid) = @_;
        my $query = qq{
        	insert into  PolyprojectNGS.patient (name,origin,run_id,project_id_dest)
        	values ('$patname','$origin','$rid','$pid')
        };
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub addPatientProject {
        my ($dbh,$patname,$origin,$rid,$pid) = @_;
        my $query = qq{
        	insert into  PolyprojectNGS.patient (name,origin,run_id,project_id_dest)
        	values ('$patname','$origin','$rid','$pid')
        };
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub upPatientName {
        my ($dbh,$patid,$patname) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set name='$patname'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientDest {
        my ($dbh,$patid,$dest) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set project_id_dest='$dest'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientSex {
        my ($dbh,$patid,$sex) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set sex='$sex'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
}

sub upPatientInfo {
        my ($dbh,$patid,$patname,$sex,$status,$desPat,$bc,$bc2,$iv,$flowcell,$family,$father,$mother,$capid,$type) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set name='$patname', sex='$sex',status='$status',description='$desPat',bar_code='$bc',bar_code2='$bc2',identity_vigilance='$iv',
        	flowcell='$flowcell',family='$family',father='$father',mother='$mother',capture_id='$capid',type='$type'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
} 

sub upPatientRun {
	my ($dbh,$runid,$patid,$param) = @_;
	my @opt = split(/ /,$param);
	my $set;

	my $v0;
	my $v1;
	my $v2;
	my $v3;
	my $v4;
	my $v5;
	my $v6;
	my $v7;
	
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
		$v6=$val[1] if $i==6;
		$v6="" if ($i==6 && !defined $val[1]);
		$v7=$val[1] if $i==7;
		$v7="" if ($i==7 && !defined $val[1]);
		$nb++;
	};
	chop($set);
	my $sql = qq{
		update PolyprojectNGS.patient
		set $set
		where run_id='$runid'
		and patient_id='$patid';
	};
	my $sth= $dbh->prepare($sql);				

	$sth->execute($v0) if $nb==1;
	$sth->execute($v0,$v1) if $nb==2;
	$sth->execute($v0,$v1,$v2) if $nb==3;
	$sth->execute($v0,$v1,$v2,$v3) if $nb==4;
	$sth->execute($v0,$v1,$v2,$v3,$v4) if $nb==5;
	$sth->execute($v0,$v1,$v2,$v3,$v4,$v5) if $nb==6;
	$sth->execute($v0,$v1,$v2,$v3,$v4,$v5,$v6) if $nb==7;
	$sth->execute($v0,$v1,$v2,$v3,$v4,$v5,$v6,$v7) if $nb==8;
	$sth->finish;
	return;
} 

sub addPatientInfo {
        my ($dbh,$patname,$patname,$rid,$sex,$status,$desPat,$bc,$iv,$flowcell,$family,$father,$mother,$capid,$pid) = @_;
        my $query = qq{
        	insert into  PolyprojectNGS.patient (name,origin,run_id,sex,status,description,bar_code,identity_vigilance,flowcell,family,father,mother,capture_id,project_id_dest)
        	values ('$patname','$patname','$rid','$sex','$status','$desPat','$bc','$iv','$flowcell','$family','$father','$mother','$capid','$pid')
        };
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub upPatientPedigree {
        my ($dbh,$projectid,$patname,$family,$father,$mother,$sex,$status) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
 			set family='$family',father='$father',mother='$mother',sex='$sex',status='$status'
        	where project_id='$projectid'
        	and name = '$patname';
        };
        return ($dbh->do($sql));
} 

sub getFreePatientsRun {
	my ($dbh) = @_;
	my $query = qq{
		SELECT a.patient_id, a.name, a.run_id, a.capture_id
		FROM PolyprojectNGS.patient a
		where project_id=0;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getFreePatientId {
	my ($dbh,$rid,$patid) = @_;
	my $query = qq{
		SELECT a.patient_id
		FROM PolyprojectNGS.patient a
		WHERE a.project_id=0
        AND a.run_id='$rid'
        AND a.patient_id='$patid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getFreeRunIdfromPatient {
	my ($dbh,$rid) = @_;
	my $query = qq{
		SELECT a.run_id
		FROM PolyprojectNGS.patient a
		WHERE a.project_id=0
        AND a.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getRunIdfromPatient {
	my ($dbh,$rid) = @_;
	my $query = qq{
		SELECT a.run_id
		FROM PolyprojectNGS.patient a
		WHERE a.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub ctrlProjectPatientName {
	my ($dbh,$pid,$patname) = @_;
	$patname =~ s/\s+//; 
	my $query = qq{
		SELECT a.patient_id
		FROM PolyprojectNGS.patient a
		WHERE a.project_id='$pid'
		AND a.name='$patname';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub ctrlPatientNameInRun {
	my ($dbh,$patname) = @_;
	my $query = qq{
		SELECT  a.name, a.project_id,a.run_id
		FROM 
		PolyprojectNGS.patient a
		where a.name like '$patname'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getProjectNamefromPatient{
	my ($dbh,$rid,$pid) = @_;
	my $query = qq{
		SELECT distinct p.name
		FROM 
		PolyprojectNGS.patient a,
		PolyprojectNGS.projects p
		where a.run_id='$rid'
		and a.project_id='$pid'
		and a.project_id=p.project_id
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delFreePatientId {
        my ($dbh,$rid,$patid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.patient
			WHERE project_id=0
			AND run_id='$rid'
        	AND patient_id='$patid';
 		};
 		return ($dbh->do($sql));
}

sub delFreeRun {
        my ($dbh,$rid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.run
			WHERE run_id='$rid';
 		};
 		return ($dbh->do($sql));
}

sub delFreeRunMethSeq {
        my ($dbh,$rid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.run_method_seq
			WHERE run_id='$rid';
 		};
 		return ($dbh->do($sql));
}

sub delFreeRunPlateform {
        my ($dbh,$rid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.run_plateform
			WHERE run_id='$rid';
 		};
 		return ($dbh->do($sql));
}

sub delFreeRunMachine {
        my ($dbh,$rid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.run_machine
			WHERE run_id='$rid';
 		};
 		return ($dbh->do($sql));
}

############ End Patient ###################
############ Run ###########################
sub getRunId {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select r.run_id
		FROM PolyprojectNGS.run r
		where r.run_id='$rid';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getRunInfoFromRunDate {
	my ($dbh,$Edate,$Bdate) = @_;	
	my $query = qq{
		SELECT 
		r.run_id, r.creation_date as cDate
		FROM PolyprojectNGS.run r
		WHERE r.creation_date
		BETWEEN '$Edate' AND DATE_ADD('$Bdate', INTERVAL 1 DAY)
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getRunInfoFromRun {
	my ($dbh,$rid) = @_;
	my $query2 = qq {where r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT 
		r.run_id, r.creation_date as cDate
		FROM PolyprojectNGS.run r
		$query2
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getRunInfo {
	my ($dbh,$rid,$pltid) = @_;
	my $query2 = qq {and r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query3 = qq {and rp.plateform_id='$pltid'};
	$query3 = "" unless $pltid;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient,
		r.file_name as FileName,r.file_type as FileType,
		r.ident_seq as gMachine,r.nbrun_solid as gRun,
		r.creation_date as cDate,r.step,r.plateform_run_name as pltRun,
		S.name as macName,
		ms.name as methSeqName,
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName'
		FROM 
		PolyprojectNGS.run r,
		PolyprojectNGS.run_plateform rp, PolyprojectNGS.plateform f,
		PolyprojectNGS.run_machine rm, PolyprojectNGS.sequencing_machines S,
		PolyprojectNGS.run_method_seq rs,PolyprojectNGS.method_seq ms
		WHERE
		r.run_id=rp.run_id
		and rp.plateform_id=f.plateform_id
		and r.run_id=rm.run_id
		and rm.machine_id=S.machine_id
		and r.run_id=rs.run_id
		and rs.method_seq_id=ms.method_seq_id
		$query2
		$query3
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

=mod
AV			AP
1=> Exome		1=> All
2=> Genome		2=> Exome
3=> Target		3=> Genome
4=> RNAseq		4=> Target
5=> All			5=> RNAseq
=cut

sub getAllRunInfo {
	my ($dbh,$numAnalyse,$rid) = @_;
	my $query2;
	#all 1
	$query2 = qq {where C.analyse not in ("")} if $numAnalyse == 1;
	#exome 2
	$query2 = qq {where C.analyse in ("exome")} if $numAnalyse == 2;
	#genome 3
	$query2 = qq {where C.analyse in ("genome")} if $numAnalyse == 3;
	#target 4
	$query2 = qq {where C.analyse not in ("exome","genome","rnaseq","singlecell")} if $numAnalyse == 4;
	#rnaseq 5
	$query2 = qq {where C.analyse ="rnaseq"} if $numAnalyse == 5;
	#rnaseq 6
	$query2 = qq {where C.analyse ="singlecell"} if $numAnalyse == 6;

	my $query3 = qq {and r.run_id='$rid'};
	$query3 = "" unless $rid;
	my $query = qq{
	SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient as 'nbpatRun',
		r.creation_date as cDate,r.plateform_run_name as pltRun,
		S.name as macName,
		ms.name as methSeqName,
		R.name as capRel,
		rr.name as projRel,        
--        pp.project_id as 'pprojid',
--        pp.version_id as 'pversionid',
 		GROUP_CONCAT(DISTINCT pp.version_id ORDER BY pp.version_id  SEPARATOR ' ') as 'ppversionid',
--       pg.project_id as 'gprojid',        
 		GROUP_CONCAT(DISTINCT rg.name ORDER BY rg.name  SEPARATOR ' ') as 'relGene',
-- 		rg.name as 'relGene',
     
-- 		GROUP_CONCAT(DISTINCT ra.name ORDER BY ra.name  SEPARATOR ' ') as 'projRelAnnot',
		GROUP_CONCAT(distinct if (p.somatic=1,1,null)) as 'somatic',
		GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ',') as 'patName',
		GROUP_CONCAT(DISTINCT a.bar_code ORDER BY a.bar_code ASC SEPARATOR ',') as 'patBC',
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		GROUP_CONCAT(DISTINCT C.capture_id ORDER BY C.capture_id ASC SEPARATOR ' ') as 'capId',
		GROUP_CONCAT(DISTINCT C.name ORDER BY C.name ASC SEPARATOR ' ') as 'capName',
		GROUP_CONCAT(DISTINCT C.analyse ORDER BY C.analyse ASC SEPARATOR ' ') as 'capAnalyse',
		GROUP_CONCAT(DISTINCT C.validation_db ORDER BY C.validation_db ASC SEPARATOR ' ') as 'capValidation',
		GROUP_CONCAT(DISTINCT C.method ORDER BY C.method ASC SEPARATOR ' ') as 'capMeth',
		GROUP_CONCAT(DISTINCT p.project_id ORDER BY p.project_id DESC SEPARATOR ' ') as 'ProjectId',
       	GROUP_CONCAT(DISTINCT p.name ORDER BY p.name DESC SEPARATOR ' ') as 'ProjectName',
		GROUP_CONCAT(DISTINCT pd.project_id ORDER BY pd.project_id DESC SEPARATOR ' ') as 'ProjectDestId',
		GROUP_CONCAT(DISTINCT pd.name ORDER BY pd.name DESC SEPARATOR ' ') as 'ProjectDestName',
        count(distinct if (a.project_id > 0,a.patient_id,null)) as 'nbPrjRun',
        GROUP_CONCAT(DISTINCT case M.type when 'ALIGN' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methAln',
        GROUP_CONCAT(DISTINCT case M.type when 'SNP' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methCall',
        count(distinct case M.type when 'ALIGN' THEN pm.patient_id ELSE NULL END ) as 'nbAln',
        count(distinct case M.type when 'SNP' THEN pm.patient_id ELSE NULL END ) as 'nbCall',
    	GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable ASC SEPARATOR ' ') as 'username',
		GROUP_CONCAT(DISTINCT ug.name ORDER BY ug.name ASC SEPARATOR ' ') as 'usergroup'

		FROM 
		PolyprojectNGS.run r
        LEFT JOIN PolyprojectNGS.patient a
        ON r.run_id = a.run_id

		LEFT JOIN PolyprojectNGS.run_plateform rp
        ON r.run_id=rp.run_id

        LEFT JOIN PolyprojectNGS.plateform f
        ON rp.plateform_id=f.plateform_id

        LEFT JOIN PolyprojectNGS.run_machine rm
        ON r.run_id = rm.run_id

        LEFT JOIN PolyprojectNGS.sequencing_machines S
        ON rm.machine_id=S.machine_id

        LEFT JOIN PolyprojectNGS.run_method_seq rs
        ON r.run_id=rs.run_id

        LEFT JOIN PolyprojectNGS.method_seq ms
        ON rs.method_seq_id=ms.method_seq_id

		LEFT JOIN PolyprojectNGS.capture_systems C
        ON a.capture_id=C.capture_id
        
 		LEFT JOIN PolyprojectNGS.releases R
        ON C.release_id=R.release_id

 		LEFT JOIN PolyprojectNGS.patient_methods pm
		ON a.patient_id = pm.patient_id

		LEFT JOIN PolyprojectNGS.methods M
		ON pm.method_id=M.method_id
 
 		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id

		LEFT JOIN PolyprojectNGS.projects pd
		ON a.project_id_dest = pd.project_id
          
        LEFT JOIN PolyprojectNGS.user_projects up
		ON a.project_id = up.project_id
        LEFT JOIN bipd_users.`USER` U
		ON up.user_id=U.user_id

 		LEFT JOIN PolyprojectNGS.ugroup_projects gp
    	ON a.project_id = gp.project_id
 		LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id
 
 		LEFT JOIN PolyprojectNGS.project_release_public_database pp
		ON p.project_id = pp.project_id
        
 		LEFT JOIN PolyprojectNGS.project_release_gene pg
		ON p.project_id = pg.project_id
        
 		LEFT JOIN PolyprojectNGS.release_gene rg
        ON rg.rel_gene_id=pg.rel_gene_id
        
 --   	LEFT JOIN PolyprojectNGS.release_public_database rd
 -- 		ON pp.version_id = rd.version_id
		
-- 	LEFT JOIN PolyprojectNGS.project_release_annotation pa
-- 		ON p.project_id = pa.project_id
 
-- 		LEFT JOIN PolyprojectNGS.release_annotation ra
-- 		ON pa.rel_annot_id = ra.rel_annot_id
		
 		LEFT JOIN PolyprojectNGS.project_release pr
		ON p.project_id = pr.project_id
 
 		LEFT JOIN PolyprojectNGS.releases rr
		ON pr.release_id = rr.release_id

		$query2
		$query3
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
#		print ".";
		 push(@res,$id);
	}
	return \@res;
}

#		GROUP_CONCAT(DISTINCT a.patient_id ORDER BY a.patient_id ASC SEPARATOR ',') as 'patId',
# 		count(distinct if (a.project_id > 0,a.patient_id,null)) as 'nbPrjRun',
sub getAllqRunInfo {
	my ($dbh,$rid) = @_;
	my $query2 = qq {where r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
	SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient as 'nbpatRun',
		r.creation_date as cDate,r.plateform_run_name as pltRun,
		r.step,
		GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ',') as 'patName',
		GROUP_CONCAT(DISTINCT a.g_project ORDER BY g_project ASC SEPARATOR ',') as 'Gproject',
		GROUP_CONCAT(DISTINCT if (a.origin_patient_id = 0,a.patient_id,null) ORDER BY a.patient_id ASC SEPARATOR ',') as 'patId',
		GROUP_CONCAT(DISTINCT a.bar_code ORDER BY a.bar_code ASC SEPARATOR ',') as 'patBC',
		GROUP_CONCAT(DISTINCT sp.code ORDER BY sp.code ASC SEPARATOR ' ') as 'spCode',		
		count(distinct case when a.project_id > 0 and a.origin_patient_id = 0 then a.patient_id else null end ) as 'nbPrjRun',
		GROUP_CONCAT(DISTINCT a.project_id ORDER BY a.project_id ASC SEPARATOR ',') as 'projectId',
		GROUP_CONCAT(DISTINCT a.project_id_dest ORDER BY a.project_id_dest ASC SEPARATOR ',') as 'projectDestId'
		
		FROM 
		PolyprojectNGS.run r
  
		LEFT JOIN PolyprojectNGS.patient a
        ON r.run_id = a.run_id
        LEFT JOIN PolyprojectNGS.species sp
        ON a.species_id = sp.species_id
        
--    	LEFT JOIN PolyprojectNGS.databases_projects dp
--    	ON a.project_id =dp.project_id
-- 		WHERE dp.db_id=4
		$query2
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
#Eviter time out mais ne marche plus
#		print ".";
		 push(@res,$id);
	}
	return \@res;
}

sub getRunFileInfo {
	my ($dbh,$rid) = @_;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,
		r.file_name as FileName,r.file_type as FileType
		FROM 
		PolyprojectNGS.run r
		WHERE r.run_id='$rid'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getRunInfoWithDate {
	my ($dbh,$Edate,$Bdate,$rid,$pltid) = @_;
	my $query2 = qq {and r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query3 = qq {and rp.plateform_id='$pltid'};
	$query3 = "" unless $pltid;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient,
		r.file_name as FileName,r.file_type as FileType,
		r.ident_seq as gMachine,r.nbrun_solid as gRun,
		r.creation_date as cDate,r.step,r.plateform_run_name as pltRun,
		S.name as macName,
		ms.name as methSeqName,
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName'
		FROM 
		PolyprojectNGS.run r,
		PolyprojectNGS.run_plateform rp, PolyprojectNGS.plateform f,
		PolyprojectNGS.run_machine rm, PolyprojectNGS.sequencing_machines S,
		PolyprojectNGS.run_method_seq rs,PolyprojectNGS.method_seq ms
		WHERE
		r.run_id=rp.run_id
		and r.creation_date between '$Edate' and DATE_ADD('$Bdate', INTERVAL 1 DAY)
		and rp.plateform_id=f.plateform_id
		and r.run_id=rm.run_id
		and rm.machine_id=S.machine_id
		and r.run_id=rs.run_id
		and rs.method_seq_id=ms.method_seq_id
		$query2
		$query3
		group by r.run_id
		order by r.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub getNBProjectRun{
        my ($dbh,$rid)=@_;
        my $sql = qq{
		SELECT DISTINCT
		count(a.patient_id) as nb
		 		FROM 
		PolyprojectNGS.patient a
		WHERE
		a.project_id>0
		and a.run_id='$rid';
		};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res;
}

sub getProjectInfoFromRid{
        my ($dbh,$rid)=@_;
        my $sql = qq{
		SELECT DISTINCT
		r.run_id,
		GROUP_CONCAT(DISTINCT p.project_id ORDER BY p.project_id DESC SEPARATOR ' ') as 'ProjectId',
       	GROUP_CONCAT(DISTINCT p.name ORDER BY p.name DESC SEPARATOR ' ') as 'ProjectName',
		GROUP_CONCAT(DISTINCT p.somatic  ORDER BY p.somatic DESC SEPARATOR ' ') as 'SomaticProject'
 		FROM 
		PolyprojectNGS.run r,
		PolyprojectNGS.patient a,
        PolyprojectNGS.projects p
		WHERE
		r.run_id='$rid'
		and r.run_id=a.run_id
		and a.project_id=p.project_id;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getProjectDestInfoFromRid{
        my ($dbh,$rid)=@_;
        my $sql = qq{
		SELECT distinct 
		a.run_id,
		GROUP_CONCAT(DISTINCT p.project_id ORDER BY p.project_id DESC SEPARATOR ' ') as 'ProjectDestId',
		GROUP_CONCAT(DISTINCT p.name ORDER BY p.name DESC SEPARATOR ' ') as 'ProjectDestName'
		FROM 
		PolyprojectNGS.patient a,
		PolyprojectNGS.projects p
		where a.run_id='$rid'
		and a.project_id_dest=p.project_id;		
        };
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub ctrlFreeRid{
        my ($dbh,$rid)=@_;
        my $sql = qq{
		SELECT DISTINCT 
		a.project_id
		FROM PolyprojectNGS.patient a
		WHERE
		a.run_id='$rid'
		and a.project_id=0;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub newRun {
	my ($dbh,$type,$desrun,$name,$pltname,$nbpat) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.run (type_run_id,description,name,plateform_run_name,nbpatient) values ($type,"$desrun","$name","$pltname",$nbpat);
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.run;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub getLastRun {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(run_id) as run_id from PolyprojectNGS.run;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub addMachine2run {
        my ($dbh,$machineid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_machine (machine_id,run_id) values ($machineid,$rid);
        };
        return ($dbh->do($sql));
} 

sub addMethSeq2run {
        my ($dbh,$methseqid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_method_seq  (method_seq_id,run_id) values ($methseqid,$rid);
        };
        return ($dbh->do($sql));
} 

sub upMachine2run {
	my ($dbh,$rid,$machineid) = @_;
	my $sql = qq{
		update PolyprojectNGS.run_machine
		set machine_id=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($machineid);
	$sth->finish;
	return;
} 

sub upMethSeq2run {
	my ($dbh,$rid,$methseqid) = @_;
	my $sql = qq{
		update PolyprojectNGS.run_method_seq
		set method_seq_id=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($methseqid);
	$sth->finish;

	return;
} 

# addPatientRun with no pid (project_id)
sub addPatientRun {
	my ($dbh,$patient,$origin,$rid,$captureid,$fam,$sex,$status,$desPat,$bc) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,run_id,capture_id,family,sex,status,description,bar_code) 
 		values ("$patient","$origin","$rid","$captureid","$fam","$sex","$status","$desPat","$bc");
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;

} 

sub newPatientRun {
	my ($dbh,$patient,$origin,$rid,$captureid,$fam,$fc,$bc,$bc2,$iv,$father,$mother,$sex,$status,$type,$speciesid,$profileid) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,run_id,capture_id,family,flowcell,bar_code,bar_code2,identity_vigilance,father,mother,sex,status,type,species_id,profile_id) 
 		values ("$patient","$origin","$rid","$captureid","$fam","$fc","$bc","$bc2","$iv","$father","$mother","$sex","$status","$type","$speciesid","$profileid");
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.patient;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub isPatientMethod {
	my ($dbh,$patientid,$methodid) = @_;
	my $query = qq{
		SELECT DISTINCT 
		patient_id,method_id  
		FROM PolyprojectNGS.patient_methods
		where patient_id='$patientid'
		and method_id='$methodid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub addMeth2pat {
	my ($dbh,$patid,$methodid) = @_;
	my $query = qq{
		insert into PolyprojectNGS.patient_methods (patient_id,method_id) values ('$patid','$methodid');
	};
    return ($dbh->do($query));
}

sub delMeth2pat {
        my ($dbh,$patid,$methodid)=@_;
        my $sql = qq{
        	DELETE FROM PolyprojectNGS.patient_methods
        	WHERE patient_id='$patid'
        	AND method_id='$methodid'
		};
 		return ($dbh->do($sql));
}

sub getPatIdfromName {
	my ($dbh,$name,$runid) = @_;
	my $query = qq{
		select a.patient_id
		FROM PolyprojectNGS.patient a
		where a.name='$name'
		and a.run_id='$runid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{patient_id};	
}

sub upStep2run {
	my ($dbh,$rid,$step) = @_;
	my $sql = qq{
		update PolyprojectNGS.run
		set step=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($step);
	$sth->finish;

	return;
} 

sub upNbPat2run {
	my ($dbh,$rid,$nbpat) = @_;
	my $sql = qq{
		update PolyprojectNGS.run
		set nbpatient=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($nbpat);
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

sub upRunDocument {
	my ($dbh,$rid,$filename,$filetype,$data) = @_;
	my $data2 =undef;
	$data2 = connect::compressData($data) if $data;
	warn "zzzzdata2" if $data;
	my $sql = qq{
		update PolyprojectNGS.run
		set file_name=?, file_type=?, document=?
		where run_id='$rid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($filename,$filetype,$data2);
	$sth->finish;
	return;
} 

sub getRunDocument {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select 
		r.run_id as runid, r.file_name as filename, r.file_type as filetype, r.document
		FROM PolyprojectNGS.run r
		where r.run_id='$rid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $z = $sth->fetchrow_hashref();
	$z->{document} = connect::uncompressData($z->{document});
	return ($z);
} 

############ End Run #######################
############ Run Type ######################
sub getType {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select rt.name as name
		from PolyprojectNGS.run r, PolyprojectNGS.run_type rt
		where r.run_id='$rid'
		and r.type_run_id=rt.type_run_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{name} if $res;
}

sub getRunType {
        my ($dbh)=@_;
        my $sql = qq{
			select  rt.type_run_id as runTypeId,rt.name as runTypeName
			from PolyprojectNGS.run_type rt;			
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getRunTypeFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  rt.type_run_id as runTypeId,rt.name as runTypeName
			from PolyprojectNGS.run_type rt			
			where rt.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub newRunTypeData {
        my ($dbh,$type) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.run_type (name) values ('$type');
  		};
 		return ($dbh->do($sql));
}

############ End Run Plateform ############
############ Users ########################
sub upInactivatePW {
        my ($dbh,$userid,$value) = @_;
 		my $sql = qq{
 			UPDATE bipd_users.`USER`
 			SET PASSWORD_TXT='$value'
			WHERE USER_ID='$userid';
 		};
 		return ($dbh->do($sql));
}

sub getUserIdfromCompleteName {
	my ($dbh,$firstname,$lastname)=@_;
	my $query = qq{	  	
		SELECT DISTINCT
		U.USER_ID,
		U.PRENOM_U as 'FirstName',
		U.NOM_RESPONSABLE as 'LastName'
		FROM bipd_users.`USER` U
		WHERE prenom_u='$firstname'
		AND nom_responsable='$lastname'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res if $res;	
}

sub getAuthentificationForUser {
	my ($dbh,$login,$pwd,$team)=@_;
	my $query = qq{	  	
		SELECT U.nom_responsable as name
		FROM bipd_users.`USER` U
		WHERE U.LOGIN=? 
		and U.password_txt=password(?)
		and U.equipe_id=?;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute($login,$pwd,$team);
	my $res = $sth->fetchall_arrayref();
	return scalar(@$res);	
}

sub getDirectorInfo {
	my ($dbh)=@_;
	my $query = qq{	  	
		SELECT T.unite_id,T.directeur,T.code_unite,T.site
		FROM bipd_users.UNITE T;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getInfoUsersFromProject {
	my ($dbh,$cunit,$pid) = @_;
	my $query = qq{
		SELECT 
    GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ' ') as 'username',
    GROUP_CONCAT(DISTINCT CASE WHEN T.code_unite<>'$cunit' THEN T.code_unite ELSE NULL END ORDER BY T.code_unite DESC SEPARATOR ' ') as 'unit',
    GROUP_CONCAT(DISTINCT T.site ORDER BY T.site DESC SEPARATOR ' ') as 'site'
		FROM PolyprojectNGS.user_projects up
        LEFT JOIN bipd_users.`USER` U
        ON up.user_id=U.user_id

    LEFT JOIN bipd_users.EQUIPE E
    ON U.equipe_id = E.equipe_id
    LEFT JOIN bipd_users.UNITE T
    ON E.unite_id = T.unite_id


	WHERE up.project_id='$pid'
 	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUsersFromProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		SELECT U.nom_responsable as name
		FROM PolyprojectNGS.user_projects up, bipd_users.`USER` U
		where up.project_id='$pid'
		and up.user_id=U.user_id;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUsersFromProjects {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
		SELECT distinct
        GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ',') as 'username'
        FROM PolyprojectNGS.user_projects up,bipd_users.`USER` U
 		WHERE up.user_id=U.user_id
		AND
		up.project_id in (@projid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{username};
}

sub getGroupsFromProjects {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
		SELECT distinct
		GROUP_CONCAT(DISTINCT ug.name ORDER BY ug.name DESC SEPARATOR ' ') as 'groupname'
		FROM PolyprojectNGS.ugroup_projects gp,bipd_users.UGROUP ug
		WHERE
		gp.ugroup_id=ug.ugroup_id
		AND
		gp.project_id in (@projid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{groupname};
}

sub getUsersAllInfoFromProject {
	my ($dbh,$pid,$unit) = @_;
	my $query2 = qq {and not T.code_unite='$unit'};
	$query2 = "" unless $unit;
	my @pid=$pid;
	my $query = qq{
		select distinct
		T.code_unite as unit ,T.organisme as organisme , T.site as site,
        U.nom_responsable as name,U.prenom_u as Firstname,U.user_id as UserId,
        U.email as Email, E.libelle as Team, E.responsables as Responsable,
        T.directeur as Director
--        ug.name as usergroup
 		from PolyprojectNGS.user_projects up
		LEFT JOIN bipd_users.`USER` U
		ON up.user_id = U.user_id
		
--		LEFT JOIN bipd_users.UGROUP_USER uu
--		ON uu.user_id=U.user_id
--		LEFT JOIN bipd_users.UGROUP ug
--		ON uu.ugroup_id=ug.ugroup_id
		
		LEFT JOIN bipd_users.EQUIPE E
		ON U.equipe_id = E.equipe_id
		LEFT JOIN bipd_users.UNITE T
		ON E.unite_id = T.unite_id

		where up.project_id in (@pid)
		$query2;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub isUserProject {
	my ($dbh,$userid,$projectid) = @_;
	my $query = qq{
		select up.user_id,up.project_id
		from PolyprojectNGS.user_projects up
		where up.user_id='$userid'
		and up.project_id='$projectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub isGroupProject {
	my ($dbh,$groupid,$projectid) = @_;
	my $query = qq{
		select up.ugroup_id,up.project_id
		from PolyprojectNGS.ugroup_projects up
		where up.ugroup_id='$groupid'
		and up.project_id='$projectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}


#a supprimer
sub isUserGroupProject {
	my ($dbh,$userid,$groupid,$projectid) = @_;
	my $query = qq{
		select up.user_id,up.ugroup_id,up.project_id
		from PolyprojectNGS.user_projects up
		where up.user_id='$userid'
		and up.ugroup_id='$groupid'
		and up.project_id='$projectid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub addGroup2project {
        my ($dbh,$groupid,$projectid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.ugroup_projects (ugroup_id,project_id) values ($groupid,$projectid);
        };
        return ($dbh->do($sql));
}

sub delGroup2project {
        my ($dbh,$groupid,$projectid) = @_;
        my $sql = qq{
   			delete from PolyprojectNGS.ugroup_projects
         	where ugroup_id=$groupid
        	and project_id=$projectid;
         };
        return ($dbh->do($sql));
}

# a supprimer
sub addUserGroup2project {
        my ($dbh,$userid,$groupid,$projectid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.user_projects (user_id,ugroup_id,project_id) values ($userid,$groupid,$projectid);
        };
        return ($dbh->do($sql));
}

# a supprimer
sub upUserGroup2project {
        my ($dbh,$userid,$groupid,$projectid) = @_;
        my $sql = qq{    
                update PolyprojectNGS.user_projects 
                set ugroup_id='$groupid'
                where user_id='$userid'
                and project_id='$projectid';
        };
        return ($dbh->do($sql));
}

# a supprimer
sub delUserGroup2project {
        my ($dbh,$userid,$groupid,$projectid) = @_;
        my $sql = qq{
   			delete from PolyprojectNGS.user_projects
        	where user_id=$userid
        	and ugroup_id=$groupid
        	and project_id=$projectid;
         };
        return ($dbh->do($sql));
}

sub getUserIdFromProject{
	my ($dbh,$pid)=@_;
	my $sql = qq{
		select up.user_id
		from PolyprojectNGS.user_projects up
		where up.project_id='$pid';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res if $res;
}

sub getUserInfo {
	my ($dbh,$name)=@_;
	my $sql2 = qq {WHERE U.nom_responsable='$name'};
	$sql2 = "" unless $name;
 	my $sql = qq{
		select distinct
		U.user_id as UserId,
		U.nom_responsable as Name,
		U.prenom_u as Firstname,
		E.unite_id,
		T.site as Site,
		T.code_unite as Code,
		U.equipe_id,
		E.libelle as Team
			
 		from bipd_users.`USER` U
		LEFT JOIN bipd_users.EQUIPE E
		ON U.equipe_id = E.equipe_id
		LEFT JOIN bipd_users.UNITE T
		ON E.unite_id = T.unite_id
		
		$sql2
		order by Name;	
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
 	return \@res if \@res;
}

sub getUserInfoFromId {
	my ($dbh,$userid)=@_;
 	my $sql = qq{
		select distinct
		U.user_id as UserId,
		U.nom_responsable as Name,
		U.prenom_u as Firstname
			
 		from bipd_users.`USER` U
		WHERE U.user_id='$userid';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res if $res;
}

sub getUserInfoFromLogin{
	my ($dbh,$login)=@_;
	my $sql = qq{
		SELECT
		U.user_id as UserId,
		U.nom_responsable as name,
		U.prenom_u as Firstname,
		U.email as Email
		FROM bipd_users.`USER` U
		WHERE U.LOGIN like '$login%'
		;	
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0] if $res;
}

sub getCodeUnitFromTeamId {
	my ($dbh,$teamid)=@_;
	my $sql = qq{
		select distinct N.code_unite
		from
		bipd_users.UNITE N,
		bipd_users.EQUIPE E
		where
		E.unite_id=N.unite_id
		and E.equipe_id='$teamid';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{code_unite} if $res;	
}

sub addUser2project {
        my ($dbh,$userid,$projectid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.user_projects (user_id,project_id) values ($userid,$projectid);
        };
        return ($dbh->do($sql));
}

sub delUser2project {
        my ($dbh,$userid,@projectid) = @_;
        my $sql = qq{    
  			delete from PolyprojectNGS.user_projects
			where project_id in (@projectid)
			and user_id=$userid;
        };
        return ($dbh->do($sql));
}

sub removeUserAllProjects{
	my ($dbh,$userid)=@_;
	my $sql = qq{
 		delete from PolyprojectNGS.user_projects
 		where user_id='$userid';
 	};
    return ($dbh->do($sql));
}

############### ugroup ##################
sub getUgroupId{
	my ($dbh,$ugroupid)=@_;
	my $sql2 = qq {where ugroup_id='$ugroupid'};
	$sql2 = "" unless $ugroupid;
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
############### ugroup_user ##################
sub getUserGroupInfoFromUgroup {
	my ($dbh,$grpid,$super) = @_;
	my $query2 = qq {and uu.ugroup_id!='$super'};
	$query2 = "" unless $super;
	my $query = qq{
		SELECT DISTINCT
		uu.user_id,
		uu.ugroup_id,
		u.nom_responsable as name,
		u.prenom_u as Firstname,
		g.name as 'group',
		T.code_unite as unit ,T.organisme as organisme , T.site as site,
		E.libelle as Team
		FROM bipd_users.UGROUP_USER uu
		LEFT JOIN bipd_users.USER u
		ON uu.user_id=u.user_id
		LEFT JOIN bipd_users.UGROUP g
		ON uu.ugroup_id=g.ugroup_id
		LEFT JOIN bipd_users.EQUIPE E
		ON u.equipe_id = E.equipe_id
		LEFT JOIN bipd_users.UNITE T
		ON E.unite_id = T.unite_id
		where uu.ugroup_id='$grpid'
		$query2
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

sub getUsersGroupProject {
	my ($dbh,$projid,$grpid) = @_;
	my @projid=$projid;
	my $query2 = qq {and up.ugroup_id='$grpid'};
	$query2 = "" unless $grpid;
	my $query = qq{
		SELECT distinct
		up.user_id,
		up.project_id,
		up.ugroup_id,
		U.NOM_RESPONSABLE as name,
		U.PRENOM_U as Firstname,
		ug.name as 'group'

		FROM PolyprojectNGS.user_projects up
		LEFT JOIN bipd_users.`USER` U
		ON up.user_id = U.user_id
		LEFT JOIN bipd_users.UGROUP ug
		ON up.ugroup_id=ug.ugroup_id

		WHERE up.project_id in (@projid)
		$query2
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUsersAndGroupsFromProject {
	my ($dbh,$pid,$grpid,$super) = @_;
	my @pid=$pid;
	my $query2 = qq {and uu.ugroup_id='$grpid'};
	$query2 = "" if (! $grpid || $grpid ==0) ;
	my $query3 = qq {and uu.ugroup_id!='$super'};
	$query3 = "" unless $super;
	my $query = qq{
		SELECT DISTINCT
		gp.project_id,
		gp.ugroup_id,
		ug.name as 'group',
        U.NOM_RESPONSABLE as name,
 		U.PRENOM_U as Firstname,
		U.user_id as UserId,
        U.email as Email, E.libelle as Team, E.responsables as Responsable,      
        T.code_unite as unit ,T.organisme as organisme , T.site as site,       
        T.directeur as Director
              
		FROM PolyprojectNGS.ugroup_projects gp
		LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id
		LEFT JOIN bipd_users.UGROUP_USER uu
		ON ug.ugroup_id=uu.ugroup_id
		LEFT JOIN bipd_users.`USER` U
		ON U.user_id=uu.user_id

		LEFT JOIN bipd_users.EQUIPE E
		ON U.equipe_id = E.equipe_id
		LEFT JOIN bipd_users.UNITE T
		ON E.unite_id = T.unite_id

		where gp.project_id in (@pid)
		$query2
		$query3
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

sub getUsersGroupFromProject {
	my ($dbh,$pid,$grpid) = @_;
	my @pid=$pid;
	my $query2 = qq {and uu.ugroup_id='$grpid'};
	$query2 = "" unless $grpid;
	my $query = qq{
		SELECT DISTINCT
		gp.project_id,
		gp.ugroup_id,
--		U.NOM_RESPONSABLE as name,
--		U.PRENOM_U as Firstname,
		ug.name as 'group'
		FROM PolyprojectNGS.ugroup_projects gp
--		LEFT JOIN bipd_users.`USER` U
--		ON up.user_id = U.user_id
--		LEFT JOIN bipd_users.UGROUP_USER uu
--		ON uu.user_id=U.user_id
		LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id

		where gp.project_id in (@pid)
		$query2
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUserIdFromGroup {
	my ($dbh,$groupid) = @_;
	my $query = qq{
		SELECT 
		uu.user_id,
		uu.ugroup_id
		FROM bipd_users.UGROUP_USER uu
		where uu.ugroup_id ='$groupid'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

############ End Users ####################
############ Database #####################
sub getDatabaseId{
        my ($dbh)=@_;
        my $sql = qq{
			select  D.db_id as dbId,D.name as dbName
			from PolyprojectNGS.polydb D Order by dbname asc;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

# from GenBoProjectQueryNgs
sub getDbId {
	my ($dbh, $database) = @_;
	my $query = qq{SELECT db_id  FROM PolyprojectNGS.polydb where NAME='$database';};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{db_id} if $res;
	return;
}

# from GenBoProjectWriteNgs
sub addDb{
	my ($dbh,$project_id,$dbid) = @_;
	my $query = qq{
		insert into PolyprojectNGS.databases_projects  (project_id,db_id) values ($project_id,$dbid);
	};
	$dbh->do($query) ;
}

############ End Database #################
############ Release ######################
sub getReleaseId{
        my ($dbh,$relid)=@_;
 		my $sql2 = qq {WHERE R.release_id='$relid'};
		$sql2 = "" unless $relid;
        my $sql = qq{
			select  R.release_id as releaseId,R.name as relName,R.def,R.species_id
			from PolyprojectNGS.releases R
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

sub getReleaseFromName {
        my ($dbh,$name)=@_;
        my $sql = qq{
			select  *
			from PolyprojectNGS.releases R
			where name='$name'
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

sub upRelease_default {
	my ($dbh,$releaseid,$default) = @_;
	my $query = qq{
		update PolyprojectNGS.releases
		set def=?
		where release_id='$releaseid';
	};
	my $sth= $dbh->prepare($query);		
	$sth->execute($default);
	$sth->finish;
	return;	
}

#not used
sub getReleaseIdRef {
        my ($dbh)=@_;
        my $sql = qq{
			select distinct
            R.release_capture_id as releaseId,R.reference as relName
			from PolyprojectNGS.releases R;
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

# from GenBoProjectQueryNgs Used
sub getReleaseId_v2 {
	my ($dbh,$name) = @_;
	my $query = qq{SELECT release_id  FROM PolyprojectNGS.releases where name='$name';};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{release_id} if $res;
	return;
}

sub getReleaseNameFromProject{
	my ($dbh,$pid)=@_;
	my $sql = qq{
		SELECT r.name FROM 
		PolyprojectNGS.releases r,
		PolyprojectNGS.project_release pr
		WHERE
		r.release_id=pr.release_id
		and pr.project_id='$pid';		
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	
	return $res->[0]->{name} if $res;
}

sub getReleaseNameFromProjects {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
		SELECT distinct
        GROUP_CONCAT(DISTINCT r.name ORDER BY r.name DESC SEPARATOR ' ') as 'name'
        FROM 
		PolyprojectNGS.releases r,
		PolyprojectNGS.project_release pr
		WHERE
		r.release_id=pr.release_id
		and pr.project_id in (@projid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{name};
}

sub getVersionIdFromProject_release_public_database {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
	SELECT distinct
--		GROUP_CONCAT(DISTINCT pp.version_id ORDER BY pp.version_id  SEPARATOR ' ') as 'ppversionid'
		pp.version_id  as ppversionid
	FROM 
		PolyprojectNGS.project_release_public_database pp
	WHERE
		pp.project_id in (@projid);	
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{ppversionid};
}

sub getReleaseGeneFromProjects {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
		SELECT distinct
-- 			pg.project_id,pg.rel_gene_id,pg.project_rel_gene_id,
			rg.name as relGene
		FROM PolyprojectNGS.project_release_gene pg
		LEFT JOIN PolyprojectNGS.release_gene rg
		ON rg.rel_gene_id=pg.rel_gene_id
		WHERE
			pg.project_id in (@projid);	
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{relGene};
}

sub getReleaseNameFromCapture{
	my ($dbh,$capid)=@_;
 	$capid =~ s/ /,/g;
 	my @capid=$capid;
 	@capid="\'\'" if ($capid eq undef);
	my $sql = qq{
		SELECT r.name FROM 
		PolyprojectNGS.releases r,
		PolyprojectNGS.capture_systems C
		WHERE
		r.release_id=C.release_id
		and C.capture_id in (@capid);		
	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

sub getCapture_fromReleaseId {
	my ($dbh,$relid)=@_;
 	my $sql = qq{
		SELECT * 
		FROM PolyprojectNGS.capture_systems
		where release_id ='$relid'	
 	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

sub getSpeciesIdFromCapture {
	my ($dbh,$capid)=@_;
 	$capid =~ s/ /,/g;
 	my @capid=$capid;
 	@capid="\'\'" if ($capid eq undef);
	my $sql = qq{
		SELECT Distinct
		r.species_id
		FROM PolyprojectNGS.capture_systems C
		LEFT JOIN PolyprojectNGS.releases r
		ON C.release_id=r.release_id
		WHERE C.capture_id in (@capid);		
	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

sub getReleaseGeneNameFromCapture{
	my ($dbh,$capid)=@_;
 	$capid =~ s/ /,/g;
 	my @capid=$capid;
 	@capid="\'\'" if ($capid eq undef);
# 	@capid="" if undef;
	my $sql = qq{
		SELECT rg.name FROM 
		PolyprojectNGS.release_gene rg,
		PolyprojectNGS.capture_systems C
		WHERE
		rg.rel_gene_id=C.rel_gene_id
		and C.capture_id in (@capid);		
	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

#not used
sub getReleaseRefFromCapture{
	my ($dbh,$capid)=@_;
 	$capid =~ s/ /,/g;
 	my @capid=$capid;
 	@capid="\'\'" if ($capid eq undef);
# 	@capid="" if undef;
	my $sql = qq{
		SELECT DISTINCT r.reference 
		FROM 
		PolyprojectNGS.releases r,
		PolyprojectNGS.capture_systems C
		WHERE
		r.release_id=C.release_id
		and C.capture_id in (@capid);		
	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

sub getReleaseVersionFromCapture{
	my ($dbh,$capid)=@_;
 	$capid =~ s/ /,/g;
 	my @capid=$capid;
 	@capid="\'\'" if ($capid eq undef);
	my $sql = qq{
		SELECT DISTINCT r.version 
		FROM 
		PolyprojectNGS.releases r,
		PolyprojectNGS.capture_systems C
		WHERE
		r.release_id=C.release_id
		and C.capture_id in (@capid);		
	};
    my @res;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my $id = $sth->fetchrow_hashref ) {
    	push(@res,$id);
    }
    return \@res if \@res;
}

sub upProjectRelease {
        my ($dbh,$projectid,$releaseid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.project_release set release_id='$releaseid'
        	where project_id='$projectid';
        };
        return ($dbh->do($sql));
}

sub addRelease{
	my ($dbh,$project_id,$release_id) = @_;
	my $query = qq{
		insert into PolyprojectNGS.project_release  (project_id,release_id,`default`) values ($project_id,$release_id,1);
	};

	$dbh->do($query) ;
}

############ End Release ##################
############ Release Annotation ######################
#not used but seen in directory forAnnotation/sc_annotation.pl
sub get_relAnnotIdfromName_v1 {
	my ($dbh,$name) = @_;
	my $query;
	$query = qq{SELECT rel_annot_id  FROM PolyprojectNGS.release_annotation where name='$name';};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{rel_annot_id} if $res;
	return;
}

#not used but seen in directory forAnnotation/sc_annotation.pl
sub get_relAnnotIdfromName_v2 {
	my ($dbh,$name) = @_;
	my $query;
	$query = qq{SELECT rel_annot_id  FROM PolyprojectNGS.release_annotation where name regexp '$name';};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	};
	return \@res if \@res;	
}

sub addProjectReleaseAnnotation{
	my ($dbh,$project_id,$rel_annot_id) = @_;
	my $query = qq{
		insert into PolyprojectNGS.project_release_annotation (project_id,rel_annot_id) values ($project_id,$rel_annot_id);
	};
	$dbh->do($query) ;
}

sub isProjectReleaseAnnotation {
	my ($dbh,$project_id,$rel_annot_id) = @_;
	my $query = qq{
		SELECT DISTINCT 
		project_id,rel_annot_id  
		FROM PolyprojectNGS.project_release_annotation
		where project_id='$project_id'
		and rel_annot_id='$rel_annot_id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

############ End Release Annotation ######################
############ Release Gene ######################
sub getReleaseGeneId{
        my ($dbh,$relgene_id)=@_;
		my $sql2 = qq {WHERE rg.rel_gene_id='$relgene_id'};
		$sql2 = "" unless $relgene_id;
        my $sql = qq{
			SELECT rg.rel_gene_id,rg.name as relgeneName
			FROM PolyprojectNGS.release_gene rg
			$sql2		
			order by rg.rel_gene_id;			
		};
        my @res;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub get_relGeneIdfromName {
	my ($dbh,$name) = @_;
	my $query = qq{SELECT rel_gene_id  FROM PolyprojectNGS.release_gene where name='$name';};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{rel_gene_id} if $res;
	return;
}

sub isProjectReleaseGene {
	my ($dbh,$project_id,$rel_gene_id) = @_;
	my $query = qq{
		SELECT DISTINCT 
		project_id,rel_gene_id  
		FROM PolyprojectNGS.project_release_gene
		where project_id='$project_id'
		and rel_gene_id='$rel_gene_id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub isBundleReleaseGene {
	my ($dbh,$bundle_id,$rel_gene_id) = @_;
	my $query = qq{
		SELECT DISTINCT 
		bundle_id,rel_gene_id  
		FROM PolyprojectNGS.bundle_release_gene
		where bundle_id='$bundle_id'
		and rel_gene_id='$rel_gene_id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub searchBundleReleaseGene {
	my ($dbh,$val,$valB) = @_;
	my @val=$val ;
	my $query2;
	$query2 = qq {where bg.bundle_id in (@val)} unless $valB;
	$query2 = qq {where bg.rel_gene_id in (@val)} if $valB;
    $query2 = "" unless $val;
	
	my $query = qq{
		SELECT DISTINCT
		rg.name,
		bg.rel_gene_id,bg.bundle_id
		FROM PolyprojectNGS.release_gene as rg
		LEFT JOIN PolyprojectNGS.bundle_release_gene bg
		ON rg.rel_gene_id=bg.rel_gene_id
		$query2
		;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub addProjectReleaseGene{
	my ($dbh,$project_id,$rel_gene_id) = @_;
	my $query = qq{
		insert into PolyprojectNGS.project_release_gene (project_id,rel_gene_id) values ($project_id,$rel_gene_id);
	};
	$dbh->do($query) ;
}

sub addBundleReleaseGene{
	my ($dbh,$bundle_id,$rel_gene_id) = @_;
	my $query = qq{
		insert into PolyprojectNGS.bundle_release_gene (bundle_id,rel_gene_id) values ($bundle_id,$rel_gene_id);
	};
	$dbh->do($query) ;
}

sub upBundleReleaseGenen {
        my ($dbh,$bundle_id,$rel_gene_id) = @_;
        my $sql = qq{
        	update PolyprojectNGS.bundle_release_gene set rel_gene_id='$rel_gene_id'
        	where bundle_id='$bundle_id';
        };
        return ($dbh->do($sql));
}
############ End Release Gene ######################
############ Project     ##################

sub getProject{
	my ($dbh,$projid)=@_;
	my $sql2 = qq {and p.project_id='$projid'};
	$sql2 = "" unless $projid;
	
	my $sql = qq{
	select 
	p.project_id as id , 
	p.name as name, 
	p.description,
	p.dejaVu,p.somatic,
	p.creation_date as cDate,
	po.name as dbname,
    r.name as relname
	
	from 
	PolyprojectNGS.projects p ,
    PolyprojectNGS.databases_projects dp,
    PolyprojectNGS.polydb po,
    PolyprojectNGS.project_release pr,
    PolyprojectNGS.releases r
	where p.type_project_id=3
    and p.project_id =dp.project_id
    and dp.db_id !=2
    and dp.db_id = po.db_id
    and p.project_id=pr.project_id
    and pr.release_id=r.release_id
	$sql2 
	order by p.project_id desc
		
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
}

sub getProjectNameFromId {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
    	select
			GROUP_CONCAT(DISTINCT p.name ORDER BY p.name DESC SEPARATOR ' ') as 'projName',
			GROUP_CONCAT(distinct if (p.somatic=1,1,0)) as 'somatic'
		from
			PolyprojectNGS.projects p
		where
			p.project_id in (@projid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getLastProject {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(project_id) as project_id,
		description 
		from PolyprojectNGS.projects;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

#    GROUP_CONCAT(DISTINCT CASE WHEN T.code_unite<>'BIP-D' THEN T.code_unite ELSE NULL END ORDER BY T.code_unite DESC SEPARATOR ' ') as 'unit',

sub getProjectAll {
	my ($dbh,$cunit,$projid)=@_;
	my $sql2 = qq {and p.project_id='$projid'};
	$sql2 = "" unless $projid;
	
	my $sql = qq{
	SELECT 
	p.project_id as id , 
	p.name as name, 
	p.description,
	p.dejaVu,p.somatic,
	p.creation_date as cDate,
	po.name as dbname,
    r.name as relname,
	GROUP_CONCAT(DISTINCT pp.version_id ORDER BY pp.version_id  SEPARATOR ' ') as 'ppversionid',
	GROUP_CONCAT(DISTINCT rg.name ORDER BY rg.name  SEPARATOR ' ') as 'relGene',
	GROUP_CONCAT(DISTINCT ug.name ORDER BY ug.name DESC SEPARATOR ' ') as 'usergroup',
	GROUP_CONCAT(DISTINCT ug.ugroup_id ORDER BY ug.ugroup_id DESC SEPARATOR ' ') as 'usergroupId',
 --   GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ' ') as 'username',
    GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ',') as 'username',
    GROUP_CONCAT(DISTINCT CASE WHEN T.code_unite<>'$cunit' THEN T.code_unite ELSE NULL END ORDER BY T.code_unite DESC SEPARATOR ' ') as 'unit',
    GROUP_CONCAT(DISTINCT T.site ORDER BY T.site DESC SEPARATOR ' ') as 'site'
	FROM
	PolyprojectNGS.projects p 
    LEFT JOIN PolyprojectNGS.databases_projects dp
    ON p.project_id =dp.project_id
    LEFT JOIN PolyprojectNGS.polydb po
    ON dp.db_id = po.db_id
    LEFT JOIN PolyprojectNGS.project_release pr
    ON p.project_id=pr.project_id
    LEFT JOIN PolyprojectNGS.releases r
    ON pr.release_id=r.release_id
 		
 	LEFT JOIN PolyprojectNGS.project_release_public_database pp
	ON p.project_id = pp.project_id
        
	LEFT JOIN PolyprojectNGS.project_release_gene pg
	ON p.project_id = pg.project_id
        
	LEFT JOIN PolyprojectNGS.release_gene rg
	ON rg.rel_gene_id=pg.rel_gene_id
    
	LEFT JOIN PolyprojectNGS.user_projects up
    ON p.project_id = up.project_id
    LEFT JOIN bipd_users.`USER` U
    ON up.user_id = U.user_id
    
	LEFT JOIN PolyprojectNGS.ugroup_projects gp
    ON p.project_id = gp.project_id
 	LEFT JOIN bipd_users.UGROUP ug
	ON gp.ugroup_id=ug.ugroup_id
    
    LEFT JOIN bipd_users.EQUIPE E
    ON U.equipe_id = E.equipe_id
    LEFT JOIN bipd_users.UNITE T
    ON E.unite_id = T.unite_id
    WHERE p.type_project_id=3
    and dp.db_id !=2
   	$sql2
   	GROUP BY p.project_id
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

sub getProjectNoUnitWithDate {
	my ($dbh,$Edate,$Bdate,$projid)=@_;
	my $sql2 = qq {and p.project_id='$projid'};
	$sql2 = "" unless $projid;
		
	my $sql = qq{
	SELECT 
	p.project_id as id , 
	p.name as name, 
	p.description,
	p.dejaVu,p.somatic,
	p.creation_date as cDate,
	po.name as dbname,
    r.name as relname,
	GROUP_CONCAT(DISTINCT ug.NAME ORDER BY ug.NAME DESC SEPARATOR ',') as 'groupname',
    GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ',') as 'username'
 	FROM
	PolyprojectNGS.projects p 
    LEFT JOIN PolyprojectNGS.databases_projects dp
    ON p.project_id =dp.project_id
    LEFT JOIN PolyprojectNGS.polydb po
    ON dp.db_id = po.db_id
    LEFT JOIN PolyprojectNGS.project_release pr
    ON p.project_id=pr.project_id
    LEFT JOIN PolyprojectNGS.releases r
    ON pr.release_id=r.release_id
	LEFT JOIN PolyprojectNGS.user_projects up
    ON p.project_id = up.project_id
    LEFT JOIN bipd_users.`USER` U
    ON up.user_id = U.user_id
 
	LEFT JOIN PolyprojectNGS.ugroup_projects gp
    ON p.project_id = gp.project_id
 	LEFT JOIN bipd_users.UGROUP ug
	ON gp.ugroup_id=ug.ugroup_id

    WHERE p.type_project_id=3
    and dp.db_id !=2
	and p.creation_date between '$Edate' and DATE_ADD('$Bdate', INTERVAL 1 DAY)
   	$sql2
   	GROUP BY p.project_id
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

sub getProjectAllWithDate{
	my ($dbh,$cunit,$Edate,$Bdate,$projid)=@_;
	my $sql2 = qq {and p.project_id='$projid'};
	$sql2 = "" unless $projid;
		
	my $sql = qq{
	SELECT 
	p.project_id as id , 
	p.name as name, 
	p.description,
	p.dejaVu,p.somatic,
	p.creation_date as cDate,
	po.name as dbname,
    r.name as relname,
    GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ' ') as 'username',
-- 	GROUP_CONCAT(DISTINCT CASE WHEN T.code_unite<>'$cunit' THEN T.code_unite ELSE NULL END ORDER BY T.code_unite DESC SEPARATOR ' ') as 'unit',
	GROUP_CONCAT(DISTINCT T.code_unite ORDER BY T.code_unite DESC SEPARATOR ' ') as 'unit',
    GROUP_CONCAT(DISTINCT T.site ORDER BY T.site DESC SEPARATOR ' ') as 'site'
	FROM
	PolyprojectNGS.projects p 
    LEFT JOIN PolyprojectNGS.databases_projects dp
    ON p.project_id =dp.project_id
    LEFT JOIN PolyprojectNGS.polydb po
    ON dp.db_id = po.db_id
    LEFT JOIN PolyprojectNGS.project_release pr
    ON p.project_id=pr.project_id
    LEFT JOIN PolyprojectNGS.releases r
    ON pr.release_id=r.release_id
	LEFT JOIN PolyprojectNGS.user_projects up
    ON p.project_id = up.project_id
    LEFT JOIN bipd_users.`USER` U
    ON up.user_id = U.user_id
    LEFT JOIN bipd_users.EQUIPE E
    ON U.equipe_id = E.equipe_id
    LEFT JOIN bipd_users.UNITE T
    ON E.unite_id = T.unite_id
    WHERE p.type_project_id=3
    and dp.db_id !=2
	and p.creation_date between '$Edate' and DATE_ADD('$Bdate', INTERVAL 1 DAY)
   	$sql2
   	GROUP BY p.project_id
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

sub getProjectName{
	my ($dbh,$projID)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.name as projName
		from
		PolyprojectNGS.projects P
		where
		P.project_id='$projID';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{projName};
}

sub getProjectDescription{
	my ($dbh,$projID)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.description as projDes
		from
		PolyprojectNGS.projects P
		where
		P.project_id='$projID';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{projDes};
}

sub getProjectSomatic{
	my ($dbh,$projID)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.somatic
		from
		PolyprojectNGS.projects P
		where
		P.project_id='$projID';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getProjectdejaVu {
	my ($dbh,$projID)=@_;
	my $sql = qq{
    		select
		P.project_id as projId,
		P.dejaVu
		from
		PolyprojectNGS.projects P
		where
		P.project_id='$projID';
	};
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getProjectPhenotype {
	my ($dbh,$projid)=@_;
	my $sql2 = qq {where  hp.project_id='$projid'};
	$sql2 = "" unless $projid;
	my $sql = qq{
		SELECT distinct
 		hp.phenotype_id,
-- 		hp.project_id,
		hh.name
		FROM PolyPhenotypeDB.phenotype_project hp
		LEFT JOIN PolyPhenotypeDB.phenotype hh
		ON hp.phenotype_id =hh.phenotype_id		
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

sub getPhenotypeFromProjects {
	my ($dbh,$projid)=@_;
	my @projid=$projid;
	my $query = qq{
	SELECT distinct
		GROUP_CONCAT(DISTINCT hh.name ORDER BY hh.name DESC SEPARATOR ',') as 'phenotype'
	FROM PolyPhenotypeDB.phenotype_project hp,PolyPhenotypeDB.phenotype hh
	WHERE
	hp.phenotype_id = hh.phenotype_id
	AND
		hp.project_id in (@projid);
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s->{phenotype};
}

sub getProjectFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT p.project_id as projectId
		FROM PolyprojectNGS.projects p 
		where  p.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getRunfromProject {
	my ($dbh,$pid) = @_;
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

sub getRunfromProjectIdDest {
	my ($dbh,$pid) = @_;
	my $query = qq{
		SELECT DISTINCT
		GROUP_CONCAT(DISTINCT a.run_id ORDER BY a.run_id DESC SEPARATOR ' ') as 'RunId'
		FROM 
		PolyprojectNGS.projects p,
		PolyprojectNGS.patient a
		WHERE
		p.project_id=a.project_id_dest
		and p.project_id='$pid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upProject {
        my ($dbh,$pid,$description,$dejavu,$somatic) = @_;
 		my $sql = qq{
 			UPDATE PolyprojectNGS.projects
 			SET description='$description', dejaVu='$dejavu', somatic='$somatic'
			WHERE project_id='$pid';
 		};
 		return ($dbh->do($sql));
}

sub upSomaticProject {
        my ($dbh,$pid,$somatic) = @_;
 		my $sql = qq{
 			UPDATE PolyprojectNGS.projects
 			SET somatic='$somatic'
			WHERE project_id='$pid';
 		};
 		return ($dbh->do($sql));
}

sub delProject {
        my ($dbh,$pid) = @_;
 		my $sql = qq{
 			DELETE FROM PolyprojectNGS.projects
			WHERE project_id='$pid';
 		};
 		return ($dbh->do($sql));
}

############ End Project ##################
#project_types from GenBoQueryNgs
sub getOriginType {
	my ($dbh,$type) =@_;
	my $query = qq{
		select type_project_id as id  from PolyprojectNGS.project_types  where name='$type';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();	
	return $s;
}
####################################################################################################

sub getCacheVariationsFilekct {
	my ($self,$chr_name) = @_;
	my $dir = $self->getCacheDir();
	confess("give a chromosome name for variations cache") unless $chr_name;
#	my $file_name = $dir."/variations.$chr_name.".$self->name().".store.gz";
	my $file_name = $dir."/variations.$chr_name.".$self->name().".kct";
}

sub getSeqMachines {
	my ($dbh,$pid) = @_;
	my $sql = qq{
		SELECT p.project_id, p.machine_id, s.name
		FROM Polyproject.projects_machines p ,Polyproject.sequencing_machines s
		where p.project_id=$pid
		and p.machine_id = s.machine_id
		};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchall_hashref("name");
	return keys %$s;		
}

############ Phenotype     ##################

sub getPhenotype { 
	my ($dbh, $pheid)=@_;
	my $query2 = qq {where e.phenotype_id='$pheid'};
	$query2 = "" unless $pheid;	
	my $query = qq{	  	
		SELECT e.phenotype_id, e.name
		FROM PolyPhenotypeDB.`phenotype` e
		$query2
		;
	};
        my @res;
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while (my $id = $sth->fetchrow_hashref ) {
                push(@res,$id);
        }
        return \@res;
}

sub getPhenotypeFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		select e.name, e.phenotype_id
		FROM PolyPhenotypeDB.`phenotype` e
		where  e.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPhenotypeProject {
        my ($dbh,$pheid,$projid)=@_;
 		my $sql2 = qq {and hp.project_id='$projid'};
 		$sql2 = "" unless $projid;
        my $sql = qq{        	
			SELECT hp.phenotype_id,hp.project_id
			FROM PolyPhenotypeDB.`phenotype_project` hp
			where hp.phenotype_id='$pheid'
			$sql2;
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

sub newPhenotypeProject {
	my ($dbh,$pheid,$projid) = @_;
	my $sql = qq{    
		insert into PolyPhenotypeDB.`phenotype_project` (phenotype_id,project_id) values ($pheid,$projid);
	};
	return ($dbh->do($sql));
}

sub removePhenotypeProjectByProject {
    my ($dbh,$projid) = @_;
	my $sql = qq{
		DELETE FROM PolyPhenotypeDB.`phenotype_project`
		where project_id='$projid'
	};
 	return ($dbh->do($sql));
}

sub getPhenotypePatient {
        my ($dbh,$pheid,$patid)=@_;
 		my $sql2 = qq {and ha.patient_id='$patid'};
 		$sql2 = "" unless $patid;
        my $sql = qq{        	
			SELECT ha.phenotype_id,ha.patient_id
			FROM PolyPhenotypeDB.`phenotype_patient` ha
			where ha.phenotype_id='$pheid'
			$sql2;
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

sub newPhenotypePatient {
	my ($dbh,$pheid,$patid) = @_;
	my $sql = qq{    
		insert into PolyPhenotypeDB.`phenotype_patient` (phenotype_id,patient_id) values ($pheid,$patid);
	};
	return ($dbh->do($sql));
}

sub removePhenotypePatientByPatient {
    my ($dbh,$patid) = @_;
	my $sql = qq{
		DELETE FROM PolyPhenotypeDB.`phenotype_patient`
		where patient_id='$patid'
	};
 	return ($dbh->do($sql));
}

########### pipeline profile methods

sub getPipelineMethods_byId {
	my ($dbh,$pipelineid)=@_;
	my $sql2 = qq {where i.pipeline_id='$pipelineid'};
	$sql2 = "" unless $pipelineid;
	my $sql = qq{        	
		SELECT * FROM PolyprojectNGS.profile_pipeline i
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

sub getPipelineMethods_fromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT i.name, i.pipeline_id
		FROM PolyprojectNGS.profile_pipeline i
		where  i.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getMethods_inMethodPipeline {
	my ($dbh,$pipelineid) = @_;
	my $sql = qq{
		SELECT * FROM PolyprojectNGS.method_pipeline mp
		WHERE mp.pipeline_id='$pipelineid'
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

sub insertPipeline {
	my ($dbh,$name,$content) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.profile_pipeline (name,content) 
 		values (?,?);
	};
	my $sthquery = $dbh->prepare($query);
	$sthquery->execute($name,$content);
	$sthquery->finish;
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.profile_pipeline;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upPipeline {
	my ($dbh,$pipeid,$pipename,$content) = @_;
	my $sql = qq{
		update PolyprojectNGS.profile_pipeline
		set name=?,content=?
		where pipeline_id='$pipeid'
		;
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($pipename,$content);
	$sth->finish;
	return;
}

sub isMethodPipeline {
	my ($dbh,$method_id,$pipeline_id) = @_;
	my $query = qq{
		SELECT DISTINCT 
		method_id,pipeline_id  
		FROM PolyprojectNGS.method_pipeline
		where method_id='$method_id'
		and pipeline_id='$pipeline_id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub insertMethodsPipeline {
	my ($dbh,$methodid,$pipelineid) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.method_pipeline (method_id,pipeline_id)
 		values (?,?);
	};
	my $sthquery = $dbh->prepare($query);
	$sthquery->execute($methodid,$pipelineid);
	$sthquery->finish;

	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.method_pipeline;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub delMethodsPipeline {
        my ($dbh,$methodid,$pipelineid)=@_;
        my $sql = qq{
        	DELETE FROM PolyprojectNGS.method_pipeline
        	WHERE method_id='$methodid'
        	AND pipeline_id='$pipelineid'
		};
 		return ($dbh->do($sql));
}

############ Species ########################
sub getSpecies {
	my ($dbh,$speciesid) = @_;
	my $query2 = qq{where s.species_id='$speciesid'};
	$query2 = "" unless $speciesid;
	my $query = qq{
		select *
		FROM PolyprojectNGS.species s
		$query2
	};
		my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getSpecies_FromName {
	my ($dbh,$name) = @_;
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

1;
