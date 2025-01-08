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
use GenBoWriteNgs;
use GenBoQueryNgs;
use GenBoProjectWriteNgs;
use util_file qw(readXmlVariations);
use insert;
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
use queryRun;
use DBI;

my $cgi = new CGI;
my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $dlf="\t";

#print $cgi->header();
if ( $opt eq "insert" ) {
	InsertTabStatSection();
}

sub InsertTabStatSection {
	my $filename = $cgi->param("file_name");

### Autocommit dbh ###########
	my $dbh = $buffer->dbh;
	$dbh->{AutoCommit} = 0;
#############################
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	
#	warn Dumper $filename;
	
	
	my $upload_filehandle = $cgi->upload("file_name");
	my $doc;
	# -s file : file size
	read( $upload_filehandle, $doc, -s $upload_filehandle );
	#binmode $doc;
	$doc =~ s/\r//g;
	my @data = split("\n",$doc);
#	warn Dumper @data;
	my $baits = builddata(\@data);
#	warn Dumper $baits;
	
### End Autocommit dbh ###########
	$dbh->commit();
#	sendOKJson("ok");
#	sendOK2("ok");
}

sub builddata {
	my ($data) = @_;
	my @mydata;
	my %hdata;
	$hdata{identifier}="baitset";
	$hdata{label}="baitset";
	foreach my $Line (@$data) {
		my %s;
		next if $Line =~ "#";
#		warn Dumper $Line;
#		my @tab = split( /$dlf/, $Line );
		my @tab = split( /\t|\s+/, $Line );
#		my @tab = split( /\s+/, $Line );
#		next unless $tab[0] =~ "#";
#		next if (length($tab[0]) == 0);
		next unless length($tab[0]);
		$s{baitset} = $tab[0];
		$s{genomesize} = $tab[1];
		$s{baitterritory} = $tab[2];
		$s{targetterritory} = $tab[3];
		$s{baitdesignefficiency} = $tab[4];
		$s{totalreads} = $tab[5];
		$s{pfreads} = $tab[6];
		$s{pfuniquereads} = $tab[7];
		$s{pctpfreads} = $tab[8];
		$s{pctpfuqreads} = $tab[9];		
		$s{pfuqreadsaligned} = $tab[10];
		$s{pctpfuqreadsaligned} = $tab[11];
		$s{pfuqbasesaligned} = $tab[12];
		$s{onbaitbases} = $tab[13];
		$s{nearbaitbases} = $tab[14];
		$s{offbaitbases} = $tab[15];
		$s{ontargetbases} = $tab[16];
		$s{pctselectedbases} = $tab[17];
		$s{pctoffbait} = $tab[18];
		$s{onbaitvsselected} = $tab[19];
		$s{meanbaitcoverage} = $tab[20];
		$s{meantargetcoverage} = $tab[21];
		$s{pctusablebasesonbait} = $tab[22];
		$s{pctusablebasesontarget} = $tab[23];
		$s{foldenrichment} = $tab[24];
		$s{zerocvgtargetspct} = $tab[25];
		$s{fold80basepenalty} = $tab[26];
		$s{pcttargetbases2x} = $tab[27];
		$s{pcttargetbases10x} = $tab[28];
		$s{pcttargetbases20x} = $tab[29];
		$s{pcttargetbases30x} = $tab[30];
		$s{hslibrarysize} = $tab[31];
		$s{hspenalty10x} = $tab[32];
		$s{hspenalty20x} = $tab[33];
		$s{hspenalty30x} = $tab[34];
		$s{atdropout} = $tab[35];
		$s{gcdropout} = $tab[36];
		$tab[37]= "" unless defined $tab[37];
		$tab[38]= "" unless defined $tab[38];
		$tab[39]= "" unless defined $tab[39];
		$s{sample} = $tab[37];
		$s{library} = $tab[38];
		$s{readgroup} = $tab[39];
		warn Dumper $tab[37];
		warn Dumper $tab[38];
		warn Dumper $tab[39];
#		$s{} = $tab[];
		
#		warn Dumper $s{baitset};
#		warn Dumper $s{genomesize};
		push(@mydata,\%s);
#		warn Dumper @mydata;
	}
	$hdata{items}=\@mydata;
#	warn Dumper \%hdata;
	return printJson(\%hdata);
#	printJson(\%hwdata);
}

sub builddataold {
	my ($data) = @_;
	my @mydata;
	my %hdata;
	$hdata{identifier}="patname";
	$hdata{label}="patname";
	foreach my $Line (@$data) {
		my %s;
#		my @tab = split( /$dlf/, $Line );
		my @tab = split( /\s+/, $Line );
		$tab[2]="" unless $tab[2];
		$tab[3]="" unless $tab[3];
		$s{patname} = $tab[0];
		$s{family} = $tab[1];
		$s{father} = $tab[2];
		$s{mother} = $tab[3];
		$s{sex} = $tab[4] if defined $tab[4];
		$s{status} = $tab[5] if defined $tab[5];
		$s{bc} = $tab[6] if defined $tab[6];
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
#	warn Dumper $resp;
	print $cgi->header();
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub printJson2 {
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
	exit(0);
}





exit(0);

