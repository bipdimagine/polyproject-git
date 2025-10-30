#!/usr/bin/perl
########################################################################
###### upload_file.pl
########################################################################
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use Carp;
use strict;
use Data::Dumper;
use GBuffer;
use Getopt::Long;
use File::Basename;
use File::Find::Rule;
use GD;
use Getopt::Long;
use Spreadsheet::WriteExcel;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
use JSON;
use queryPolyproject;
use DBI;
#use Bio::DB::HTS::Tabix;
=mod 	
#use feature qw/switch/; 
given/when deprecated => change for :
given => for
when => if & elsif
default => else
=cut
use Try::Tiny;
#warn "0000000000000000InsertSectionnnnnnnnnnnnnnnnnnnnnnnnnnn";

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $dlf="\t";

if ( $opt eq "insert" ) {
	InsertSection();
} elsif ($opt eq "insertPaste") {
	InsertPasteSection();
} elsif ($opt eq "insertTranscript") {
	InsertTranscriptSection();
} elsif ($opt eq "getloadFile") {
	getloadFileSection();
}

sub InsertTranscriptSection {
	my $filename = $cgi->param("file_name");
	my $paramdir = $cgi->param("param_dir");
	my @listdir = split( /,/, $paramdir);
	my $bunid = $cgi->param("param_capid");
	my $tmod = $cgi->param("param_trans");
	my $version;
	if ($listdir[0] eq "") {
		my $info_proj = queryPolyproject::getLastProject($buffer->dbh);
		my $rel=queryPolyproject::getReleaseNameFromProject($buffer->dbh,$info_proj->[0]->{project_id});
		$version=$rel;
	} else {
		$version=$listdir[0];#release
	}
	my $enddir_t=$listdir[1];#capture==> capture/agilent
	my @enddir_sp=split("/",$enddir_t);	
	my $enddir=$enddir_sp[0]."/".$version."/".$enddir_sp[1];#capture==> capture/version/agilent
	my $publicdir = $buffer->config()->{public_data}->{root}.$enddir."/";
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	my $upload_filehandle = $cgi->upload("file_name");
	my $doc;
	# -s file : file size
	read( $upload_filehandle, $doc, -s $upload_filehandle );
	my ($name_o, $path_o, $extension_o) = fileparse( $publicdir.$filename, '\..*' );
	chop($path_o);
	makedir($path_o);
	my $file_out= $publicdir.$filename;
	$doc =~ s/\r//g;
	my @data = split("\n",$doc);
	my @tmod = split( /,/, $tmod );	
	my $datas = builddata_db(\@data,$file_out,$path_o,$bunid,$tmod[0],$tmod[1]);
}

sub builddata_db {
	my ($data,$file_out,$path,$bunid,$tmod,$btmod) = @_;
	my @mydata;
	my %hdata;
	$hdata{identifier}="row";
	$hdata{label}="row";
	my $row=1;
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $Line (@$data) {
		my %s;
		$s{row} = $row++;
		my @tab = split( /\s+/, $Line );
 		my $line;
		for (my $i = 0; $i< scalar(@tab); $i++) {
			$s{"col".($i+1)}=$tab[$i];
			$line.=$s{"col".($i+1)}."\t";
 		}
		chop($line);
		$line=$line."\n";
		print $FHO $line;
	}
	chmod(0666,$FHO);
	close($FHO);
	my $list_tr;
	my $list_mod;
	open( my $FILE,$file_out )|| die();;
	while ( my $Line = <$FILE> ) {
		$Line =~ s/,/ /g;
		my @data_file = split( /\s+/, $Line );
		#### Tester #####
		if ($data_file[0] !~ /^[a-zA-Z0-9-_]*$/) {
			sendFormError("<b>Error Transcript</b>: Transcript Id must be alplanumeric. $data_file[0]:<b>Not Ok</b>, Transcripts not Added");
		}
		$list_tr.=$data_file[0].",";
		$list_mod.=$data_file[1].",";
	}
	close $FILE;
	chop($list_tr);
	chop($list_mod);
	my $dataf = addTranscriptsFile($bunid,$tmod,$btmod,$list_tr,$list_mod,$file_out,$path);
}

