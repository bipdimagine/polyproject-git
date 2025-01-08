#!/usr/bin/perl
########################################################################
###### uploadpatient_file.pl
#./uploadpatient_file.pl option=insert file_name=1247ped.csv  project=TEST2012_0186
#./uploadpatient_file.pl option=extract file_name=lola project=TEST2012_0186
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
#use GenBoWriteNgs;
#use GenBoQueryNgs;
#use GenBoProjectWriteNgs;
#use util_file qw(readXmlVariations);
#use insert;
use File::Basename;
use GD;
use Getopt::Long;
#use response;
use Spreadsheet::WriteExcel;
#use Spreadsheet::ParseExcel;
#use Spreadsheet::XLSX;
#use Spreadsheet::BasicRead;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
#use JSON::XS;
use JSON;
use queryPolyproject;
use DBI;

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $dlf="\t";

#print $cgi->header();
if ( $opt eq "insert" ) {
	InsertTabPatSection();
} elsif ($opt eq "insertBCG") {
	InsertBCGSection();
}

sub InsertTabPatSection {
	my $filename = $cgi->param("file_name");

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	
	my $upload_filehandle = $cgi->upload("file_name");
	my $doc;
	# -s file : file size
	read( $upload_filehandle, $doc, -s $upload_filehandle );
	#binmode $doc;
	$doc =~ s/\r//g;
	my @data = split("\n",$doc);
	my $fams = builddata(\@data);
	
### End Autocommit dbh ###########
	$dbh->commit();
#	sendOKJson("ok");
#	sendOK2("ok");
}

sub builddata {
	my ($data) = @_;
	my @mydata;
	my %hdata;
	$hdata{identifier}="patname";
	$hdata{label}="patname";
	foreach my $Line (@$data) {
		my %s;
		#Patient  Family  Father  Mother  Sex  Status  BC  BC2  IV  Person 
#		my @tab = split( /$dlf/, $Line );
#		my @tab = split( /[ \n\t\r]/, $Line );
#		my @tab = split( /\s+/, $Line );
		my @tab = split( /\s/, $Line );
		$tab[2]="" unless $tab[2];
		$tab[3]="" unless $tab[3];
		$s{patname} = $tab[0];
		$s{family} = $tab[1];
		$s{father} = $tab[2];
		$s{mother} = $tab[3];
		$s{sex} = $tab[4] if defined $tab[4];
		$s{status} = $tab[5] if defined $tab[5];
		$s{bc} = $tab[6] if defined $tab[6];
		$s{bc2} = $tab[7] if defined $tab[7];
		$s{iv} = $tab[8] if defined $tab[8];
		$s{person} = $tab[9] if defined $tab[9];
		push(@mydata,\%s);
	}
	$hdata{items}=\@mydata;
	return printJson(\%hdata);
}

sub InsertBCGSection {
	my $filename = $cgi->param("file_name");

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	
	my $upload_filehandle = $cgi->upload("file_name");
	my $doc;
	# -s file : file size
	read( $upload_filehandle, $doc, -s $upload_filehandle );
	#binmode $doc;
	$doc =~ s/\r//g;
	my @data = split("\n",$doc);
	my $bcgs = buildbcgdata(\@data);
	
### End Autocommit dbh ###########
	$dbh->commit();
#	sendOKJson("ok");
#	sendOK2("ok");
}

sub buildbcgdata {
	my ($data) = @_;
	my @mydata;
	my %hdata;
	$hdata{identifier}="patname";
	$hdata{label}="patname";
	foreach my $Line (@$data) {
		my %s;
		my @tab = split( /\s/, $Line );
		$s{patname} = $tab[0];
		$s{iv} = $tab[1];
		push(@mydata,\%s);
	}
	$hdata{items}=\@mydata;
	return printJson(\%hdata);
}

sub printJson {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header();
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}


exit(0);

