#!/usr/bin/perl
#############################################################################
# new_polyproject.pl ##from GenBo/script/ngs_exome/last_script/new_project.pl
#############################################################################

use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 

use Carp;
use strict;
use Set::IntSpan::Fast::XS ;
use Data::Dumper;
use GBuffer;
use Getopt::Long;
use File::Basename;
use File::Find::Rule;
use List::Util qw/ max min /;

#use util_file qw(readXmlVariations);
#use insert;

use CGI;
use connect;
use JSON::XS;
use queryPolyproject;
use queryPerson;

my $cgi = new CGI;

#chargement du buffer
my $buffer = GBuffer->new;

#paramètre passés au cgi
my $opt = $cgi->param('opt');

#print $cgi->header();
if ( $opt eq "newPoly" ) {
	ProjectSection();
} elsif ( $opt eq "newgPoly" ) {
	genomicProjectSection();
} elsif ( $opt eq "newRun" ) {
	RunSection();
} elsif ( $opt eq "newPatRun" ) {
	PatRunSection();
} elsif ( $opt eq "addProjPat" ) {
	ProjectPatientSection();
} elsif ( $opt eq "addPatientProj" ) {
	addPatientProjSection();
} elsif ( $opt eq "newRunG" ) {
	genomicRunSection();
} 

###### Add Project  ###################################################################
sub ProjectSection {
	my $project_name;
	my $golden_path = $cgi->param('golden_path');
	my $description = $cgi->param('description');
	my $dejavu = $cgi->param('dejaVu');
	my $somatic = $cgi->param('somatic');
	my $database = $cgi->param('database');
#	my $analyse = $cgi->param('analyse');

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};

	my %config;
	$config{type_db} = $database;
	my $dbid = queryPolyproject::getDbId($buffer->dbh,$config{type_db});
	die("$database unknown") unless $dbid;
	sendError( "undefined database " . $dbid ) unless ($dbid);
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
	die("release $golden_path  unknown") unless $releaseid;
	sendError( "undefined release " . $releaseid) unless ($releaseid);
# No project_type but run_type and all run_type=3 for ngs
# All projects are ngs: type=3
	my $type={"id"=>3};
	my $prefix;
	if($database eq "polydev"){
		$prefix= "DEV";
	}
	elsif($database eq "Polyexome"){
		$prefix = "NGS";
	}
	elsif($database eq "Polyrock"){
		$prefix = "ROCK";
	}
	else {
		sendError("No project created for database Polyprod");
		die;
	}
#call => renvoit id et nom
	my $query = qq{CALL PolyprojectNGS.new_project("$prefix",$type->{id},"$description");};
	my $sth = $buffer->dbh()->prepare( $query );
	$sth->execute();

	my $res = $sth->fetchall_arrayref({});
	sendError("No project created") if ( scalar(@$res) == 0 );

	my $pid = $res->[0]->{project_id};
	sendError("No project created") unless ($pid);

	queryPolyproject::addDb($buffer->dbh,$pid,$dbid);
	#add Release to Project Release
	queryPolyproject::addRelease($buffer->dbh,$pid,$releaseid);
	
	#dejaVu somatic update Project	
	queryPolyproject::upProject($buffer->dbh,$pid,$description,$dejavu,$somatic);
### End Autocommit dbh ###########
	$dbh->commit();

	my $typeId=$type->{id};
	my $name = $res->[0]->{name};
	
	$ENV{'DATABASE'} = "";
	my $buffer = GBuffer->new();
	my $projectG = $buffer->newProject(-name=>$name);
#	$projectG->getProjectPath();
	$projectG->makePath();
# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
	my $dbh = $buffer->dbh;
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
	#TODO: decommenté"
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for project name: " . $name);	
} # End of project section



###### Add Genomic Project  ###################################################################

sub genomicProjectSection {
# All projects are ngs: type=3
	my $runid = $cgi->param('run');
	my $golden_path = $cgi->param('golden_path');
	my $description = $cgi->param('description');
	my $dejavu = $cgi->param('dejaVu');
	my $somatic = $cgi->param('somatic');
	
#	my $groupdisease_id = $cgi->param('disease');
	my $database = $cgi->param('database');

	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	
	my $listPatname= $cgi->param('PatNameSel');
	my @PatName = split(/,/,$listPatname);
	my $listChoice = $cgi->param('choice');
		my @fieldCh = split(/,/,$listChoice);

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};

	my %config;
	$config{type_db} = $database;

	my $dbid = queryPolyproject::getDbId($buffer->dbh,$config{type_db});
	die("$database unknown") unless $dbid;
	sendError( "undefined database " . $dbid ) unless ($dbid);
	my $releaseid = queryPolyproject::getReleaseId_v2($buffer->dbh,$golden_path);
	die("release $golden_path  unknown") unless $releaseid;
	sendError( "undefined release " . $releaseid) unless ($releaseid);
