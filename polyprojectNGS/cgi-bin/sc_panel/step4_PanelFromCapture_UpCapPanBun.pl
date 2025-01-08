#!/usr/bin/perl
########################################################################
#./step4_PanelFromCapture_UpCapPanBun.pl
########################################################################
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);

use lib "$Bin/..";
use lib "$Bin/../GenBo";
use lib "$Bin/../GenBo/lib/GenBoDB";
use lib "$Bin/../GenBo/lib/obj-nodb";
use lib "$Bin/../GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/../GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/../packages"; 
use lib "$Bin/../../../polymorphism-cgi/packages/export";

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
print "step4_PanelFromCapture_UpCapPanBun.pl: update Capture analyse=validation, Panel & Bundle\n";
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

### Autocommit dbh ###########
my $dbh = $buffer->dbh;
$dbh->{AutoCommit} = 0;
#############################
#my @res_sorted=sort { $a->{capture_id} <=> $b->{capture_id}} @res;
my @res_sorted=sort { $a->{captureId} <=> $b->{captureId}} @res;
my $line=1;
foreach my $u (@res_sorted) {
	next if ($u->{capAnalyse} =~ m/(exome)|(genome)|(rnaseq)|(chipseq)/);
	my $res_pC=f_utils::searchIn_panelCapture($buffer,$u->{captureId},1);
	print "Panel: $res_pC->[0]->{panel_id}  ==> Cap: $u->{captureId}\n";
	my $pan_Validation;
	if ($res_pC->[0]->{panel_id}) {
		my $pan_res = queryPanel::getPanel($buffer->dbh,$res_pC->[0]->{panel_id});
		$pan_Validation=$pan_res->[0]->{validation_db};
	}
	my $capAnalyse=$u->{capAnalyse};
	$res_pC->[0]->{panel_id}+= 0;
	if ($u->{capAnalyse} =~ "target") { 
		print "MAJ Panel: $res_pC->[0]->{panel_id}  ==> Cap: $u->{captureId}\n";
#		warn $res_pC->[0]->{panel_id};
		queryPanel::upCaptureAnalyse($buffer->dbh,$u->{captureId},"target");
		f_utils::add_bundlepanelWithCapture($buffer,$u->{captureId},$res_pC->[0]->{panel_id});		
		$capAnalyse="target";
		
	};
	printf("%3d Capture: %35s # Analyse: %20s Validation: %20s\n",$line,$u->{capName},$capAnalyse,$pan_Validation);
	$line++;
	print "================> $line\n";
			
}
print "Print End Program\n";

#### End Autocommit dbh ###########
$dbh->commit();
=mod
=cut
exit(0);

