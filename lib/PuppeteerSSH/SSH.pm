#
#===============================================================================
#
#         FILE: SSH.pm
#
#  DESCRIPTION: Handles SSH-Connections
#
#        FILES: ---
#         BUG\%config, S: ---
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
use Readonly;

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

sub _getSSHConnection {
    my ( $server, $options ) = @_;
    my $ssh = Net::OpenSSH->new( $server, %$options );
    $ssh->error and croak "Couldn't establish SSH connection: " . $ssh->error;

    return $ssh;
}

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
    my ($copyLocalTempFH, $copyLocalTempPath) = tempfile($template);
#    my ($copyLocalTempFH, $copyLocalTempPath) = tempfile();

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
