#
#===============================================================================
#
#         FILE: Groupfiles.pm
#
#  DESCRIPTION: manages the access to groupfiles and returns the contents
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 01/30/2017 10:02:17 PM
#     REVISION: ---
#===============================================================================
package PuppeteerSSH::Groupfiles;

use strict;
use warnings;
use Carp 'croak';

use File::HomeDir;
use File::Spec;
use File::Slurper 'read_lines';

our $VERSION = 0.1;

our $setUserPathForTesting; 
our $setGlobalPathForTesting;

sub new {
    my $class = shift;

    my ( $groupfile, $dshGroupname ) = @_;

    my $self = {
        dshGroupfile => _getDshGroupFile($dshGroupname),
        groupfile    => _getUserGroupFile($groupfile),
    };
    bless $self, $class;

    return $self;
}
## --- end sub new

sub _getUserGroupFile {
    my ($groupfile) = @_;

    return undef unless $groupfile;

    if ( -f $groupfile && -r $groupfile ) {
        return $groupfile;
    } else {
        croak "Specified server file doesn't exist or isn't readable";
    }

    return;
}    ## --- end sub _getUserGroupFile

sub _getDshGroupFile {
    my ($groupname) = @_;

    return undef unless $groupname;

    my $userHome           = File::HomeDir->my_home;
    my $userDshGroupFile   = File::Spec->catfile( $userHome . '/.dsh/group/', $groupname );
    my $globalDshGroupFile = File::Spec->catfile( '/etc/dsh/group/', $groupname );

    if( defined $setUserPathForTesting ){ # FOR TESTING
        $userDshGroupFile = $setUserPathForTesting;
    }

    if( defined $setGlobalPathForTesting ){ # FOR TESTING
        $globalDshGroupFile = $setGlobalPathForTesting;
    }

    my $dshGroupFile;
    if ( -f $userDshGroupFile && -r $userDshGroupFile ) {
        $dshGroupFile = $userDshGroupFile;
    } elsif ( -f $globalDshGroupFile && -r $globalDshGroupFile ) {
        $dshGroupFile = $globalDshGroupFile;
    } else {
        croak "Specified dsh group doesn't exist or isn't readable";
    }

    return $dshGroupFile;
}    ## --- end sub _getDshGroupFile

sub _generateServerList {
    my ( $groupfile, $dshGroupfile ) = @_;

    my $serverpath = $groupfile || $dshGroupfile;
    my @serverArray = read_lines($serverpath);

    return \@serverArray;
}    ## --- end sub _generateServerList

sub getServers {
    my ($self) = @_;

    my $serverArray = _generateServerList( $self->{groupfile}, $self->{dshGroupfile} );

    return $serverArray;
}    ## --- end sub getServers

1;

