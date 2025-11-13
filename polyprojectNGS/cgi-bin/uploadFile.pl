#!/usr/bin/perl
########################################################################
###### uploadFile.pl
#./uploadFile.pl
########################################################################
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
#use lib "$Bin/GenBo/lib/obj-lite";
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
#use insert;
use File::Basename;
use GD;
use Getopt::Long;
#use response;
use Spreadsheet::WriteExcel;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
use JSON::XS;
use queryPolyproject;
use DBI;
use JSON;

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');

if ( $opt eq "runDoc" ) {
	RunDocumentSection();
}  elsif ( $opt eq "getrunDoc" ) {
	my $runid = $cgi->param('fileRunid');
	getRunDocument($buffer,$runid);
}  elsif ( $opt eq "sampleDoc" ) {
	SampleDocumentSection();
}	
	
###### get Doc Run  ###################################################################
sub getRunDocument{
	my ($buffer,$runid) = @_;
	my $res = queryPolyproject::getRunDocument($buffer->dbh,$runid);
	my $filename = $res->{filename};
	my $type = $res->{filetype};
	print "Content-type: application/octet-stream\n";
	print "Content-Disposition: attachment;filename=$filename\n\n";
	binmode(STDOUT);
	print $res->{document}."\n";
	exit(0);
}

###### Add Doc Run  ###################################################################
sub RunDocumentSection {
	my $run = $cgi->param("fileRunid");
	my $filename = $cgi->param("file_name");
### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################	
	$filename =~ s/ /_/g;
	$filename =~ s/\\/_/g;
#	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	my ( $name, $path, $extension ) = fileparse( $filename, '\.[a-z]+' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	my $runid = queryPolyproject::getRunId($buffer->dbh,$run);
	$runid =$runid->[0]->{run_id};
	################################	
	my $upload_filehandle = $cgi->upload("file_name");
	my $data;
	# Dans table run: document , file_name , file_type
	read( $upload_filehandle, $data, -s $upload_filehandle );
	my %ok;
	if ( !$filename ) {
		$ok{status} = "error";
	} else {
			my $file_type =  $cgi->param('file_type');
			$file_type = $extension unless $file_type;
			queryPolyproject::upRunDocument($buffer->dbh, $run,$filename,$file_type,$data);
	}		
### End Autocommit dbh ###########
	$dbh->commit();
	sendFormOK("File $filename is temporary uploaded");
}

###### Add Sample Sheet Run  ###################################################################
sub SampleDocumentSection {
	my $filename = $cgi->param("samplefile_name");
	my $runname = $cgi->param("runName");
	my $runpltname = $cgi->param("runPltName");

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################	
	$filename =~ s/ /_/g;
	$filename =~ s/\\/_/g;
#	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	my ( $name, $path, $extension ) = fileparse( $filename, '\.[a-z]+' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	
	$extension =~ s/\.//;
	unless ($runname) {
		sendFormError("Error: File $filename is not uploaded, <b>Run Name</b> and <b>Plateform Run Name</b> are required");			
	}
	unless ($runpltname) {
		sendFormError("Error: File $filename is not uploaded, <b>Run Name</b> and <b>Plateform Run Name</b> are required");			
	}
		
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
		#$tempdir=$dir_sp[0]."sequencing/Temp/";
		$tempdir=$dir_sp[0]."Temp/";
	}
	my $Indir=$tempdir.$runname;
 	system("rm -rf $Indir");
	makedir($Indir);
	system("chmod -R 777 $Indir");
	$Indir=$tempdir.$runname."/".$runpltname;
	makedir($Indir);		
	system("chmod -R 777 $Indir");
	my $upload_filehandle = $cgi->upload("samplefile_name");		
	my $file_out= $Indir."/".$filename;
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
	while (read ($upload_filehandle, my $Buffer,  -s $upload_filehandle)) {
		print $FHO $Buffer;
	}		
	close $FHO;
	chmod(777,$FHO);		
### End Autocommit dbh ###########
	$dbh->commit();
	sendFormOK("File $filename is temporary uploaded");
}

###### Add Doc Run  ###################################################################

sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header();
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


sub sendError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header();
	exit(0);
}


sub makedir {
	my ($dir) = @_;
	if (!(-d $dir)){
		mkdir ($dir,0755);
	}
	return $dir;	
} 


sub display2_form {
 print <<HTML
  <!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>
  <head>
	<title>User Creation</title>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'></meta>
	<!-- chargement des feuilles de styles necessaires à l affichage -->
        <link href='/includes/user/user.css' rel='stylesheet' type='text/css'/>
  </head>
<body>
    <script type="text/javascript"> 
myWindow=window.open('','','location=1,status=1,scrollbars=1,resizable=no,width=200,height=100,menubar=no,toolbar=no')
myWindow.document.write("<p>error_message</p>")
myWindow.focus()
     </script> 
</body>
HTML
	
}















sub response2 {
	my ($rep) = @_;
	print qq{<textarea>};
# 	print encode_json $rep;
#	print "\n";
# 	print to_json($rep);
#	print $rep;
	print qq{</textarea>};
	exit(0);
}

exit(0);












