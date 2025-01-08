#!/usr/bin/perl
########################################################################
###### upload_file.pl
########################################################################
use FindBin qw($Bin);
use lib "$Bin/GenBo";
use lib "$Bin/GenBo/lib/GenBoDB";
use lib "$Bin/GenBo/lib/obj-nodb";
use lib "$Bin/GenBo/lib/GenBoDB/writeDB";
use lib "$Bin/GenBo/script/ngs_exome/last_script/packages";
use lib "$Bin/packages"; 
use Carp;
use strict;
use Data::Dumper;
#use GBuffer;
use Getopt::Long;
use util_file qw(readXmlVariations);
use File::Basename;
use File::Find::Rule;
use Logfile::Rotate; 
use File::Find::Rule;
use File::Glob qw(:globally :nocase);
use Time::Local;
use POSIX 'strftime';


#use GD;
use Getopt::Long;
#use Spreadsheet::WriteExcel;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );  
use connect;
use JSON;
use DBI;
use feature qw/switch/; 
#use Try::Tiny;
use Proc::Simple;

$| =1;

my $cgi = new CGI;
#my $buffer = GBuffer->new;
my $opt = $cgi->param('opt');
my $dlf="\t";

#my $publicdir = $buffer->config()->{public_data}->{root}."/";
#my $rootdir;
#$rootdir = "/poly-disk/poly-data/" if ($publicdir =~ m/(poly-disk)/);
my $rootdir = "/poly-disk/poly-data/" ;

#die unless $rootdir;

my $publicIndir = $rootdir."spring/inFILES/";
my $publicOutdir = $rootdir."spring/outFILES/";


if ( $opt eq "insert" ) {
	InsertSection();
} elsif ($opt eq "findFile") {
	findFileSection();
} elsif ($opt eq "listProject") {
	listProjectSection();
} elsif ($opt eq "findSpringFile") {
	findSpringFileSection();
} elsif ($opt eq "delProject") {
	delProjectSection();
}

