use strict;

use FindBin;
use Test::More tests => 8;
use App::Config;
use App::Manager::Tomcat;

my $f = sprintf( '%s/%s', $FindBin::Bin, '/res/tc_remote_config.ini' );
my $c = App::Config->new->config( $f );

my $tc = App::Manager::Tomcat->new( $c );

ok( $tc->deploy() == 1, 'deploy' );
diag( 'wait 6 sec' );
sleep( 6 );
ok( $tc->status() == 2, 'status: exists and up' );

ok( $tc->stop() == 1, 'stop' );
diag( 'wait 5 sec' );
sleep( 5 );
ok( $tc->status() == 1, 'status: exists' );

ok( $tc->start() == 1, 'start' );
diag( 'wait 5 sec' );
sleep( 5 );
ok( $tc->status() == 2, 'status: exists and up' );

ok( $tc->undeploy() == 1, 'undeploy' );
diag( 'wait 5 sec' );
sleep( 5 );
ok( $tc->status() == 0, 'status: removed' );


