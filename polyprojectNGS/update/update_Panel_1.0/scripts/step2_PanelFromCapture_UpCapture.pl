#!/usr/bin/perl
########################################################################
#./step2_PanelFromCapture_UpCapture.pl
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
use queryValidationDB;
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

my $query = qq{
	select  C.capture_id as captureId,C.name as capName,
	C.version as capVs, C.description as capDes,
	C.filename as capFile, C.type as capType,
	C.analyse as capAnalyse,
	C.method as capMeth,
	C.primers_filename as capFilePrimers
	from PolyprojectNGS.capture_systems C
	;
};
my @res;
my $sth = $buffer->dbh->prepare($query) || die();
$sth->execute();
while (my $id = $sth->fetchrow_hashref ) {
	push(@res,$id);
}

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
#my @res_sorted=sort { $a->{capture_id} <=> $b->{capture_id}} @res;
my @res_sorted=sort { $a->{captureId} <=> $b->{captureId}} @res;

print "=============================================================================\n";
print "step2_PanelFromCapture_UpCapture.pl: update Capture analyse=target:validation\n";
print "except Analyse in exome, genome, rnaseq, chipseq\n";
print "=============================================================================\n";


foreach my $u (@res_sorted) {
	next if ($u->{capAnalyse} =~ m/(exome)|(genome)|(rnaseq)|(chipseq)/);
	my $booltarget=1;
	$booltarget=0 if ($u->{capAnalyse} =~ "target:");
	queryPanel::upCaptureAnalyse($buffer->dbh,$u->{captureId},"target:".$u->{capAnalyse}) if $booltarget;
	my $res_pC=f_utils::searchIn_panelCapture($buffer,$u->{captureId},1);
	my $pan_Validation;
	if ($res_pC->[0]->{panel_id}) {
		my $pan_res = queryPanel::getPanel($buffer->dbh,$res_pC->[0]->{panel_id});
		$pan_Validation=$pan_res->[0]->{validation_db};
	}
	my $capAnalyse=$u->{capAnalyse};
	$capAnalyse="target:".$u->{capAnalyse} if $booltarget;
}

=mod
=cut
#### End Autocommit dbh ###########
$dbh->commit();
print "Print End Program\n";

exit(0);

