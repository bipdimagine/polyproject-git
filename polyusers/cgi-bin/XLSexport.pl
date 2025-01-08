#!/usr/bin/perl
########################################################################
use strict;
use CGI qw/:standard :html3/;
use Spreadsheet::WriteExcel;

my $cgi = new CGI();
my $exp = $cgi->param('my_input');
my $time=time();
print "Content-type: application/ms-excel;charset=utf-8\n";
##print "Content-type: application/vnd.ms-excel;charset=utf-16;";
print "Content-Disposition: attachment; filename=gridXLS_$time.csv\n\n";
#print "Pragma: no-cache";
#print "Expire: 0";
binmode(STDOUT);
print "$exp";
exit;
