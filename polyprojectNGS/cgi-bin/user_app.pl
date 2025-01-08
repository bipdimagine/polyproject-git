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
use queryPolyproject;
use connect;
use export_data;
use GBuffer;
use Data::Dumper;

use JSON;

my $cgi    = new CGI;
my $buffer = GBuffer->new;

my $login = $cgi->param('login');
my $pwd   = $cgi->param('pwd');
my $team=6; #BIP-D
     

checkAuthentification($buffer,$login,$pwd,$team);

sub checkAuthentification {
        my ( $buffer, $login, $pwd,$team ) = @_;
        my $res = queryPolyproject::getAuthentificationForUser($buffer->dbh,$login,$pwd,$team);
        my $items;
        $items->{name} = "BAD_LOGIN";
        $items->{name} = "OK" if $res>0;
      	export_data::print_simpleJson($cgi,[$items]);
        exit(0);
}

exit(0);