# No project_type but run_type and all run_type=3 for ngs
	my $type={"id"=>3};
	my $prefix;
	if($database eq "polydev"){
		$prefix= "DEV";
	}
	elsif($database eq "Polyexome"){
		$prefix = "NGS";
#	$prefix = "TES";
	}
	elsif($database eq "Polyrock"){
		$prefix = "ROCK";
#	$prefix = "TES";
	}
	else {
		sendError("No project created for database Polyprod");
		die;
	}
#call => renvoit id et nom
	my $query = qq{CALL PolyprojectNGS.new_project("$prefix",$type->{id},"$description");};
	my $sth = $buffer->dbh()->prepare( $query );
	$sth->execute();

	my $res = $sth->fetchall_arrayref({});
	sendError("No project created") if ( scalar(@$res) == 0 );

	my $pid = $res->[0]->{project_id};
	sendError("No project created") unless ($pid);

=pod
=cut
	queryPolyproject::addDb($buffer->dbh,$pid,$dbid);
	queryPolyproject::addRelease($buffer->dbh,$pid,$releaseid);
	#dejaVu & somatic update Project
	queryPolyproject::upProject($buffer->dbh,$pid,$description,$dejavu,$somatic);

	for (my $i = 0; $i< scalar(@PatId); $i++) {
		if (@fieldCh[$i] eq "U") {
			queryPolyproject::upPatientProjectDest($buffer->dbh,@PatId[$i],$pid);
		} elsif (@fieldCh[$i] eq "A") {
			my $last_patient_id=queryPolyproject::addPatientProject($buffer->dbh,@PatName[$i],@PatName[$i],$runid,$pid);
		}
	}	

### End Autocommit dbh ###########
	$dbh->commit();

	my $typeId=$type->{id};
	my $name = $res->[0]->{name};
	$ENV{'DATABASE'} = "";
	my $buffer = GBuffer->new();
	my $projectG = $buffer->newProject(-name=>$name);
	$projectG->getProjectPath();
	$projectG->makePath();
# cgi-bin/plaza/GenBo/lib/obj/GenBoProject.pm :{mode=>0777,verbose=>0}
	my $dbh = $buffer->dbh;
### Autocommit dbh ###########
	$dbh->{AutoCommit} = 0;
	#TODO: decommenté"
#	my $query1 =qq{INSERT INTO $database.ORIGIN(NAME,TYPE_ORIGIN_ID,DESCRIPTION) values ("$name",$typeId,"$description");};
#	$dbh->do($query1) ;
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("New Project ".$name." contains now Patients: ".$listPatname );				

} # End of project section


###### Add Run ###################################################################
sub RunSection {
	my $description = $cgi->param('description');
	my $gmachine = $cgi->param('gmachine');
	my $grun = $cgi->param('grun');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $method_seq = $cgi->param('mseq');
	my $type = $cgi->param('type');
	my $capture = $cgi->param('capture');
	my $patients = $cgi->param('patient');
	my $sex = $cgi->param('sex');
	my $status = $cgi->param('status');
	my $desPat = $cgi->param('desPat');
	my $bc = $cgi->param('bc');
	my $users = $cgi->param('user');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
	
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);	
	my $captureId = queryPolyproject::getCaptureId($buffer->dbh,$capture);
	sendError( "undefined capture " . $capture ) unless ($captureId);

	my $validAln="";
	if ($group_method_align_name) {
		my @ListAln = split(/,/,$group_method_align_name);
		foreach my $u (@ListAln) {
			my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
			$validAln.=$method_align->{id}."," if ($method_align);
		}
		chop($validAln);
		sendError("undefined method_align: " . $group_method_align_name ) unless $validAln;	
	}

	my $validMeth="";
	if ($group_method_calling_name) {
		my @ListMeth = split(/,/,$group_method_calling_name);
		foreach my $u (@ListMeth) {
			my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
			$validMeth.=$method_call->{id}."," if ($method_call);
		}
		chop($validMeth);
		sendError("undefined method_call: " . $group_method_calling_name ) unless $validMeth;	
	}
# create runid
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id},$description,$gmachine,$grun);
	my $runid=$last_run_id->{'LAST_INSERT_ID()'};

# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
	
# new patient
	for my $u (@pat) {
		my $last_patient_id=queryPolyproject::addPatientRun($buffer->dbh,$u,$u,$runid, $captureId,$sex,$status,$desPat,$bc);
		# add Method in patient_methods
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$validAln);	
			foreach my $m (@ListAln) {
				my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
				queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
			}	
		}
		if ($group_method_calling_name) {
			my @ListMeth = split(/,/,$validMeth);	
			foreach my $m (@ListMeth) {
				my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
				queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
			}	
		}		
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runid);	
}

sub isUniqPatient {
	my ($dbh,@patient) = @_;
	my $novalidP="";
	my %seen;
	for my $p (@patient) {
		$novalidP.=$p."," if $seen{$p}++;
	}
	chop($novalidP);
	return $novalidP
}

sub genomicRunSection {
	my $selplt = $cgi->param('SelPlt');
	my $description = $cgi->param('description');
	my $name = $cgi->param('name');
	my $pltname = $cgi->param('pltname');
	my $plateform = $cgi->param('plateform');
	my $seq_machine = $cgi->param('machine');

	my $method_pipeline = $cgi->param('method_pipeline');	
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $group_method_other_name = $cgi->param('method_other');
	
	my $method_seq = $cgi->param('mseq');
	my $captureId = $cgi->param('capture');
	my $type = $cgi->param('type');
	my $nbpat = $cgi->param('nbpat');
	my $fc = $cgi->param('fc');
	my $typepat = $cgi->param('typePatient');
	my $speciesid = $cgi->param('species');
	my $profileid = $cgi->param('profileId');
	my $samplefile = $cgi->param('file');

# group
	my $groups = $cgi->param('group');
	$groups=~ s/ //g;
	$groups=~ s/\n/;/g;
	my @grp=split(/,/,$groups);

	my $patients = $cgi->param('patient');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
	
	my $families = $cgi->param('family');
	$families=~ s/ //g;
	$families=~ s/\n/;/g;
	my @fam=split(/,/,$families);

	my $fathers = $cgi->param('father');
	$fathers=~ s/ //g;
	$fathers=~ s/\n/;/g;
	my @lfathers=split(/,/,$fathers);

	my $mothers = $cgi->param('mother');
	$mothers=~ s/ //g;
	$mothers=~ s/\n/;/g;
	my @lmothers=split(/,/,$mothers);

	my $sexs = $cgi->param('sex');
	$sexs=~ s/ //g;
	$sexs=~ s/\n/;/g;
	my @lsexs=split(/,/,$sexs);

	my $statuss = $cgi->param('status');
	$statuss=~ s/ //g;
	$statuss=~ s/\n/;/g;
	my @lstatuss=split(/,/,$statuss);

	my $barcode = $cgi->param('bc');
	$barcode=~ s/ //g;
	$barcode=~ s/\n/;/g;
	my @bc=split(/,/,$barcode);

	my $barcode2 = $cgi->param('bc2');
	$barcode2=~ s/ //g;
	$barcode2=~ s/\n/;/g;
	my @bc2=split(/,/,$barcode2);

	my $gbarcode = $cgi->param('iv');
	$gbarcode=~ s/ //g;
	$gbarcode=~ s/\n/;/g;
	my @bcg=split(/,/,$gbarcode);

	my $p_person = $cgi->param('person');
	$p_person=~ s/ //g;
	$p_person=~ s/\n/;/g;
	my @person=split(/,/,$p_person);
	
# Extended	options
	my $extended=0;
	my $s_personsearch = $cgi->param('s_personsearch');
	$s_personsearch=~ s/ //g;
	$s_personsearch=~ s/\n/;/g;
	$extended= 1 if $s_personsearch;
	my @s_personsearch=split(/,/,$s_personsearch);
	
	my $s_person = $cgi->param('s_person');
	$s_person=~ s/ //g;
	$s_person=~ s/\n/;/g;
	my @s_person=split(/,/,$s_person);	
	my $s_personid = $cgi->param('s_person_id');
	$s_personid=~ s/ //g;
	$s_personid=~ s/\n/;/g;
	my @s_personid=split(/,/,$s_personid);
	my $hash_pers;		
	for (my $i = 0; $i< scalar(@s_personsearch); $i++) {
		$hash_pers->{$s_personsearch[$i]} = $s_person[$i].",".$s_personid[$i];
	}
#	warn Dumper $hash_pers;
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $plateformid = queryPolyproject::getPlateformFromName($buffer->dbh,$plateform);
	sendError( "undefined plateform " . $plateform) unless ($plateformid);
	my $smid = queryPolyproject::getMachineFromName($buffer->dbh,$seq_machine);
	sendError( "undefined machine " . $seq_machine ) unless ($smid);
	my $meth_seq = queryPolyproject::getMethSeqFromName($buffer->dbh,$method_seq);
	sendError( "undefined method seq " . $method_seq ) unless ($meth_seq);
	my $rtype = queryPolyproject::getOriginType($buffer->dbh, $type);
	sendError( "undefined type " . $type) unless ($rtype);
	
# Error Patients 
	my $novalidPatient = isUniqPatient($buffer->dbh,@pat);
	sendError( "<b>Error Patient:<b> Duplicated Patients $novalidPatient in this current Run..." ) if ($novalidPatient);

# Warning Genotype Bar Code
	my %seenB = ();
	my @duplicateB = map { 1==$seenB{$_}++ ? $_ : () } @bcg;

	my $messageduplicateB="";
	if (scalar @duplicateB) {
		$messageduplicateB=join(",",@duplicateB);
	}
	$messageduplicateB="<br><b>Warning:</b> Duplicated Genotype Code : $messageduplicateB" if scalar @duplicateB;

	if (! $extended) {
		my @identical;
		my %hdata;
		$hdata{identifier}="Row";
		$hdata{label}="Row";
		my $ident=0;
		my $row=1;
		my %seen=();
		my %seenPers=();
		my @existPers;
		foreach my $s (@person) {
			next unless $s;
			my $personList= queryPerson::getPatientPersonInfo_Startwith_PersonName($buffer->dbh,$s);
			if (scalar @$personList) {
				$ident=1;
#				if ($s=~ m/^[A-Z]{2}[0-9]{10}$/) 
				my @newPersonName=new_PersonName($row,$s,$personList);
				@existPers=map{$_->{person}}@newPersonName;
				push(@identical,@newPersonName) unless $seenPers{@existPers." ".$s};
				#warn Dumper  @identical;
				$seenPers{@existPers." ".$s}++;
				$row++;			
				for my $y (@$personList) {
					#next if $y->{person}=~ m/^[A-Z]{2}[0-9]{10}$/;
					next if $seen{$y->{person_id}}++;
#					die;
					my %si;
					$si{Row} = $row++;
					$si{imax} = 0;
					$si{person_s} = $s;
					$si{person} = $y->{person};
					$si{person_id} = $y->{person_id};				
					$si{patient} = $y->{name};
					$si{patient_id} = $y->{patient_id};
					$si{run} = $y->{run_id};
					$si{projectId} = $y->{project_id};
					$si{project} = $y->{project};
					$si{capAnalyse} = $y->{capAnalyse};
					$si{family} = $y->{family};
					$si{sex} = $y->{sex};
					$si{status} = $y->{status};
					$si{iv_vcf} = $y->{identity_vigilance_vcf};
					push(@identical,\%si);
				}				
			}
		}
		$hdata{items}=\@identical;
		if ($ident) {
			my $extend;
			$extend=\%hdata;
			sendExtended("Extend",$extend);
		}
	}
# create runid
	my $last_run_id=queryPolyproject::newRun($buffer->dbh,$rtype->{id},$description,$name,$pltname,$nbpat);
	my $runid=$last_run_id->{'LAST_INSERT_ID()'};
# genomic plateform: update field step: 1 => not validate ; 0 => validate
	queryPolyproject::upStep2run($buffer->dbh,$runid,1);
# update sample sheet file	
	#my $publicdir = $buffer->config()->{public_data}->{root};
	#my @dir_sp = split(/public-data/,$publicdir);
	#my $tempdir=$dir_sp[0]."sequencing/Temp/";
	my $publicdir;
	my @dir_sp;
	my $tempdir;
	if (exists $buffer->config()->{public_data}->{root}) {
		$publicdir = $buffer->config()->{public_data}->{root};
		@dir_sp = split(/public-data/,$publicdir);
		$tempdir=$dir_sp[0]."sequencing/Temp/";
	} else {
		$publicdir = $buffer->hash_config_path()->{root}->{project_data};
		@dir_sp = split(/public-data/,$publicdir);
		$tempdir=$dir_sp[0]."sequencing/Temp/";
	}
	my $pre_Indir=$tempdir.$name;
	my $Indir=$pre_Indir."/".$pltname;
	my $level = 3 ;
	my @files;
	@files = File::Find::Rule->extras({ follow => 1, follow_skip => 2 })
     							  ->file()
                                  ->name( $samplefile )
                                  ->maxdepth( $level )
                                  ->in( $Indir );
	if (scalar @files) {
		# Open the file
		my $dir_filename=$Indir."/".$samplefile;
		
		my ( $o_name, $o_path, $o_extension ) = fileparse( $dir_filename, '\..*' );
		$o_extension =~ s/\.//;	
		open MYFILE, $dir_filename || print "Cannot open file";
		my $blob_file;

		# Read in the contents
		while (<MYFILE>) {
    		$blob_file .= $_;
    	}
		close MYFILE;
		my $file_type=$o_extension;
		queryPolyproject::upRunDocument($buffer->dbh, $runid,$samplefile,$file_type,$blob_file);
		system("rm -rf $pre_Indir");
	}
	
# method pipeline
	my $validPipe="";
	if ($method_pipeline) {
		my $meth_pipe = queryPolyproject::getPipelineMethods_byId($buffer->dbh,$method_pipeline);
		my @ListPipe = split(/ /,$meth_pipe->[0]->{content});	
		foreach my $m (@ListPipe) {
				my $method_p= queryPolyproject::getMethodsFromName($buffer->dbh,$m);
				$validPipe.=$method_p->{id}."," if ($method_p);
		}
		chop($validPipe);
		sendError("Error undefined method in Pipeline Methods: " . $method_pipeline ) unless $validPipe;	
	}

# method aln
	my $validAln="";
	my $validCall="";
	my $validOther="";
	unless ($selplt) {
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$group_method_align_name);
			foreach my $u (@ListAln) {
				my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
				$validAln.=$method_align->{id}."," if ($method_align);
			}
			chop($validAln);
			sendError("Error undefined method_align: " . $group_method_align_name ) unless $validAln;	
		}
