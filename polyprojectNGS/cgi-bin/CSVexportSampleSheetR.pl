#!/usr/bin/perl
########################################################################
use strict;
use CGI qw/:standard :html3/;
#use TEXT::CSV;

my $cgi = new CGI();
my $exp = $cgi->param('my_input');
my $fcid = $cgi->param('my_fcid');
my $header = $cgi->param('my_header');
my $time=time();
#my $header ="[Data]"."\r\n";
my $name = "SampleSheet_".$fcid."_".$time;
print "Content-type:text/csv;charset=utf-8\n";
print "Content-Disposition: attachment; filename=$name.csv\n\n";
binmode(STDOUT);
print "$header";
print "$exp";
exit;

