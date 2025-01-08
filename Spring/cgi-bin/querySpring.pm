package querySpring;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;



############ Users ########################

sub getAuthentificationForUser {
	my ($dbh,$login,$pwd,$team)=@_;
	my $query2 = qq {and U.equipe_id='$team'};
	$query2 = "" unless $team;
	my $query = qq{	  	
		SELECT U.nom_responsable as name
		FROM bipd_users.`USER` U
		WHERE U.LOGIN='$login' 
		and U.password_txt=password('$pwd')
		$query2
		;
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $res = $sth->fetchall_arrayref();
	return scalar(@$res);	
}
##########################################

1;