sub InsertSection {
#	die;
	my $filename = $cgi->param("file_name");
	my $userdir = $cgi->param('param_user');
	my $out = $cgi->param("param_out");
	my $paramdir = $cgi->param("param_dir");
	my $paramfile = $cgi->param("param_file");
	
	my $force = $cgi->param("param_force");
#	my $source = $cgi->param("param_source");
	my $source = "$Bin/SPRING_dev";

	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	$name =~ s/\\/_/g;
	$filename = $name . $extension;
	$extension =~ s/\.//;
	my $upload_filehandle = $cgi->upload("file_name");
	my $Indir_user=$publicIndir.$userdir;
	makedir($Indir_user);
	system("chmod -R 777 $Indir_user");
	my $enddir=$paramdir;
	my ($name_i, $path_i, $extension_i) = fileparse( $Indir_user."/".$enddir."/".$filename, '\..*' );
	chop($path_i);
	makedir($path_i);
#	warn Dumper $source;
#	warn Dumper "$Indir_user/$enddir/$filename";
#	warn Dumper "$Bin/dos2unix";
	system("$source/dos2unix $Indir_user/$enddir/$filename");
#	system("$Bin/dos2unix $Indir_user/$enddir/$filename");
	system("chmod -R 777 $path_i");
	my $Outdir_user=$publicOutdir.$userdir;
	makedir($Outdir_user);
	system("chmod -R 777 $Outdir_user");
	my $outdir = $Outdir_user."/".$enddir."/";
	makedir($outdir);
	system("chmod -R 777 $outdir");

	#### $filename
	$filename=$out if $out;	
	my $file_out= $Indir_user."/".$enddir."/".$filename;
	if (-e $file_out && not $force) {
		sendFormError("<b>Error:</b>"."<BR>Click Before on Force to make a copy version file and replace it");
 		return;
 	}
	if (! $filename) {
		sendFormError("<b>Error:</b>"."<BR>No File selected");
 		return;
 	}
#	if ($paramfile eq "firstFile" && $extension_i ne ".mtx") {
	if ($paramfile eq "firstFile" && $extension_i !~ m/mtx/) {
		sendFormError("<b>Error:</b>$filename"."<BR>Matrix extension file must contain .mtx");
 		return;
 	}
	if ($paramfile eq "secondFile" && $extension_i !~ m/(csv)|(tsv)/) {
		sendFormError("<b>Error:</b> $filename"."<BR>Gene List extension file must be .csv or tsv");
 		return;
 	}
 	if ($paramfile eq "cellsFile" && $extension_i !~ m/(csv)|(tsv)/) {
		sendFormError("<b>Error:</b> $filename"."<BR>Cells Grouping List extension file must be .csv or tsv");
 		return;
 	}
 	if ($paramfile eq "genesetsFile" && $extension_i !~ m/(gmt)/) {
		sendFormError("<b>Error:</b> $filename"."<BR>Gene Sets extension file must be .gmt");
 		return;
 	}
 
 	if ($paramfile eq "cellsFile" && $extension_i !~ m/(csv)|(tsv)/) {
		sendFormError("<b>Error:</b> $filename"."<BR>Cells Grouping List extension file must be .csv or tsv");
 		return;
 	}
 	
 	#####################
	open( my $FHO, '>', $file_out ) or die("Can't create file: $file_out\n");
#	binmode $FHO;
	while (read ($upload_filehandle, my $Buffer,  -s $upload_filehandle)) {
		print $FHO $Buffer;
	}
		
	close $FHO;
	chmod(777,$FHO);	
	system("$source/dos2unix $file_out");
#	system("$Bin/dos2unix $file_out");
#	system("chmod -R 777 $path_i");
	if ($paramfile eq "genesetsFile" && $extension_i =~ m/(gmt)/) {
		format_genesetFile($Indir_user,$enddir,$filename);
		
	}
	
	system("chmod -R 777 $path_i");
	sendFormOK("OK:$filename is uploaded");
}

sub format_genesetFile {
	my ($Indir,$project,$filename) = @_;
	my $file_gmt=$filename;
	
	my $file_i=$Indir."/".$project."/".$file_gmt;
	my $file_o=$Indir."/".$project."/"."geneset_".$file_gmt;
	open( my $FH, '<', $file_i) or die("Can't read this file_i: $file_i\n");
	open( my $FHO, '>', $file_o ) or die("Can't create file: $file_o\n");
	while ( my $Line = <$FH> ) {
		my @data = split( /\s+/, $Line );
		my $name_set;
		for (my $i = 0; $i< scalar(@data); $i++) {
			$name_set=$data[$i] if $i==0;
			next if $i==0;
			next if $i==1;
			print $FHO $data[$i]."\t".$name_set."\n";
	
		}
	}
	close($FH);
	close($FHO);	
}


=mod
=cut

sub findFileSection {
	my $userdir = $cgi->param('param_user');
	my $paramdir = $cgi->param("param_dir");
	my $p_matrix = $cgi->param("param_matrix");
	my $p_genes = $cgi->param("param_genes");
	my $p_cells = $cgi->param("param_cells");	
	my $p_genesets = $cgi->param("param_genesets");	
	my $p_customcolor = $cgi->param("param_customcolor");	

#	my $rootdir = "/poly-disk/poly-data/";
#	my $publicdir = $rootdir."spring/inFILES/";
#	my $outdir = $rootdir."spring/outFILES/";
	my $Indir_user=$publicIndir.$userdir;
	my $Outdir_user=$publicOutdir.$userdir;
	my $f_matrix=findFile($Indir_user,$paramdir,$p_matrix);
	my $f_genes=findFile($Indir_user,$paramdir,$p_genes);
	my $f_cells=findFile($Indir_user,$paramdir,$p_cells);
	my $f_genesets=findFile($Indir_user,$paramdir,$p_genesets);
	my $f_customcolor=findFile($Indir_user,$paramdir,$p_customcolor);
	if ($f_cells) {
		my $type="cg";
		trace_option($Indir_user,$paramdir,$p_cells,$type);
	}
	if ($f_genesets) {
		my $type="gs";
		trace_option($Indir_user,$paramdir,$p_genesets,$type);
	}
	if ($f_customcolor) {		
		my $type="cc";
		trace_option($Indir_user,$paramdir,$p_customcolor,$type);
	}	
	#sendOK("OK: $Indir_user:$Outdir_user");
	my $ok_Indir_user="spring/inFILES/".$userdir;
	my $ok_Outdir_user="spring/outFILES/".$userdir;
#	warn Dumper $ok_Indir_user;
#	warn Dumper $ok_Outdir_user;
	sendOK("OK:$ok_Indir_user:$ok_Outdir_user"); 
}

