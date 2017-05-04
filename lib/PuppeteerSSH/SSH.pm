#
#===============================================================================
#
#         FILE: SSH.pm
#
#  DESCRIPTION: Handles SSH-Connections
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION:
#      VERSION: 0.3
#      CREATED: 19.01.2017 16:35:32
#     REVISION: ---
#===============================================================================
package PuppeteerSSH::SSH;

our $VERSION = 0.4;

use strict;
use warnings;
use feature 'say';
use Carp 'croak';

use Net::OpenSSH;
use File::Spec;
use File::Temp 'tempfile';
use Params::Util '_ARRAY';

sub new {
    my $class = shift;
    my ( $server, $sshOptions ) = @_;

    my %options;
    $options{ master_opts } = _setsshOptions( $sshOptions );
    my $sshConnection = _getSSHConnection( $server, \%options );
    my $self = {
        connection => $sshConnection,
        serverName => $server,
        sshOptions => $sshOptions,
    };

    bless $self, $class;
    return $self;
}

sub getCleanHostline {
    my $self = shift;
    my ($server) = @_;
    $server ||= $self->{serverName};
    my $splittedServerLine = _parseConnectionString($server);
    return join '_' , grep {defined} @$splittedServerLine{qw(user ipv6 hostname port)};
}

sub _getSSHConnection {
    my ( $server, $options ) = @_;
    my $ssh = Net::OpenSSH->new( $server, %$options );
    $ssh->error and croak "Couldn't establish SSH connection: " . $ssh->error;

    return $ssh;
}

sub _parseConnectionString {
    my ($target) = @_;

    # The code is partly stolen from Net::OpenSSH->parse_connection_opts
    # https://metacpan.org/source/SALVA/Net-OpenSSH-0.74/lib/Net/OpenSSH.pm#L171
    # I considered calling it directly but since this function isn't mentioned in the documentation
    # I see it as a private function
    my $IPv6_re =
qr((?-xism::(?::[0-9a-fA-F]{1,4}){0,5}(?:(?::[0-9a-fA-F]{1,4}){1,2}|:(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})))|[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}:(?:[0-9a-fA-F]{1,4}|:)|(?::(?:[0-9a-fA-F]{1,4})?|(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))))|:(?:(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|[0-9a-fA-F]{1,4}(?::[0-9a-fA-F]{1,4})?|))|(?::(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|:[0-9a-fA-F]{1,4}(?::(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|(?::[0-9a-fA-F]{1,4}){0,2})|:))|(?:(?::[0-9a-fA-F]{1,4}){0,2}(?::(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|(?::[0-9a-fA-F]{1,4}){1,2})|:))|(?:(?::[0-9a-fA-F]{1,4}){0,3}(?::(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|(?::[0-9a-fA-F]{1,4}){1,2})|:))|(?:(?::[0-9a-fA-F]{1,4}){0,4}(?::(?:(?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](?:25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))|(?::[0-9a-fA-F]{1,4}){1,2})|:))));

    my ( $user, $passwd, $ipv6, $host, $port ) = $target =~ m{^
                       \s*               # space
                       (?:
                         ([^:]+)         # username
                         (?::(.*))?      # : password
                         \@              # @
                       )?
                       (?:               # host
                          (              #   IPv6...
                            \[$IPv6_re(?:\%[^\[\]]*)\] #     [IPv6]
                            |            #     or
                            $IPv6_re     #     IPv6
                          )
                          |              #   or
                          ([^\[\]\@:]+)  #   hostname / ipv4
                       )
                       (?::([^\@:]+))?   # port
                       \s*               # space
                     $}ix
      or croak "bad host/target '$target' specification";

    wantarray and return ( $user, $passwd, $ipv6, $host, $port );

    return {
        user     => $user,
        password => $passwd,
        ipv6     => $ipv6,
        hostname => $host,
        port     => $port
    };
}    ## --- end sub _parseConnectionString


sub _setsshOptions {
    my	( $sshOptions )	= @_;

    return unless _ARRAY($sshOptions);

    my @processedSshOptions;
    foreach my $opt (@$sshOptions){
        push @processedSshOptions, ('-o' => $opt);
    }

    return \@processedSshOptions;
} ## --- end sub _setsshOptions

sub getFileFromServer {
    my $self = shift;
    my ( $fileToGet ) = @_;

    my $template = _createTempFileTemplate( $self->{serverName} );
    my ($copyLocalTempFH, $copyLocalTempPath) = tempfile($template, TMPDIR => 1 );

    $self->{connection}->scp_get( File::Spec->canonpath($fileToGet), $copyLocalTempPath );
    $copyLocalTempFH->flush();

    return $copyLocalTempPath;
}

sub _createTempFileTemplate {
    my	( $servername )	= @_;
    $servername //= '';
    return 'puppeteer_' . $servername . '_XXXXXXXX';
} ## --- end sub _createTempFileTemplate

sub _getLocalPath {
    my	( $fileToGet,$servername )	= @_;

    croak "not a valid path" unless ($fileToGet && $servername);

    return join "_", ($fileToGet,$servername);
} ## --- end sub _getLocalPath

sub executeOnServer {
    my $self = shift;
    my ( $copyToDir, $scriptToExecute ) = @_;

    my ( undef, undef, $file ) = File::Spec->splitpath($scriptToExecute);

    $self->{connection}->system( File::Spec->catfile( $copyToDir, $file ) );
}

sub putFileOnServer {
    my $self = shift;
    my ( $copyToDir, $scriptToExecute ) = @_;
    $self->{connection}->scp_put( File::Spec->canonpath($scriptToExecute), File::Spec->canonpath($copyToDir) );
}

1;
