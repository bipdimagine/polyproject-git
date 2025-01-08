#!/usr/bin/perl
########################################################################
########################################################################
use CGI qw/:standard :html3/;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../../polymorphism-cgi/packages/export";
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/packages"; 
use Time::Local;
use querySpring;
use connect;
use export_data;
#use GBuffer;
use Data::Dumper;

use JSON;

my $cgi    = new CGI;
#my $buffer = GBuffer->new;

my $login = $cgi->param('login');
my $pwd   = $cgi->param('pwd');
#my $team=6; #BIP-D
     

checkAuthentification($login,$pwd);

sub checkAuthentification {
        my ( $login, $pwd,$team ) = @_;
        my $res = querySpring::getAuthentificationForUser(get_dbh(),$login,$pwd,$team);
        my $items;
        $items->{name} = "BAD_LOGIN";
        $items->{name} = "OK" if $res>0;
      	export_data::print_simpleJson($cgi,[$items]);
        exit(0);
}

sub get_dbh {
 return connect::getdbh({user=>"polyweb",pw=>"mypolyweb",port=>3306,ip=>"10.200.27.108"});
}
exit(0);
