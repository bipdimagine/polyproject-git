package queryStat;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

sub getYearsFromPatient {
	my ($dbh) = @_;
	my $query = qq{
		-- SELECT distinct extract(year from creation_date) as cYear FROM PolyprojectNGS.patient;
		SELECT distinct extract(year from p.creation_date) as cYear 
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
		WHERE a.project_id>0
		AND p.creation_date is not null
		AND p.creation_date>0;
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res if \@res;
}

sub countPatAnalyseMachineYear {
	my ($dbh,$cyear,$analyse,$mac,$not) = @_;
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
	my $queryMac;
#	$mac="''" unless $mac;
	$queryMac = qq {AND sm.name in ($mac)} if $mac;
	my $query = qq{
		SELECT 
--   	count(distinct if (a.name!="",a.name,null)) as 'nbPat'
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.projects p   #new
		ON a.project_id = p.project_id	  #new	
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_machine rm
		ON r.run_id = rm.run_id
		LEFT JOIN PolyprojectNGS.sequencing_machines sm
		ON rm.machine_id = sm.machine_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
		$queryMac
		AND p.creation_date regexp '$cyear';#new
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalyseMachineYear {
	my ($dbh,$cyear,$analyse,$mac,$not) = @_;
	$cyear=~ s/,/|/g;
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
	my $queryMac;
#	$mac="''" unless $mac;
	$queryMac = qq {AND sm.name in ($mac)} if $mac;
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT sm.name ORDER BY sm.name DESC SEPARATOR ',') as 'machine',
  		GROUP_CONCAT(DISTINCT sm.type ORDER BY sm.name DESC SEPARATOR ',') as 'type',
		year(p.creation_date) as 'year'

		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.projects p   #new
		ON a.project_id = p.project_id	  #new	
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_machine rm
		ON r.run_id = rm.run_id
		LEFT JOIN PolyprojectNGS.sequencing_machines sm
		ON rm.machine_id = sm.machine_id
 
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryMac
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
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
		ON a.project_id = p.project_id
		
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
 		AND p.creation_date regexp '$cyear';#new
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalyseUserYear {
	my ($dbh,$cyear,$analyse,$user,$not) = @_;
	$cyear=~ s/,/|/g;
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
	my $queryUser = qq {AND U.user_id in ($user)};
	
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
#		GROUP_CONCAT(DISTINCT T.code_unite ORDER BY T.code_unite DESC SEPARATOR ',') as 'unit',
		GROUP_CONCAT(DISTINCT U.nom_responsable ORDER BY U.nom_responsable DESC SEPARATOR ',') as 'user',
		year(p.creation_date) as 'year'
		
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
        LEFT JOIN PolyprojectNGS.user_projects up
        ON p.project_id = up.project_id
        LEFT JOIN bipd_users.`USER` U
        ON up.user_id=U.user_id
				
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryUser
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
}

sub countPatAnalyseGroup {
	my ($dbh,$cyear,$analyse,$group,$not) = @_;
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
	$group="''" unless $group;
	my $query = qq{
		SELECT 
 		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
--       a.patient_id,ug.name
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
        LEFT JOIN PolyprojectNGS.ugroup_projects gp
        ON p.project_id = gp.project_id
        LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id

		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id!=0		
		AND ug.ugroup_id in ($group)
 		AND p.creation_date regexp '$cyear';#new
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalyseGroupYear {
	my ($dbh,$cyear,$analyse,$group,$not) = @_;
	$cyear=~ s/,/|/g;
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
	$group="''" unless $group;
	my $queryGroup = qq {AND ug.ugroup_id in ($group)};
	
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
#		GROUP_CONCAT(DISTINCT T.code_unite ORDER BY T.code_unite DESC SEPARATOR ',') as 'unit',
		GROUP_CONCAT(DISTINCT ug.name ORDER BY ug.name DESC SEPARATOR ',') as 'group',
		year(p.creation_date) as 'year'
		
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
        LEFT JOIN PolyprojectNGS.ugroup_projects gp
        ON p.project_id = gp.project_id
        LEFT JOIN bipd_users.UGROUP ug
		ON gp.ugroup_id=ug.ugroup_id
				
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryGroup
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
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
		LEFT JOIN PolyprojectNGS.projects p   #new
		ON a.project_id = p.project_id	  #new	
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
		AND p.creation_date regexp '$cyear';  #new
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalysePlateformYear {
	my ($dbh,$cyear,$analyse,$pltid,$not) = @_;
	warn Dumper $pltid;
	$cyear=~ s/,/|/g;
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
	
	my $queryPlt = qq {AND f.plateform_id in ($pltid)};
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
 		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ',') as 'plateform',
		year(p.creation_date) as 'year'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
		ON r.run_id=rp.run_id
		LEFT JOIN PolyprojectNGS.plateform f
		ON rp.plateform_id=f.plateform_id 
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryPlt
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
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
		LEFT JOIN PolyprojectNGS.projects p   #new
		ON a.project_id = p.project_id	  #new	
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
 		AND p.creation_date regexp '$cyear'	  #new	
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

sub getProjectAnalyseByPlateformYear {
	my ($dbh,$cyear,$analyse,$not) = @_;
	$cyear=~ s/,/|/g;
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
	SELECT DISTINCT
		p.name as 'project',
 		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT f.name ORDER BY f.name DESC SEPARATOR ',') as 'plateform',
		year(p.creation_date) as 'year'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
		LEFT JOIN PolyprojectNGS.run r
		ON a.run_id = r.run_id
		LEFT JOIN PolyprojectNGS.run_plateform rp
		ON r.run_id=rp.run_id
		LEFT JOIN PolyprojectNGS.plateform f
		ON rp.plateform_id=f.plateform_id 
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp '$cyear'
 		GROUP BY p.name
 		ORDER BY p.name;
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
		ON a.project_id = p.project_id
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
 		AND p.creation_date regexp '$cyear'	  #new	
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

sub getProjectAnalyseByTeamUnitYear {
	my ($dbh,$cyear,$analyse,$unit,$not) = @_;
	$cyear=~ s/,/|/g;
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
	my $queryUnit = qq {AND T.unite_id in ($unit)};
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
-- 		GROUP_CONCAT(DISTINCT T.code_unite ORDER BY T.code_unite DESC SEPARATOR ',') as 'unit',
        E.LIBELLE as 'team',
        T.CODE_UNITE as 'unit',
		year(p.creation_date) as 'year'
		
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
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
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryUnit
 		GROUP BY p.name
 		ORDER BY p.name
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
		ON a.project_id = p.project_id
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
		AND a.project_id>0		
		AND E.unite_id in ($unit)
 		AND p.creation_date regexp '$cyear';#new
	};

	return $dbh->selectrow_array($query);
}

sub getProjectAnalyseUnitYear {
	my ($dbh,$cyear,$analyse,$unit,$not) = @_;
	$cyear=~ s/,/|/g;
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
	my $queryUnit = qq {AND T.unite_id in ($unit)};
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT T.code_unite ORDER BY T.code_unite DESC SEPARATOR ',') as 'unit',
		year(p.creation_date) as 'year'
		
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id		
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
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryUnit
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
}

sub countPatAnalysePhenotypeYear {
	my ($dbh,$cyear,$analyse,$phe,$not) = @_;
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
	$phe="''" unless $phe;
	my $queryPhe = qq {AND pp.phenotype_id in ($phe)};
	if ($phe =~ '999') {
		$queryPhe = qq {AND pp.phenotype_id is null}
	}
	my $query = qq{
		SELECT 
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
		LEFT JOIN PolyPhenotypeDB.phenotype_project pp
		ON a.project_id=pp.project_id
		LEFT JOIN PolyPhenotypeDB.`phenotype` phe
		ON pp.phenotype_id=phe.phenotype_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id>0		
		$queryPhe
 		AND p.creation_date regexp '$cyear';
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalysePhenotypeYear {
	my ($dbh,$cyear,$analyse,$phe,$not) = @_;
	$cyear=~ s/,/|/g;
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
	$phe="''" unless $phe;
	my $queryPhe = qq {AND pp.phenotype_id in ($phe)};
	if ($phe =~ '999') {
		$queryPhe = qq {AND pp.phenotype_id is null}
	}
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT phe.name ORDER BY phe.name DESC SEPARATOR ',') as 'phenotype',
		year(p.creation_date) as 'year'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
		LEFT JOIN PolyPhenotypeDB.phenotype_project pp
		ON a.project_id=pp.project_id
		LEFT JOIN PolyPhenotypeDB.`phenotype` phe
		ON pp.phenotype_id=phe.phenotype_id
 
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryPhe
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
}

sub countPatAnalyseProfileYear {
	my ($dbh,$cyear,$analyse,$prof,$not) = @_;
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
	$prof="''" unless $prof;
	my $queryProf = qq {AND f.profile_id in ($prof)};
	my $query = qq{
		SELECT 
		count(distinct if (a.patient_id!=0,a.patient_id,null)) as 'nbPat'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
		LEFT JOIN PolyprojectNGS.profile f
		ON a.profile_id = f.profile_id
		WHERE
		$query2
		AND a.run_id!=0		
		AND a.project_id>0		
		$queryProf
 		AND p.creation_date regexp '$cyear';
	};
	return $dbh->selectrow_array($query);
}

sub getProjectAnalyseProfileYear {
	my ($dbh,$cyear,$analyse,$prof,$not) = @_;
	$cyear=~ s/,/|/g;
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
	$prof="''" unless $prof;
	my $queryProf = qq {AND f.profile_id in ($prof)};
	my $query = qq{
 		SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
        f.name as 'profile',
        f.profile_id as 'profileId',
 		year(p.creation_date) as 'year'		
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
 		LEFT JOIN PolyprojectNGS.profile f
		ON a.profile_id = f.profile_id
 		WHERE
		$query2
 		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
 		$queryProf
  		GROUP BY p.name
 		ORDER BY p.name;
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
sub getProjectAnalysePhenotypeYear {
	my ($dbh,$cyear,$analyse,$phe,$not) = @_;
	$cyear=~ s/,/|/g;
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
	$phe="''" unless $phe;
	my $queryPhe = qq {AND pp.phenotype_id in ($phe)};
	if ($phe =~ '999') {
		$queryPhe = qq {AND pp.phenotype_id is null}
	}
	my $query = qq{
	SELECT DISTINCT
		p.name as 'project',
		cs.analyse as 'analyse',
		GROUP_CONCAT(DISTINCT phe.name ORDER BY phe.name DESC SEPARATOR ',') as 'phenotype',
		year(p.creation_date) as 'year'
		FROM PolyprojectNGS.patient a
		LEFT JOIN PolyprojectNGS.capture_systems cs
		ON a.capture_id = cs.capture_id
		LEFT JOIN PolyprojectNGS.projects p
		ON a.project_id = p.project_id
		LEFT JOIN PolyPhenotypeDB.phenotype_project pp
		ON a.project_id=pp.project_id
		LEFT JOIN PolyPhenotypeDB.`phenotype` phe
		ON pp.phenotype_id=phe.phenotype_id
 
		WHERE
		$query2
		AND a.project_id>0
		AND p.name regexp '^NGS[0-9]{4}_'
		AND p.creation_date regexp ('$cyear')
		$queryPhe
 		GROUP BY p.name
 		ORDER BY p.name
	};
	my @res;
	my $sth = $dbh->prepare($query);
	$sth->execute();
	while (my $id = $sth->fetchrow_hashref ) {
		 push(@res,$id);
	}
	return \@res;	
}
=cut

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




1;
