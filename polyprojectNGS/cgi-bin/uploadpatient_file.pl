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
    # Dictionnaire de correspondance (Mapping) entre le fichier et vos clés JSON
    my %header_mapping = (
        'Patient' => 'patname',
        'Family'  => 'family',
        'Father'  => 'father',
       	'Mother'  => 'mother',
        'Sex'     => 'sex',
        'Status'  => 'status',
        'Group'   => 'group',
        'BC'      => 'bc',
        'BC2'     => 'bc2',
        'IV'      => 'iv',
        'Person'  => 'person',
        'Lane'    => 'lane',
        'Reads'   => 'reads',
    );
    
    # 1. On extrait et nettoie l'en-tête d'origine
    my $header_line = shift @$data; 
    return printJson(\%hdata) unless $header_line;
    
    my @headers = split(/\t/, $header_line);
    s/^\s+|\s+$//g for @headers;

    #On garde les noms réels pour headers---
    $hdata{headers} = \@headers; # Contient maintenant: ["Patient", "Family", "Sex", ...]    
    # On crée un tableau parallèle pour nos clés JSON internes
    my @json_keys;
    foreach my $column_name (@headers) {
        my $json_key = $header_mapping{$column_name} || lc($column_name);
        push(@json_keys, $json_key);
    }
    # 2. On parcourt les lignes de données
    foreach my $Line (@$data) {
        next if $Line =~ /^\s*$/;       
        my @tab = split(/\t/, $Line);
        s/^\s+|\s+$//g for @tab;        
        my %s;
        # On utilise @json_keys pour remplir le hash de données du patient
        for (my $i = 0; $i < @json_keys; $i++) {
            my $json_key = $json_keys[$i];
            $s{$json_key} = $tab[$i] // ""; 
        }        
        push(@mydata, \%s);
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