sub addTranscriptsFile {
	my ($bunid,$tmod,$btmod,$transcript,$transmission,$file_out,$path) = @_;
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
##############################
	my $invalidTranscript="";
	my @ListTranscript = split(/,/,$transcript);
	my @ListTransmission = split(/,/,$transmission);
	for (my $i = 0; $i< scalar(@ListTranscript); $i++) {
		my $transcriptid = queryPolyproject::getTranscriptId($buffer->dbh,$ListTranscript[$i]);
		unless ($transcriptid) {
			my $last_transcript_id=queryPolyproject::newTranscriptData($buffer->dbh,$ListTranscript[$i],$ListTransmission[$i],$tmod);
			$transcriptid = $last_transcript_id->{'LAST_INSERT_ID()'};
		}
		if ($transcriptid) {
			queryPolyproject::upTranscriptTransmission($buffer->dbh,$transcriptid,$ListTransmission[$i]) if $tmod;
			my $Btr=queryPolyproject::getBundleTranscriptId($buffer->dbh,$bunid,$transcriptid);
			if (exists $Btr->[0]->{transcript_id}) {
				queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bunid,$transcriptid,$ListTransmission[$i]) if $btmod;
				queryPolyproject::upBunTranscriptTransmission($buffer->dbh,$bunid,$transcriptid,) unless $btmod;
				$invalidTranscript.= $ListTranscript[$i].",";
				next;
			}
		}
		queryPolyproject::newBundleTranscript($buffer->dbh,$transcriptid,$bunid,$ListTransmission[$i],$btmod);
	}
	my $lastProjectId = queryPolyproject::getLastProject($buffer->dbh);
	my $projectname = queryPolyproject::getProjectName($buffer->dbh,$lastProjectId->[0]->{project_id});
	my $project = $buffer->newProject(-name=>$projectname);
	my $sql1 = qq{SELECT ENSEMBL_ID FROM PolyprojectNGS.transcripts WHERE GENE="" OR GENE IS NULL;};
	my $prep = $dbh->prepare($sql1);
	$prep->execute();
	my @trs =keys %{$prep->fetchall_hashref('ENSEMBL_ID')};

	foreach my $tr_name (@trs){
		eval {
			my $tr1 = $project->newTranscript($tr_name);
			my $gname = $tr1->getGene()->external_name();
			my $sql = qq{update PolyprojectNGS.transcripts SET GENE='$gname' where ENSEMBL_ID='$tr_name'};
			$dbh->do($sql);
		}		
	} 
### End Autocommit dbh ###########
	my $bundleList = queryPolyproject::getBundle($buffer->dbh,$bunid);		
	$dbh->commit();
	if ($invalidTranscript) {
		chop($invalidTranscript);
		$invalidTranscript= "<br><b>But</b>Transcripts already seen: ".$invalidTranscript;
	}
	unlink $file_out;
	check_rmdir($path);
	my $refreshMessage=". Please, refresh Bundle List...";
	sendFormOK("Successful validation for Bundle : ". $bundleList->[0]->{bunName}.$invalidTranscript.$refreshMessage);	
}

###########################################################################
sub InsertSection {
	my $filename = $cgi->param("file_name");
	my $out = $cgi->param("param_out");
	my $paramdir = $cgi->param("param_dir");
	my @listdir = split( /,/, $paramdir);
	my $capid = $cgi->param("param_capid");
	my $type = $cgi->param("param_type");
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my $version=$listdir[0];#release
#	my $versionf=$listdir[0];#release for genome fasta files
	my $enddir_t=$listdir[1];#capture==> capture/agilent
	my @enddir_sp=split("/",$enddir_t);
		
	$version="HG19" if ($version =~ /^HG19/);
	$version="HG38" if ($version =~ /^HG38/);
	my $enddir=$enddir_sp[0]."/".$version."/".$enddir_sp[1];#capture==> capture/version/agilent
	
	my $publicdir = $buffer->config()->{public_data}->{root}.$enddir."/";
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	
	my $upload_filehandle = $cgi->upload("file_name");
	my $doc;
	# -s file : file size
	read( $upload_filehandle, $doc, -s $upload_filehandle );
	my ($name_o, $path_o, $extension_o) = fileparse( $publicdir.$filename, '\..*' );
	chop($path_o);
	makedir($path_o);
	#### $filename
	$filename=$out if $out;
	my $file_out= $publicdir.$filename;
	$doc =~ s/\r//g;
	my @data = split("\n",$doc);
#	my $datas = builddata(\@data,$file_out,$path_o,$type,$versionf);
	my $datas = builddata(\@data,$file_out,$path_o,$type,$version);
	if ($cap->[0]->{capName}) {
		queryPolyproject::upCaptureFileData($buffer->dbh,$capid,$filename) if ($type eq "capture");
		queryPolyproject::upPrimerFileData($buffer->dbh,$capid,$filename) if ($type eq "primer");
	}
### End Autocommit dbh ###########
	$dbh->commit();
	sendFormOK("Successful deposit ".$type." File : ". $filename);	
}

