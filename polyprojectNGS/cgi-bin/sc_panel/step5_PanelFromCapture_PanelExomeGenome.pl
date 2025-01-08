#!/usr/bin/perl
########################################################################
#./step5_PanelFromCapture_PanelExomeGenome.pl
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
print "step5_PanelFromCapture_PanelExomeGenome.pl: update Capture analyse=validation, Panel & Bundle\n";
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
	next if ($u->{capAnalyse} =~ m/(target)|(rnaseq)|(chipseq)/);
	print "Capture : $u->{captureId}  $u->{capName} ==> Cap: $u->{capAnalyse}\n";
	my $res_cB=f_utils::searchIn_captureBundle($buffer,$u->{captureId},1);
	if ($res_cB->[0]->{capture_id}) {
		my $name_validation=$u->{capName};
		$name_validation=~ s/[_-]//g;
		print "==========A======> Create Panel: $u->{capName} Schemas: validation_$name_validation Panel_CaptureId: $u->{captureId}\n";
		my @validationList = queryPanel::getSchemasValidation($buffer->dbh,"validation_".$name_validation);
		my @val_name;
		foreach my $r (@validationList) {
			my %s;
			next unless scalar @$r;
			push(@val_name,values %{$r->[0]}) if values %{$r->[0]} ne "";
		}
		f_utils::createValidationDB($buffer,"validation_".$name_validation) unless scalar @val_name;
		my $panelId=f_utils::new_panel($buffer,$u->{capName},$name_validation);
		if (defined $panelId ) {		
			queryPanel::addPanel2Capture($buffer->dbh,$panelId,$u->{captureId});
			f_utils::add_bundlepanelWithCapture($buffer,$u->{captureId},$panelId);
		}		
	}
}
print "Print End Program\n";

#### End Autocommit dbh ###########
$dbh->commit();

sub addremPanel_forFilteringAnalyseCapture {
	my ($buffer,$panelId,$mode) = @_;
	my $captureList= queryPolyproject::getCaptureId($buffer->dbh);
	foreach my $c (@$captureList){
		next unless ($c->{capAnalyse} =~ m/(exome)|(genome)/);
		if ($mode eq "add") {
			queryPanel::addPanel2Capture($buffer->dbh,$panelId,$c->{captureId});				
		} elsif ($mode eq "rem") {
			queryPanel::removePanel2Capture($buffer->dbh,$panelId,$c->{captureId});				
		}
	}
}

=mod
=cut

exit(0);

