package App::Manager;

use strict;
use Exporter qw/import/;

use Net::SFTP::Foreign;
use LWP::UserAgent;

our @EXPORT_OK = qw/is_local_url copy_remote is_exist_remote is_up del_remote/;


sub new	{
	my $class = shift;
	my $cfg = shift;
	my $opt = shift || {};
	
	my $self = { cfg => $cfg };
	
	bless $self, $class;
	$self->_init( $opt );	
	
	return $self;
}

sub cfg	{
	my $self = shift;
	return $self->{cfg};
}

# simply test remote or local

sub is_local_url	{
	my $url = shift;
	
	if( $url !~ m#\w+://# )	{
		return 1;
	}
	
	return undef;
}

sub copy_remote	{
	my $app = shift or return;
	my $dst = shift or return;
	my $login = shift or return;
	my $passwd = shift or return;
	
	$app =~ /\/?([^\/]*)$/;
	my $app_name = $1;
	
	$dst =~ s#.+://##;
	my @arr = split( '/', $dst, 2 );
	die 'bad url' if( @arr == 1 );
	$arr[1] = sprintf( '/%s/%s', $arr[1], $app_name );
	
	my $ch = Net::SFTP::Foreign->new( host => $arr[0], user => $login, password => $passwd );
	$ch->die_on_error( 'Unable to establish SFTP connection', $ch->error );
	
	$ch->put( $app, $arr[1] ) or die "put failed: " . $ch->error;
	
	return 1;
}

sub is_exist_remote	{
	my $app = shift or return;
	my $dst = shift or return;
	my $login = shift or return;
	my $passwd = shift or return;
	
	$app =~ /\/([^\/]*)$/;
	my $app_name = $1;
	
	$dst =~ s#.+://##;
	my @arr = split( '/', $dst, 2 );
	die 'bad url' if( @arr == 1 );
	$arr[1] = sprintf( '/%s/%s', $arr[1], $app_name );
	
	my $ch = Net::SFTP::Foreign->new( host => $arr[0], user => $login, password => $passwd );
	$ch->die_on_error( 'Unable to establish SFTP connection', $ch->error );
	
	return $ch->test_e( $arr[1] );
}

sub is_up	{
	my $url = shift;
	
	my $ua = LWP::UserAgent->new();
	my $res = $ua->head( $url );
	
	if( $res->is_success && $res->code == 200 )	{
		return 1;
	}
	
	warn $res->status_line;
	
	return undef;
}

sub del_remote	{
	my $app = shift or return;
	my $dst = shift or return;
	my $login = shift or return;
	my $passwd = shift or return;
	
	$app =~ /\/?([^\/]*)$/;
	my $app_name = $1;
	
	$dst =~ s#.+://##;
	my @arr = split( '/', $dst, 2 );
	die 'bad url' if( @arr == 1 );
	$arr[1] = sprintf( '/%s/%s', $arr[1], $app_name );
	
	my $ch = Net::SFTP::Foreign->new( host => $arr[0], user => $login, password => $passwd );
	$ch->die_on_error( 'Unable to establish SFTP connection', $ch->error );
	
	$ch->remove( $arr[1] ) or die "remove failed: " . $ch->error;
	
	return 1;
}


# abstract methods

sub _init	{
	die "init unimplemented";
}

sub deploy	{
	die "abstract method";
}

sub undaploy	{
	die "abstract method";
}

sub start	{
	die "abstract method";
}

sub stop	{
	die "abstract method";
}

sub status	{
	die "abstract method";
}



1;