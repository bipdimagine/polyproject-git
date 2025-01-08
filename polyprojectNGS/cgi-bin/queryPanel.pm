package queryPanel;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;



############ Plateform #####################
sub getPlateformId{
	my ($dbh,$plateformid)=@_;
	my $sql2 = qq {where f.plateform_id='$plateformid'};
	$sql2 = "" unless $plateformid;
	my $sql = qq{
		select  f.plateform_id as plateformId,f.name as plateformName
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
############ Machine #######################
sub getMachineId{
        my ($dbh,$machineid)=@_;
		my $sql2 = qq {where S.machine_id='$machineid'};
		$sql2 = "" unless $machineid;
        my $sql = qq{
			select  S.machine_id as machineId,S.name as macName,
			S.type as macType
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

############ Method_Seq #####################
sub getSeqMethodId{
        my ($dbh,$methodseqid)=@_;
		my $sql2 = qq {where ms.method_seq_id='$methodseqid'};
		$sql2 = "" unless $methodseqid;
        my $sql = qq{
			select  ms.method_seq_id as methodSeqId,ms.name as methSeqName
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
############ Method ########################
sub getAlnMethodId{
        my ($dbh,$methid)=@_;
		my $sql2 = qq {and M.method_id='$methid'};
		$sql2 = "" unless $methid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
			from PolyprojectNGS.methods M 
			where M.type='ALIGN'
			$sql2
			order by M.name
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

sub getCallMethodId{
        my ($dbh,$methid)=@_;
		my $sql2 = qq {and M.method_id='$methid'};
		$sql2 = "" unless $methid;
        my $sql = qq{
			select  M.method_id as methodId,M.name as methName,
			M.type as methType
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


################################# Schemas Validation #########################################
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

sub countIn_TablesValidation {
	my ($dbh,$name,$table) = @_;
	my $sql;
	$sql = qq{select count(*) as NB from `$name`.$table};
 	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#################################### Capture ##################################################
sub getCaptureId{
        my ($dbh,$capid)=@_;
		my $query2 = qq {where C.capture_id='$capid'};
		$query2 = "" unless $capid;
        my $sql = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType,
			C.analyse as capAnalyse,
			C.method as capMeth,
			C.release_id as capRel,
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

sub getCaptureIdSingle{
	my ($dbh,$capid)=@_;
	my $query2 = qq {where C.capture_id='$capid'};
	$query2 = "" unless $capid;
	my $query = qq{
		select  C.capture_id as captureId,C.name as capName,
		C.version as capVs, C.description as capDes,
		C.filename as capFile, C.type as capType,
		C.analyse as capAnalyse,
		C.method as capMeth,
		C.release_id as capRel,
		C.validation_db as capValidation,
		C.primers_filename as capFilePrimers
		from PolyprojectNGS.capture_systems C
		$query2			
		;
	};
 	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCaptureFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes, C.analyse as capAnalyse,
			C.filename as capFile, C.type as capType
			from PolyprojectNGS.capture_systems C
			where C.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getCaptureFromAnalyse {
	my ($dbh,$analyse) = @_;
	my $query = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType,
			C.analyse as capAnalyse,
			C.method as capMeth,
			C.primers_filename as capFilePrimers
			from PolyprojectNGS.capture_systems C
			where C.analyse='$analyse';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
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
	my ($dbh,$capture,$capVs,$capDes,$capFile,$capFilePrimers,$capType,$capMeth,$releaseid,$capAnalyse) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.capture_systems (name,version,description,filename,primers_filename,type,method,release_id,analyse)
		values ('$capture','$capVs','$capDes','$capFile','$capFilePrimers','$capType','$capMeth','$releaseid','$capAnalyse');
  	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.capture_systems;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
 }

sub upCaptureData {
        my ($dbh,$capid,$capture,$capVs,$capDes,$capAnalyse,$capFile,$capFilePrimers,$capType,$capMeth,$releaseid) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set name='$capture',version='$capVs',description='$capDes',analyse='$capAnalyse',filename='$capFile',primers_filename='$capFilePrimers',type='$capType',method='$capMeth',release_id='$releaseid'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

sub upCaptureAnalyse {
        my ($dbh,$capid,$capAnalyse) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.capture_systems
 			set analyse='$capAnalyse'
 			where capture_id='$capid';
  		};
 		return ($dbh->do($sql));
}

#################################### Panel ##################################################
sub getPanel {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
			select
			n.name as panName, n.panel_id, n.validation_db
			from PolyprojectNGS.panel n
			$query2;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getValidation {
	my ($dbh,$validation) = @_;
	my @validation=$validation;
	my $query2 = qq {where n.validation_db not in (@validation)};
	$query2 = "" unless $validation;
	my $query = qq{
			select
			n.name as panName, n.panel_id, n.validation_db
			from PolyprojectNGS.panel n
			$query2;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getNameFromPanelId {
	my ($dbh,$panid) = @_;
	my $query = qq{
			select n.name as panName
			from PolyprojectNGS.panel n
			where n.panel_id='$panid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getPanelIdFromName {
	my ($dbh,$name) = @_;
	my $query = qq{
			select n.panel_id, n.name as panName
			from PolyprojectNGS.panel n
			where binary n.name='$name';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getLastPanel {
	my ($dbh) = @_;
	my $query = qq{
		SELECT MAX(panel_id) as panel_id from PolyprojectNGS.panel;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPanelsfromCapture {
	my ($dbh,$capid,$panid) = @_;
	my $query2 = qq {where cs.capture_id='$capid'};
	$query2 = "" unless $capid;
	my $query3 = qq {and n.panel_id='$panid'};
	$query3 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        cs.capture_id as capId, cs.name as capName,
 		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
        r.name as capRel
		FROM PolyprojectNGS.panel n
  		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
 		$query2
 		$query3
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub geDistinctPanelsfromCapture {
	my ($dbh,$capid,$panid) = @_;
	my $query2 = qq {where cs.capture_id='$capid'};
	$query2 = "" unless $capid;
	my $query3 = qq {and n.panel_id='$panid'};
	$query3 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
        n.panel_id as panId,
 		n.name as panName,
        n.validation_db as panValidation,
--       cs.capture_id as capId,
		GROUP_CONCAT(DISTINCT cs.capture_id ORDER BY cs.capture_id ASC SEPARATOR ' ') as 'capId'
--       cs.name as capName,
-- 		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
--       r.name as capRel
		FROM PolyprojectNGS.panel n
  		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
        GROUP BY panId
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub getPanelInfovsCapture {
	my ($dbh,$panid,$capid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query3 = qq {and cs.capture_id='$capid'};
	$query3 = "" unless $capid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        cs.capture_id as capId, cs.name as capName,
		cs.version as capVs, cs.description as capDes,
		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
		cs.filename as capFile, cs.primers_filename as capFilePrimers,
        r.name as capRel
 --       GROUP_CONCAT(DISTINCT b.name ORDER BY b.name ASC SEPARATOR ' ') as 'bunName',
 --       COUNT(DISTINCT b.name) as 'nbBun'
		FROM PolyprojectNGS.panel n
  		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON cs.capture_id=cb.capture_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON cb.bundle_id=b.bundle_id
 		$query2
 		$query3
--       GROUP BY capId
        ORDER BY panId
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

sub getPanelBundlevsCapture {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        cs.capture_id as capId, cs.name as capName,
		cs.version as capVs, cs.description as capDes,
		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
		cs.filename as capFile, cs.primers_filename as capFilePrimers,
        r.name as capRel,
        GROUP_CONCAT(DISTINCT b.name ORDER BY b.name ASC SEPARATOR ' ') as 'bunName',
        COUNT(DISTINCT b.name) as 'nbBun'
		FROM PolyprojectNGS.panel n
  		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON cs.capture_id=cb.capture_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON cb.bundle_id=b.bundle_id
 		$query2
        GROUP BY capId
        ORDER BY panId
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

sub getPanelvsCapture {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        cs.capture_id as capId, cs.name as capName,
		cs.version as capVs, cs.description as capDes,
		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
		cs.filename as capFile, cs.primers_filename as capFilePrimers,
        r.name as capRel
 		FROM PolyprojectNGS.panel n
  		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
 		$query2
        ORDER BY panId
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

sub getPanelvsBundle {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        cs.capture_id as capId, cs.name as capName,
		cs.version as capVs, cs.description as capDes,
		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
		cs.filename as capFile, cs.primers_filename as capFilePrimers,
        r.name as capRel
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bp
		ON n.panel_id = bp.panel_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON bp.bundle_id=b.bundle_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON b.bundle_id=cb.bundle_id
 		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON cb.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
 		ON cs.release_id = r.release_id
 		$query2
        ORDER BY panId
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

sub getDetailPanel {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where n.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
		SELECT DISTINCT
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
        bp.panel_id as bp_panId,
        GROUP_CONCAT(DISTINCT b.bundle_id ORDER BY b.bundle_id ASC SEPARATOR ' ') as 'bunId',
        GROUP_CONCAT(DISTINCT b.name ORDER BY b.bundle_id ASC SEPARATOR ' ') as 'bunName',
        cs.capture_id as capId, cs.name as capName,
		cs.version as capVs, cs.description as capDes,
		cs.analyse as capAnalyse, cs.type as capType, cs.method as capMeth,
		cs.filename as capFile, cs.primers_filename as capFilePrimers,
        r.name as capRel
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bp
		ON n.panel_id = bp.panel_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON bp.bundle_id=b.bundle_id
 		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
 		LEFT JOIN PolyprojectNGS.releases r
		ON cs.release_id = r.release_id
		GROUP BY  capId
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

#not used
sub getPanelInfo {
	my ($dbh,$capid) = @_;
	my $query2 = qq {where  cb.capture_id='$capid'};
	$query2 = "" unless $capid;
	my $query = qq{
		SELECT distinct
		n.name as panName,n.validation_db,
		bn.panel_id as panId, bn.bundle_id as bunId,
		b.name as bunName,
		cb.capture_id as capId,
		cs.name as capName
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bn
		ON n.panel_id = bn.panel_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON bn.bundle_id = b.bundle_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON b.bundle_id = cb.bundle_id
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON cb.capture_id = cs.capture_id
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

#not used
sub delPanel {
	my ($dbh,$panelid) = @_;
	my $sql = qq{
		DELETE FROM PolyprojectNGS.panel
		where panel_id='$panelid';
	};
 	return ($dbh->do($sql));
}

sub newPanel {
	my ($dbh,$name,$validation) = @_;
	my $query = qq{    
		insert into PolyprojectNGS.panel (name,validation_db) values ('$name','$validation');
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from PolyprojectNGS.panel;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
} 

sub upPanelName {
        my ($dbh,$panid,$panName) = @_;
 		my $sql = qq{    
 			update PolyprojectNGS.panel
 			set name='$panName'
 			where panel_id='$panid';
  		};
 		return ($dbh->do($sql));
}

################################## Panel_Capture ############################################
sub searchPanelCapture {
	my ($dbh,$val,$valB) = @_;
	my $query2;
	$query2 = qq {where pc.panel_id='$val'} unless $valB;
	$query2 = qq {where pc.capture_id='$val'} if $valB;
	$query2 = "" unless $val;
	
	my $query = qq{
		select * from PolyprojectNGS.panel_capture pc
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

sub getPanelCapture {
	my ($dbh,$panelid,$captureid) = @_;
	my $query = qq{
		select * from PolyprojectNGS.panel_capture pc
		where pc.panel_id='$panelid'
		and pc.capture_id='$captureid'
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub addPanel2Capture {
	my ($dbh,$panid,$capid) = @_;
	my $sql = qq{    
		insert into PolyprojectNGS.panel_capture (panel_id,capture_id) values ($panid,$capid);
	};
	return ($dbh->do($sql));
}

sub removePanel2Capture {
	my ($dbh,$panid,$capid) = @_;
	my $sql = qq{  
		delete from  PolyprojectNGS.panel_capture 
		where capture_id='$capid'
		and panel_id='$panid'
	};
	return ($dbh->do($sql));
}

################################# Capture_Bundle ############################################
sub searchCaptureBundle {
	my ($dbh,$val,$valB) = @_;
	my @val=$val ;
	my $query2;
	$query2 = qq {where cb.bundle_id in (@val)} unless $valB;
	$query2 = qq {where cb.capture_id in (@val)} if $valB;
    $query2 = "" unless $val;
	
	my $query = qq{
		select * from PolyprojectNGS.capture_bundle cb
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

sub getCaptureBundle {
	my ($dbh,$captureid,$bundleid) = @_;
	my $query = qq{
		select * from PolyprojectNGS.capture_bundle cb
		where cb.bundle_id='$bundleid'
		and cb.capture_id='$captureid'
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#not used
sub getBundleCapture {
	my ($dbh,$bundleid) = @_;
	my $query = qq{
			select cs.name, cs.validation_db, cs.method, cs.type, cs.capture_id
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

sub getCaptureBundleId {
	my ($dbh,$bundleid,$captureid) = @_;
	my $query2 = qq {and cb.capture_id='$captureid'};
	$query2 = "" unless $captureid;
	my $query = qq{
			select cb.bundle_id, cb.capture_id
			from 
			PolyprojectNGS.capture_bundle cb
			where cb.bundle_id='$bundleid'
			$query2
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

sub newCaptureBundle {
        my ($dbh,$captureid,$bundleid)=@_;
        my $sql = qq{
        	insert into PolyprojectNGS.capture_bundle (capture_id,bundle_id) 
        	values ('$captureid','$bundleid');       	
		};
 		return ($dbh->do($sql));
}

sub delCaptureBundle {
        my ($dbh,$captureid,$bundleid)=@_;
        my $sql = qq{
 			delete from  PolyprojectNGS.capture_bundle     	
  			where capture_id='$captureid'
			and bundle_id='$bundleid'
		};
 		return ($dbh->do($sql));
}

################################## Bundle_Panel #############################################
sub searchBundlePanel {
	my ($dbh,$val,$valB) = @_;
	my $query2;
	$query2 = qq {where bp.bundle_id='$val'} unless $valB;
	$query2 = qq {where bp.panel_id='$val'} if $valB;
	$query2 = "" unless $val;
	
	my $query = qq{
		select * from PolyprojectNGS.bundle_panel bp
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

sub getBundlePanel{
	my ($dbh,$bundleid,$panelid)=@_;
	my $query = qq{        	
		select *
		from PolyprojectNGS.bundle_panel bp
		where bp.bundle_id='$bundleid'
		and bp.panel_id='$panelid'
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#not used
sub delBundle2Panel {
	my ($dbh,$bundleid,$panid) = @_;
	my $sql = qq{    
		delete from  PolyprojectNGS.bundle_panel 
		where bundle_id='$bundleid'
		and panel_id='$panid'
	};
	return ($dbh->do($sql));
}

sub addBundlePanel {
	my ($dbh,$bundleid,$panid) = @_;
	my $sql = qq{    
		insert into PolyprojectNGS.bundle_panel (bundle_id,panel_id) values ($bundleid,$panid);
	};
	return ($dbh->do($sql));
}

sub delBundlePanel {
	my ($dbh,$bundleid,$panid) = @_;
	my $sql = qq{    
		delete from  PolyprojectNGS.bundle_panel 
		where bundle_id='$bundleid'
		and panel_id='$panid'
	};
	return ($dbh->do($sql));
}

##################################### Bundle ################################################
sub getBundle {
	my ($dbh,$bunid)=@_;
	my $query2 = qq {where b.bundle_id='$bunid'};
	$query2 = "" unless $bunid;
	my $query = qq{        	
		select b.bundle_id as bundleId,b.name as bunName,
		b.version as bunVs, b.description as bunDes,
		b.creation_date as cDate, b.mesh_id as meshid
		from PolyprojectNGS.bundle b
		$query2;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getBundleFromPanel {
	my ($dbh,$panelid,$captureid,$exclude) = @_;
	my $query2;
	$query2 = qq {where pc.panel_id='$panelid' and pc.capture_id='$captureid'} unless $exclude;
	my $query = qq{
		SELECT distinct
		n.name as panName, n.panel_id as panId,n.validation_db as panValidation,
		cs.name as capName, cs.capture_id as capId,cs.method as capMeth, cs.type as capType,
		b.bundle_id as bundleId, b.name as bunName, 
		b.description as bunDes, b.version as bunVs,
		b.creation_date as cDate, b.mesh_id as meshid
		FROM PolyprojectNGS.panel_capture pc
		LEFT JOIN PolyprojectNGS.panel n
		ON n.panel_id = pc.panel_id
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON cs.capture_id=cb.capture_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON cb.bundle_id=b.bundle_id		
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

sub getBundleNoCapFromBundlePanel {
	my ($dbh,$panelid,$exclude) = @_;
	my $query2;
	$query2 = qq {WHERE n.panel_id='$panelid'} unless $exclude;
	$query2 = qq {WHERE n.panel_id!='$panelid'} if $exclude;
	my $query = qq{
		SELECT DISTINCT
		b.name as bunName, b.bundle_id,
		n.panel_id
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bp
		ON n.panel_id = bp.panel_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON bp.bundle_id=b.bundle_id		
        $query2
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

sub getBundleFromBundlePanel {
	my ($dbh,$panelid,$captureid) = @_;
	my $query2 = qq {AND cb.capture_id='$captureid'};
	$query2 = "" unless $captureid;
	my $query = qq{
		SELECT DISTINCT
		b.name as bunName, b.bundle_id as bunId
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bp
		ON n.panel_id = bp.panel_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON bp.bundle_id = cb.bundle_id
		LEFT JOIN PolyprojectNGS.bundle b
		ON cb.bundle_id=b.bundle_id		
        WHERE n.panel_id='$panelid'
		$query2
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

sub getBundleCaptureFromBundlePanel {
	my ($dbh,$panelid,$captureid,$exclude) = @_;
	my $query2;
	$query2 = qq {WHERE n.panel_id!='$panelid'} if $exclude;
	$query2 = qq {WHERE n.panel_id='$panelid' AND cb.capture_id='$captureid'} unless $exclude;
	my $query = qq{
		SELECT DISTINCT
		n.panel_id,cb.bundle_id,cb.capture_id
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.bundle_panel bp
		ON n.panel_id = bp.panel_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON bp.bundle_id = cb.bundle_id
        $query2
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

sub getBundleCaptureFromBundlePanelbyPC {
	my ($dbh,$panelid,$captureid,$exclude) = @_;
	my $query2;
#	$query2 = qq {WHERE n.panel_id!='$panelid'} if $exclude;
	$query2 = qq {WHERE n.panel_id='$panelid' AND pc.capture_id='$captureid'};
	my $query = qq{
	SELECT DISTINCT
	n.panel_id,bp.bundle_id,pc.capture_id
	FROM PolyprojectNGS.panel n
	LEFT JOIN PolyprojectNGS.bundle_panel bp
	ON n.panel_id = bp.panel_id
	LEFT JOIN PolyprojectNGS.panel_capture pc
	ON n.panel_id = pc.panel_id
        $query2
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

sub getBundleCaptureFromPanelCapture {
	my ($dbh,$panelid,$captureid,$exclude) = @_;
	my $query2;
	$query2 = qq {WHERE n.panel_id!='$panelid'} if $exclude;
	$query2 = qq {WHERE n.panel_id='$panelid' AND cb.capture_id='$captureid'} unless $exclude;
	my $query = qq{
	SELECT DISTINCT
		n.panel_id, cb.capture_id,cb.bundle_id
		FROM PolyprojectNGS.panel n
		LEFT JOIN PolyprojectNGS.panel_capture pc
		ON n.panel_id = pc.panel_id
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON pc.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.capture_bundle cb
		ON cs.capture_id=cb.capture_id	
        $query2
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

################################### Transcripts #############################################
sub countTranscriptFromPanelCaptureBundle {
	my ($dbh,$panid,$capid)=@_;
	my @capid=$capid ;
	my $query2 = qq {AND cb.capture_id in (@capid)};
	$query2 = "" unless $capid;
 	my $sql = qq{
 		SELECT COUNT(*) as nb
 		FROM (
			SELECT DISTINCT
			b.bundle_id,
			bt.transcript_id
			FROM 
			PolyprojectNGS.capture_bundle cb
			LEFT JOIN PolyprojectNGS.bundle b
			ON cb.bundle_id=b.bundle_id
            LEFT JOIN PolyprojectNGS.bundle_panel bp
            ON b.bundle_id = bp.bundle_id
			LEFT JOIN PolyprojectNGS.bundle_transcripts bt
			ON b.bundle_id=bt.bundle_id
			WHERE bt.transcript_id is not null
			AND bp.panel_id='$panid'
			$query2
		) as TRid
		;		
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchrow_array;
	$sth->finish;
	return $res;
}

#not used , but used in queryPolyproject
sub countTranscriptFromCaptureBundle {
	my ($dbh,$capid)=@_;
	my @capid=$capid ;
	my $query2 = qq {and cb.capture_id in (@capid)};
	$query2 = "" unless $capid;
 	my $sql = qq{
 		SELECT COUNT(*) as nb
 		FROM (
			SELECT DISTINCT
			bt.transcript_id
			FROM 
			PolyprojectNGS.capture_bundle cb
			LEFT JOIN PolyprojectNGS.bundle b
			ON cb.bundle_id=b.bundle_id
            LEFT JOIN PolyprojectNGS.bundle_panel bn
            ON b.bundle_id = bn.bundle_id
			LEFT JOIN PolyprojectNGS.bundle_transcripts bt
			ON b.bundle_id=bt.bundle_id
			WHERE bt.transcript_id is not null
			$query2
		) as TRid
		;		
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchrow_array;
	$sth->finish;
	return $res;
}

sub countTranscriptFromBundle {
	my ($dbh,$bunid)=@_;
 	my $sql = qq{
 		SELECT COUNT(*) as nb
 		FROM (
			SELECT DISTINCT
			b.bundle_id,
			bt.transcript_id

			FROM 
			PolyprojectNGS.bundle b
			LEFT JOIN PolyprojectNGS.bundle_transcripts bt
			ON b.bundle_id=bt.bundle_id

           where bt.bundle_id='$bunid'	
		) as TRid
		;		
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $res = $sth->fetchrow_array;
	$sth->finish;
	return $res;
}

###################################### Group ################################################
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
	return \@res if \@res;
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
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

#not used
sub getPatientGroups {
	my ($dbh,$groupid,$patid) = @_;
	my $query2 = qq {and pg.patient_id='$patid'};
	$query2 = "" unless $patid;
	my $query = qq{
			select pg.patient_id, pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.group_id='$groupid'
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

sub getPatientIdFromPatientGroups {
	my ($dbh,$groupid,$patid) = @_;
	my $query2 = qq {and pg.patient_id='$patid'};
	$query2 = "" unless $patid;
	my $query = qq{
			select pg.patient_id, pg.group_id
			from PolyprojectNGS.patient_groups pg
			where pg.group_id='$groupid'
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

#not used, but used in queryPolyproject 
sub searchGroup {
	my ($dbh,$groupid) = @_;
	my $query2 = qq {where g.group_id='$groupid'};
	$query2 = "" unless $groupid;
	my $query = qq{
		select * from PolyprojectNGS.group g
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

#not used
sub getNameFromGroupId {
	my ($dbh,$groupid) = @_;
	my $query = qq{
			select g.name as groupName
			from PolyprojectNGS.group g
			where g.group_id='$groupid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

#not used
sub upGroup {
        my ($dbh,$groupid,$group) = @_;
        my $sql = qq{
        	update PolyprojectNGS.group
        	set name='$group'
        	where group_id='$groupid';
        };
        return ($dbh->do($sql));
} 

################################### Releases ################################################
sub getReleaseId{
	my ($dbh,$releaseid)=@_;
	my $query2 = qq {where R.release_id='$releaseid'};
	$query2 = "" unless $releaseid;
	my $sql = qq{
			select  R.release_id as releaseId,R.name as relName
			from PolyprojectNGS.releases R
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

##################################### Patient ################################################

sub getPatientInfoFromProject {
	my ($dbh,$numAnalyse,$pid) = @_;
	my $query2;
	$query2 = qq {where C.analyse in ("exome","genome")} if $numAnalyse == 1;
	$query2 = qq {where C.analyse ="target"} if $numAnalyse == 2;
	$query2 = qq {where C.analyse ="rnaseq"} if $numAnalyse == 3;
	$query2 = qq {where C.analyse in ("exome","genome","target","rnaseq")} if $numAnalyse == 4;
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
 		n.name as panName,
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
 		LEFT JOIN PolyprojectNGS.panel n
        ON a.panel_id=n.panel_id
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

sub getPatientFromPatientId {
	my ($dbh,$patid) = @_;
	my $query = qq{
		select a.patient_id,a.name,a.project_id,a.run_id,a.capture_id
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getPatientFromName {
	my ($dbh,$name,$runid,$projectid) = @_;
	my $query2 = qq {and  a.run_id='$runid'};
	$query2 = "" unless $runid;
	my $query3 = qq {and a.project_id='$projectid'};
	$query3 = "" unless $projectid;
	my $query = qq{
		select a.patient_id,a.name,a.project_id,a.run_id,a.capture_id,a.panel_id,
		a.family,a.father,a.mother,a.sex,a.status,a.bar_code,a.flowcell
		FROM PolyprojectNGS.patient a
		where a.name='$name'
		$query2
		$query3
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

sub getDates_Patient{
	my ($dbh,$patid) = @_;
	my $query = qq{
		select a.patient_id,a.creation_date,a.update_date
		FROM PolyprojectNGS.patient a
		where a.patient_id='$patid';
			};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}


#with Panel
sub getPanelFromPatientId {
	my ($dbh,$patid) = @_;
	my $query2 = qq {where  a.patient_id='$patid'};
	$query2 = "" unless $patid;
	my $query = qq{
        SELECT DISTINCT
        a.patient_id,n.panel_id, n.name as panName, n.validation_db as panValidation
        FROM PolyprojectNGS.patient a
        LEFT JOIN PolyprojectNGS.panel n
        ON a.panel_id = n.panel_id
		$query2
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}

#not used
sub searchPatientIdFromPanelId {
	my ($dbh,$panid) = @_;
	my $query2 = qq {where a.panel_id='$panid'};
	$query2 = "" unless $panid;
	my $query = qq{
        SELECT DISTINCT
        a.patient_id,a.panel_id
        FROM PolyprojectNGS.patient a
		$query2
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

# not used
sub getPatientFromCaptureId {
	my ($dbh,$capid) = @_;
	my $query = qq{
		SELECT 
		a.patient_id, a.name as pat_name, a.capture_id ,
		a.run_id, a.project_id, a.project_id_dest,
		p.name as proj_name
		FROM PolyprojectNGS.patient a
        LEFT JOIN PolyprojectNGS.projects p
        ON a.project_id = p.project_id
		where a.capture_id = '$capid';	
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

# not used
sub getPatientInfoFromPatientId {
	my ($dbh,$patid) = @_;
	my $query = qq{
		SELECT 
--		a.patient_id, a.name as pat_name, a.capture_id , a.panel_id,
--		a.run_id, a.project_id, a.project_id_dest,
		a.*,
		p.name as proj_name
		FROM PolyprojectNGS.patient a
        LEFT JOIN PolyprojectNGS.projects p
        ON a.project_id = p.project_id
		where a.patient_id = '$patid';	
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
		select a.name as name, a.patient_id,a.project_id,a.run_id,a.capture_id,a.panel_id,
		a.bar_code,a.sex,a.status,a.description,a.flowcell,a.creation_date as cDate,
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

sub getPatientProjectInfo {
	my ($dbh,$pid,$rid) = @_;
	my $query2 = qq {and a.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query = qq{
		SELECT distinct a.project_id,a.run_id,a.name,a.patient_id,
		a.project_id_dest,a.family,a.father,a.mother,a.sex,a.status,a.bar_code,a.flowcell,
		r.description as desRun, r.document,r.name as nameRun,
		r.file_name as FileName,r.file_type as FileType,		
		S.name as macName,
       	GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		ms.name as methSeqName,
		C.name as capName,
		a.creation_date as cDate,
		a.update_date as uDate
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

sub getPatientsInfoProjectDest {
	my ($dbh,$rid,$pid) = @_;
	my $query2 = qq {and a.project_id_dest='$pid'};
	$query2 = "" unless $pid;
	my $query = qq{
		select a.name as name, a.patient_id,a.project_id_dest,a.run_id,a.capture_id,
		a.family,a.father,a.mother,a.flowcell,
		a.bar_code,a.sex,a.status,a.description,
		a.creation_date as cDate,a.update_date as uDate,
		a.project_id
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




sub newPatientRun {
	my ($dbh,$patient,$origin,$rid,$captureid,$panelid,$fam,$fc,$bc,$father,$mother,$sex,$status) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,run_id,capture_id,panel_id,family,flowcell,bar_code,father,mother,sex,status,creation_date) 
 		values ("$patient","$origin","$rid","$captureid","$panelid","$fam","$fc","$bc","$father","$mother","$sex","$status",now());
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

sub addPatientRun {
	my ($dbh,$patient,$origin,$rid,$captureid,$fam,$sex,$status,$desPat,$bc) = @_;
	my $query = qq{    
 		insert into PolyprojectNGS.patient (name,origin,run_id,capture_id,family,sex,status,description,bar_code,creation_date) 
 		values ("$patient","$origin","$rid","$captureid","$fam","$sex","$status","$desPat","$bc",now());
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

sub upPatientPanel {
        my ($dbh,$patid,$panid,$runid) = @_;
		my $sql2 = qq {and run_id='$runid'};
		$sql2 = "" unless $runid;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set panel_id='$panid' 
        	where patient_id='$patid'
  			$sql2;
        };
        return ($dbh->do($sql));
}
 
sub upPatientCapture {
        my ($dbh,$patid,$capid,$runid) = @_;
		my $sql2 = qq {and run_id='$runid'};
		$sql2 = "" unless $runid;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set capture_id='$capid' 
        	where patient_id='$patid'
  			$sql2;
        };
        return ($dbh->do($sql));
} 

sub upPatientInfo {
        my ($dbh,$patid,$patname,$sex,$status,$desPat,$bc,$flowcell,$family,$father,$mother,$panid,$capid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set name='$patname', sex='$sex',status='$status',description='$desPat',bar_code='$bc',
        	flowcell='$flowcell',family='$family',father='$father',mother='$mother',panel_id='$panid',
        	capture_id='$capid'
        	where patient_id='$patid';
        };
        return ($dbh->do($sql));
} 

sub upDatePatient {
	    my ($dbh,$patid) = @_;
        my $sql = qq{
        	update PolyprojectNGS.patient 
        	set creation_date=update_date
        	where patient_id='$patid';
        };
         return ($dbh->do($sql));
}

sub addPatientInfo {
        my ($dbh,$patname,$patname,$rid,$sex,$status,$desPat,$bc,$flowcell,$family,$father,$mother,$panid,$capid,$pid) = @_;
        my $query = qq{
        	insert into  PolyprojectNGS.patient (name,origin,run_id,sex,status,description,bar_code,flowcell,family,father,mother,panel_id,capture_id,project_id_dest,creation_date)
        	values ('$patname','$patname','$rid','$sex','$status','$desPat','$bc','$flowcell','$family','$father','$mother','$panid','$capid','$pid',now())
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

####################################### Run #################################################
sub getRunInfo {
	my ($dbh,$rid,$pltid) = @_;
	my $query2 = qq {where r.run_id='$rid'};
	$query2 = "" unless $rid;
	my $query3 = qq {and rp.plateform_id='$pltid'};
	$query3 = "" unless $pltid;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient as 'nbpatRun',
		r.file_name as FileName,r.file_type as FileType,
		r.ident_seq as gMachine,r.nbrun_solid as gRun,
		r.creation_date as cDate,r.step,r.plateform_run_name as pltRun,
		S.name as macName,
		ms.name as methSeqName,
		GROUP_CONCAT(distinct if (p.somatic=1,1,null)) as 'somatic',
		GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ',') as 'patName',
		GROUP_CONCAT(DISTINCT a.bar_code ORDER BY a.bar_code ASC SEPARATOR ',') as 'patBC',
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		GROUP_CONCAT(DISTINCT C.capture_id ORDER BY C.capture_id ASC SEPARATOR ' ') as 'capId',
		GROUP_CONCAT(DISTINCT n.name ORDER BY n.name ASC SEPARATOR ' ') as 'panName',
		GROUP_CONCAT(DISTINCT C.name ORDER BY C.name ASC SEPARATOR ' ') as 'capName',
		GROUP_CONCAT(DISTINCT C.analyse ORDER BY C.analyse ASC SEPARATOR ' ') as 'capAnalyse',
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
    	GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable ASC SEPARATOR ' ') as 'username'

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
        
 		LEFT JOIN PolyprojectNGS.panel n
        ON a.panel_id=n.panel_id
        
        
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

sub getAllRunInfo {
	my ($dbh,$numAnalyse,$rid) = @_;
	my $query2;
	$query2 = qq {where C.analyse in ("exome","genome")} if $numAnalyse == 1;
	$query2 = qq {where C.analyse ="target"} if $numAnalyse == 2;
	$query2 = qq {where C.analyse ="rnaseq"} if $numAnalyse == 3;
	$query2 = qq {where C.analyse in ("exome","genome","target","rnaseq")} if $numAnalyse == 4;
	my $query3 = qq {and r.run_id='$rid'};
	$query3 = "" unless $rid;
	my $query = qq{
		SELECT DISTINCT
 		r.run_id,r.name,r.description,r.nbpatient as 'nbpatRun',
		r.creation_date as cDate,r.plateform_run_name as pltRun,
		R.name as capRel,
		GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ',') as 'patName',
		GROUP_CONCAT(DISTINCT a.bar_code ORDER BY a.bar_code ASC SEPARATOR ',') as 'patBC',
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ' ') as 'plateformName',
		GROUP_CONCAT(DISTINCT C.capture_id ORDER BY C.capture_id ASC SEPARATOR ' ') as 'capId',
		GROUP_CONCAT(DISTINCT n.name ORDER BY n.name ASC SEPARATOR ' ') as 'panName',
		GROUP_CONCAT(DISTINCT C.name ORDER BY C.name ASC SEPARATOR ' ') as 'capName',
		GROUP_CONCAT(DISTINCT C.analyse ORDER BY C.analyse ASC SEPARATOR ' ') as 'capAnalyse',
		GROUP_CONCAT(distinct if (p.somatic=1,1,null)) as 'somatic',
		GROUP_CONCAT(DISTINCT p.project_id ORDER BY p.project_id DESC SEPARATOR ' ') as 'ProjectId',
       	GROUP_CONCAT(DISTINCT p.name ORDER BY p.name DESC SEPARATOR ' ') as 'ProjectName',
--		GROUP_CONCAT(DISTINCT pd.project_id ORDER BY pd.project_id DESC SEPARATOR ' ') as 'ProjectDestId',
--		GROUP_CONCAT(DISTINCT pd.name ORDER BY pd.name DESC SEPARATOR ' ') as 'ProjectDestName',
        count(distinct if (a.project_id > 0,a.patient_id,null)) as 'nbPrjRun',
        GROUP_CONCAT(DISTINCT case M.type when 'SNP' THEN M.name ELSE NULL END ORDER BY M.name ASC SEPARATOR ' ') as 'methCall',
        count(distinct case M.type when 'SNP' THEN pm.patient_id ELSE NULL END ) as 'nbCall'

		FROM 
		PolyprojectNGS.run r
        LEFT JOIN PolyprojectNGS.patient a
        ON r.run_id = a.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
        ON r.run_id=rp.run_id
        LEFT JOIN PolyprojectNGS.plateform f
        ON rp.plateform_id=f.plateform_id

		LEFT JOIN PolyprojectNGS.capture_systems C
        ON a.capture_id=C.capture_id
 		LEFT JOIN PolyprojectNGS.releases R
        ON C.release_id=R.release_id
 		LEFT JOIN PolyprojectNGS.panel n
        ON a.panel_id=n.panel_id
        
 		LEFT JOIN PolyprojectNGS.patient_methods pm
		ON a.patient_id = pm.patient_id
		LEFT JOIN PolyprojectNGS.methods M
		ON pm.method_id=M.method_id
		
 		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
--		LEFT JOIN PolyprojectNGS.projects pd
--		ON a.project_id_dest = pd.project_id
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

sub getRunDataInfo {
	my ($dbh,$rid) = @_;
	my $query = qq{
		SELECT DISTINCT
		r.run_id,r.name,r.description,r.nbpatient,r.plateform_run_name
		FROM 
		PolyprojectNGS.run r
		WHERE r.run_id='$rid'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
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

###################################### END ##################################################

1;