# method call
		if ($group_method_calling_name) {
			my @ListCall = split(/,/,$group_method_calling_name);
			foreach my $u (@ListCall) {
				my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
				$validCall.=$method_call->{id}."," if ($method_call);
			}
			chop($validCall);
			sendError("Error undefined method_call: " . $group_method_calling_name ) unless $validCall;	
		}		
# method other
		if ($group_method_other_name) {
			my @ListOther = split(/,/,$group_method_other_name);
			foreach my $u (@ListOther) {
				my $method_other = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"other");
				$validOther.=$method_other->{id}."," if ($method_other);
			}
			chop($validOther);
			sendError("Error undefined method_other: " . $group_method_other_name ) unless $validOther;	
		}		
	}	
# add link run_id
	queryPolyproject::addPlateform2run($buffer->dbh,$plateformid->{id},$runid);
	queryPolyproject::addMachine2run($buffer->dbh,$smid->{machineId},$runid);
	queryPolyproject::addMethSeq2run($buffer->dbh,$meth_seq->{methodSeqId},$runid);
# new patient & family
	my $i;
	my $validR="";
	my $validP="";
	my %seen;
	my %seen2;
	my @patientpersonId;
	for my $p (@pat) {
		my $j;
		for my $f (@fam) {
			if ($i==$j) {
				my $pname=queryPolyproject::ctrlPatientNameInRun($buffer->dbh,$p);
				for my $pc (@$pname) {
					$validR.=$pc->{name}.":".$pc->{run_id}."," unless $seen{$pc->{name}}++;
					my $proj=queryPolyproject::getProjectNamefromPatient($buffer->dbh,$pc->{run_id},$pc->{project_id}) if $pc->{project_id};
					if (defined $proj) {
						$validP.=$pc->{name}.":". $proj->{name}."," unless $seen2{$pc->{name}}++;
					};
				}
				$profileid=0 unless defined $profileid;
				$profileid=0 unless $profileid;
				my $last_patient_id=queryPolyproject::newPatientRun($buffer->dbh,$p,$p,$runid,$captureId,$f,$fc,$bc[$i],$bc2[$i],$bcg[$i],$lfathers[$i],$lmothers[$i],$lsexs[$i],$lstatuss[$i],$typepat,$speciesid,$profileid);
				my $patient_id=$last_patient_id->{'LAST_INSERT_ID()'};

				# phase 1
				my $personRunList= queryPerson::getPatientPersonInfo_byPersonName_Run($buffer->dbh,$person[$i]);
				my @existPers=map{$_->{person_id}}@$personRunList;
				my $person_id;
				my $l_species=queryPerson::getSpecies_FromId($buffer->dbh,$speciesid);
				unless (scalar(@existPers)) {
					my $last_person_id;
					$last_person_id=queryPerson::insertPerson($buffer->dbh,$person[$i],$lsexs[$i],$lstatuss[$i],0,0,0,0) if $person[$i];
					$last_person_id=queryPerson::insertPerson($buffer->dbh,$p,$lsexs[$i],$lstatuss[$i],0,0,0,0) unless $person[$i];
					$person_id=$last_person_id->{'LAST_INSERT_ID()'};
				} else {
					if ($hash_pers->{$person[$i]})	{
						if ((split ',',$hash_pers->{$person[$i]})[1]) {
							$person_id=(split ',',$hash_pers->{$person[$i]})[1];
						} else {
							my $person_name=(split ',',$hash_pers->{$person[$i]})[0];
							my $last_person_id=queryPerson::insertPerson($buffer->dbh,$person_name,$lsexs[$i],$lstatuss[$i],0,0,0,0);
							$person_id=$last_person_id->{'LAST_INSERT_ID()'};
							$hash_pers->{$person[$i]}.=	$person_id;
						}
					} else {
						my $e_person=queryPerson::getPersonName_fromName($buffer->dbh,$person[$i]);
						$person_id=$e_person->{person_id};
					}					
				}				
				queryPerson::insertPatientPerson($buffer->dbh,$patient_id,$person_id);
				push(@patientpersonId,$patient_id.",".$person_id);
				my $persname;
				#$persname=$l_species->{code}.sprintf("%010d", $person_id) if ($person[$i] eq $p || !$person[$i]);
				#queryPerson::upPersonName($buffer->dbh,$person_id,$persname) if ($person[$i] eq $p || !$person[$i]);				
				$persname=$l_species->{code}.sprintf("%010d", $person_id) unless $person[$i];
				queryPerson::upPersonName($buffer->dbh,$person_id,$persname) unless $person[$i];				
				
				#Group (new/old)
				if (defined $grp[$i] && $grp[$i]) {
					my $groupid;
					# test si group exist
					my $group = queryPolyproject::getGroupIdFromName($buffer->dbh,$grp[$i]) if (defined $grp[$i] && $grp[$i]);
					my $last_groupid = queryPolyproject::newGroup($buffer->dbh,$grp[$i]) unless defined $group;
					$groupid = $last_groupid->{'LAST_INSERT_ID()'} if defined $last_groupid;
					$groupid = $group->{group_id} unless defined $last_groupid;
					my $patient_id=$last_patient_id->{'LAST_INSERT_ID()'};
				#Patient Group
					queryPolyproject::addGroup2patient($buffer->dbh,$patient_id,$groupid) if ($groupid);
				}
			};
			$j++;
		}
		$i++;
	}	
	chop($validR);
	chop($validP);
	# phase 2
	# update person for familyId fatherId motherId
	for my $l (@patientpersonId) {
		my $l_patid=(split(/,/,$l))[0];
		my $l_persid=(split(/,/,$l))[1];
		my $res_pat=queryPerson::getPatientPersonInfo_byPatientId_Run($buffer->dbh,$l_patid);		
		my $fam;
		my $familyId;
		if ($res_pat->{family}) {
			$fam=queryPerson::getFamily_FromName($buffer->dbh,$res_pat->{family});
			unless ($fam->{name}) {
				my $last_family_id=queryPerson::insertFamily($buffer->dbh,$res_pat->{family});
				$familyId=$last_family_id->{'LAST_INSERT_ID()'};
			} else {
				$familyId=$fam->{family_id};
			}			
		}
		queryPerson::upPerson_inFamilyId($buffer->dbh,$res_pat->{person_id},$familyId) if $familyId;		
		if ($res_pat->{father}) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$res_pat->{father},$res_pat->{run_id});
			queryPerson::upPerson_inFatherId($buffer->dbh,$res_pat->{person_id},$patientList->[0]->{person_id});			
		}
		if ($res_pat->{mother}) {
			my $patientList = queryPerson::getPatientPersonInfo_byPatientName_Run($buffer->dbh,$res_pat->{mother},$res_pat->{run_id});
			queryPerson::upPerson_inMotherId($buffer->dbh,$res_pat->{person_id},$patientList->[0]->{person_id});
		}		
	}		
