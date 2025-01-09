package f_utils;

use strict;
use Data::Dumper;
use JSON;


use GBuffer;

use queryPolyproject;
use queryValidationDB;
use queryPanel;
use Carp;
use JSON;
use Getopt::Long;



#Schemas_Validation
sub createValidationDB {
	my ($buffer,$name_DB) = @_;
	queryValidationDB::createSchemasValidation($buffer->dbh,$name_DB) or 
	die "SchemasValidation not created";
	queryValidationDB::createExonValidation($buffer->dbh,$name_DB) or 
	die "ExonValidation not created";         
}

#Capture
sub searchIn_capture {
	my ($buffer,$capId) = @_;
	my $c_List = queryPanel::getCaptureId($buffer->dbh,$capId);
	return $c_List;
}

#CaptureBundle
sub searchIn_captureBundle {
	my ($buffer,$val,$valB) = @_;
	my $cB_List=queryPanel::searchCaptureBundle($buffer->dbh,$val,$valB);
	return $cB_List;
}

#Panel
# A revoir:Utiliser Upperfirst ????? panName
sub new_panel {
	my ($buffer,$capAnalyse,$event_panName) = @_;
	my $panelId;
	my $panName=ucfirst($capAnalyse);
#	my $panName="Panel_".$capAnalyse;
	my $ctrlpanid = queryPanel::getPanelIdFromName($buffer->dbh,$panName);
	if (defined $ctrlpanid->{panel_id}) {
		$panName=ucfirst($capAnalyse)."_V2";
	}
	my $panValidation;
	$panValidation=$event_panName if $event_panName;
	$panValidation=$capAnalyse unless $event_panName;
	my $last_panid = queryPanel::newPanel($buffer->dbh,$panName,$panValidation);
	if (defined $last_panid ) {
		$panelId=$last_panid->{'LAST_INSERT_ID()'};
	}
	return $panelId;		
}

sub new_panelOld {
	my ($buffer,$capAnalyse) = @_;
	my $panelId;
	my $panName="Panel_".$capAnalyse;
	my $ctrlpanid = queryPanel::getPanelIdFromName($buffer->dbh,$panName);
	if (defined $ctrlpanid->{panel_id}) {
		$panName="PaneL_".$capAnalyse;
	}
	my $panValidation=$capAnalyse;
	my $last_panid = queryPanel::newPanel($buffer->dbh,$panName,$panValidation);
	if (defined $last_panid ) {
		$panelId=$last_panid->{'LAST_INSERT_ID()'};
	}
	return $panelId;		
}

#Bundle
sub searchBundleInfo_fromBundlePanel {
	my ($buffer,$BP,$field) = @_;
	my $listBun;
	my %seen=();
	foreach my $b (@$BP){
		my $bu = queryPanel::getBundle($buffer->dbh,$b->{bundle_id});
		$listBun.=$bu->{$field}." " unless $seen{$bu->{$field}}++;
	}
	chop($listBun);
	return $listBun;
}

#PanelCapture
sub searchIn_panelCapture {
	my ($buffer,$valA,$valB) = @_;
	my $pC_List=queryPanel::searchPanelCapture($buffer->dbh,$valA,$valB);
	return $pC_List;
}

#BundlePanel
sub searchIn_bundlePanel {
	my ($buffer,$valId,$valB) = @_;
	my $bP_List=queryPanel::searchBundlePanel($buffer->dbh,$valId,$valB);
	return $bP_List;
}

sub add_bundlepanelWithCapture {
	my ($buffer,$captureId,$panelId) = @_;
	my $val=$captureId;my $valB=1;
	my $resCB=queryPanel::searchCaptureBundle($buffer->dbh,$val,$valB);
	foreach my $b (@$resCB) {	
#		print "addBundlePanel:Bun: $b->{bundle_id} Pan: $panelId\n";		
		queryPanel::addBundlePanel($buffer->dbh,$b->{bundle_id}, $panelId);
	}
}


1;
