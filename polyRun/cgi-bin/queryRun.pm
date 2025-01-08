package queryRun;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

####  tabix RTT2111_Cas_Index.cov.gz mean_all

sub get_coverage_patient{
	my($coverage_infile) = @_;	
	my $tabix = new Tabix(-data =>$coverage_infile);
	my $res = $tabix->query("mean_all");
#	warn Dumper $res;
	my @result;
	my $cov;
	my $line;
	eval {$line = $tabix->read($res)};	
	if ( $@ ) {
		if ($@ =~ "iter is not of type ti_iter_t") {return \@result;}
	} else {
	while(my $line = $tabix->read($res)){
		my %s;
		my($a,$b,$c) = split(" ",$line);
		next if $b==1;
#		next if $c==1;
		if ($b==5 || $b==15 || $b==30 ) {
			if ($c>=0.99994 && $c<1) {
				$c=0.99994;
			}
		}
		$s{cov5} = sprintf("%2.2f",$c*=100) if $b==5;
		$s{cov15} = sprintf("%2.2f",$c *=100) if $b==15;
		$s{cov30} = sprintf("%2.2f",$c *=100 )if $b==30;
		$s{cov99} = sprintf("%2.2f",$c) if $b==99;
		push(@result,\%s);
	}
	return \@result;
	}
}

sub getProjectIdfromPatient {
	my ($dbh,$rid) = @_;
	my $query = qq{
		select distinct a.project_id,a.run_id
		FROM PolyprojectNGS.patient a
		where a.run_id='$rid'
		and not a.project_id = 0;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getProjectNamefromPatientId{
	my ($dbh,$rid,$patid) = @_;
	my $query = qq{
		SELECT distinct p.name
		FROM 
		PolyprojectNGS.patient a,
		PolyprojectNGS.projects p
		where a.run_id='$rid'
		and a.patient_id='$patid'
		and a.project_id=p.project_id
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}



sub getRunIdfromProjectPatientId {
	my ($dbh,$pid,$patid) = @_;
#	warn $gid;
	my $query = qq{
		select a.run_id
		FROM PolyprojectNGS.patient a
		where a.project_id='$pid'
		and a.patient_id='$patid';
	};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{run_id};
}

sub getRunIdfromPatientGenboId {
	my ($dbh,$gid) = @_;
#	warn $gid;
	my $query = qq{
		select a.run_id
		FROM PolyprojectNGS.patient a
		where a.genbo_id='$gid';
	};
	my $sth = $dbh->prepare( $query );
	$sth->execute();
	my $res = $sth->fetchall_arrayref({});
	return $res->[0]->{run_id};
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

sub getRunfromPatient {
	my ($dbh,$rid) = @_;
	my $query2 = qq {and a.run_id in ($rid)};
	$query2 = "" unless $rid;
	my $query = qq{
		select distinct a.run_id
		FROM PolyprojectNGS.patient a
		where a.run_id>0
		and a.project_id>0
		$query2		
		order by a.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getRunfromPatientMac {
	my ($dbh,$mid,$rid) = @_;
	my $query2 = qq {and a.run_id in ($rid)};
	$query2 = "" unless $rid;
	my $query = qq{
		select distinct a.run_id
		FROM 
        PolyprojectNGS.patient a,
        PolyprojectNGS.run r,
        PolyprojectNGS.run_machine rm
		where a.run_id>0
		and a.project_id>0
        and a.run_id = r.run_id
        and r.run_id = rm.run_id
        and rm.machine_id='$mid'
		$query2		
		order by a.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getRunfromPatientMacPlt {
	my ($dbh,$mid,$pltid,$rid) = @_;
	my $query2 = qq {and a.run_id in ($rid)};
	$query2 = "" unless $rid;
	my $query = qq{
		select distinct a.run_id
		FROM 
        PolyprojectNGS.patient a,
        PolyprojectNGS.run r,
        PolyprojectNGS.run_machine rm,
        PolyprojectNGS.run_plateform rp
		where a.run_id>0
		and a.project_id>0
        and a.run_id = r.run_id
        and r.run_id = rm.run_id
        and r.run_id = rp.run_id
        and rm.machine_id='$mid'
        and rp.plateform_id='$pltid'        
		$query2		
		order by a.run_id desc;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getRunId {
	my ($dbh,$rid) = @_;
	my $query2 = qq {where r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT DISTINCT r.run_id
		FROM PolyprojectNGS.run r
		$query2
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
		SELECT DISTINCT
		r.run_id,r.description,
		r.file_name as FileName,r.file_type as FileType,
		r.ident_seq as gMachine,r.nbrun_solid as gRun,
		r.plateform_run_name as pltRun,
		r.creation_date as cDate
		FROM 
		PolyprojectNGS.run r
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
	my ($dbh,$rid) = @_;
	my $query2 = qq {and r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,r.description,
		r.file_name as FileName,r.file_type as FileType,
		r.ident_seq as gMachine,r.nbrun_solid as gRun,
		r.plateform_run_name as pltRun,
		r.creation_date as cDate,
		S.machine_id as macId,
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


sub getPlateformFromRun {
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

############ Project     ##################
sub getProject{
	my ($dbh)=@_;
	my $sql = qq{
		select distinct p.project_id as id , p.name as name,
		p.description as description,
		p.creation_date as cDate
 		from PolyprojectNGS.projects p ,
   		PolyprojectNGS.databases_projects dp
		where p.type_project_id=3
    	and p.project_id =dp.project_id
    	and dp.db_id !=2
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

############ Run     ##################
############ Patient     ##################
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

1;