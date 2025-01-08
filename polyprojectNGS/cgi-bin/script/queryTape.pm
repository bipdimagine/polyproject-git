package queryTape;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

######################   Tape  ########################################
sub getLastTape {
	my ($dbh)=@_;
	my $sql = qq{    
		SELECT MAX(tape_id) from Polytape.Tape t;
	};
	return $dbh->selectrow_array($sql);
}

sub newTapeId {
	my ($dbh,$tapenum) = @_;
	my $sql = qq{    
		insert into Polytape.Tape (tape_number)
		values ($tapenum);
	};
 	return ($dbh->do($sql));
}

sub getTape {
	my ($dbh,$tapenum)=@_;
	my $sql2 = qq {where t.tape_number='$tapenum'};
	$sql2 = "" unless $tapenum;
	my $sql = qq{
		select t.tape_id,t.tape_number as tapeNum,
		t.description as tapeDes,
		t.creation_date as cDate
		from Polytape.Tape t
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

sub getTapeOld {
	my ($dbh,$tapenum)=@_;
	my $sql2 = qq {where t.tape_number='$tapenum'};
	$sql2 = "" unless $tapenum;
	my $sql = qq{
		select t.tape_id,t.tape_number as tapeNum,
		t.reference_constructor as tapeRef,
		t.constructor as tapeType,
		t.description as tapeDes,
		t.creation_date as cDate
		from Polytape.Tape t
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

sub getIdfromTapeNumber {
	my ($dbh,$tapenum) = @_;
	my $query = qq{
		select t.tape_number, t.tape_id
		FROM Polytape.Tape t
		where  t.tape_number='$tapenum'
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getIdfromTapeNumberOld {
	my ($dbh,$tapenum,$taperef) = @_;
	my $query2 = qq {and t.reference_constructor='$taperef'};
	$query2 = "" unless $taperef;
	my $query = qq{
		select t.tape_number, t.tape_id
		FROM Polytape.Tape t
		where  t.tape_number='$tapenum'
		$query2;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

######################  Contents ########################################
sub newContent {
	my ($dbh,$pltrun,$listfiles,$typemac,$mac,$plt,$run) = @_;
	my $query = qq{    
		insert into Polytape.Contents (plateform_run_name,list_files_name,type_machine,machine,plateform,run) 
		values ('$pltrun','$listfiles','$typemac','$mac','$plt','$run');
	};
	$dbh->do($query);
	my $sql = qq{    
		SELECT LAST_INSERT_ID() from Polytape.Contents;
	};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub upContent_run {
	my ($dbh,$contentid,$run) = @_;
	my $sql = qq{
		update Polytape.Contents
		set run=?
		where content_id='$contentid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($run);
	$sth->finish;

	return $run;
}

sub upContent_plateform {
	my ($dbh,$contentid,$plateform) = @_;
	my $sql = qq{
		update Polytape.Contents
		set plateform=?
		where content_id='$contentid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($plateform);
	$sth->finish;

	return;
}

sub upContent_machine {
	my ($dbh,$contentid,$machine,$type) = @_;
	my $sql = qq{
		update Polytape.Contents
		set machine=?, type_machine=?
		where content_id='$contentid';
	};
	my $sth= $dbh->prepare($sql);				
	$sth->execute($machine,$type);
	$sth->finish;

	return;
}

sub delContent {
	#cascade deletion in Polytape.Tape_Contents
	my ($dbh,$contentid) = @_;
	my $sql = qq{
		delete from Polytape.Contents
		where content_id=$contentid;
	};
 	return ($dbh->do($sql));
}

sub getFilesListFromContentId {
	my ($dbh,$contentid) = @_;
	my $query = qq{
		SELECT
		c.list_files_name as filesRun
--		c.content_id as filesRun
		FROM 
		Polytape.Contents c
		WHERE
		c.content_id='$contentid';
	};	
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;
}

sub getContentIdfromPltRun {
	my ($dbh,$pltrun) = @_;
	my $query = qq{
		select c.content_id
		FROM Polytape.Contents c
		where c.plateform_run_name='$pltrun'
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
#	my $sth = $dbh->prepare($query);
#	$sth->execute();
#	my $s = $sth->fetchrow_hashref();
#	return $s;
}

######################  Tape_Contents ###################################
sub newTapeContent {
	my ($dbh,$tapeid,$contentid) = @_;
	my $sql = qq{    
		insert into Polytape.Tape_Contents (tape_id,content_id) 
		values (?,?);
	};
	my $sth= $dbh->prepare($sql);
				
	$sth->execute($tapeid,$contentid);
	$sth->finish;

	return;
}

sub getTapeContentsOld {
	my ($dbh,$tapeid,$contentid) = @_;
	my $query2 = qq {and tc.content_id='$contentid'};
	$query2 = "" unless $contentid;
	my $query = qq{
		select tc.tape_id, tc.content_id
		FROM Polytape.Tape_Contents tc
		where tc.tape_id='$tapeid'
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

sub getTapeContents {
	my ($dbh,$tapeid,@contentid) = @_;
#	my @contentid=$contentid;
	my $query2 = qq {and tc.content_id in (@contentid)};
	$query2 = "" unless @contentid;
	my $query = qq{
		select tc.tape_id, tc.content_id
		FROM Polytape.Tape_Contents tc
		where tc.tape_id='$tapeid'
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


sub getContentsFromTapeIdByFilters{
	my $pltrun='';
	my $run='';
	my $plt='';
	my $type='';
	my $mac='';
	my $cid='';
	my ($dbh,$tapeid,$queryfilter) = @_;
	my @filterI = split( /,/, $queryfilter );
	my $query2;
	for (my $i = 0; $i< scalar(@filterI); $i++) {
		my @filterII = split( /=/, @filterI[$i] );
		if  (@filterII[0] eq 'pltrun') {
			$pltrun=@filterII[1];
#			my $queryA = qq {and c.plateform_run_name='$pltrun'};
			my $queryA = qq {and c.plateform_run_name regexp '$pltrun'};
			$query2 .= $queryA." ";
		}
		elsif  (@filterII[0] eq 'run') {
			$run=@filterII[1];
			my $queryA = qq {and c.run regexp '$run'};
			$query2 .= $queryA." ";
		}
		elsif  (@filterII[0] eq 'plateform') {
			$plt=@filterII[1];
			my $queryA = qq {and c.plateform='$plt'};
			$query2 .= $queryA." ";
		}
		elsif (@filterII[0] eq 'type') {
			$type=@filterII[1];
			my $queryA = qq {and c.type_machine regexp '$type'};
			$query2 .= $queryA." ";
		}
		elsif (@filterII[0] eq 'machine') {
			$mac=@filterII[1];
			my $queryA = qq {and c.machine regexp '$mac'};
			$query2 .= $queryA." ";
		}
		elsif (@filterII[0] eq 'cid') {
			@filterII[1]=~ s/;/,/gm;
			$cid=@filterII[1];
			my $queryA = qq {and c.content_id in ($cid)};
			$query2 .= $queryA." ";
		}
		chop $query2;
	}
	my $query = qq{
		SELECT t.tape_id ,
		c.content_id,c.plateform_run_name as pltRun,
--		c.list_files_name as filesRun,
		c.creation_date as cDate,
		c.plateform,c.machine,c.type_machine,c.run
		FROM 
		Polytape.Tape t,
		Polytape.Tape_Contents tc,
		Polytape.Contents c
		WHERE
		t.tape_id='$tapeid'
		and t.tape_id=tc.tape_id
		and tc.content_id=c.content_id
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

############################## Run #######################################
sub getRunIdfromPltRun {
	my ($dbh,$pltrun) = @_;
	my $query = qq{
		select r.run_id
		FROM PolyprojectNGS.run r
		where  r.plateform_run_name='$pltrun';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}
############ Machine #######################
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
############ Machine #######################
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

sub getSequencingMachines {
	my ($dbh,$rid) = @_;
	my $sql = qq{
		select S.name as name,S.type as type		
		from PolyprojectNGS.run_machine rm, PolyprojectNGS.sequencing_machines S
		where rm.run_id='$rid' and rm.machine_id=S.machine_id;};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my @res;
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
	
#	my $res = $sth->fetchall_arrayref({});
#	return $res->[0]->{name} if $res;
}



1;