sub builddata {
	my ($data,$file_out,$path,$type,$version) = @_;
#	warn Dumper $data;
#	my $g_analyse;
#	my @file_ctrl;
#	$g_analyse = $buffer->config()->{public_data}->{root}."/genome/".$version."/fasta/all.fa.fai";
#	@file_ctrl=get_chrFile($g_analyse);
	my @mydata;
	my %hdata;
	$hdata{identifier}="row";
	$hdata{label}="row";
	my $row=1;
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $Line (@$data) {
		if ($Line =~/#.*/ ) {
			print $FHO $Line."\n";
			next;
		}
		my %s;
		$s{row} = $row++;
		my @tab = split( /\s+/, $Line );
 		my $line;
		my $ktab=0;# separator <tab> or not==> Not=0
		for ($type) {
			if (/primer/) {
				for (scalar(@tab)) {
					if (/4/) {
#						$line=Primer4($Line,$file_out,$FHO,$path,$ktab,$version,@file_ctrl);						
						$line=Primer4($Line,$file_out,$FHO,$path,$ktab,$version);												
					} elsif (/6/) {
#						$line=Primer6($Line,$file_out,$FHO,$path,$ktab,$version,@file_ctrl);						
						$line=Primer6($Line,$file_out,$FHO,$path,$ktab,$version);												
					} else {
						sendFormError("Error Primer Columns: must be 4 or 6 columns");						
					}					
				}
			} elsif (/capture/) {
#				$line=Capture($Line,$file_out,$FHO,$path,$ktab,$version,@file_ctrl);
				$line=Capture($Line,$file_out,$FHO,$path,$ktab,$version);				
			}
		}
=mod 	
given => for
when => if & elsif
default => else
=cut
 		push(@mydata,\%s);
		chop($line);
		$line=$line."\n";
		print $FHO $line;
	}
	chmod(0666,$FHO);
	close($FHO);
	open( my $BED,$file_out )|| die();;
	my @all =  <$BED>;
	close $BED;
	chomp(@all);
	open( $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	my @sall = sort par_chr grep {$_ !~ /^#/} @all;
 	print $FHO join("\n",@sall);	
 	close $FHO;
 	if ($type eq "capture") {
#	my $publicdir = $buffer->config()->{public_data}->{$version};
#		my $bgzip = $buffer->software("bgzip");
		my $tabix = $buffer->software("tabix");
		my $bgzip = $buffer->software("bgzip");
#		warn Dumper $tabix;
#		warn Dumper $bgzip;
#		my $tabix = $buffer->config->{software}->{tabix};
#		my $bgzip = $buffer->config()->{software}->{bgzip};
		my $file_outgz = $file_out . ".gz";
		my $file_out_ori = $file_out . ".ori";
		run("cp $file_out $file_out_ori");
		chmod(0666,$file_out_ori);
		run("$bgzip -f $file_out");
		run("mv $file_out_ori $file_out");	
		chmod(0666,$file_out);
		chmod(0666,$file_outgz);
		run(" $tabix -f -s 1 -b 2 -e 2  $file_outgz");
		chmod(0666,$file_outgz.'.tbi'); 		
 	}		
}

######################################################################################
sub InsertPasteSection {	
	my $capid = $cgi->param("capId");
	my $filename = $cgi->param("file_name");
	my $paramdir = $cgi->param("Param_dir");
#	my $analyse = $cgi->param("Param_analyse");
	my $type = $cgi->param("type");		
	my $Lines = $cgi->param("Lines");	
	$Lines=~ s/<plus>/+/g;
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	#my $g_analyse;
	#my @file_ctrl;
	my $cap = queryPolyproject::getCaptureName($buffer->dbh,$capid);
	my @listdir = split( /,/, $paramdir);
	my $version=$listdir[0];#release
#	my $enddir=$listdir[1];#capture
	my $enddir_t=$listdir[1];#capture==> capture/agilent
	my @enddir_sp=split("/",$enddir_t);	
	my $enddir=$enddir_sp[0]."/".$version."/".$enddir_sp[1];#capture==> capture/version/agilent
	
#	my $g_analyse = $buffer->config()->{public_data}->{root}."/genome/".$version."/fasta/all.fa.fai";
#	my @file_ctrl=get_chrFile($g_analyse);
	
	$version="HG19" if ($version =~ /^HG19/);
	$version="HG38" if ($version =~ /^HG38/);
	my $publicdir;
	if (exists $buffer->config()->{public_data}->{root}) {
		$publicdir = $buffer->config()->{public_data}->{root}.$enddir."/";
		warn "XXXXXXXXXXXXXXXXXXXXXXX0 Old";
	} else {
		$publicdir = $buffer->hash_config_path()->{root}->{public_data}.$enddir."/";		
		warn "XXXXXXXXXXXXXXXXXXXXXXX0 new";
	}	
	warn Dumper $publicdir;	


=mod
	if (exists $buffer->hash_config_path()->{root}->{public_data}) {
		$publicdir = $buffer->hash_config_path()->{root}->{public_data}.$enddir."/";		
		warn "XXXXXXXXXXXXXXXXXXXXXXX0 new";
	} else {
		$publicdir = $buffer->config()->{public_data}->{root}.$enddir."/";
		warn "XXXXXXXXXXXXXXXXXXXXXXX0 Old";
	}	
	warn Dumper $publicdir;	

=cut	
	
	
	
	my ($name_o, $path_o, $extension_o) = fileparse( $publicdir."/".$filename, '\..*' );

	chop($path_o);
	makedir($path_o);
	#chmod(0777,$path_o);
#	system("chmod g+rw $path_o");
	my $file_out= $publicdir.$filename;
	my @mydata;
	my %hdata;
	$hdata{identifier}="row";
	$hdata{label}="row";
	my @data = split(",",$Lines);
	my $row=1;
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	foreach my $l (@data) {
		my %s;
		$s{row} = $row++;
		my @tab = split( /<tab>/, $l );
 		my $line;
 		my $ktab=1;# separator <tab> or not ==> OK=1
		for ($type) {
			if (/primer/) {
				for (scalar(@tab)) {
					if (/4/) {
#						$line=Primer4($l,$file_out,$FHO,$publicdir,$ktab,$version,@file_ctrl);						
						$line=Primer4($l,$file_out,$FHO,$publicdir,$ktab,$version);						
						
					} elsif (/6/) {
#						$line=Primer6($l,$file_out,$FHO,$publicdir,$ktab,$version,@file_ctrl);						
						$line=Primer6($l,$file_out,$FHO,$publicdir,$ktab,$version);						
						
					} else {
						sendError("Error Primer Columns: must be 4 or 6 columns");						
					}					
				}								
			} elsif (/capture/) {
#				$line=Capture($l,$file_out,$FHO,$publicdir,$ktab,$version,@file_ctrl);
				$line=Capture($l,$file_out,$FHO,$publicdir,$ktab,$version);				
			}			
		}	 		
=mod 	
given => for
when => if & elsif
default => else
=cut
 		push(@mydata,\%s);
 		chop($line);
 		$line=$line."\n";
  		print $FHO $line;
	}	
	chmod(0666,$FHO);
	close($FHO);
 	open( my $BED,$file_out )|| die();;
 	my @all =  <$BED>;
 	close $BED;
 	chomp(@all);
 	open( $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
 	my @sall = sort par_chr grep {$_ !~ /^#/} @all;
 	print $FHO join("\n",@sall);	
 	close $FHO;
 	if ($type eq "capture") {
		my $bgzip = $buffer->config->{software}->{bgzip};
		my $tabix = $buffer->config->{software}->{tabix};
		my $file_outgz = $file_out . ".gz";
		my $file_out_ori = $file_out . ".ori";
		run("cp $file_out $file_out_ori");
		chmod(0666,$file_out_ori);
		run("$bgzip -f $file_out");
		run("mv $file_out_ori $file_out");	
		chmod(0666,$file_out);
		chmod(0666,$file_outgz);
		run(" $tabix -f -s 1 -b 2 -e 2  $file_outgz");
		chmod(0666,$file_outgz.'.tbi'); 		
 	}
	if ($cap->[0]->{capName}) {
		queryPolyproject::upCaptureFileData($buffer->dbh,$capid,$filename) if ($type eq "capture");		
		queryPolyproject::upPrimerFileData($buffer->dbh,$capid,$filename) if ($type eq "primer");
	}	
	$dbh->commit();
	sendOK("Successful deposit ".$type." File : ". $filename);	
}

######################################################################################
sub Capture {
#	my ($inline,$file_out,$FHO,$directory,$ktab,$version,@file_ctrl) = @_;
	my ($inline,$file_out,$FHO,$directory,$ktab,$version) = @_;
	my @tab;
	@tab = split( /\s+/, $inline  ) unless $ktab;
	@tab = split( /<tab>/, $inline ) if $ktab;
	my $line;
	my %s;
	for (my $i = 0; $i< scalar(@tab); $i++) {
		$s{"col".($i+1)}=$tab[$i];
		for ($i) {
			if (/0/) {
#				my $chr_found=find_chr_ctrl($tab[$i],@file_ctrl);
#				unless ($chr_found){
#					rm_file_gz_tbi($file_out,$FHO,$directory);
#					sendError("Error Chromosome: First Column not confirm to Genome Index Fasta File (.fai) of the release") if $ktab;
#					sendFormError("Error Chromosome: First Column not confirm to Genome Index Fasta File (.fai)] of the release") unless $ktab;						
#				}
			} elsif (/1|2/) {
				if ($tab[$i] !~ /^[0-9]+$/) {
					rm_file_gz_tbi($file_out,$FHO,$directory);
					sendError("Error Position Begin End: Second and Third Column must be Numeric") if $ktab;
					sendFormError("Error Position Begin End: Second and Third Column must be Numeric") unless $ktab;
				}				
			} else {
				#nothing
			}
		}		
=mod 	
given => for
when => if & elsif
default => else
=cut
		$line.=$s{"col".($i+1)}."\t";
	}
	if ($s{"col".2}> $s{"col".3}) {
		rm_file_gz_tbi($file_out,$FHO,$directory);
		sendError("Error Position Begin > End: position Begin must be smaller than End: $s{'col'.1} $s{'col'.2} > $s{'col'.3}") if $ktab;
		sendFormError("Error Position Begin > End: position Begin must be smaller than End: $s{'col'.1} $s{'col'.2} > $s{'col'.3}") unless $ktab;
	}
	return $line;
}

sub Primer4 {
#	my ($inline,$file_out,$FHO,$directory,$ktab,$version,@file_ctrl) = @_;
	my ($inline,$file_out,$FHO,$directory,$ktab,$version) = @_;
	my @tab;
	@tab = split( /\s+/, $inline  ) unless $ktab;
	@tab = split( /<tab>/, $inline ) if $ktab;
	my $line;
	my %s;
	for (my $i = 0; $i< scalar(@tab); $i++) {
		$s{"col".($i+1)}=$tab[$i];
		for ($i) {
			if (/0/) {
				#if ($analyse eq "genome") {
#				my $chr_found=find_chr_ctrl($tab[$i],@file_ctrl);
#				unless ($chr_found){
#					rm_file($file_out,$FHO,$directory);
#					sendError("Error Chromosome: First Column not confirm to Genome Fasta Index File (.fai) of the release") if $ktab;
#					sendFormError("Error Chromosome: First Column not confirm to Genome Fasta Index File (.fai) of the release") unless $ktab;
#				}				
			} elsif (/1|2/) {
				if ($tab[$i] !~ /^[0-9]+$/) {
					rm_file($file_out,$FHO,$directory);
					sendError("Error Position Begin End: Second and Third Column must be Numeric") if $ktab;
					sendFormError("Error Position Begin End: Second and Third Column must be Numeric") unless $ktab;
				}
				
			} elsif (/3/) {
				if ($tab[$i] !~ /^[0-9][0-9]?$/) {
					rm_file($file_out,$FHO,$directory);
					sendError("Error Pool: Column 4 must be Integer max=99") if $ktab;
					sendFormError("Error Pool: Column 4 must be Integer max=99") unless $ktab;
				}				
			}			
		}				
=mod 	
given => for
when => if & elsif
default => else
=cut
		$line.=$s{"col".($i+1)}."\t";
	}
	if ($s{"col".2}> $s{"col".3}) {
		rm_file($file_out,$FHO,$directory);
		sendError("Error Position Begin > End: position Begin must be smaller than End: $s{'col'.1} $s{'col'.2} > $s{'col'.3}") if $ktab;
		sendFormError("Error Position Begin > End: position Begin must be smaller than End: $s{'col'.1} $s{'col'.2} > $s{'col'.3}") unless $ktab;
	}
	return $line;
}

sub Primer6 {
#	my ($inline,$file_out,$FHO,$directory,$ktab,$version,@file_ctrl) = @_;
	my ($inline,$file_out,$FHO,$directory,$ktab,$version) = @_;
	my @tab;
	@tab = split( /\s+/, $inline  ) unless $ktab;
	@tab = split( /<tab>/, $inline ) if $ktab;
	my $line;
	my %s;
	for (my $i = 0; $i< scalar(@tab); $i++) {
		$s{"col".($i+1)}=$tab[$i];
		for ($i) {
			if (/0/) {
#				my $chr_found=find_chr_ctrl($tab[$i],@file_ctrl);
#				unless ($chr_found){
#					rm_file($file_out,$FHO,$directory);
#					sendError("Error Chromosome: First Column not confirm to Genome Fasta Index File (.fai) of the release") if $ktab;
#					sendFormError("Error Chromosome: First Column not confirm to Genome Fasta Index File (.fai) of the release") unless $ktab;
#				}				
			} elsif (/1|2|3|4/) {
				if ($tab[$i] !~ /^[0-9]+$/) {
					rm_file($file_out,$FHO,$directory);
					sendError("Error Position Begin End: Second and Third Column must be Numeric") if $ktab;
					sendFormError("Error Position Begin End: Second and Third Column must be Numeric") unless $ktab;
				}				
			} elsif (/5/) {
				if ($tab[$i] !~ /^[0-9][0-9]?$/) {
					rm_file($file_out,$FHO,$directory);
					sendError("Error Pool: Column 6 must be Integer max=99") if $ktab;
					sendFormError("Error Pool: Column 6 must be Integer max=99") unless $ktab;
				}				
			}
		}
=mod 	
given => for
when => if & elsif
default => else
=cut
		$line.=$s{"col".($i+1)}."\t";
	}
	if ($s{"col".2}> $s{"col".3}) {
		rm_file($file_out,$FHO,$directory);
		sendError("Error Position Begin<sub>1</sub> > End<sub>1</sub>: position Begin must be smaller than End") if $ktab;
		sendFormError("Error Position Begin<sub>1</sub> > End<sub>1</sub>: position Begin must be smaller than End") unless $ktab;
	}
	if ($s{"col".4}> $s{"col".5}) {
		rm_file($file_out,$FHO,$directory);
		sendError("Error Position Begin<sub>2</sub> > End<sub>2</sub>: position Begin must be smaller than End") if $ktab;
		sendFormError("Error Position Begin<sub>2</sub> > End<sub>2</sub>: position Begin must be smaller than End") unless $ktab;
	}
	if ($s{"col".3}> $s{"col".4}) {
		rm_file($file_out,$FHO,$directory);
		sendError("Error Position End<sub>1</sub> > Begin<sub>2</sub>: position End<sub>1</sub> must be smaller than Begin<sub>2</sub>") if $ktab;
		sendFormError("Error Position End<sub>1</sub> > Begin<sub>2</sub>: position End<sub>1</sub> must be smaller than Begin<sub>2</sub>") unless $ktab;
	}
	return $line;
}

###########################################################################

sub getloadFileSection {
	my $filebed = $cgi->param("file_name");
	my $folderdir = $cgi->param("folder_dir");
   
	my $filename=fileparse( $filebed, '\..*' );	
	my $captureInfo= queryPolyproject::getCaptureFromName($buffer->dbh,$filename);	
	my $publicdir = $buffer->config()->{public_data}->{root};
	my $beddir = $buffer->config()->{public_data}->{root}.$folderdir;
	my $level = 3 ;
	my @files;
	@files = File::Find::Rule->extras({ follow => 1, follow_skip => 2 })
     							  ->file()
                                  ->name( $filebed  )
                                  ->maxdepth( $level )
                                  ->in( $beddir );
	sendError("Error File: $filebed <b>unknown</b>") unless scalar @files;
    my $FH;
	open( $FH, '<', $files[0] ) or die("Can't read this file: $filebed\n");
	my @wdata;
	my %hwdata;
	my $row=1;
	$hwdata{identifier}="row";		
	while ( my $Line = <$FH> ) {
		my %s;
		my @data = split( /\s+/, $Line );
		$s{row} = $row;
		$s{chr} = $data[0];
		$s{start} = $data[1];
		$s{end} = $data[2];
		push(@wdata,\%s);
		$row++;
	}
	$hwdata{items}=\@wdata;
	printJson(\%hwdata);
}


#not used
sub get_chrFile {
	my ($ctrl_file) = @_;	
	open( my $FH, '<', $ctrl_file ) or die("Can't read file: $ctrl_file\n");
	my @lchr;
	while ( my $Line = <$FH> ) {		
		chop($Line);
		next if $Line =~ m/^$/;
		my @data = split( /[ \t]/, $Line );
		push(@lchr,$data[0]);
		
	}
	close($FH);
	return @lchr if scalar @lchr>=1;
}

#not used
sub find_chr_ctrl {
	my ($lchr,@file_ctrl) = @_;	
	my $valid;
	for (my $i = 0; $i< scalar(@file_ctrl); $i++) {
		$valid=$file_ctrl[$i] if $lchr eq $file_ctrl[$i];
		last if $lchr eq $file_ctrl[$i];
	}
	return $valid if $valid;
}

sub rm_file {
	my ($file_out,$FHO,$directory) = @_;
	unlink $file_out;
	close($FHO);
	check_rmdir($directory);
}

sub rm_file_gz_tbi {
	my ($file_out,$FHO,$directory) = @_;
	unlink $file_out;
	unlink $file_out.".gz";
	unlink $file_out.".gz".".tbi";
	close($FHO);
	check_rmdir($directory);
}

sub run {
	my ($cmd) = @_;
	my $return = system($cmd);
	if ($return ne 0){
		confess("error : $cmd");
	}
}

sub par_chr ($$) {
	my ($left,$right) = @_;
	my @l = split("\t",$left);
	my @r = split("\t",$right);
	return give_chr_index($l[0]) <=> give_chr_index($r[0]) ||  $l[1] <=> $r[1];
}

sub give_chr_index {
	my ($c) = @_;
	$c =~ s/chr//;
	if ($c eq  'X'){
		return 23;
	}
	if ($c eq 'Y'){
		return 24;
	}
	if ($c eq "MT" || $c eq "M"){
		return 25;
	}
	return $c;
}

sub check_rmdir {
	my ($dir) = @_;
	opendir(DIR,$dir) or die "$!";
	# need twice readdir
	readdir DIR; # reads .
	readdir DIR; # reads ..
	rmdir $dir unless (readdir DIR);
	close DIR;
}

sub makedir {
	my ($dir) = @_;
	if (!(-d $dir)){
		mkdir ($dir,0755);
	}
	return $dir;	
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

sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
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

