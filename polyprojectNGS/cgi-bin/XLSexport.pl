#!/usr/bin/perl
########################################################################
use strict;
use FindBin qw($Bin);
use CGI qw/:standard :html3/;
use Spreadsheet::WriteExcel;

my $cgi = new CGI();
#my $exp = $cgi->param('valfile');
my $exp = $cgi->param('my_input');
#my $exp
my $time=time();
print "Content-type: application/ms-excel;charset=utf-8\n";
print "Content-Disposition: attachment; filename=gridXLS_$time.csv\n\n";
binmode(STDOUT);
print "$exp";
exit;
