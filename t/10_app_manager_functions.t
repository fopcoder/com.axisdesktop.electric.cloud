use strict;

use FindBin;
use Test::More tests => 11;
use App::Config;

use App::Manager qw/is_local_url copy_remote is_exist_remote del_remote is_up/;

my $f = sprintf( '%s/%s', $FindBin::Bin, '/res/am_remote_config.ini' );
my $c = App::Config->new->config( $f );

# is_local_url

ok( is_local_url( '/data/file' ) == 1, 'local url test' );
ok( is_local_url( 'data/file' ) == 1, 'local url test' );
ok( is_local_url( 'http://data/file' ) == 0, 'local url test' );
ok( is_local_url( 'https://data/file' ) == 0, 'local url test' );
ok( is_local_url( 'scp://data/file' ) == 0, 'local url test' );

# copy_remote

ok( copy_remote( $c->app_file, $c->deploy_url, $c->deploy_user, $c->deploy_password ) == 1, 'copy remote' );

# is_exist_remote

ok( is_exist_remote( $c->app_file, $c->deploy_url, $c->deploy_user, $c->deploy_password ) == 1, 'is exist remote' );

# del_remote

ok( del_remote( $c->app_file, $c->deploy_url, $c->deploy_user, $c->deploy_password ) == 1, 'del remote' );
ok( is_exist_remote( $c->app_file, $c->deploy_url, $c->deploy_user, $c->deploy_password ) == 0, 'not exist remote' );

# is_up

ok( is_up( 'https://google.com' ) == 1, 'is up' );
ok( is_up( 'https://kokoko.ko' ) == 0, 'is up' );