sub findFile {
	my ($Dir,$projdir,$p_file) = @_;
	my @files;
	my @s_ext;
	@s_ext=qw/ p_file /;
	@files = File::Find::Rule->file()
                                  ->name( [  $p_file ])
                                  ->in( $Dir."/".$projdir."/" );
	my $filename="";
	$filename= getfileName($files[0]) if scalar @files;
	return $filename;
}

sub trace_option {
	my ($Indir,$p_project,$p_file,$type) = @_;
	my $depose_file=$Indir."/".$p_project."/".$p_file.".".$type;
 	system("touch $depose_file");	
}

sub delProjectSection {
	my $userdir = $cgi->param('param_user');
	my $project =  $cgi->param("name");

	my $Indir_user=$publicIndir.$userdir;
	my $Outdir_user=$publicOutdir.$userdir;
	
	my $spring_idir= $Indir_user."/".$project;
	my $spring_odir= $Outdir_user."/".$project;
	if (! -e $spring_odir) {

 		sendError("<b>Error:</b>"."<BR>Project $project not found in outdir for User $userdir");
 	}
	if (! -e $spring_idir) {
 		sendError("<b>Error:</b>"."<BR>Project $project not found in indir for User $userdir");
 	}
 	system("rm -rf $spring_odir");
 	system("rm -rf $spring_idir");
	sendOK("OK:Project $project deleted for User $userdir");				
}

sub findSpringFileSection {
	my $userdir = $cgi->param('param_user');
	my $project =  $cgi->param("name");

	my $Outdir_user=$publicOutdir.$userdir;
	my $springdir= $Outdir_user."/".$project;
	my @files_hdf5;
	my @sp_hdf5;
	@sp_hdf5=qw/ *.hdf5 /;
	@files_hdf5 = File::Find::Rule->file()
                                  ->name( [  @sp_hdf5 ])
                                  ->in( $springdir."/" );
	
	my @files_json;
	my @sp_json;
	@sp_json=qw/ *.json /;
	@files_json = File::Find::Rule->file()
                                  ->name( [  @sp_json ])
                                  ->in( $springdir."/" );
	my $ok=1;
	$ok=0 if scalar @files_hdf5 < 2;
	$ok=1 if scalar @files_json < 4;
	sendOK("OK") if $ok; 
	sendError("Error: Spring out parameters files not found for project name: $project") unless $ok;
}