#  add Meth call & aln to patient
	unless ($selplt) {
		for my $u (@pat) {
			# add Method in patient_methods
			if ($group_method_align_name) {
				my @ListAln = split(/,/,$validAln);	
				foreach my $m (@ListAln) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($group_method_calling_name) {
				my @ListCall = split(/,/,$validCall);	
				foreach my $m (@ListCall) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($group_method_other_name) {
				my @ListOther = split(/,/,$validOther);	
				foreach my $m (@ListOther) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}
			if ($method_pipeline) {
				my @ListMethPipe = split(/,/,$validPipe);	
				foreach my $m (@ListMethPipe) {
					my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runid);
					queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
				}	
			}					
		}
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	if ($validP)	{
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR."<BR>and Project: ".$validP.$messageduplicateB)
	} elsif ($validR)	{
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid.
		"</B><BR><B>WARNING:</B> Patient already exist in Run: ".$validR.$messageduplicateB)
	} else {
		sendOK("OK: Patient created: <B>". $patients."</B> in Run: <B>".$runid."</B>".$messageduplicateB)
	}
}

sub new_PersonName {
	my ($row,$person,$List) = @_;
	my @simPers=split('__',join(',',map{$_->{person}}@$List));
	my @indice;
	push(@indice,'0');
	foreach my $m (@$List) {
		if ($m->{person} =~ /__/) {
			my $t=(split('__',$m->{person}))[1];
			push(@indice,(split('__',$m->{person}))[1]);
			
		}
	}
	my $indice2=max @indice;
	$indice2++;
	my $new_name=$person."__".$indice2;
	my @newPerson;
	my %si;
	$si{Row} = $row;
	$si{person_s} = $person;
	$si{imax} = $indice2;
	$si{person} = 'New Person/'.$new_name;
	$si{person_id} = "";				
	$si{patient} = "";
	$si{patient_id} = "";
	$si{run} = "";
	$si{projectId} = "";
	$si{project} = "";
	$si{capAnalyse} = "";
	$si{family} = "";
	$si{sex} = "";
	$si{status} = "";
	$si{iv_vcf} = "";
	push(@newPerson,\%si);
	return @newPerson;
}

