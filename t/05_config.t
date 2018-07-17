use strict;

use FindBin;
use Test::Simple tests => 15;
use Test::Exception;
use App::Config;

my $f = sprintf( '%s/%s', $FindBin::Bin, '/res/base_config.ini' );
my $c = App::Config->new->config( $f );

ok( $c->deploy_user eq 'test_login', 'deploy_user config' );
ok( $c->deploy_password eq 'test_password', 'deploy_password config' );
ok( $c->deploy_url eq 'test_deploy_url', 'deploy-url config' );

ok( $c->app_url eq 'test_app_url', 'app-url config' );
ok( $c->app_file eq 'sample.war', 'app-file config' );
ok( $c->app_server_user eq 'server_user', 'app-server-user config' );
ok( $c->app_server_password eq 'server_password', 'app-server-password config' );

dies_ok( sub{ $c->somefunc }, 'die if accessor does not exist' );

$c	->deploy_user( 'new_login' )
	->deploy_password( 'new_password' )
	->deploy_url( 'new_deploy_url' )
	
	->app_url( 'new_app_url' )
	->app_file( 'hello.war' )
	->app_server_user( 'new_server_user' )
	->app_server_password( 'new_server_password' )
;

ok( $c->deploy_user eq 'new_login', 'set new deploy user' );
ok( $c->deploy_password eq 'new_password', 'set new password' );
ok( $c->deploy_url eq 'new_deploy_url', 'set new deploy-url' );

ok( $c->app_url eq 'new_app_url', 'set new app-url' );
ok( $c->app_file eq 'hello.war', 'set new app-file' );
ok( $c->app_server_user eq 'new_server_user', 'set new app-server-user' );
ok( $c->app_server_password eq 'new_server_password', 'set new app-server-password' );


