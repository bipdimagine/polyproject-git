#!/usr/bin/perl
########################################################################
###### pedigree_file.pl #################################################
#./script_pedigreeFile.pl
#/data-xfs/dev/plaza/polyprojectNGS/cgi-bin/pedigree_file.pl -opt=insert -ped="NGS2014_0429.ped"
#/data-xfs/dev/plaza/polyprojectNGS/cgi-bin/pedigree_file.pl -opt=extract -project="NGS2014_0429"
#./script_pedigreeFile.pl -opt=extract -project="NGS2014_0429" -dirped
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

#use util_file qw(readXmlVariations);
#use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;
use Logfile::Rotate; 

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


my $cgi    = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $project_name = $cgi->param('project');
my $dirped = $cgi->param("dirped");
my $force = $cgi->param("force");
my $view = $cgi->param("view");

GetOptions(
		'opt=s' => \$opt,
        'pedfile=s' => \$pedfile,
        'project=s'  => \$project_name,
        'dirped' => \$dirped,
        'force' => \$force,
        'view' => \$view
        
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
########################################################################################
sub ExtractPedigreeSection {
	unless ($project_name) {
		confess ("usage :
          $0 -opt=extract -project=project_name [-dirped] [-force]
          -dirped : extract a pedfile into a project directory
          -force : make a copy of old pedfile and replace it
          \n");
	}
	my $project = $buffer->newProject(-name => $project_name);
	# Attention newProject: unless $project->name() ne marche pas ...
	die( "unknown project" . $project_name ) unless $project->id();
	my $dir=$project->getProjectPath();
	my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$project->id());
	$dir =~ s/$rel\///;
	my $file_out;
	$file_out=$dir.$project_name.".ped" if $dirped;
	$file_out=$project_name.".ped" unless $dirped;
#	my ( $name, $path, $extension ) = fileparse( $file_out, '\..*' );
	if (-e $file_out && !$force) {
		sendError("Error: Project Patient Ped file  <b>". $project_name.".ped"." </b> already exists in project folder: ". $project_name."<BR>Click Before on Force to make a copy version file and replace it");
 		return;
 	}
  	my $patientList = queryPolyproject::getPatientProjectInfo($buffer->dbh,$project->id());
#  	warn Dumper $patientList;
	my %fat;

	foreach my $f (@$patientList) {
		$f->{family}=$f->{name} unless $f->{family};
		$fat{$f->{family}."_".$f->{father}}=1 if $f->{father};
	}
	
	my %mot;
	foreach my $m (sort {$b->{family} cmp $a->{family}}@$patientList) {
		$m->{family}=$m->{name} unless $m->{family};
		$mot{$m->{family}."_".$m->{mother}}=1 if $m->{mother};
	}
#	seek $FHO,0,0;
	my @data;
	my %seen;
	foreach my $p (@$patientList) {
		my %s;
		my $fatnew=0;
		my $motnew=0;
		$fatnew=1 unless $p->{father};
		$motnew=1 unless $p->{mother};
		$p->{father}=$p->{family}."_Pere" unless $p->{father};
		$p->{mother}=$p->{family}."_Mere" unless $p->{mother};		
		$p->{father}=0 if (($fat{$p->{family}."_".$p->{name}}));
		$p->{mother}=0 if (($mot{$p->{family}."_".$p->{name}}));
		$p->{father}=0 unless  $p->{mother};
		$p->{mother}=0 unless  $p->{father};

		$s{family} = $p->{family};
		$s{name} = $p->{name};
		$s{father}=$p->{father};
		$s{mother}=$p->{mother};
		$s{sex}=$p->{sex};
		$s{sex}=1 unless $p->{sex};
		$s{status}=$p->{status};
		$s{status}=2 unless $p->{status};		
		my $father=$s{father};
		my $mother=$s{mother};
		push(@data,\%s);

		my %a;
		if ($father eq $p->{family}."_Pere" && $fatnew) {
			$a{family} = $p->{family};
			$a{name} = $p->{family}."_Pere";
			$a{father}=0;
			$a{mother}=0;
			$a{sex}=1;
			$a{status}=1;
			push(@data,\%a) unless $seen{$a{name}}++;
		}
		my %b;
		if ($mother eq $p->{family}."_Mere" && $motnew) {
			$b{family} = $p->{family};
			$b{name} = $p->{family}."_Mere";
			$b{father}=0;
			$b{mother}=0;
			$b{sex}=2;
			$b{status}=1;
			push(@data,\%b) unless $seen{$b{name}}++;
		}
	}
	my @result_sorted=sort {$b->{family} cmp $a->{family}||$b->{father} cmp $a->{father}||$b->{mother} cmp $a->{mother}} @data;
	my $dlo="\t";
	my $file_out2;
	$file_out2=$project_name.".ped";
	logrotate_File("$file_out2",$dir);
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $l (@result_sorted) {
#		print $l->{family}.$dlo.$l->{name}.$dlo.$l->{father}.$dlo.$l->{mother}.$dlo.$l->{sex}.$dlo.$l->{status}."\n";
		print $FHO $l->{family}.$dlo.$l->{name}.$dlo.$l->{father}.$dlo.$l->{mother}.$dlo.$l->{sex}.$dlo.$l->{status}."\n";
	}
	chmod(0777,$FHO);
	close($FHO);
	sendOK("Successful validation for Project Patient Ped file: <b>". $project_name.".ped</b>" );
}

sub logrotate_File {
	my ($sub,$dir_backup) = @_;
	my $file_out = $dir_backup.'/'.$sub;
	if (-e $file_out) {
		my $merge_rotate = new Logfile::Rotate (
				File  => $file_out,
				Count => 9,
				Dir	  => $dir_backup,
				Gzip  => 'no',
				 );		
		$merge_rotate->rotate();
		unlink $file_out;
	}
}

########################################################################################
sub OptInsertSection {
	my @spfile = split(/\./,$pedfile);
	unless (($pedfile && $spfile[1] eq "ped") || ($project_name)) {
		confess ("usage :
          $0 -opt=insert -pedfile=NGS*.ped \n");
	}
	#modif
	
	my $project = $buffer->newProject(-name => $project_name);
	# Attention newProject: unless $project->name() ne marche pas ...
	die( "unknown project" . $project_name ) unless $project->id();
	my $dir=$project->getProjectPath();
	my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$project->id());
	$dir =~ s/$rel\///;
	my $level = 3 ;
	my @files;
	@files = File::Find::Rule->extras({ follow => 1, follow_skip => 2 })
     							  ->file()
                                  ->name( $pedfile )
                                  ->maxdepth( $level )
                                  ->in( $dir ) unless $project_name;
    @files =  $dir.$project_name.".ped" if $project_name   ;                    
	foreach my $u (@files) {
		InsertSection($u);
	}

	sub InsertSection {
		my ($find_filename) = @_;
		my ( $name, $path, $extension ) = fileparse( $find_filename, '\..*' );
		die unless (-e $find_filename || $view);
		my $project_name =$name;
		InsertPedigreeSection($find_filename,$project_name);
	}

	sub InsertPedigreeSection {
		my ($filename,$project_name) = @_;
		my $FH;
		if ($view) {
			 open( $FH, '<', $filename ) or emptyFile();
		} else {
			open( $FH, '<', $filename ) or die("Can't read this file: $filename\n");
		}
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

	sub emptyFile {
		my @wdata;
		my %hwdata;
		$hwdata{identifier}="patient";
		my %s;
		$s{patient} = "";
		$s{family} = "";
		$s{father} = "";
		$s{mother} = "";
		$s{sex} = "";
		$s{status} = "";
		push(@wdata,\%s);
		$hwdata{items}=\@wdata;
		printJson(\%hwdata);
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
			my @wdata;
			my %hwdata;
#			$hwdata{label}="patient";
			$hwdata{identifier}="patient";
		
			while ( my $Line = <$FH> ) {
				my %s;
				my @data = split( /\s+/, $Line );
				$invalid_project.=$data[1]."," unless (($hash{$data[1]})||(($data[2] eq 0)&&($data[3] eq 0)));
				next unless ($hash{$data[1]} || $view) ;
				$listPatientName.=$data[1].",";
				$data[2]="" unless ((($data[2]) && ($hash{$data[2]}))|| $view);
				$data[3]="" unless ((($data[3]) && ($hash{$data[3]}))|| $view);
				$s{patient} = $data[1];
				$s{family} = $data[0];
				$s{father} = $data[2];
				$s{mother} = $data[3];
				$s{sex} = $data[4];
				$s{status} = $data[5];
				#warn $s{patient}."\t".$s{family}."\t".$s{father}."\t".$s{mother}."\t".$s{sex}."\n" unless $view;
				push(@wdata,\%s);
				queryPolyproject::upPatientPedigree($buffer->dbh,$pid,$data[1],$data[0],$data[2],$data[3],$data[4],$data[5]) unless $view;
			}
			$hwdata{items}=\@wdata;
			printJson(\%hwdata) if $view;
			
			chop($listPatientName);
			#### End Autocommit dbh ###########
			$dbh->commit();
			my $typecomOK;
			$typecomOK="messageOK" if $pedfile;
			$typecomOK="sendOK" unless $pedfile;
			my $typecomError;
			$typecomError="messageError" if $pedfile;
			$typecomError="sendError" unless $pedfile;
			
			my $rescomm;
			if ($listPatientName) {
				if (uniqList($invalid_project)) {
				$rescomm="$typecomOK('Project: '.'$project_name'.'<br>Depending Pedigree File, Update Patients: '.'$listPatientName'.'
<br>Project: '.'$project_name'.' Invalid Patients: '.uniqList('$invalid_project'))";
				} else {
				$rescomm="$typecomOK('Project: '.'$project_name'.'<br>Depending Pedigree File, Update Patients: '.'$listPatientName')";
				}
			} else {
				$rescomm="$typecomError('Error Project: '.'$project_name'.' Error Invalid Patients: '.uniqList('$invalid_project'))";	
			}
			eval $rescomm;
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
	exit(0);
}

sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}

exit(0);

