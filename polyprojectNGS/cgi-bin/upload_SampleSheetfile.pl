#!/usr/bin/perl
########################################################################
###### upload_SampleSheetfile.pl
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
#use util_file qw(readXmlVariations);
use File::Basename;
use File::Find::Rule;
use Logfile::Rotate; 
use File::Glob qw(:globally :nocase);
use Time::Local;
use POSIX 'strftime';
#use GD;
use Getopt::Long;
#use Spreadsheet::WriteExcel;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
use JSON;
use DBI;
use feature qw/switch/; 
#use Try::Tiny;
use Proc::Simple;

$| =1;

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');


#my $publicdir = $buffer->config()->{public_data}->{root};
my $publicdir;
warn "zzzzzzzzzzzzzzzzzzzzzzzzzzz";
if (exists $buffer->config()->{root}->{project_data}) {
	warn "EXISTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT";
	$publicdir = $buffer->config()->{root}->{project_data};
	warn "RRRRRRRRR0";
	warn Dumper $publicdir;
}
else {
	$publicdir = $buffer->config()->{public_data}->{root};
}


my @dir_sp = split(/public-data/,$publicdir);
my $sampledir=$dir_sp[0]."sequencing/SampleSheet/";
warn "RRRRRRRRR";
warn Dumper $sampledir;

if ( $opt eq "insert" ) {
	InsertSection();
} elsif ($opt eq "findFile") {
	findFileSection();
}  elsif ($opt eq "copypaste") {
	copypasteSection();
}  elsif ($opt eq "copypastediag") {
	copypastediagSection();
}

sub InsertSection {
	my $filename = $cgi->param("file_name");
	my $out = $cgi->param("param_out");
	my $paramdir = $cgi->param("param_dir");
	my $paramfile = $cgi->param("param_file");
	$filename=specialChar($filename);
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	my $upload_filehandle = $cgi->upload("file_name");
	my $Indir=$sampledir.$paramdir;
	makedir($Indir);
	system("chmod -R 777 $Indir");

	#### $filename
	$filename=$out if $out;	
	my $file_out= $Indir."/".$filename;
	
	if (! $filename) {
		sendFormError("<b>Error:</b>"."<BR>No File selected");
 		return;
 	}
#	if ($paramfile eq "runFile" && $extension !~ m/(csv)|(tsv)/) {
	if ($paramfile eq "runFile" && $extension !~ m/(csv)/) {
		sendFormError("<b>Error:</b> $filename"."<BR>Detailed Run File extension file must be .csv");
 		return;
 	}
 	
 	#####################
 	system("rm -rf $Indir/short_*");
 	#original file
 	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
#	binmode $FHO;
	while (read ($upload_filehandle, my $Buffer,  -s $upload_filehandle)) {
		$Buffer=specialChar($Buffer);
		print $FHO $Buffer;
	}		
	close $FHO;
	chmod(777,$FHO);
#	system("/usr/local/bin/dos2unix $file_out");
	
	#short file
	my $shortfile_out= $Indir."/"."short_".$filename;
	open( my $FHSHO, '>', $shortfile_out ) or die("Can't create file: $shortfile_out\n");	
#	my $desired_cols="Flowcell - Lane,Nom de projet,Réf Projet,Patient,BC i7,BC i5,SI-GA";#order matters here
	my $desired_cols="Patient,BC i7,BC i5,Ref Projet,Flowcell - Lane,SI-GA";#order matters here
	my @desired_cols = split (/,/,$desired_cols);
	# reads first line to get actual column names
	open( my $FHI, '<', $file_out ) or die("Can't create file: $file_out\n");

	my $header_line = (<$FHI>);
	my @actual_cols = split(/[,;]/,$header_line);
# get column number of the actual column names
	my $pos =0;
	my %col2_num = map {$_ => $pos++}@actual_cols;
	my @slice = map{if (exists $col2_num{$_}) { $col2_num{$_} } else {()} }@desired_cols;               
	my @chosen_cols;           
	my @slice_forHeader = map{if (exists $col2_num{$_}) { $col2_num{$_};push (@chosen_cols,$_) }}@desired_cols;               
	print $FHSHO join(",",@chosen_cols),"\n"; #header line
	my $sheet;
	$sheet.=join(",",@chosen_cols)."\n";	
	while (<$FHI>)
	{
		my @row = (split(/[,;]/))[@slice];
		print $FHSHO join(",",@row),"\n";       #each data row
		$sheet.=join(",",@row)."\n";
	}	
	close $FHI;
	close $FHSHO;
	chmod(777,$FHSHO);
	system("chmod -R 777 $Indir");
	sendComplexFormOK("OK:$filename is uploaded",$sheet);
}