sub listProjectSection {	
	my $userdir = $cgi->param('param_user');
	my $springdir= $publicOutdir."/".$userdir."/";
	my @project_dirs;
	@project_dirs = File::Find::Rule->directory
									->maxdepth( 1 )
									->in( $springdir);
#	sendError("Error User: Reload Spring Utility please ...") unless $userdir; 
#	warn "listProjectSection";
	my @data;
	my %hdata;
	$hdata{identifier}="id";
	$hdata{label}="name";
	my $ind=1;
	for (my $i = 0; $i< scalar(@project_dirs); $i++) {
		next unless $userdir;
		next unless $i;
		my %s;
		$s{name} = (split '\/', $project_dirs[$i])[-1];
		my $f_cg=findFile($publicIndir.$userdir."/",$s{name},"*.cg");
		my $f_gs=findFile($publicIndir.$userdir."/",$s{name},"*.gs");
		my $f_cc=findFile($publicIndir.$userdir."/",$s{name},"*.cc");
		my $f_o=findFile($publicOutdir.$userdir."/".$s{name}."/",$s{name},"*.json");
		my $o_dir=$publicOutdir.$userdir."/".$s{name};

		my $datedir_o=(stat($o_dir))[9];
		my $date_f=strftime "%Y-%m-%d %H:%M:%S", localtime($datedir_o);
		my @datec = split(/ /,$date_f);
		my ($YY, $MM, $DD) = split("-", $datec[0]);
		my $mydate = sprintf("%02d/%02d/%4d",$DD, $MM, $YY);
		$s{cDate} = $mydate;
		
		$s{out} = 0;
		$s{out} = 1 if $f_o;
		$s{cg} = 0;
		$s{cg} = 1 if $f_cg;
		$s{gs} = 0;
		$s{gs} = 1 if $f_gs;
		$s{cc} = 0;
		$s{cc} = 1 if $f_cc;
		
		$s{id} = $ind;
		$ind++;
		push(@data,\%s);
	}	
#	$hdata{items}=\@data;
#	my @result_sorted=sort { $a->{cDate} cmp $b->{cDate} } @data;
	my @result_sorted=sort { join('', (split '/', $b->{cDate})[2,1,0]) cmp join('', (split '/', $a->{cDate})[2,1,0]) } @data;
	$hdata{items}=\@result_sorted;
	printJson(\%hdata);		
}
=mod
@dates = sort { join('', (split '/', $a)[2,1,0]) cmp join('', (split '/', $b)[2,1,0]) } @dates;
=cut
sub getfileName {
	my ($filename) = @_;
	my ( $name, $path, $extension ) = fileparse( $filename, '\..*' );
	return $name.$extension	
}

sub logrotate_File {
	my ($sub,$dir_backup) = @_;
	my $file_out = $dir_backup.'/'.$sub;
	if (-e $file_out) {
		my $merge_rotate = new Logfile::Rotate (
				File  => $file_out,
				Count => 5,
				Dir	  => $dir_backup,
				Gzip  => 'no',
				 );		
		$merge_rotate->rotate();
		run("rm -rf $file_out");
	}
}

sub rm_file {
	my ($file_out,$FHO,$directory) = @_;
	unlink $file_out;
	close($FHO);
	check_rmdir($directory);
}

sub run {
	my ($cmd) = @_;
	my $return = system($cmd);
	if ($return ne 0){
		confess("error : $cmd");
	}
}

sub check_rmdir {
	my ($dir) = @_;
	opendir(DIR,$dir) or die "$!";
	# need twice readdir
	readdir DIR; # reads .
	readdir DIR; # reads ..
	rmdir $dir unless (readdir DIR);
	close DIR;
}

sub makedir {
	my ($dir) = @_;
	if (!(-d $dir)){
		mkdir ($dir,0755);
	}
	return $dir;	
} 

sub sendFormOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendFormError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/html');
	print qq{<textarea>};
	print to_json($resp);
	print qq{</textarea>};
	exit(0);
}

sub sendOK {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "OK";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}

sub sendError {
	my ($text) = @_;
	my $resp;
	$resp->{status}  = "Error";
	$resp->{message} = $text;
	print $cgi->header('text/json-comment-filtered');
	print encode_json $resp;
	print "\n";
	exit(0);
}



sub printJson {
        my ($data)= @_;
                print $cgi->header('text/json-comment-filtered');
                print encode_json $data;
        exit(0)
}

exit(0);

