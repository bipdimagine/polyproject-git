#!/usr/bin/perl
########################################################################
###### stat.pl #################################################
#./stat.pl opt=pat year=2015,2016
########################################################################
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

use GenBoPatient;
#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use Getopt::Long;
use List::Util qw[min max];
#use Switch;
use GBuffer;
use connect;
use Data::Dumper;
use Carp;
use JSON;
use queryStat;
use export_data;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;
#paramètre passés au cgi
my $opt = $cgi->param('opt');
	
if ( $opt eq "patAna" ) {
	patAnaSection();
} elsif ( $opt eq "patAnaPlt" ) {
	patAnaPltSection();
} elsif ( $opt eq "patAnaUnit" ) {
	patAnaUnitSection();
} elsif ( $opt eq "EYpatDetail" ) {
	EachYearpatDetailSection();
} elsif ( $opt eq "patAnaUser" ) {
	patAnaUserSection();
}  elsif ( $opt eq "EYUpatDetail" ) {
	EachYearUnitpatDetailSection();
}

sub patAnaSection {
	my $cyear = $cgi->param('year');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
#	$not += 0;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear;
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;

	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="year";
	foreach my $y (@listYearNbPat){
		my %s;
		my $nbYearPatList = queryStat::countPatAnalyseYear($buffer->dbh,$y,$StrListAnalyse,$not);
		$s{year} = $y += 0;
		$s{nbPat} = $nbYearPatList += 0;
		$s{Row} = $row++;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub patAnaPltSection {
	my $cyear = $cgi->param('year');
	my $plateform = $cgi->param('plateform');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
#	$not += 0;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear;
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;

	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="year";
	foreach my $y (@listYearNbPat){
		my %s;
		my $nbYearPatList = queryStat::countPatAnalysePlateformYear($buffer->dbh,$y,$StrListAnalyse,$plateform,$not);
		$s{year} = $y += 0;
		$s{nbPat} = $nbYearPatList += 0;
		$s{Row} = $row++;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub patAnaUnitSection {
	my $cyear = $cgi->param('year');
	my $cunit = $cgi->param('unit');
	my @listUnit;
	@listUnit = sort (split(/,/,$cunit));
	my $cyear = $cgi->param('year');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear;
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;

	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	my $ListUnit;
	for (my $i = 0; $i< scalar(@listUnit); $i++) {
		$ListUnit.="'".$listUnit[$i]."'".",";
	}
	chop($ListUnit);

	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="year";
	foreach my $y (@listYearNbPat){
		my %s;
		$ListUnit="" unless defined $ListUnit;
		my $nbYearPatAnalysUnitList = queryStat::countPatAnalyseUnitYear($buffer->dbh,$y,$StrListAnalyse,$ListUnit,$not);
		$s{year} = $y += 0;
		$s{nbPat} = $nbYearPatAnalysUnitList += 0;
		$s{Row} = $row++;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub EachYearpatDetailSection {
	my $cyear = $cgi->param('year');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear;
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;
	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	my @data;
	my %hdata;
	$hdata{label}="year";
	my %seen;
	my %seen2;
	my $numcol=1;
	my %totPlt;
	foreach my $y (@listYearNbPat){
		my $nbYearPatList = queryStat::countPatAnalyseByPlateformYear($buffer->dbh,$y,$StrListAnalyse,$not);
		foreach my $n (@$nbYearPatList){
			my %s;
			$s{year} = $y += 0;
			$s{name} = $n->{name};
			$s{nbPat} = $n->{nbPat} += 0;
			$totPlt{$s{name}} =$numcol unless $seen{$s{name}}++;
			$s{col}=$numcol++  unless $seen2{$totPlt{$s{name}}}++;
			push(@data,\%s);
		}
	}
	my @dataf;
	my %totYearName;
	my (%hByYear, %hCol);
	foreach my $c (@data) {
		$c->{col}= $totPlt{$c->{name}};
		
		$hByYear{$c->{year}}->{$c->{col}}  =$c->{name};
		$hCol{$c->{col}}  =$c->{name};
	}
	foreach my $year (sort {$a <=> $b} @listYearNbPat) {
		foreach my $c (sort {$a <=> $b} keys %hCol) {
			if (exists $hByYear{$year}) {
				if (not exists $hByYear{$year}->{$c}) {
					my %new;
					$new{'col'} = $c;
					$new{'name'} = $hCol{$c};
					$new{'nbPat'} = 0;
					$new{'year'} = $year;
					push (@data, \%new);
				}
			}
			else {
				my %new;
				$new{'col'} = $c;
				$new{'name'} = $hCol{$c};
				$new{'nbPat'} = 0;
				$new{'year'} = $year;
				push (@data, \%new);
			}
		}
	}
	my $row=1;
	foreach my $c (sort {$a->{year} <=> $b->{year}} @data) {
		$c->{'Row'}=$row++;
	}
	my @result_sorted=sort { $a->{year} <=> $b->{year}} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

sub patAnaUserSection {
	my $cyear = $cgi->param('year');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $cuser = $cgi->param('user');
	my @listUser;
	@listUser = sort (split(/,/,$cuser));
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear; 
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;

	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	
	my $ListUser;
	for (my $i = 0; $i< scalar(@listUser); $i++) {
		$ListUser.="'".$listUser[$i]."'".",";
	}
	chop($ListUser);	
	my $row=1;
	my @data;
	my %hdata;
	$hdata{label}="year";
	foreach my $y (@listYearNbPat){
		my %s;
		$ListUser="" unless defined $ListUser;
		my $nbYearPatList = queryStat::countPatAnalyseUser($buffer->dbh,$y,$StrListAnalyse,$ListUser,$not);
		$s{year} = $y += 0;
		$s{nbPat} = $nbYearPatList += 0;
		$s{Row} = $row++;
		push(@data,\%s);
	}
	$hdata{items}=\@data;
	printJson(\%hdata);
}

sub EachYearUnitpatDetailSection {
	my $cyear = $cgi->param('year');
	my @listYearNbPat;
	@listYearNbPat = sort (split(/,/,$cyear));
	my $analyse = $cgi->param('analyse');
	my @analyse = split(/,/,$analyse);
	my $unit = $cgi->param('unit');
	my $not;
	$not= $cgi->param('not');
	$not=0 unless defined $not;
	my $db_year= queryStat::getYearsFromPatient($buffer->dbh) unless defined $cyear;
	@listYearNbPat=sort(split(/,/, join(",",map{$_->{cYear}}@$db_year))) unless defined $cyear;
	my $StrListAnalyse;
	for (my $i = 0; $i< scalar(@analyse); $i++) {
		$StrListAnalyse.="'".$analyse[$i]."'".",";
	}
	chop($StrListAnalyse);
	my @data;
	my %hdata;
	$hdata{label}="year";
	my %seen;
	my %seen2;
	my $numcol=1;
	my %totUnit;
	foreach my $y (@listYearNbPat){
		my $nbYearUPatList = queryStat::countPatAnalyseByTeamYear($buffer->dbh,$y,$StrListAnalyse,$unit,$not);
		foreach my $n (@$nbYearUPatList){
			my %s;
			$s{year} = $y += 0;
			$s{name} = $n->{equipe_id};
			$s{teamName} = $n->{libelle};
			$s{teamLeader} = $n->{responsables};
			$s{nbPat} = $n->{nbPat} += 0;
			$totUnit{$s{name}} =$numcol unless $seen{$s{name}}++;
			$s{col}=$numcol++  unless $seen2{$totUnit{$s{name}}}++;
			push(@data,\%s);
		}
	}
	my @dataf;
	my %totYearName;
	my (%hByYear, %hCol);
	foreach my $c (@data) {
		$c->{col}= $totUnit{$c->{name}};
		
		$hByYear{$c->{year}}->{$c->{col}}  =$c->{name};
		$hCol{$c->{col}}  =$c->{name};
	}
	foreach my $year (sort {$a <=> $b} @listYearNbPat) {
		foreach my $c (sort {$a <=> $b} keys %hCol) {
			if (exists $hByYear{$year}) {
				if (not exists $hByYear{$year}->{$c}) {
					my %new;
					$new{'col'} = $c;
					$new{'name'} = $hCol{$c};
					$new{'teamName'} = "";
					$new{'teamLeader'} = "";
					$new{'nbPat'} = 0;
					$new{'year'} = $year;
					push (@data, \%new);
				}
			}
			else {
				my %new;
				$new{'col'} = $c;
				$new{'name'} = $hCol{$c};
				$new{'nbPat'} = 0;
				$new{'teamName'} = "";
				$new{'teamLeader'} = "";
				$new{'year'} = $year;
				push (@data, \%new);
			}
		}
	}
	my $row=1;
	foreach my $c (sort {$a->{year} <=> $b->{year}} @data) {
		$c->{'Row'}=$row++;
	}
	my @result_sorted=sort { $a->{year} <=> $b->{year}} @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);
}

###################################################################################

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}
exit(0);



