sub copypasteSection {
	my $folder = $cgi->param("folder");
	my $rfile = $cgi->param("rfile");	
	my $stype = $cgi->param("stype");	
	my $controlbc = $cgi->param("controlbc");	
	my $cumul = $cgi->param("cumul");
	my $Indir=$sampledir.$folder;
	makedir($Indir);
	system("chmod -R 777 $Indir");
	my $filename=$folder.".csv";

	#1)resume file	
	system("rm -rf $Indir/*resume_*") unless $cumul;
	my $file_out= $Indir."/".$stype."_"."resume_".$filename;
	my @row = split(/\n/,$rfile);
	open( my $FH, '>', $file_out ) or die("Can't create file: $file_out\n");
	for (my $i = 0; $i< scalar(@row); $i++) {
		$row[$i] =~ s/,//g;
		$row[$i]=specialChar($row[$i]);
		$row[$i] =~ s/\t/,/g;
		print $FH $row[$i],"\n";
	}
	close $FH;
	chmod(777,$FH);
	system("chmod -R 777 $Indir");	
	
	#2)short file Wgs Exome Genome Sc
 	system("rm -rf $Indir/*short_*") unless $cumul;
	my $shortfile_out= $Indir."/".$stype."_"."short_".$filename;
	open( my $FHSHO, '>', $shortfile_out ) or die("Can't create file: $shortfile_out\n");	
	my $desired_cols="Patient,BC i7,BC i5,Ref Projet,Flowcell - Lane";#order matters here
	my @desired_cols = split (/,/,$desired_cols);
	# reads first line to get actual column names
	open( my $FHI, '<', $file_out ) or die("Can't create file: $file_out\n");

	my $header_line = (<$FHI>);
#	my @actual_cols = split(/[,;]/,$header_line);
	my @actual_cols = split(/[,]/,$header_line);
	@actual_cols = map { s/\n//; $_ } @actual_cols;# if inside column	
	
	# get column number of the actual column names
	my $pos =0;
	my %col2_num = map {$_ => $pos++}@actual_cols;
	my @slice = map{if (exists $col2_num{$_}) { $col2_num{$_} } else {()} }@desired_cols;   
	my @chosen_cols;           
	my @slice_forHeader = map{if (exists $col2_num{$_}) { $col2_num{$_};push (@chosen_cols,$_) }}@desired_cols; 
	my $all_chosen=join(",",@chosen_cols);
	if (scalar @chosen_cols<5) {
		for (my $i = 0; $i< scalar(@desired_cols); $i++) {
			if ($all_chosen !~ $desired_cols[$i]) {
 				sendError("Error: Column <b>$desired_cols[$i]</b> Not found...");
			}					
		}	
	}	              
	print $FHSHO join(",",@chosen_cols),"\n"; #header line
	my $sheet;#	$sheet.=join(",",@chosen_cols)."\n";
	my $nbsample=0;	
	my %seenP = ();
	my %seenLP = ();
	my $lproj;
	my @dupBC1;
	my @dupBC2;	
	my @BCdup;
	my $cpt=1;
	my $dupLanePat;
	while (<$FHI>)
	{
#		my @row = (split(/[,;]/))[@slice];
		my @row = (split(/[,]/))[@slice];
		@row = map { s/\n//; $_ } @row;# if inside column
		
		#Lane
		$row[4]=~ s/\.//m;
		my $r_fc=controlfield($row[4]);
		sendError("Error: Flocell-Lane <b>$row[4]</b> in line $cpt: Presence of <b>Line Feed</b> and/or <b>Inverted Commas</b>") if  $r_fc;



		my $colPat=$row[0];#Patient
		sendError("Error: Patient with spaces <b>$colPat</b> in line $cpt...") if $colPat =~ /\s/;
		#warn Dumper @row;
		#control BC
		my $colBC1=$row[1];#BC1
		if ($controlbc =~ m/(uniq)|(multiple)/) {
			my $r_c1=controlBC($colBC1);
			sendError("Error: Uniq or Multiple BC ==> For Bar Code <b>BC i7</b> Not Valid in line $cpt... Rules: [ATGC], length=8 or 10") if  $r_c1;
		}
		push(@dupBC1,$colBC1);
				
		my $colBC2=$row[2];#BC2
		if ($colBC2) {
		if ($controlbc =~ m/(uniq)|(multiple)/) {
			my $r_c2=controlBC($colBC2);
			sendError("Error: Uniq or Multiple BC ==> Bar Code <b>BC i5</b> Not Valid in line $cpt... Rules: [ATGC], length=8 or 10") if  $r_c2;
		}		
		push(@dupBC2,$colBC2);
			
		}

		my $colProj = $row[3];#Project
		if ($row[3]) {
			$lproj.=$colProj."," unless $seenP{$colProj}++;			
		}

#		#Lane
#		$row[4]=~ s/\.//m;
		
		print $FHSHO join(",",@row),"\n";       #each data row
		$nbsample++ if $row[0];#Patient
		push(@BCdup,$colBC1."-".$colBC2.";".$row[0]) if $colBC2;
		#$f->{$colPat}=1 if $seenLP{$colPat."-".$row[4]}++;
		$dupLanePat=$colPat.";". $row[4] if $seenLP{$colPat."-".$row[4]}++;
			
		$cpt++;
	}
	if ($dupLanePat) {
		my @a_dupLanePat = split(/;/,$dupLanePat);
		sendError("Error: Patient $a_dupLanePat[0] Duplicated in same Lane $a_dupLanePat[1] ...");
	}
	my $r_bcpat=lookforDuplicateBCpat(@BCdup);
	if ($r_bcpat) {
		my @a_bcpat = split(/;/,$r_bcpat);
		sendError("Error: For <b>BC i7 - BCi5 </b>, Patient: $a_bcpat[1] ==> Duplicated Bar Code: $a_bcpat[0] ...");
		
	}
#		if ($controlbc =~ m/(uniq)|(multiple)/) {
	if ($controlbc =~ m/(uniq)/) {
		my $r_lnbc1=lookforUniqLength(@dupBC1);
		sendError("Error: Uniq BC ==> For <b>BC i5</b>, Multiple Bar Code Length:  $r_lnbc1 ...") if $r_lnbc1;	
	}
	
	if ($controlbc =~ m/(uniq)/) {	
		my $r_lnbc2=lookforUniqLength(@dupBC2);
		sendError("Error: Uniq BC ==> For <b>BC i7</b>, Multiple Bar Code Length:  $r_lnbc2 ...") if $r_lnbc2;
	}
	
	
	#my $r_dupLanePatBC1=lookforDuplicateLanePatBC(@dupLanePatBC1);
#	if ($r_bcpat) {

	chop($lproj);
	my $nbproj=scalar(split(/,/,$lproj));
	
	close $FHI;
	close $FHSHO;
	
	#3) cumulative short file
	my $cumulative_shortfile_out= $Indir."/"."short_".$filename;
	open( my $FHSHCO, '>>', $cumulative_shortfile_out ) or die("Can't create file: $cumulative_shortfile_out\n");	

	my $desired_cols="Patient,BC i7,BC i5,Ref Projet,Flowcell - Lane";#order matters here
	my @desired_cols = split (/,/,$desired_cols);
	# reads first line to get actual column names
	open( my $FHI, '<', $file_out ) or die("Can't create file: $file_out\n");
	my @actual_cols = split(/[,;]/,$header_line);
	@actual_cols = map { s/\n//; $_ } @actual_cols;
# get column number of the actual column names
	my $pos =0;
	my %col2_num = map {$_ => $pos++}@actual_cols;
	my @slice = map{if (exists $col2_num{$_}) { $col2_num{$_} } else {()} }@desired_cols;               
	my @chosen_cols;           
	my @slice_forHeader = map{if (exists $col2_num{$_}) { $col2_num{$_};push (@chosen_cols,$_) }}@desired_cols;               
	print $FHSHCO join(",",@chosen_cols),"\n"; #header line
	while (<$FHI>)
	{
		next if $_ =~ "Ref Projet";
#		my @row = (split(/[,;]/))[@slice];
		my @row = (split(/[,]/))[@slice];
		@row = map { s/\n//; $_ } @row;
		$row[4]=~ s/\.//m;
		print $FHSHCO join(",",@row),"\n";       #each data row
	}
	close $FHI;
	close $FHSHCO;
	chmod(777,$FHSHCO);
	
	my $sheet;
	open( my $FHCI, '<', $cumulative_shortfile_out ) or die("Can't create file: $cumulative_shortfile_out\n");
	while ( my $Line = <$FHCI> ) {		
		$sheet.=$Line;
	}	
	close $FHCI;
	
	#4) create/update table  info_short
	my $info_shortfile_out= $Indir."/"."info_short_".$filename;
	open( my $FHINFO, '>>', $info_shortfile_out ) or die("Can't create file: $info_shortfile_out\n");
	print $FHINFO $stype.",".$nbsample.",".$nbproj."\n";
	close $FHINFO;
	my $info;
	$info="type,nbsample,nbproj\n";
	open( my $FHINFOI, '<', $info_shortfile_out ) or die("Can't create file: $info_shortfile_out\n");
	while ( my $Line = <$FHINFOI> ) {
		$info.=$Line;
	}	
	close $FHINFOI;
	system("chmod -R 777 $Indir");
	sendComplexOK("OK: ".$stype."_resume_".$filename." is uploaded",$sheet,$info);
}

sub lookforDuplicateBCpat {
	my (@bc) = @_;
	my $invalid;
	my %seen;
	foreach my $string (@bc) {
		my @s_string = split(/;/,$string);
    	next unless $seen{$s_string[0]}++;
    	$invalid.=$string.",";
  	}
	chop($invalid);	
	return $invalid if $invalid;
	return 0;	
}

sub lookforDuplicate {
	my (@bc) = @_;
	my $invalid;
	my %seen;
	foreach my $string (@bc) {
		#warn Dumper $string;
    	next unless $seen{$string}++;
    	$invalid.=$string.",";
  	}
	chop($invalid);	
	return $invalid if $invalid;
	return 0;	
}

sub lookforUniqLength {
	my (@bc) = @_;
	my @lnBC;
	foreach my $t (@bc) {
		push(@lnBC,length($t));
  	}
	my @uniq_lnBC=keys %{{map{$_=>1}@lnBC}};
	return join ',',@uniq_lnBC if scalar @uniq_lnBC>1;
	return 0;	
}

sub copypastediagSection {
	my $folder = $cgi->param("folder");
	my $rfile = $cgi->param("rfile");	
	my $stype = $cgi->param("stype");	
	my $cumul = $cgi->param("cumul");
	my $site = $cgi->param("site");
	my $dual = $cgi->param("dual");
	my $project=$folder;
#	die;
	my $Indir;
	if ($site =~ "Diag") {
		$site="diag";
		makedir($sampledir.$site);
		$Indir=$sampledir.$site."/".$folder;
	} else {
		$Indir=$sampledir.$folder;
	};
	makedir($Indir);
	system("chmod -R 777 $Indir");
	my $filename=$folder.".csv";
	
	#1)resume file	
	system("rm -rf $Indir/*resume_*") unless $cumul;
	my $file_out= $Indir."/".$stype."_"."resume_".$filename;
	printResumeFile($file_out,$rfile);
	system("chmod -R 777 $Indir");	

# cas pedigree 
	#2)short file #3)short file with bc
 	system("rm -rf $Indir/*short_*") unless $cumul;
	my $shortfile_out= $Indir."/".$stype."_"."short_".$filename;		
	my $bc_shortfile_out= $Indir."/"."bc_short_".$filename;	
#	printShortFile($shortfile_out,$file_out,$bc_shortfile_out,$Indir,$stype,$filename);
	printShortFile($shortfile_out,$file_out,$bc_shortfile_out,$Indir,$stype,$dual,$filename);

	#4)Sample sheet
	my $fileSample_out;
	$fileSample_out= $Indir."/"."SampleSheet_".$filename;	

#	return $header."#".$sheet;
#	my $HeaderSheet=printSampleFileAndLine($fileSample_out,$bc_shortfile_out,$stype);
#	my $HeaderSheet=printSampleFileAndLine($fileSample_out,$bc_shortfile_out,$stype,$dual);
	my $HeaderSheet=printSampleFileAndLine($fileSample_out,$bc_shortfile_out,$stype,$dual,$project);
	my @sp_HeaderSheet=split(/#/,$HeaderSheet);
	
	#5)pedigree & vcf
	my $filePedigree_out;
	$filePedigree_out= $Indir."/"."Pedigree_".$filename;	
	my $pedigree=printPedigreeFileAndLine($filePedigree_out,$file_out);

	my $info="";
	system("chmod -R 777 $Indir");	
#	sendComplexHeaderOK("OK: ".$stype."_resume_".$filename." is uploaded",$header,$sheet);
	sendComplexHeaderOK("OK: ".$stype."_resume_".$filename." is uploaded",$sp_HeaderSheet[0],$sp_HeaderSheet[1],$pedigree);
}

sub printResumeFile {
	my ($file_out,$rfile) = @_;
	my @row = split(/\n/,$rfile);
	open( my $FH, '>', $file_out ) or die("Can't create file: $file_out\n");
	for (my $i = 0; $i< scalar(@row); $i++) {
		$row[$i] =~ s/,//g;
		$row[$i]=specialChar($row[$i]);
		$row[$i] =~ s/\t/,/g;
		print $FH $row[$i],"\n";
	}
	close $FH;
	chmod(777,$FH);
}
#	printShortFile($shortfile_out,$file_out,$bc_shortfile_out,$Indir,$stype,$dual,$filename);

sub printShortFile {
#	my ($shortfile_out,$file_out,$rfile) = @_;
	my ($shortfile_out,$file_in,$bc_shortfile_out,$Indir,$stype,$dual,$filename) = @_;
	open( my $FHSHO, '>', $shortfile_out ) or die("Can't create file: $shortfile_out\n");	
#Patient	Sexe	lien de parenté	Statut	Sex	Mother	Father	Status	IV	Family	index	index2
#	my $desired_cols="Patient,index,index2";#order matters here
	my $desired_cols;#order matters here
	$desired_cols="Patient,index,index2" if $dual;#order matters here
	$desired_cols="Patient,index" unless $dual;#order matters here
	my @desired_cols = split (/,/,$desired_cols);
	# reads first line to get actual column names
	open( my $FHI, '<', $file_in ) or die("Can't open file: $file_in\n");

	my $header_line = (<$FHI>);
#	my @actual_cols = split(/[,;]/,$header_line);
	my @actual_cols = split(/[,]/,$header_line);
	@actual_cols = map { s/\n//; $_ } @actual_cols;# if inside column	
	for (@actual_cols)
    {
		s/^\s+//g;   # Remove spaces at the beginning
        s/\s+$//g;   # Remove spaces at the end
    }	
	# get column number of the actual column names
	my $pos =0;
	my %col2_num = map {$_ => $pos++}@actual_cols;
	my @slice = map{if (exists $col2_num{$_}) { $col2_num{$_} } else {()} }@desired_cols;   
	my @chosen_cols;           
	my @slice_forHeader = map{if (exists $col2_num{$_}) { $col2_num{$_};push (@chosen_cols,$_) }}@desired_cols; 
	my $all_chosen=join(",",@chosen_cols);
	if (scalar @chosen_cols<5) {
		for (my $i = 0; $i< scalar(@desired_cols); $i++) {
			if ($all_chosen !~ $desired_cols[$i]) {
 				sendError("Error: Column <b>$desired_cols[$i]</b> Not found. <b>Upper</b> and <b>Lower</b> case of your Header File must be <b>strictly identical</b> to the request <b>field</b>...");
			}					
		}	
	}
	print $FHSHO join(",",@chosen_cols),"\n"; #header line
	
	while (<$FHI>)
	{
#		my @row = (split(/[,;]/))[@slice];
		my @row = (split(/[,]/))[@slice];
		@row = map { s/\n//; $_ } @row;# if inside column
		#Patient
#		$row[$i] =~ s/,//g;
#		$row[$i] =~ s/ /_/g;
		
		my $colPat=$row[0];#Patient
#		$row[0] =~ s/ /_/g;
		
		next if $colPat eq "X_0";
		sendError("Error: Patient with spaces <b>$colPat</b>...") if $colPat =~ /\s/;
		
		#control BC
		my $colBC1=$row[1];#index BC1
		my $r_c1=controlBC($colBC1);
		sendError("Error: Bar Code <b>index</b> Not Valid...") if  $r_c1;
		if ($dual) {
			my $colBC2=$row[2];#index2 BC2
			my $r_c2=controlBC($colBC2);
			sendError("Error: Bar Code <b>BC i5</b> Not Valid...") if  $r_c2;			
		}
		print $FHSHO join(",",@row),"\n";       #each data row
	}	
	close $FHI;
	close $FHSHO;

	open( my $FHBCO, '>', $bc_shortfile_out ) or die("Can't create file: $bc_shortfile_out\n");	
#	open( my $FHBCI, '<', $Indir."/".$stype."_"."short_".$filename ) or die("Can't open file: $file_out\n");
	open( my $FHBCI, '<', $Indir."/".$stype."_"."short_".$filename ) or die("Can't open file: ".$Indir."/".$stype."_"."short_".$filename."\n");
	my @chosen_cols_bc;
	for (my $i = 0; $i< scalar(@chosen_cols); $i++) {
			push (@chosen_cols_bc,$chosen_cols[$i]) unless ($chosen_cols[$i] eq "index"||$chosen_cols[$i] eq "index2");
			push (@chosen_cols_bc,"I7_Index_ID") if ($chosen_cols[$i] eq "index");#I7BC	
			push (@chosen_cols_bc,$chosen_cols[$i]) if ($chosen_cols[$i] eq "index");#BC1 index	
			if ($dual) {
				push (@chosen_cols_bc,"I5_Index_ID") if ($chosen_cols[$i] eq "index2");#I5BC	
				push (@chosen_cols_bc,$chosen_cols[$i]) if ($chosen_cols[$i] eq "index2");#BC2 index2	
			}
		
	}
	print $FHBCO join(",",@chosen_cols_bc),"\n"; #header line
	
	my $cpt=1;	
	while (<$FHBCI>)
	{
		next if $_ =~ "index";
		my @row;
		#Patient
		my @rowP = (split(/,/))[0];#Patient
		next unless $rowP[0];
		next if $rowP[0] eq "\n";
		next if $rowP[0] eq "X_0";
		$rowP[0]=specialCharInField($rowP[0]);
		push (@row,$rowP[0]);
		#BCID and BC for I7 index
		push(@row,"I7BC".$cpt);#I7BC			
		push(@row,(split(/,/))[1]);#BC1		
		#BCID and BC for I5 index2
		if ($dual) {
			push(@row,"I5BC".$cpt);#I5BC			
			push(@row,(split(/,/))[2]);#BC2		
		}
		print $FHBCO join(",",@row);       #each data row
		$cpt++;
	}
	
	close $FHBCI;
	close $FHBCO;	
}

sub printSampleFileAndLine {
	my ($fileSample_out,$bc_shortfile_out,$stype,$dual,$project) = @_;
	my $datestring =strftime "%e/%m/%Y", localtime;
	my $headerRF0="\r\n"."[Data]"."\r\n";
	
#	my $headerData="Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,I5_Index_ID,index2,Sample_Project,Description"."\r\n";
	my $headerData;
	$headerData="Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,I5_Index_ID,index2,Sample_Project,Description"."\r\n" if $dual;
	$headerData="Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description"."\r\n" unless $dual;
	my $headerDF0="[Header]"."\r\n"."IEMFileVersion,4";
	my $headerDa0="Date,".$datestring."\r\n";		
	my $headerR0="\r\n"."[Reads]"."\r\n";
	my $headerS0="\r\n"."[Settings]"."\r\n"."Adapter,AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"."\r\n"."AdapterRead2,AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"."\r\n";

	my $allLines="";
	$allLines=$headerDF0."\r\n";
	$allLines.="Investigator Name,CD"."\r\n"."Experiment Name,Projet NGS CD"."\r\n" if ($stype eq "miseq");
	$allLines.=$headerDa0;

##	$allLines.="Workflow,NextSeq FASTQ Only"."\r\n"."Application,NextSeq FASTQ Only"."\r\n"."Description,RENOME_V4-S51"."\r\n"."Chemistry,Twist"."\r\n" if ($stype eq "nextseq");		
	$allLines.="Workflow,NextSeq FASTQ Only"."\r\n"."Application,NextSeq FASTQ Only"."\r\n"."Description,".$project."\r\n"."Chemistry,Twist"."\r\n" if ($stype eq "nextseq");		
	$allLines.="Workflow,GenerateFASTQ"."\r\n"."Application,FASTQ Only"."\r\n"."Assay,Gendx"."\r\n"."Description,PLAQUE IV   96 samples"."\r\n"."Chemistry,Amplicon"."\r\n" if ($stype eq "miseq");
		
	$allLines.=$headerR0;
	$allLines.="149"."\r\n"."149"."\r\n" if ($stype eq "nextseq");
	$allLines.="151"."\r\n"."151"."\r\n" if ($stype eq "miseq");
		
	$allLines.=$headerS0;
	$allLines.=$headerRF0;
	#$allLines.=$headerData;
	my $dlo=",";
	open( my $FHBCI, '<', $bc_shortfile_out ) or die("Can't open file: $bc_shortfile_out\n");
	open( my $FHSO, '>', $fileSample_out ) or die("Can't create file: $fileSample_out\n");

	my $sheet="";
	print $FHSO	$allLines.$headerData;
	#$sheet.=$allLines;
	while (<$FHBCI>)
	{
		next if $_ =~ "index";
		my @row;
		#Patient
		my @rowP = (split(/,/))[0];#Patient
		next unless $rowP[0];
		next if $rowP[0] eq "\n";
		$rowP[0]=specialCharInField($rowP[0]);
		push (@row,$rowP[0]);
		push (@row,$dlo.$dlo);
		push(@row,(split(/,/))[1]);#I7BC		
		push(@row,(split(/,/))[2]);#index		
		if ($dual) {
			push(@row,(split(/,/))[3]);#I5BC		
			push(@row,(split(/,/))[4]);#index2
		}
		push(@row,$project.$dlo);#project		
#		push (@row,$dlo);
		@row = map { s/\n//; $_ } @row;# if inside column	
		print $FHSO join(",",@row),"\n";       #each data row
		$sheet.=join(",",@row)."\n";
	}
	$sheet=$headerData.$sheet;
	close $FHSO;
	close $FHBCI;
	my $header=$allLines;
	return $header."#".$sheet;
}

sub printPedigreeFileAndLine {
	my ($filePedigree_out,$file_in) = @_;
	open( my $FHPEDO, '>', $filePedigree_out ) or die("Can't create file: $filePedigree_out\n");
	my $desired_cols="Patient,Family,Mother,Father,Status,Sex,IV";#order matters here
	my @desired_cols = split (/,/,$desired_cols);
	# reads first line to get actual column names
	open( my $FHI, '<', $file_in ) or die("Can't open file: $file_in\n");
	my $header_line = (<$FHI>);
	my @actual_cols = split(/[,]/,$header_line);
	@actual_cols = map { s/\n//; $_ } @actual_cols;# if inside column	
	for (@actual_cols)
    {
		s/^\s+//g;   # Remove spaces at the beginning
        s/\s+$//g;   # Remove spaces at the end
    }	
	# get column number of the actual column names
	my $pos =0;
	my %col2_num = map {$_ => $pos++}@actual_cols;
	my @slice = map{if (exists $col2_num{$_}) { $col2_num{$_} } else {()} }@desired_cols;   
	my @chosen_cols;           
	my @slice_forHeader = map{if (exists $col2_num{$_}) { $col2_num{$_};push (@chosen_cols,$_) }}@desired_cols; 
	my $all_chosen=join(",",@chosen_cols);
	if (scalar @chosen_cols<5) {
		for (my $i = 0; $i< scalar(@desired_cols); $i++) {
			if ($all_chosen !~ $desired_cols[$i]) {
 				sendError("Error: Column <b>$desired_cols[$i]</b> Not found...");
			}					
		}	
	}
	print $FHPEDO join(",",@chosen_cols),"\n"; #header line
	my $pedigree=join(",",@chosen_cols)."\n";
	while (<$FHI>)
	{
		my @field;
		my @row = (split(/[,]/))[@slice];
		@row = map { s/\n//; $_ } @row;# if inside column
		#warn Dumper @row;
		#Sex
		my $colSex=specialCharInField($row[5]);
		next if $colSex eq "x";
		#Patient
		my $colPat=specialCharInField($row[0]);
		push(@field,$colPat);
		#Family
		my $colFam=specialCharInField($row[1]);
		push(@field,$colFam);
		#Mother
		my $colMot=specialCharInField($row[2]);
		push(@field,$colMot);
		#Father
		my $colFat=specialCharInField($row[3]);
		push(@field,$colFat);
		#Status
		my $colSta=specialCharInField($row[4]);
		my $r_sta=controlStatusSex($colSta);
		sendError("Error: <b>Sex</b> Not Valid...") if  $r_sta;
		push(@field,$colSta);
		#Sex
#		my $colSex=specialCharInField($row[5]);
		my $r_sex=controlStatusSex($colSex);
		sendError("Error: <b>Sex</b> Not Valid...") if  $r_sex;
		push(@field,$colSex);
		#IV identity Vigilance
		my $colIV=specialCharInField($row[6]);
		my $r_iv=controlIV($colIV);
		sendError("Error: Identity Vigilance <b>IV</b> Not Valid...") if  $r_iv;
		push(@field,$colIV);
		
		print $FHPEDO join(",",@field),"\n";       #each data row
		$pedigree.=join(",",@row)."\n";	
	}
	close $FHI;
	close $FHPEDO;
	return $pedigree;
}

sub findFileSection {
	my $paramdir = $cgi->param("param_dir");
	my $type = $cgi->param("type");
	my $Indir=$sampledir;
	my $f_short=findFile($Indir,$paramdir,"short_*.csv");
 	sendError("Error: Unknown Run Folder $paramdir...") unless $f_short;
	my $shortfile_out= $Indir.$paramdir."/".$f_short;
	open( my $FH, '<', $shortfile_out ) or die("Can't create file: $shortfile_out\n");
	my $sheet;
	my $p_prev="";
	my $l_prev="";	
	my $cpt=1;
	my $chg=0;
	while ( <$FH> ) {
		if ($_ =~ "Ref Projet") {
			#HeadLine
			$chg=0;
			$p_prev="";
			$l_prev="";	
			next;
		}  else {
			$chg++;
			my @row;
			#Patient
			my @rowP = (split(/,/))[0];#Patient
			next unless $rowP[0];
			next if $rowP[0] eq "\n";
			$rowP[0]=specialCharInField($rowP[0]);
			push (@row,$rowP[0]);
			#BCID and BC for I7
			push (@row,"I7BC".$cpt) if ($type =~ m/(Dual)|(Rapid)|(Mixed)/);#I7BC
			my $first=(split(/,/))[1];		
			push (@row,(split(/,/))[1]) if ($type =~ m/(Dual)|(Rapid)|(Normal)|(Mixed)/);#BC1			
			push (@row,"I7BC".$cpt) if ($type =~ m/(Rapid)|(Normal)/);#I7BC #Description		
			#BCID and BC for I5
			#push (@row,"I5BC".$cpt) if ($type eq "Dual");#I5BC
			#push (@row,(split(/,/))[2]) if ($type eq "Dual");#BC2
			push (@row,"I5BC".$cpt) if ($type =~ m/(Dual)|(Mixed)/);#I5BC
			push (@row,(split(/,/))[2]) if ($type =~ m/(Dual)/);#BC2
			my $second=(split(/,/))[2] if ($type =~ m/(Mixed)/);#I5BC
			$second=getN(length($first)) if $second eq "";			
			push (@row,$second) if ($type =~ m/(Mixed)/);#BC2
			#Project
			my $p_cur=(split(/,/))[3];
			$p_prev=$p_cur if ($p_cur);
			$p_prev=specialCharInField($p_prev) if ($p_cur);
			push (@row,$p_prev);#Project
			#Lane
			my $l_cur;
			my @ll_cur=(split(/,/))[4]=~ /(\d+)/g;# $VAR1 = 'A - Lane 1 a 2'
			$l_cur=getFromNumRange(join(",",@ll_cur)) if scalar @ll_cur==2;
			$l_cur=join(",",@ll_cur) if scalar @ll_cur>2;
			$l_cur=join(",",split(//,$ll_cur[0])) if scalar @ll_cur==1;
			$l_prev=$l_cur if ($l_cur);
			$l_prev="1,2" if ($chg==1 && scalar split( /,/, $l_prev)<1);
			push (@row,$l_prev);#Lane
			
			$sheet.=join(" ",@row)."\n";
			$cpt++;	
		} 
	}
	close($FH);
	my $mes_type;
	$mes_type=" for <b>Dual Sample Sheet</b>" if ($type =~ m/(Dual)/);
	$mes_type=" for <b>Rapid Sample Sheet</b>" if ($type =~ m/(Rapid)/);
	$mes_type=" for <b>Normal Sample Sheet</b>" if ($type =~ m/(Normal)/);
	$mes_type=" for <b>Mixed Dual Single Sample Sheet</b>" if ($type =~ m/(Mixed)/);
	sendComplexOK("OK: $f_short $mes_type",$sheet) if $f_short; 
}

sub getN {
	my ($ln) = @_;
	if ($ln >=1) {
		my $string="";
		for (my $i = 0; $i< $ln; $i++) {
			$string.="N";
		}
		return $string;	
	} else {
		return 0;		
	}
}

sub controlfield {
	my ($field) = @_;
	if ($field =~ /\n/ ||$field =~ /"/) {
		return 1;
	}
	return 0;
}

sub controlBC {
	my ($bc) = @_;
	my @row=split(//,$bc);
	if (scalar @row==8||scalar @row==10) {
		for (my $i = 0; $i< scalar(@row); $i++) {
			if ($row[$i]!~ m/A|T|G|C/) { return 1}
		}			
	} else {
		return 1;
	}
	return 0;
}

#$s =~ /^[0-9,.E]+$/

sub controlIV {
	my ($iv) = @_;
	my @row=split(//,$iv);
	# test scalar eventually
	if (scalar @row) {
		for (my $i = 0; $i< scalar(@row); $i++) {
			if ($row[$i]!~ /^[0-9]+$/) { return 1}			
		}			
	} else {
		return 0;
	}
	return 0;
}

sub controlStatusSex {
	my ($val) = @_;
	if ($val) {
		if ($val !~ /^[1-2]$/) { return 1}
		return 0;
	} else {
		return 1;
	}
}

sub specialChar {
	my ($string) = @_;
	$string =~ s/;/ /g;
	$string =~ s/\+/ /g;
	$string =~ s/\&/ /g;
	$string =~ s/\?//g;
	$string =~ s/’//g;
	$string =~ s/\'//g;
	$string =~ s/é/e/g;
	$string =~ s/è/e/g;
	$string =~ s/ê/e/g;
	$string =~ s/à/a/g;	
	return $string;
}

sub specialCharInField {
	my ($string) = @_;
	$string =~ s/ /_/g;
	$string =~ s/\./_/g;
	$string =~ s/-/_/g;
	$string =~ s/\*/_/g;
	$string =~ s/\+/ /g;
	$string =~ s/\&/ /g;
	return $string;
}

sub getFromNumRange {
	my ($range) = @_;
	my @sp_range = split( /,/, $range);
	my $numlist;
	for (my $i = $sp_range[0]; $i< $sp_range[1]+1; $i++) {
		$numlist.=$i.",";
	}
	chop($numlist);
	return $numlist;
}

sub sendComplexFormOK {
	my ($text,$sheet) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendComplexOK {
	my ($text,$sheet,$info) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	$resp->{sheet} = $sheet;
	$resp->{info} = $info;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendComplexHeaderOK {
	my ($text,$header,$sheet,$pedigree) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	$resp->{header} = $header;
	$resp->{sheet} = $sheet;
	$resp->{pedigree} = $pedigree;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub findFile {
	my ($Dir,$projdir,$p_file) = @_;
	my @files;
	my @s_ext;
	@s_ext=qw/ p_file /;
	@files = File::Find::Rule->file()
                                  ->name( [  $p_file ])
#                                  ->name( [  'short_*.csv' ])
                                  ->in( $Dir."/".$projdir."/" );
	my $filename="";
	$filename= getfileName($files[0]) if scalar @files;
	return $filename;
}

sub getfileName {
	my ($filename) = @_;
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	return $name.$extension	
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

