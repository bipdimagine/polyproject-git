#!/usr/bin/perl
########################################################################
###### createPolyproject.pl
########################################################################
#use CGI;
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-lite";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";

#ce script est utilisé pour inserer des données dans la BD à partir de l'interface.
#Il s'agit principalement de valider ou invalider les variations
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
#use Encode::Encoding;
#use Encode::Alias;
#use Encode;

use export_data;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $option = $cgi->param('option');

#print $cgi->header();

if ( $option eq "capture" ) {
	CaptureSection();
} elsif ( $option eq "method" ) {
        MethodSection();
} elsif ( $option eq "machine" ) {
        MachineSection();
} elsif ( $option eq "release" ) {
        ReleaseSection();
} elsif ( $option eq "database" ) {
        DatabaseSection();
} elsif ( $option eq "type" ) {
        TypeSection();
} elsif ( $option eq "plateform" ) {
		PlateformSection();
} elsif ( $option eq "disease" ) {
        DiseaseSection();
} elsif ( $option eq "polyU" ) {
        PolyUserList();
} elsif ( $option eq "polyT" ) {
        PolyUserTeam();
} elsif ( $option eq "user" ) {
        PolyUser();
} elsif ( $option eq "polyP" ) {
		PolyPatient();
} elsif ( $option eq "polyG" ) {
		GetProjName();
}  elsif ( $option eq "polyD" ) {
		PolyDisease();
}

