package queryPolyproject;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;


############ Plateform #####################
sub getPlateformId{
	my ($dbh)=@_;
	my $sql = qq{
		select  f.plateform_id as plateformId,f.name as plateformName
		from PolyprojectNGS.plateform f;
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

sub getPlateform2 {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select f.name as name
		from PolyprojectNGS.run_plateform rf, PolyprojectNGS.plateform f
		where rf.run_id='$rid' and rf.plateform_id=f.plateform_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{name} if $res;
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
	
	#my $res = $sth->fetchall_arrayref({});
	#return $res->[0]->{name} if $res;
}


# delete from PolyprojectNGS.plateform where plateform_id=9
sub newPlateformData {
        my ($dbh,$plateform) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.plateform (name) values ('$plateform');
 		};
 		return ($dbh->do($sql));
}

# delete from PolyprojectNGS.run_plateform where run_id=5;
sub addPlateform2run {
        my ($dbh,$plateformid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_plateform (plateform_id,run_id) values ($plateformid,$rid);
        };
        return ($dbh->do($sql));
} 

############ End Plateform #################
############ Machine #######################
sub getMachineId{
        my ($dbh)=@_;
        my $sql = qq{
			select  S.machine_id as machineId,S.name as macName,
			S.type as macType
			from PolyprojectNGS.sequencing_machines S;
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

# delete from PolyprojectNGS.sequencing_machines where machine_id=6
sub newMachineData {
        my ($dbh,$machine,$mactype) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.sequencing_machines (name,type) values ('$machine','$mactype');
  		};
 		return ($dbh->do($sql));
}

############ End Machine ###################
############ Method ########################
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

sub getAlnMethodName{
        my ($dbh,$rid)=@_;
        my $sql = qq{
			select rm.run_id,rm.method_id,M.name as methAln
			from PolyprojectNGS.run_methods rm, PolyprojectNGS.methods M
			where rm.run_id='$rid'
			and rm.method_id=M.method_id
			and M.type='ALIGN'
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
        my ($dbh,$rid)=@_;
        my $sql = qq{
			select rm.run_id,rm.method_id,M.name as methCall
			from PolyprojectNGS.run_methods rm, PolyprojectNGS.methods M
			where rm.run_id='$rid'
			and rm.method_id=M.method_id
			and M.type='SNP'
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

sub getAlnMethodId{
        my ($dbh)=@_;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
			from PolyprojectNGS.methods M 
			where M.type='ALIGN'
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

sub getCallMethodId{
        my ($dbh)=@_;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
			from PolyprojectNGS.methods M 
			where M.type='SNP'
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


# delete from PolyprojectNGS.methods where method_id=7
sub newMethodData {
        my ($dbh,$method,$type) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.methods (name,type) values ('$method','$type');
  		};
 		return ($dbh->do($sql));
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

sub getSeqMethodId{
        my ($dbh)=@_;
        my $sql = qq{
			select  ms.method_seq_id as methodSeqId,ms.name as methSeqName
			from PolyprojectNGS.method_seq ms ;			
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

sub upMethSeq2run {
        my ($dbh,$mid,$rid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.run_method_seq set method_seq_id='$mid'
        	where run_id='$rid';
        };
        return ($dbh->do($sql));
} 
# delete from PolyprojectNGS.methods_seq where method_seq_id=5
sub newMethSeqData {
        my ($dbh,$methseq) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.method_seq (name) values ('$methseq');
  		};
 		return ($dbh->do($sql));
}

############ End Method Seq ################
############ Capture #######################

sub getCaptureId{
        my ($dbh)=@_;
        my $sql = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType
			from PolyprojectNGS.capture_systems C;
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
sub getCapture {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select c.name as name
		from PolyprojectNGS.patient t, PolyprojectNGS.capture_systems c
		where t.run_id='$rid'
		and t.capture_id=c.capture_id;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{name} if $res;
}

# delete from PolyprojectNGS.capture_systems where capture_id=3
sub newCaptureData {
        my ($dbh,$capture,$capVs,$capDes,$capFile,$capType) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.capture_systems (name,version,description,filename,type) 
 			values ('$capture','$capVs','$capDes','$capFile','$capType');
  		};
 		return ($dbh->do($sql));
}

############ End Capture ###################
############ Patient #######################

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

sub getPatientsFromProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		select a.name as name
		FROM PolyprojectNGS.patient a
		where a.project_id='$pid';
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
	my ($dbh,$rid) = @_;
	my $query = qq{
		select a.name as name
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

sub getPatientsInfoFromRun {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select a.name as name, a.patient_id,a.project_id,a.run_id,a.capture_id
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


sub getPatientProjectInfo {
	my ($dbh,$pid) = @_;
	my $query = qq{
		SELECT distinct a.project_id,a.run_id,a.name,a.patient_id,
		S.name as macName,
		f.name as plateformName,
		ms.name as methSeqName,
		C.name as capName,
		r.creation_date as cDate
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

sub getPatientProjectInfo2 {
	my ($dbh,$pid) = @_;
	my $query = qq{
		SELECT a.project_id,a.run_id,a.name,
		S.name as macName,
		f.name as plateformName,
		ms.name as methSeqName,
		C.name as capName,
		r.creation_date as cDate
		FROM 
		PolyprojectNGS.patient a, PolyprojectNGS.run r,
		PolyprojectNGS.run_machine rm, PolyprojectNGS.sequencing_machines S,
		PolyprojectNGS.run_plateform rp, PolyprojectNGS.plateform f,
		PolyprojectNGS.run_method_seq rs,PolyprojectNGS.method_seq ms,
		PolyprojectNGS.capture_systems C
		where a.project_id='$pid'
		and a.run_id=r.run_id
		and r.run_id=rm.run_id
		and r.run_id=rp.run_id
		and r.run_id=rs.run_id
		and rs.method_seq_id=ms.method_seq_id
		and rp.plateform_id=f.plateform_id
		and rm.machine_id=S.machine_id
		and a.capture_id=C.capture_id
		order by run_id;	
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;
}

sub upPatientProject {
        my ($dbh,$patid,$pid,$genboid) = @_;
        warn "upPatientProject";
        warn Dumper $genboid;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set project_id='$pid', genbo_id='$genboid' 
        	where patient_id='$patid';
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




=pod	
=cut


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

# delete from PolyprojectNGS.run where run_id=5;
sub newRun {
	my ($dbh,$type) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.run (type_run_id) values ($type);
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

# delete from PolyprojectNGS.run_machine where run_id=5;
sub addMachine2run {
        my ($dbh,$machineid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_machine (machine_id,run_id) values ($machineid,$rid);
        };
        return ($dbh->do($sql));
} 

# delete from PolyprojectNGS.run_method_seq  where run_id=5;
sub addMethSeq2run {
        my ($dbh,$methseqid,$rid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.run_method_seq  (method_seq_id,run_id) values ($methseqid,$rid);
        };
        return ($dbh->do($sql));
} 

# delete from PolyprojectNGS.patient where run_id=5;

# delete from project_methods where project_id=1111 and method_id=4;
sub addMeth2run {
        my ($dbh,$methodid,$rid) = @_;
        #warn Dumper $methodid;
        #warn Dumper $projectid;
        my $sql = qq{    
                insert into PolyprojectNGS.run_methods (method_id,run_id) values ($methodid,$rid);
        };
        return ($dbh->do($sql));
}

sub addPatientRun {
	my ($dbh,$patient,$pid,$rid,$captureid,$genboid) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,project_id,run_id,capture_id,genbo_id) 
 		values ("$patient","$pid","$rid","$captureid","$genboid");
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

sub addPatientRun_v2 {
	my ($dbh,$patient,$rid,$captureid) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,run_id,capture_id,genbo_id) 
 		values ("$patient","$rid","$captureid",0);
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



sub upPatientGenbo {
        my ($dbh,$patientid) = @_;
        my $sql = qq{    
                update PolyprojectNGS.patient set genbo_id='$patientid'
                where  patient_id='$patientid';
        };
        return ($dbh->do($sql));
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

# delete from PolyprojectNGS.run_type where type_run_id=7
sub newRunTypeData {
        my ($dbh,$type) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.run_type (name) values ('$type');
  		};
 		return ($dbh->do($sql));
}


############ End Run Plateform ############
############ Disease ######################
sub getDiseaseId{
	my ($dbh)=@_;
	my $sql = qq{
		select  d.disease_id as diseaseId,d.description as diseaseName, 
		d.abbreviations as diseaseAbb
		from PolyprojectNGS.disease d order by d.description;
	};
	my @res;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub getDiseasesFromProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		select d.description as description, d.abbreviations as diseaseAbb,
		d.disease_id as diseaseId
		from PolyprojectNGS.project_disease pd, PolyprojectNGS.disease d
		where pd.project_id='$pid'
		and pd.disease_id=d.disease_id;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub ctrlDiseaseId {
	my ($dbh,$id) = @_;
	my $query = qq{
		SELECT d.disease_id as diseaseId
		FROM PolyprojectNGS.disease d
		where  d.disease_id='$id';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub ctrlDiseaseIdProject {
	my ($dbh,$id) = @_;
	my $query = qq{
		SELECT pd.project_id as projectId
		FROM PolyprojectNGS.project_disease pd
		where  pd.disease_id='$id';
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getDiseaseFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
		SELECT d.disease_id as diseaseId
		FROM PolyprojectNGS.disease d 
		where  d.description='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

# delete from disease where disease_id=1120
sub newDiseaseData {
        my ($dbh,$disease,$abb) = @_;
 		my $sql = qq{    
 			insert into PolyprojectNGS.disease (description,abbreviations) values ('$disease','$abb');
 		};
 		return ($dbh->do($sql));
}

sub delDiseaseData {
        my ($dbh,$diseaseid) = @_;
 		my $sql = qq{
			delete from PolyprojectNGS.disease 
			where disease_id=$diseaseid;
 		};
 		return ($dbh->do($sql));
}

# delete from project_disease where project_id=1120
sub addDisease2project {
        my ($dbh,$diseaseid,$projectid) = @_;
		my $sql = qq{    
			insert into PolyprojectNGS.project_disease (disease_id,project_id) values ($diseaseid,$projectid);
		};
		return ($dbh->do($sql));
}

sub delDisease2project {
        my ($dbh,$diseaseid,$projectid) = @_;
		my $sql = qq{    
			delete from PolyprojectNGS.project_disease 
			where project_id=$projectid
			and disease_id=$diseaseid;
		};
		return ($dbh->do($sql));
}



############ End Disease ##################
############ Users ########################
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

sub getUsersInfoFromProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		select distinct T.code_unite as unit ,T.organisme as organisme , T.site as site
		from PolyprojectNGS.user_projects up, bipd_users.`USER` U, 
		bipd_users.EQUIPE E, bipd_users.UNITE T
		where up.project_id='$pid'
		and up.user_id=U.user_id
		and U.equipe_id=E.equipe_id
		and E.unite_id=T.unite_id
		and not U.equipe_id=6;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUsersAllInfoFromProject {
	my ($dbh,$pid) = @_;
	my $query = qq{
		select T.code_unite as unit ,T.organisme as organisme , T.site as site,
        U.nom_responsable as name,U.prenom_u as Firstname,
        U.email as Email, E.libelle as Team, E.responsables as Responsable,
        T.directeur as Director
		from PolyprojectNGS.user_projects up, bipd_users.`USER` U, 
		bipd_users.EQUIPE E, bipd_users.UNITE T
		where up.project_id='$pid'
		and up.user_id=U.user_id
		and U.equipe_id=E.equipe_id
		and E.unite_id=T.unite_id;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getUserInfo{
	my ($dbh)=@_;
 	my $sql = qq{
		select
		U.user_id as UserId,
		U.nom_responsable as Name,
		U.prenom_u as Firstname,
		N.unite_id,
		N.site as Site,
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
 	return \@res if \@res;
}

sub addUser2project {
        my ($dbh,$userid,$projectid) = @_;
        my $sql = qq{    
                insert into PolyprojectNGS.user_projects (user_id,project_id) values ($userid,$projectid);
        };
        return ($dbh->do($sql));
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
############ End Database #################
############ Release ######################

sub getReleaseId{
        my ($dbh)=@_;
        my $sql = qq{
			select  R.release_id as releaseId,R.name as relName
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
############ End Release ##################
############ Project     ##################

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

# delete from project_methods where project_id=1111 and method_id=4;
#sub addMeth2project {
#        my ($dbh,$methodid,$projectid) = @_;
        #warn Dumper $methodid;
        #warn Dumper $projectid;
#        my $sql = qq{    
#                insert into PolyprojectNGS.project_methods (method_id,project_id) values ($methodid,$projectid);
#        };
#        return ($dbh->do($sql));
#}

############ End Project ##################
#####################################################################################################""
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




########################################################################




sub getCacheVariationsFilekct {
	my ($self,$chr_name) = @_;
	my $dir = $self->getCacheDir();
	confess("give a chromosome name for variations cache") unless $chr_name;
#	my $file_name = $dir."/variations.$chr_name.".$self->name().".store.gz";
	my $file_name = $dir."/variations.$chr_name.".$self->name().".kct";
}



sub getSequencingMachines_v2 {
	my ($self) = @_;
	my @res = queryPolyproject::getSeqMachines($self->buffer->dbh,$self->id);
	return \@res;
	
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



1;
