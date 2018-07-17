package App::Config;

use strict;
use vars qw/$AUTOLOAD/;
use Cwd qw/getcwd/;
use Config::IniFiles;

our $DEFAULT = {
	'config' => 'config.ini',
	'app-file' => '',
	'app-server-user' => '',
	'app-server-password' => '',
	'app-url' => '',
	'deploy-url' => '',
	'deploy-user' => '',
	'deploy-password' => '',
};

sub new	{
	my $class = shift;
	my $opt = shift || {};
	
	my $self = {};
	bless $self, $class;
	
	# config at first
	$self->config( $opt->{config} ) if $opt->{config};
	
	# command line params override config params
	foreach my $k ( keys %$opt )	{
		next if( $k eq 'config' );
		
		if( defined $DEFAULT->{ $k } )	{
			$self->$k( $opt->{ $k } );	
		}
	}
	
	return $self;
}

sub AUTOLOAD	{
	my $self = shift;
	
	my $func = $AUTOLOAD;
	$func =~ s/.*:://;
	$func =~ s/_/-/g;
	
	if( defined $DEFAULT->{ $func } )	{
		return @_ ? $self->_set( $func, @_ ) : $self->_get( $func );
	}
	else	{
		die sprintf( 'function %s undefined', $func );
	}
}

sub _set	{
	my $self = shift;
	my $name = shift or return;
	my $val = shift;
	
	$self->{ $name } = $val;
	
	return $self;
}

sub _get	{
	my $self = shift;
	my $name = shift or return;
	
	return $self->{ $name };
}

sub config	{
	my $self = shift;
	my $file = shift or return;
	
	unless( $file =~ m#^/# )	{
		$file = sprintf( '%s/%s', getcwd(), $file );
	}
	
	return unless( -e $file );
	
	warn sprintf( 'using config file: %s', $file );
	
	my $cfg = Config::IniFiles->new( -file => $file, -fallback => 'default' );

	foreach my $k ( keys %$DEFAULT )	{
		next if( $k eq 'config' );
		
		my $v = $cfg->val( 'default', $k ) || '';
		$k =~ s/-/_/g;
		$self->$k( $v );
	}

	return $self;
}


sub DESTROY	{}


1;