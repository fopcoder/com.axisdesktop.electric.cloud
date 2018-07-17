#!/usr/bin/perl

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long;
use Data::Dumper;

use App::Config;
use App::Manager::Tomcat;

my %h = ();

GetOptions( \%h,
	'action=s',
	'config=s',
	'deploy-url=s',
	'deploy-user=s',
	'deploy-password=s',
	'app-url=s',
	'app-file=s',
	'app-server-user=s',
	'app-server-password=s',
) or die 'bad params';

die '--action undefined' unless( $h{action} );

my $cfg = App::Config->new( \%h );
my $mng = App::Manager::Tomcat->new( $cfg );

if( $h{action} eq 'deploy' )	{
	$mng->deploy() && warn 'deploy ok';	
}
elsif( $h{action} eq 'status' )	{
	warn $mng->status();
}
elsif( $h{action} eq 'start' )	{
	$mng->start() && warn 'start ok';
}
elsif( $h{action} eq 'stop' )	{
	$mng->stop() && warn 'stop ok';
}
elsif( $h{action} eq 'undeploy' )	{
	$mng->undeploy() && warn 'undepoloy ok';
}
else	{
	die sprintf( '--action %s undefined', $h{action} );
}
