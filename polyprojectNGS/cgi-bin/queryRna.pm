package queryRna;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;

sub getProjectAll {
	my ($dbh,$projid)=@_;
	my $sql2 = qq {and p.project_id='$projid'};
	$sql2 = "" unless $projid;
	
	my $sql = qq{
SELECT
	p.project_id as id , 
	p.name as name, 
	p.description,
	p.creation_date as cDate,
    r.name as relname,
	GROUP_CONCAT(DISTINCT pp.version_id ORDER BY pp.version_id  SEPARATOR ' ') as 'ppversionid',
	GROUP_CONCAT(DISTINCT rg.name ORDER BY rg.name  SEPARATOR ' ') as 'relGene'

FROM PolyprojectNGS.projects p
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


WHERE p.type_project_id=3
    and dp.db_id =4
	and p.creation_date != "0000-00-00 00:00:00"
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

##################################################



1;