###### Add Pat Run   ###################################################################
sub PatRunSection {
	my $runId = $cgi->param('run');
	my $captureId = $cgi->param('capture');
	my $patients = $cgi->param('patient');
	my $group_method_align_name = $cgi->param('method_align');
	my $group_method_calling_name = $cgi->param('method_call');
	my $sex = $cgi->param('sex');
	my $status = $cgi->param('status');
	my $desPat = $cgi->param('desPat');
	my $bc = $cgi->param('bc');
	my $users = $cgi->param('user');
	$patients=~ s/ //g;
	$patients=~ s/\n/;/g;
	my @pat=split(/,/,$patients);
	
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $username = $ENV{'LOGNAME'};
	my $validAln="";
	if ($group_method_align_name) {
		my @ListAln = split(/,/,$group_method_align_name);
		foreach my $u (@ListAln) {
			my $method_align = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"ALIGN");
			$validAln.=$method_align->{id}."," if ($method_align);
		}
		chop($validAln);
		sendError("undefined method_align: " . $group_method_align_name ) unless $validAln;	
	}

	my $validMeth="";
	if ($group_method_calling_name) {
		my @ListMeth = split(/,/,$group_method_calling_name);
		foreach my $u (@ListMeth) {
			my $method_call = queryPolyproject::getMethodsFromName($buffer->dbh,$u,"SNP");
			$validMeth.=$method_call->{id}."," if ($method_call);
		}
		chop($validMeth);
		sendError("undefined method_call: " . $group_method_calling_name ) unless $validMeth;	
	}
