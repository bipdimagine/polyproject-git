#!/usr/bin/perl
########################################################################
use strict;
use CGI qw/:standard :html3/;
use Spreadsheet::WriteExcel;

my $cgi = new CGI();
my $exp = $cgi->param('my_input');
my $fcid = $cgi->param('my_fcid');
my $time=time();
#my $name = "SampleSheet_" . $_POST['name']."_".$time;
my $name = "SampleSheet_".$fcid."_".$time;
print "Content-type: application/ms-excel;charset=utf-8\n";
print "Content-Disposition: attachment; filename=$name.csv\n\n";
binmode(STDOUT);
print "$exp";
exit;

