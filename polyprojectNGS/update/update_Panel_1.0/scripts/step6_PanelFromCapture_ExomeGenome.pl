#!/usr/bin/perl
########################################################################
#./step6_PanelFromCapture_ExomeGenome.pl
########################################################################
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);

use lib "$Bin/../../../..";
use lib "$Bin/../../../../GenBo";
use lib "$Bin/../../../../GenBo/lib/GenBoDB";
use lib "$Bin/../../../../GenBo/lib/obj-nodb";
use lib "$Bin/../../../../GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/../../../../packages"; 
use lib "$Bin/../../../cgi-bin";
use lib "$Bin/../../../../polymorphism-cgi/packages/export";

use util_file qw(readXmlVariations);
use insert;
use Time::Local;
use List::MoreUtils qw/ uniq /;
use File::Basename;
use File::Find::Rule;

use GBuffer;
use connect;
use queryPolyproject;
use queryPanel;
use f_utils;
use Data::Dumper;
use Carp;
use JSON;
use export_data;
use Getopt::Long;
#use warnings;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

print "======================================================================================\n";
print "step6_PanelFromCapture_ExomeGenome.pl: update Capture analyse=validation, Panel & Bundle\n";
print "except Analyse in exome, genome, rnaseq, chipseq\n";
print "======================================================================================\n";

my $query = qq{
			select  C.capture_id as captureId,C.name as capName,
			C.version as capVs, C.description as capDes,
			C.filename as capFile, C.type as capType,
			C.analyse as capAnalyse,
			C.method as capMeth,
			C.primers_filename as capFilePrimers
			from PolyprojectNGS.capture_systems C
};
my @res;
my $sth = $buffer->dbh->prepare($query) || die();
$sth->execute();
while (my $id = $sth->fetchrow_hashref ) {
	push(@res,$id);
}
=mod
=cut


### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
#my @res_sorted=sort { $a->{capture_id} <=> $b->{capture_id}} @res;
my @res_sorted=sort { $a->{captureId} <=> $b->{captureId}} @res;
my $line=1;
foreach my $u (@res_sorted) {
	next if ($u->{capAnalyse} =~ m/(target)|(rnaseq)|(chipseq)/);

	print "Capture : $u->{captureId}  $u->{capName} ==> Cap: $u->{capAnalyse}\n";
	
	my $CapPan = queryPanel::getPanelsfromCapture($buffer->dbh);
	my %seenP;
	foreach my $c (sort {$a->{panId} <=> $b->{panId}}@$CapPan){
		next if exists $seenP{$c->{panId}};
		$seenP{$c->{panId}}++;
		queryPanel::addPanel2Capture($buffer->dbh,$c->{panId},$u->{captureId});
	}
			
}
print "Print End Program\n";

#### End Autocommit dbh ###########
$dbh->commit();

exit(0);

