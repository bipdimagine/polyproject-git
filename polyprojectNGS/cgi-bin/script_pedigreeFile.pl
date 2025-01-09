#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_pedigreeFile.pl
#./script_pedigreeFile.pl -opt=insert -ped="NGS2014_035*.ped"
#./script_pedigreeFile.pl -opt=extract -project="NGS2014_0423"
#./script_pedigreeFile.pl -opt=extract -projec="NGS2014_0423" -dirped
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
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

#use GenBoWriteNgs;
#use GenBoQueryNgs;
#use GenBoRelationWrite;
#use GenBoProjectWriteNgs;
#use GenBoProjectQueryNgs;
#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use Data::Dumper;
use Carp;
use JSON;
use Getopt::Long;
#use warnings;

my $opt;
my $pedfile;
my $project_name;
my $dirped=0;

GetOptions(
		'opt=s' => \$opt,
        'pedfile=s' => \$pedfile,
        'project=s'  => \$project_name,
        'dirped' => \$dirped
        
);
unless ($opt eq "insert" || $opt eq "extract") {
	confess ("usage :
		$0 -opt=extract -project=project_name [-dirped]
		-dirped : extract a pedfile into a project directory\n
		$0 -opt=insert -pedfile=NGS*.ped \n");
}

if ($opt eq "insert") {
	OptInsertSection();
} elsif ($opt eq "extract") {
	ExtractPedigreeSection();
}

sub ExtractPedigreeSection {
	unless ($project_name) {
		confess ("usage :
          $0 -opt=extract -project=project_name [-dirped]
          -dirped : extract a pedfile into a project directory\n");
	}
	my $cgi    = new CGI;
	my $buffer = GBuffer->new;
	my $project = $buffer->newProject(-name => $project_name);
	# Attention newProject: unless $project->name() ne marche pas ...
	die( "unknown project" . $project_name ) unless $project->id();
	my $dir=$project->getProjectPath();
	$dir =~ s/HG[0-9]+\///;
	my $file_out;
	$file_out=$dir.$project_name.".ped" if $dirped;
	$file_out=$project_name.".ped" unless $dirped;
	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$project->id());
	my %fat;
	foreach my $f (@$patientList) {
		$f->{family}=$f->{name} unless $f->{family};
		$fat{$f->{family}."_".$f->{father}}=1 if $f->{father};
	}
	
	my %mot;
	foreach my $m (@$patientList) {
		$m->{family}=$m->{name} unless $m->{family};
		$mot{$m->{family}."_".$m->{mother}}=1 if $m->{mother};
	}
#	seek $FHO,0,0;
	my @data;
	my %seen;
	foreach my $p (@$patientList) {
		my %s;
		$p->{father}=$p->{family}."_P" unless $p->{father};
		$p->{mother}=$p->{family}."_M" unless $p->{mother};		
		$p->{father}=0 if (($fat{$p->{family}."_".$p->{name}}));
		$p->{mother}=0 if (($mot{$p->{family}."_".$p->{name}}));
		$p->{father}=0 unless  $p->{mother};
		$p->{mother}=0 unless  $p->{father};

		$s{family} = $p->{family};
		$s{name} = $p->{name};
		$s{father}=$p->{father};
		$s{mother}=$p->{mother};
		$s{sex}=$p->{sex};
		$s{status}=$p->{status};
		my $father=$s{father};
		my $mother=$s{mother};
		push(@data,\%s);
		my %a;
		if ($father eq $p->{family}."_P") {
			$a{family} = $p->{family};
			$a{name} = $p->{family}."_P";
			$a{father}=0;
			$a{mother}=0;
			$a{sex}=1;
			$a{status}=1;
			push(@data,\%a) unless $seen{$a{name}}++;
		}
		my %b;
		if ($mother eq $p->{family}."_M") {
			$b{family} = $p->{family};
			$b{name} = $p->{family}."_M";
			$b{father}=0;
			$b{mother}=0;
			$b{sex}=2;
			$b{status}=1;
			push(@data,\%b) unless $seen{$b{name}}++;
		}
	}
	my @result_sorted=sort {$b->{family} cmp $a->{family}||$b->{name} cmp $a->{name}} @data;
	my @result_sorted=sort {$b->{family} cmp $a->{family}||$b->{father} cmp $a->{father}||$b->{mother} cmp $a->{mother}} @data;
	my $dlo="\t";
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $l (@result_sorted) {
		print $FHO $l->{family}.$dlo.$l->{name}.$dlo.$l->{father}.$dlo.$l->{mother}.$dlo.$l->{sex}.$dlo.$l->{status}."\n";
	}
	close($FHO);
	
}

sub OptInsertSection {
	my @spfile = split(/\./,$pedfile);
	unless ($pedfile && $spfile[1] eq "ped") {
		confess ("usage :
          $0 -opt=insert -pedfile=NGS*.ped \n");
	}
	my $cgi    = new CGI;
	my $buffer = GBuffer->new;
	my $dir = "/data-xfs/sequencing/ngs/" ;
	my $level = 3 ;
	my @files = File::Find::Rule->extras({ follow => 1, follow_skip => 2 })
     							  ->file()
                                  ->name( $pedfile )
                                  ->maxdepth( $level )
                                  ->in( $dir );

	foreach my $u (@files) {
		InsertSection($u);
	}
	
	sub InsertSection {
		my ($find_filename) = @_;
		my ( $name, $path, $extension ) = fileparse( $find_filename, '\..*' );
		die unless (-e $find_filename );
		my $project_name =$name;
		InsertPedigreeSection($find_filename,$project_name);
	}

	sub InsertPedigreeSection {
		my ($filename,$project_name) = @_;
		open( my $FH, '<', $filename ) or die("Can't read this file: $filename\n");
 		upPedigreeProject($project_name,$FH);
		close($FH);

		sub uniqList {
			# need => use List::MoreUtils qw/ uniq /;
			my ($v) = @_;
			my @vs = split /,/ ,$v;
			my @unique = uniq @vs;
			my $invalid;
			foreach ( @unique ) {
				$invalid.=$_.",";
			}
			chop( $invalid );
			return ( $invalid );
		}

		sub upPedigreeProject {
			my ($project_name,$FH) = @_;
			my $projid = queryPolyproject::getProjectFromName($buffer->dbh,$project_name);
			next unless $projid;
			my $project = $buffer->newProject(-name => $project_name );
			die( "unknown project" . $project_name ) unless $project->id();
			### Autocommit dbh ###########
			my $dbh = $buffer->dbh;
			$dbh->{AutoCommit} = 0;
			##############################
#			seek $FH,0,0;
			my $pid = $project->id();
			my $listPatientName;
			my $invalid_project;
			my $patients = $project->getPatients();
			my %hash = map{$_->name(), 1} @$patients;
		
			while ( my $Line = <$FH> ) {
				my @data = split( /\s+/, $Line );
				$invalid_project.=$data[1]."," unless (($hash{$data[1]})||(($data[2] eq 0)&&($data[3] eq 0)));
				next unless $hash{$data[1]} ;
				$listPatientName.=$data[1].",";
				$data[2]="" unless (($data[2]) && ($hash{$data[2]}));
				$data[3]="" unless (($data[3]) && ($hash{$data[3]}));
				queryPolyproject::upPatientPedigree($buffer->dbh,$pid,$data[1],$data[0],$data[2],$data[3],$data[4],$data[5]);
			}
			chop($listPatientName);
			#### End Autocommit dbh ###########
			$dbh->commit();

			if ($listPatientName) {
				if (uniqList($invalid_project)) {
				messageOK ("Project: ".$project_name."\tPedigree updating for Patients: ".$listPatientName.
				"\nProject: ".$project_name."\tInvalid Patients: ".uniqList($invalid_project));
				} else {
				messageOK ("Project: ".$project_name."\tPedigree updating for Patients: ".$listPatientName);
				}
			} else {
				messageError("Project: ".$project_name."\tError Invalid Patients: ".uniqList($invalid_project));
			}
		}	
	}
}

sub messageOK {
        my ($title) = @_;
        print "$title \n\n";
}

sub messageError {
        my ($title) = @_;
        print "$title \n\n";
}

exit(0);

