package App::Manager::Tomcat;

use strict;
use parent 'App::Manager';
use App::Manager qw/is_local_url copy_remote del_remote is_exist_remote is_up/;
use Try::Tiny;
use Cwd qw/getcwd/;
use File::Copy;
use LWP::UserAgent;
use HTTP::Request::Common;

sub _init	{
	my $self = shift;
}

sub deploy	{
	my $self = shift;
	
	my $res = try	{
		my $app = $self->cfg->app_file;
		my $du = $self->cfg->deploy_url;
		
		die 'app-file undefined' unless( $app );
		die 'deploy-url undefined' unless( $du );

		# make abs path
		unless( $app =~ m#^/# )	{
			$app = sprintf( '%s/%s', getcwd(), $app )
		}
		
		die 'app-file does not exist' unless( -e $app );
		
		if( is_local_url( $self->cfg->deploy_url ) )	{
			# make abs path
			unless( $du =~ m#^/# )	{
				$du = sprintf( '%s/%s', getcwd(), $du );
			}
			
			die sprintf( 'deploy-url does not exist: %s', $du ) unless( -e $du );
			
			copy( $app, $du ) or die "deploy failed: $!";
		}
		else	{
			my $user = $self->cfg->deploy_user;
			my $passwd = $self->cfg->deploy_password;
			
			die 'user undefined' unless( $user );
			die 'password undefined' unless( $passwd );
			
			copy_remote( $app, $du, $user, $passwd ) or die "deploy failed: $!";
		}
		
		return 1;
	}
	catch	{
		warn $_;
		return undef;
	};
	
	return $res;
}

sub start	{
	my $self = shift;
	
	my $app_file = $self->cfg->app_file;
	my $app_url = $self->cfg->app_url;
	my $user = $self->cfg->app_server_user;
	my $passwd = $self->cfg->app_server_password;
	
	die 'app-file undefined' unless( $app_file );
	die 'app-url undefined' unless( $app_url );
	die 'app-server-user undefined' unless( $user );
	die 'app-server-password undefined' unless( $passwd );

	# get context name
	$app_file =~ s#.*/##;
	$app_file =~ s#\..*$##;
	
	# get manage url
	$app_url =~ s#$app_file.*##;
	$app_url = sprintf( '%s/manager/text/start?path=/%s', $app_url, $app_file );
 
	my $ua = LWP::UserAgent->new();
	my $request = GET $app_url;
	$request->authorization_basic( $user, $passwd );
	 
	my $res = $ua->request( $request );
	
	if( $res->is_success )	{
		my $c = $res->decoded_content;
		
		if( $c =~ /OK/ )	{
			return 1;
		}
		else	{
			warn $c;
		}
	}
	else	{
		warn sprintf( '%s : %s', $res->status_line, $app_url );
	}
	
	return undef;
}

sub stop	{
	my $self = shift;
	
	my $app_file = $self->cfg->app_file;
	my $app_url = $self->cfg->app_url;
	my $user = $self->cfg->app_server_user;
	my $passwd = $self->cfg->app_server_password;
	
	die 'app-file undefined' unless( $app_file );
	die 'app-url undefined' unless( $app_url );
	die 'app-server-user undefined' unless( $user );
	die 'app-server-password undefined' unless( $passwd );

	# get context name
	$app_file =~ s#.*/##;
	$app_file =~ s#\..*$##;
	
	# get manage url
	$app_url =~ s#$app_file.*##;
	$app_url = sprintf( '%s/manager/text/stop?path=/%s', $app_url, $app_file );
 
	my $ua = LWP::UserAgent->new();
	my $request = GET $app_url;
	$request->authorization_basic( $user, $passwd );
	 
	my $res = $ua->request( $request );
	
	if( $res->is_success )	{
		my $c = $res->decoded_content;
		
		if( $c =~ /OK/ )	{
			return 1;
		}
		else	{
			warn $c;
		}
	}
	else	{
		warn sprintf( '%s : %s', $res->status_line, $app_url );
	}
	
	return undef;
}

sub undeploy	{
	my $self = shift;
	
	my $res = try	{
		my $app = $self->cfg->app_file;
		my $du = $self->cfg->deploy_url;
		
		die 'app-file undefined' unless( $app );
		die 'deploy-url undefined' unless( $du );

		# get file name
		$app =~ s#.*/##;
		
		if( is_local_url( $self->cfg->deploy_url ) )	{
			unless( $du =~ m#^/# )	{
				$du = sprintf( '%s/%s/%s', getcwd(), $du, $app );
			}
			
			die sprintf( 'deploy-url does not exist: %s', $du ) unless( -e $du );
			
			unlink( $du  ) or die "undeploy failed: $!";
		}
		else	{
			my $user = $self->cfg->deploy_user;
			my $passwd = $self->cfg->deploy_password;
			
			die 'login undefined' unless( $user );
			die 'password undefined' unless( $passwd );
			
			del_remote( $app, $du, $user, $passwd ) or die "undeploy failed: $!";
		}
		
		return 1;
	}
	catch	{
		warn $_;
		return undef;
	};
	
	return $res;
}

sub status	{
	my $self = shift;
	
	my $app_file = $self->cfg->app_file;
	my $app_url = $self->cfg->app_url;
	my $deploy_url = $self->cfg->deploy_url;
	my $user = $self->cfg->deploy_user;
	my $passwd = $self->cfg->deploy_password;
	
	die 'app-file undefined' unless( $app_file );
	die 'app-url undefined' unless( $app_url );
	
	die 'deploy-url undefined' unless( $deploy_url );
	die 'deploy-user undefined' unless( $user );
	die 'deploy-password undefined' unless( $passwd );
	
	my $status = 0;
	
	if( is_exist_remote( $app_file, $deploy_url, $user, $passwd ) )	{
		$status = 1;
		
		if( is_up( $app_url ) )	{
			$status = 2;
		}
	}

	return $status;
}

1;