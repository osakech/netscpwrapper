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

our $VERSION = 0.3;

use strict;
use warnings;
use feature 'say';
use Carp 'croak';
use Readonly;

use Net::OpenSSH;
use File::Spec;

Readonly my $DEBUG => 0;

sub new {
    my $class = shift;
    my ( $server, $port ) = @_;

    my $sshConnection = _getSSHConnection( $server, $port );
    my $self = {
        connection => $sshConnection,
        serverName => $server,
    };
    bless $self, $class;
    return $self;
}

sub _getSSHConnection {
    my ( $server, $port ) = @_;

    my $ssh = Net::OpenSSH->new($server);
    $ssh->error and croak "Couldn't establish SSH connection: " . $ssh->error;

    return $ssh;
}

sub getFileFromServer {
    my $self = shift;
    my ( $copyToDir, $fileToGet ) = @_;

    my $copyLocalPath = join "_", ( $fileToGet, $self->{serverName} );
    unlink $copyLocalPath;
    $self->{connection}->scp_get( $fileToGet, $copyLocalPath );

    return $copyLocalPath;
}

sub executeOnServer {
    my $self = shift;
    my ( $copyToDir, $scriptToExecute ) = @_;

    my ( $volume, $directories, $file ) = File::Spec->splitpath($scriptToExecute);

    if ($DEBUG) {
        say $$. ' executeOnServer -> copyToDir -> ' . $copyToDir;
        say $$. ' executeOnServer -> scriptToExecute -> ' . $file;
    }
    $self->{connection}->system( join '/', ( $copyToDir, $file ) );
}

sub putFileOnServer {
    my $self = shift;
    my ( $copyToDir, $scriptToExecute ) = @_;
    if ($DEBUG) {
        say $$. ' putFileOnServer -> copyToDir -> ' . $copyToDir;
        say $$. ' putFileOnServer -> scriptToExecute -> ' . $scriptToExecute;
    }
    $self->{connection}->scp_put( $scriptToExecute, $copyToDir );
}

#sub executeOnServerAndPipe{
#    my($server,$copyToDir,$scriptToExecute) = @_;
#    my $ssh = Net::OpenSSH->new($server);
#    $ssh->error and die "Couldn't establish SSH connection: ". $ssh->error;
#    my ($rout, $err) = $ssh->pipe_out(join '/', ($copyToDir,$scriptToExecute) );
#    $ssh->error and die "remote command failed: " . $ssh->error;
#    my @dataRows;
#    while (<$rout>) {
#        push @dataRows , $_;
#    }
#    close $rout;
#    return \@dataRows;
#
#}
1;