# new patient
	for my $u (@pat) {
		my $last_patient_id=queryPolyproject::addPatientRun($buffer->dbh,$u,$u,$runId, $captureId,$sex,$status,$desPat,$bc);
		# add Method in patient_methods
		if ($group_method_align_name) {
			my @ListAln = split(/,/,$validAln);	
			foreach my $m (@ListAln) {
				my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runId);
				queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
			}	
		}
		if ($group_method_calling_name) {
			my @ListMeth = split(/,/,$validMeth);	
			foreach my $m (@ListMeth) {
				my $patid=queryPolyproject::getPatIdfromName($buffer->dbh,$u,$runId);
				queryPolyproject::addMeth2pat($buffer->dbh,$patid,$m);
			}	
		}		
	}
#### End Autocommit dbh ###########
	$dbh->commit();
	sendOK("Successful validation for the run ID :".$runId);	
}

###### Add Link Project Patient  ###################################################################
sub addPatientProjSection {
	my $runid = $cgi->param('run');
	my $pid = $cgi->param('project');
	my $projname = $cgi->param('projname');
	my $listPatid= $cgi->param('PatIdSel');
	my @PatId = split(/,/,$listPatid);
	
	my $listPatname= $cgi->param('PatNameSel');
	my @PatName = split(/,/,$listPatname);
#	my $listChoice = $cgi->param('choice');
#	my @fieldCh = split(/,/,$listChoice);

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $project = $buffer->newProject(-name=>$projname);
	my $username = $ENV{'LOGNAME'};

	my $validPat="";
	my $validPatname="";
	my $notvalidPatname="";
	for (my $i = 0; $i< scalar(@PatId); $i++) {
			my $patname =@PatName[$i];
			my $patid=queryPolyproject::ctrlProjectPatientName($buffer->dbh,$pid,$patname);
			$validPat.=@PatId[$i]."," unless ($patid);
			$validPatname.=$patname."," unless ($patid);
			$notvalidPatname.=$patname."," if ($patid);
	}
	chop($validPat);
	chop($validPatname,$notvalidPatname);
	my @ListPat = split(/,/,$validPat);	
	if ($validPat) {
		for my $u (@ListPat) {
			my $patname = queryPolyproject::getPatientName($buffer->dbh,$u);		
			queryPolyproject::upPatientProject($buffer->dbh,$u,$pid);
			my $patid=queryPolyproject::ctrlProjectPatientName($buffer->dbh,$pid,$patname);
 			my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$patid->{patient_id});
			queryPolyproject::upSomaticProject($buffer->dbh,$pid,1) if $groupid->[0]->{group_id} ;			
		}
		$dbh->commit();
		$project->getProjectPath();
		$project->makePath();
		sendOK("Successful validation for Patient Name: <B>" . $validPatname . "</B><BR> with Project:" .$projname." (Id: ". $pid.")".
		"<BR>Patient Name Not Valid:<B> ".$notvalidPatname."</B> (Already linked to another project)" );	
	} else {
		$dbh->commit();
		sendError("Patient Name: <B>" . $notvalidPatname . "</B> already linked to another project");
	}
}

