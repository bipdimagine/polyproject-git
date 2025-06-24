package queryStat;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

sub getYearsFromPatient {
	my ($dbh) = @_;
	my $query = qq{
		SELECT distinct extract(year from creation_date) as cYear FROM PolyprojectNGS.patient;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub countPatAnalyseYear {
	my ($dbh,$cyear,$analyse,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	my $query = qq{
		SELECT 
--   	count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
		AND a.creation_date regexp '$cyear';
	};
	return $dbh->selectrow_array($query);
}

sub countPatAnalyseUser {
	my ($dbh,$cyear,$analyse,$user,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	$user="''" unless $user;
	my $query = qq{
		SELECT 
--		count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON p.project_id = a.project_id
		
        LEFT JOIN PolyprojectNGS.user_projects up
        ON p.project_id = up.project_id
        
        LEFT JOIN PolyprojectNGS.ugroup_projects gp
        ON p.project_id = gp.project_id
        
        LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id
		LEFT JOIN bipd_users.UGROUP_USER uu
		ON ug.ugroup_id=uu.ugroup_id
		       
        LEFT JOIN bipd_users.`USER` U
        ON uu.user_id=U.user_id OR up.user_id=U.user_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
		AND U.user_id in ($user)
 		AND a.creation_date regexp '$cyear';
	};
	return $dbh->selectrow_array($query);
}

sub countPatAnalysePlateformYear {
	my ($dbh,$cyear,$analyse,$plateform,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	my $query = qq{
        Select
--		count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
		ON r.run_id=rp.run_id
        LEFT JOIN PolyprojectNGS.plateform f
        ON rp.plateform_id=f.plateform_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
        AND f.name = '$plateform'		
		AND a.creation_date regexp '$cyear';
	};
	return $dbh->selectrow_array($query);
}

sub countPatAnalyseByPlateformYear {
	my ($dbh,$cyear,$analyse,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	my $query = qq{
        Select
 --   	f.name, count(distinct if (a.name!="",a.name,null)) as 'nbPat'
        f.name, count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
		ON r.run_id=rp.run_id
        LEFT JOIN PolyprojectNGS.plateform f
        ON rp.plateform_id=f.plateform_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
 		AND a.creation_date regexp '$cyear'
 		GROUP BY f.name;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub countPatAnalyseByTeamYear {
	my ($dbh,$cyear,$analyse,$unit,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	my $query3;
	$query3 = qq {AND E.unite_id in ($unit)};
	
	my $query = qq{
		Select
 		E.equipe_id,E.libelle,E.responsables,
--		count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON p.project_id = a.project_id
        LEFT JOIN PolyprojectNGS.user_projects up
        ON p.project_id = up.project_id
        LEFT JOIN bipd_users.`USER` U
        ON up.user_id=U.user_id
        LEFT JOIN bipd_users.EQUIPE E
        ON U.equipe_id = E.equipe_id
        LEFT JOIN bipd_users.UNITE T
        ON E.unite_id = T.unite_id
		WHERE
		$query2
		$query3
 		AND a.run_id!=0		
  		AND a.project_id!=0		
 		AND a.creation_date regexp '$cyear'
  		GROUP BY E.equipe_id;
 
 	};	
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		push(@res,$id);
	}
	return \@res;
}

sub countPatAnalyseUnitYear {
	my ($dbh,$cyear,$analyse,$unit,$not) = @_;
	my $query2;
	if ($analyse =~ "target") {
		my $s_analyse=$analyse;
		$s_analyse =~ s/\'//g;
		if ($s_analyse eq "target") {
			$query2 = qq {cs.analyse not in ("exome","genome","rnaseq","singlecell","amplicon","other")} unless $not;
			$query2 = qq {cs.analyse in ("exome","genome","rnaseq","singlecell","amplicon","other")} if $not;
		} else {
			$query2 = qq {cs.analyse in ("")};
		}
	} else {
		$query2 = qq {cs.analyse in ($analyse)} unless $not;
		$query2 = qq {cs.analyse not in ($analyse)} if $not;
	}
	$unit="''" unless $unit;
	my $query = qq{
		SELECT 
#		count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON p.project_id = a.project_id
        LEFT JOIN PolyprojectNGS.user_projects up
        ON p.project_id = up.project_id
        LEFT JOIN bipd_users.`USER` U
        ON up.user_id=U.user_id
        LEFT JOIN bipd_users.EQUIPE E
        ON U.equipe_id = E.equipe_id
        LEFT JOIN bipd_users.UNITE T
        ON E.unite_id = T.unite_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
		AND E.unite_id in ($unit)
 		AND a.creation_date regexp '$cyear';
	};

	return $dbh->selectrow_array($query);
}


1;