sub CaptureSection {
	my $capListId = queryPolyproject::getCaptureId($buffer->dbh);
#	warn Dumper($capListId);
	my @data;
	my %hdata;
	$hdata{identifier}="capName";
	$hdata{label}="capName";
        	foreach my $c (@$capListId){
		my %s;
		$s{captureId} = $c->{captureId};
		$s{captureId} += 0;
		$s{capName} = $c->{capName};
		$s{capVs} = $c->{capVs};
		$s{capDes} = $c->{capDes};
		$s{capTitle} = $c->{capName}." ".$c->{capDes};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
#warn Dumper($hdata{items});
#print Dumper($hdata{items});
	printJson(\%hdata);
}

sub MethodSection {
	my $metListId = queryPolyproject::getMethodId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="methName";
	$hdata{label}="methName";
	foreach my $c (@$metListId){
		my %s;
		$s{methodId} = $c->{methodId};
		$s{methodId} += 0;
		$s{methName} = $c->{methName};
		$s{methType} = $c->{methType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub MachineSection {
	my $macListId = queryPolyproject::getMachineId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="macName";
	$hdata{label}="macName";
        	foreach my $c (@$macListId){
		my %s;
		$s{machineId} = $c->{machineId};
		$s{machineId} += 0;
		$s{macName} = $c->{macName};
		$s{macType} = $c->{macType};
		$s{macDes} = $c->{macName}." ".$c->{macType};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub ReleaseSection {
	my $relListId = queryPolyproject::getReleaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="relName";
	$hdata{label}="relName";
        	foreach my $c (@$relListId){
		my %s;
		$s{releaseId} = $c->{releaseId};
		$s{releaseId} += 0;
		$s{relName} = $c->{relName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub DatabaseSection {
	my $dbListId = queryPolyproject::getDatabaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="dbName";
	$hdata{label}="dbName";
        	foreach my $c (@$dbListId){
		my %s;
		$s{dbId} = $c->{dbId};
		$s{dbId} += 0;
		$s{dbName} = $c->{dbName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub TypeSection {
	my $typeListId = queryPolyproject::getTypeId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="typeName";
	$hdata{label}="typeName";
        	foreach my $c (@$typeListId){
		my %s;
		$s{typeId} = $c->{typeId};
		$s{typeId} += 0;
		$s{typeName} = $c->{typeName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub PlateformSection {
	my $plateformListId = queryPolyproject::getPlateformId($buffer->dbh);
#	warn Dumper $plateformListId;
	my @data;
	my %hdata;
	$hdata{identifier}="plateformName";
	$hdata{label}="plateformName";
	foreach my $c (@$plateformListId){
		my %s;
		$s{plateformId} = $c->{plateformId};
		$s{plateformId} += 0;
		$s{plateformName} = $c->{plateformName};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub DiseaseSection {
	my $typeListId = queryPolyproject::getDiseaseId($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="diseaseId";
	$hdata{label}="diseaseId";
        	foreach my $c (@$typeListId){
		my %s;
		$s{diseaseId} = $c->{diseaseId};
		$s{diseaseId} += 0;
		$s{diseaseName} = $c->{diseaseName};
		$s{diseaseAbb} = $c->{diseaseAbb};		
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub PolyUserList {
#   my $projid = $cgi->param('ProjSel');
    my $projname = $cgi->param('ProjSel');
#	my $projListId = queryPolyproject::getProjectUserLink($buffer->dbh,$projid);
	my $projListId = queryPolyproject::getProjectUserLink($buffer->dbh,$projname);
	my @data;
	my %hdata;
	my $row=1;
	my %unique;
	my @ppV;
#	my @listDisease;
    foreach my $c (@$projListId){
		#remplacer " " par "-" pour les noms composés nécessaire pour
		#contruire liste de nom unique
#		my @listDisease;
#		my @ppV;
		$c->{userName}=~ s/ /-/g;
		$c->{Disease}=~ s/\n//g;
		unless($unique{$c->{projId}}){
			$unique{$c->{projId}}->{projName} = $c->{projName};
			$unique{$c->{projId}}->{cmethSnp} = $c->{MethSnp};
			$unique{$c->{projId}}->{cmethAln} = $c->{MethAln};
			$unique{$c->{projId}}->{relName} = $c->{relName};
			$unique{$c->{projId}}->{projDes} = $c->{projDes};
			$unique{$c->{projId}}->{typName} = $c->{typName};
			$unique{$c->{projId}}->{capName} = $c->{capName};
			$unique{$c->{projId}}->{macName} = $c->{macName};
			$unique{$c->{projId}}->{dbName}  = $c->{dbName};
			$unique{$c->{projId}}->{userName} = $c->{userName};
			$unique{$c->{projId}}->{cDate} = $c->{cDate};
			$unique{$c->{projId}}->{plateformName} = $c->{plateformName};
			$unique{$c->{projId}}->{Disease} = $c->{Disease};
		}
		else{
			$unique{$c->{projId}}->{cmethSnp}.=" ".$c->{MethSnp} if $c->{MethSnp} ne "";
			$unique{$c->{projId}}->{cmethAln}.=" ".$c->{MethAln} if $c->{MethAln} ne "";
			$unique{$c->{projId}}->{userName}.=" ".$c->{userName} if $c->{userName} ne "";
			$unique{$c->{projId}}->{plateformName}.=" ".$c->{plateformName} if $c->{plateformName} ne "";
			$unique{$c->{projId}}->{Disease}.=";".$c->{Disease} if $c->{Disease} ne "";
		}
	}
#warn Dumper sort(%unique);
#die;
# Liste Unique de cmethSnp
	my %unique1;
	foreach my $k (keys(%unique)){
		my %meth;
		my @umethSnp = split(/\s+/,$unique{$k}->{cmethSnp});
		foreach my $m (@umethSnp){
			$meth{$m}=1;
		}
		my %aln;
		my @umethAln = split(/\s+/,$unique{$k}->{cmethAln});
		foreach my $n (@umethAln){
			$aln{$n}=1;
		}

		my %user;
		my @usersp = split(/\s+/,$unique{$k}->{userName});
		foreach my $u (@usersp){
			$user{$u}=1;
		}

		my %plateform;
		my @plateformsp = split(/\s+/,$unique{$k}->{plateformName});
		foreach my $u (@plateformsp){
			$plateform{$u}=1;
		}

		my %disease;
#		my @diseasep = split(/\s+/,$unique{$k}->{Disease});
		my @diseasep = split(/;/,$unique{$k}->{Disease});
		foreach my $u (@diseasep){
			$disease{$u}=1;
		}

		foreach my $k1 (keys(%meth)){
			$unique1{$k}->{umethSnp}.= $k1." ";
			$unique1{$k}->{projName} = $unique{$k}->{projName};
			$unique1{$k}->{relName} = $unique{$k}->{relName};
			$unique1{$k}->{projDes} = $unique{$k}->{projDes};
			$unique1{$k}->{typName} = $unique{$k}->{typName};
			$unique1{$k}->{capName} = $unique{$k}->{capName};
			$unique1{$k}->{macName} = $unique{$k}->{macName};
			$unique1{$k}->{dbName}  = $unique{$k}->{dbName};
			$unique1{$k}->{cDate}  = $unique{$k}->{cDate};
		}
		foreach my $k1 (keys(%aln)){
			$unique1{$k}->{umethAln}.= $k1." ";
			$unique1{$k}->{projName} = $unique{$k}->{projName};
			$unique1{$k}->{relName} = $unique{$k}->{relName};
			$unique1{$k}->{projDes} = $unique{$k}->{projDes};
			$unique1{$k}->{typName} = $unique{$k}->{typName};
			$unique1{$k}->{capName} = $unique{$k}->{capName};
			$unique1{$k}->{macName} = $unique{$k}->{macName};
			$unique1{$k}->{dbName}  = $unique{$k}->{dbName};
			$unique1{$k}->{cDate}  = $unique{$k}->{cDate};
		}

		foreach my $k1 (keys(%user)){
			$unique1{$k}->{userName}.= $k1." ";
			$unique1{$k}->{projName} = $unique{$k}->{projName};
			$unique1{$k}->{relName} = $unique{$k}->{relName};
			$unique1{$k}->{projDes} = $unique{$k}->{projDes};
			$unique1{$k}->{typName} = $unique{$k}->{typName};
			$unique1{$k}->{capName} = $unique{$k}->{capName};
			$unique1{$k}->{macName} = $unique{$k}->{macName};
			$unique1{$k}->{dbName}  = $unique{$k}->{dbName};
			$unique1{$k}->{cDate}  = $unique{$k}->{cDate};
		}
		
		foreach my $k1 (keys(%plateform)){
			$unique1{$k}->{plateformName}.= $k1." ";
			$unique1{$k}->{projName} = $unique{$k}->{projName};
			$unique1{$k}->{relName} = $unique{$k}->{relName};
			$unique1{$k}->{projDes} = $unique{$k}->{projDes};
			$unique1{$k}->{typName} = $unique{$k}->{typName};
			$unique1{$k}->{capName} = $unique{$k}->{capName};
			$unique1{$k}->{macName} = $unique{$k}->{macName};
			$unique1{$k}->{dbName}  = $unique{$k}->{dbName};
			$unique1{$k}->{cDate}  = $unique{$k}->{cDate};
		}
		
		foreach my $k1 (keys(%disease)){
#			$unique1{$k}->{Disease}.= $k1." ";
			$unique1{$k}->{Disease}.= $k1.";";
			$unique1{$k}->{projName} = $unique{$k}->{projName};
			$unique1{$k}->{relName} = $unique{$k}->{relName};
			$unique1{$k}->{projDes} = $unique{$k}->{projDes};
			$unique1{$k}->{typName} = $unique{$k}->{typName};
			$unique1{$k}->{capName} = $unique{$k}->{capName};
			$unique1{$k}->{macName} = $unique{$k}->{macName};
			$unique1{$k}->{dbName}  = $unique{$k}->{dbName};
			$unique1{$k}->{cDate}  = $unique{$k}->{cDate};
		}
		
	}
#warn Dumper %unique1;
#die;
	$hdata{identifier}="Row";
	$hdata{label}="projName";
	foreach my $k2 (keys(%unique1)){
		my %s;
		$unique1{$k2}->{umethAln}=~ s/^ //;
		chop($unique1{$k2}->{umethSnp});
		chop($unique1{$k2}->{umethAln});
		chop($unique1{$k2}->{userName});
		chop($unique1{$k2}->{plateformName});
		chop($unique1{$k2}->{Disease});
		$s{Row} = $row++;
		$s{projId} = $k2;
		$s{projId} += 0;
		$s{projName} = $unique1{$k2}->{projName};
#pour les filtres il faut name au lieu de projName
		$s{name} = $unique1{$k2}->{projName};
#		$s{relName} = $unique1{$k2}->{relName};
		$s{Rel} = $unique1{$k2}->{relName};
		$s{MethSnp} = $unique1{$k2}->{umethSnp};
#pour les filtres: ne pas avoir null
		if (defined($unique1{$k2}->{umethAln})) {
			$s{MethAln} = $unique1{$k2}->{umethAln};
		} else { $s{MethAln} ="";}
		$s{projDes} = $unique1{$k2}->{projDes};
		$s{Type} = $unique1{$k2}->{typName};
		$s{capName} = $unique1{$k2}->{capName};
		$s{macName} = $unique1{$k2}->{macName};
		$s{Database} = $unique1{$k2}->{dbName};
		my @datec = split(/ /,$unique1{$k2}->{cDate});
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
#		$s{cDate} = $unique1{$k2}->{cDate};
		$s{userName} = $unique1{$k2}->{userName};
		$s{plateformName} = $unique1{$k2}->{plateformName};
		$s{Disease} = $unique1{$k2}->{Disease};
		my $buffer = GBuffer->new(-verbose=>1);
		my $project = $buffer->newProject(-name=>$s{name});
		if($s{Type} eq "ngs") {$s{nbPatient} = @{$project->getPatients()}};
		if (defined $s{userName}){
			$s{statut} = qq{<img src='/icons/myicons2/bullet_green.png'>};
		} else {
			$s{statut} = qq{<img src='/icons/myicons2/bullet_red.png'>};
		}
		if (defined $s{nbPatient} && $s{nbPatient} < 1) {
			$s{statut} = qq{<img src='/icons/myicons2/bullet_red.png'>};
		}
 		$buffer->dbh->disconnect();
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}


sub PolyUserTeam {
        my $projid = $cgi->param('ProjSel');
#warn $projid;
	my $userTeamList = queryPolyproject::getProjectTeamLink($buffer->dbh,$projid);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="projName";
        	foreach my $c (@$userTeamList){
		my %s;
		$s{Row} = $row++;
		$s{projId} = $c->{projId};
		$s{projId} += 0;
		$s{Name} = $c->{Name};
		$s{Firstname} = $c->{Firstname};
		$s{Email} = $c->{Email};
		$s{Code} = $c->{Code};
		$s{Organisme} = $c->{Organisme};
		$s{Site} = $c->{Site};
		$s{Director} = $c->{Director};
		$s{Team} = $c->{Team};
		$s{Responsable} = $c->{Responsable};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub PolyUser {
	my $userList = queryPolyproject::getProjectUser($buffer->dbh);
	my @data;
	my %hdata;
	$hdata{identifier}="UserId";
	$hdata{label}="Name";
        	foreach my $c (@$userList){
		my %s;
		$s{UserId} = $c->{UserId};
		$s{UserId} += 0;
		$s{Name} = $c->{Name};
		$s{Firstname} = $c->{Firstname};
		$s{Code} = $c->{Code};
		$s{Team} = $c->{Team};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub PolyPatient {
#		my $projid = $cgi->param('ProjSel');
		my $projectName = $cgi->param('ProjSel');
		my $buffer2 = GBuffer->new();
 		my $project = $buffer2->newProject(-name=>$projectName);
		die ("unknown project ".$projectName ) unless $project;
		my @data;
		my %hdata;
		my $row=1;
		$hdata{identifier}="Row";
		$hdata{label}="Row";
		foreach  my $patient (@{$project->getPatients()}){
#			print $patient->name()."\n";
			my %s;
			$s{Row} = $row++;
			$s{Patient}=$patient->name();
			push(@data,\%s);
		}
		$hdata{items}=\@data;
#		warn Dumper @data;
		printJson(\%hdata);
}

sub PolyDisease {
        my $projName = $cgi->param('ProjSel');
#warn $projid;
	my $projDiseaseList = queryPolyproject::getProjectDiseaseLink($buffer->dbh,$projName);
	my @data;
	my %hdata;
	my $row=1;
	$hdata{identifier}="Row";
	$hdata{label}="projName";
        	foreach my $c (@$projDiseaseList){
		my %s;
		$s{Row} = $row++;
		$s{projId} = $c->{projId};
		$s{projId} += 0;
		$s{projName} = $c->{projName};
		$s{diseaseId} = $c->{diseaseId};
		$s{diseaseName} = $c->{Disease};
		$s{diseaseAbb} = $c->{abbDis};
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}
 
sub GetProjName {
		my $projid = $cgi->param('ProjSel');
#		print $projid;
		my $projectName = queryPolyproject::getProjectName($buffer->dbh,$projid);
		warn $projectName;
		my @data;
		my %hdata;
		$hdata{identifier}="projName";
		$hdata{label}="projName";
		$hdata{items}=$projectName;
#		warn Dumper \@data;
		printJson(\%hdata);
}


sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}