# Old vesrsion
sub ProjectPatientSection {
	my $projectId=$cgi->param('project');
	my $patientid = $cgi->param('patient');
	$patientid=~ s/ //g;
	$patientid=~ s/\n/;/g;
	my @pat=split(/,/,$patientid);
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$projectId);
	my $project = $buffer->newProject(-name=>$projectname);
	my $username = $ENV{'LOGNAME'};
	# Control Patient Name with projet_id
	my $validPat="";
	my $validPatname="";
	my $notvalidPatname="";
	for my $v (@pat) {
			my $patname = queryPolyproject::getPatientName($buffer->dbh,$v);		
			my $patid=queryPolyproject::ctrlProjectPatientName($buffer->dbh,$projectId,$patname);
			$validPat.=$v."," unless ($patid);
			$validPatname.=$patname."," unless ($patid);
			$notvalidPatname.=$patname."," if ($patid);
	}
	chop($validPat);
	chop($validPatname,$notvalidPatname);
	my @ListPat = split(/,/,$validPat);	
	if ($validPat) {
		for my $u (@ListPat) {
			my $patname = queryPolyproject::getPatientName($buffer->dbh,$u);		
			queryPolyproject::upPatientProject($buffer->dbh,$u,$projectId);
			my $patid=queryPolyproject::ctrlProjectPatientName($buffer->dbh,$projectId,$patname);
 			my $groupid=queryPolyproject::getGroupIdFromPatientGroups($buffer->dbh,$patid->{patient_id});
			queryPolyproject::upSomaticProject($buffer->dbh,$projectId,1) if defined $groupid ;			
		}	
### End Autocommit dbh ###########
		$dbh->commit();
#		$ENV{'DATABASE'} = "";
		
#		my $name = $projectname;
#		my $buffer = GBuffer->new();
#		my $projectG = $buffer->newProject(-name=>$name);
#		$projectG->getProjectPath();
#		$projectG->makePath();
		$project->getProjectPath();
		$project->makePath();
		sendOK("Successful validation for Patient Name:<B>" . $validPatname . "</B><BR> with Project Id : ". $projectId.
		"<BR>Patient Name Not Valid:<B> ".$notvalidPatname."</B>" );	
	} else {
		sendError("Patient Name: <B>" . $notvalidPatname . "</B> already linked project ID: " . $projectId);
	}	
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

sub response {
	my ($rep) = @_;
	print qq{<textarea>};
	print to_json($rep);
	print qq{</textarea>};
	exit(0);
}

exit(0);
