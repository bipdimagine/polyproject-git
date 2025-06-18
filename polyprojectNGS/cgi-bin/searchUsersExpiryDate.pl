#!/usr/bin/perl
########################################################################
###### searchUsersExpiryDate.pl
########################################################################
#use CGI;
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/../polymorphism-cgi/packages/export";

use Time::Local;
#use DateTime;
#use DateTime::Duration;

#use Time::Local;
#use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;
use POSIX qw(strftime);
use Time::Piece;
#use File::Basename;
#use File::Find::Rule;
use GBuffer;
use connect;
#use queryPolyproject;
#use queryPerson;
#use queryQuery;
use Data::Dumper;
use Carp;
use JSON;
use List::Util qw/ max min /;

use export_data;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $s_user=getUserExpiryInfo($buffer->dbh);

my $datec= POSIX::strftime('%Y-%m-%d %H:%M:%S', localtime);
# Conversion des deux dates en objets Time::Piece
my $date_now = Time::Piece->strptime($datec, '%Y-%m-%d %H:%M:%S');
#warn Dumper $date_now;

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
foreach my $u (@$s_user){
	my $date_user = Time::Piece->strptime($u->{pw_date}, '%Y-%m-%d %H:%M:%S');
	# Incrémentation d'une année
	# Ajout d'un an (365 * 24 * 60 * 60 secondes)
	my $date_user_plus1 = $date_user + (365 * 24 * 60 * 60);
	if ($date_user_plus1 < $date_now) {
		upInactivatePW($buffer->dbh,$u->{user_id},"X");
	}
}
### End Autocommit dbh ###########
$dbh->commit();
printData("");# need for sendData_noStatusTextStandby in .js


## getDB

sub getUserExpiryInfo {
	my ($dbh) = @_;
	my $query = qq{
		SELECT distinct
			up.user_id,
			U.nom_responsable,U.prenom_u,U.pw_date,U.pw,
			U.equipe_id,
			#E.equipe_id,
			#T.unite_id,
			T.code_unite,T.organisme
		FROM PolyprojectNGS.user_projects up
		LEFT JOIN bipd_users.`USER` U
		ON up.user_id=U.user_id
		LEFT JOIN bipd_users.EQUIPE E
    	ON U.equipe_id = E.equipe_id
    	LEFT JOIN bipd_users.UNITE T
    	ON E.unite_id = T.unite_id
		WHERE U.pw !="X"
		AND U.pw_date != "null"
		AND U.pw_date != "0000-00-00 00:00:00"
		AND T.organisme = "APHP"
		AND T.code_unite="CEDI"
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

sub upInactivatePW {
	my ($dbh,$userid,$value) = @_;
	my $sql = qq{
		UPDATE bipd_users.`USER`
		SET PASSWORD_TXT='$value',PW='$value'
		WHERE USER_ID='$userid';
	};
	return ($dbh->do($sql));
}

#		my $s_patient=getPatient_FromName_Projid($buffer->dbh,$patNGS,$projectid);
=mod
## getDB

sub getPatient_FromName_Projid {
	my ($dbh,$patname,$projid) = @_;
	my $query = qq{
		SELECT * 
		FROM PolyprojectNGS.patient a
		WHERE a.name='$patname'
		AND a.project_id='$projid';
	};
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my $s = $sth->fetchrow_hashref();
	return $s;	
}
=cut
####################################################################################
sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}

sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub sendError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub response {
	my ($rep) = @_;
	print qq{<textarea>};
	print to_json($rep);
	print qq{</textarea>};
	exit(0);
}

sub printJson_noexit {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
}

sub sendFormOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendFormError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendComplexOK {
	my ($text,$sheet) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendComplexError {
	my ($text,$sheet) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendExtended {
	my ($text,$extend) = @_;
	my $resp;
	$resp->{status}  = "Extended";
	$resp->{message} = $text;
	$resp->{extend} = $extend;
#	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendDialog {
	my ($text,$dialog) = @_;
	my $resp;
	$resp->{status}  = "Dialog";
	$resp->{message} = $text;
	$resp->{dialog} = $dialog;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub sendDuoDialog {
	my ($text,$dialog1,$dialog2) = @_;
	my $resp;
	$resp->{status}  = "DuoDialog";
	$resp->{message} = $text;
	$resp->{dialog1} = $dialog1;
	$resp->{dialog2} = $dialog2;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub sendError2 {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	#response($resp);
	exit(0);
}

sub printData {
        my ($data)= @_;
                print $cgi->header('text/plain');
        		print "$data\n";
        exit(0)
}



exit(0);



