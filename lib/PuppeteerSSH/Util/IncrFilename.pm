#
#===============================================================================
#
#         FILE: IncrFilename.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/11/2017 03:37:01 PM
#     REVISION: ---
#===============================================================================
package PuppeteerSSH::Util::IncrFilename;

our $VERSION = '0.1';

use strict;
use warnings;
use File::Spec;

sub _isIncrFilename {
    my ($filename) = @_;

    if ( $filename and $filename =~ /_\d{6}$/ ) {
        return 1;
    }
    return;
}    ## --- end sub _isIncrFilename

sub _initIncrFilename {
    my ($filename) = @_;
    $filename //= '';
    return $filename . '_000001';
}    ## --- end sub _initIncrFilename

sub _incrFilename {
    my ($filename) = @_;

    $filename =~ /_(\d+)$/;
    my $digit = $1;
    $digit++;

    my $formatedDigit = sprintf( "%06d", $digit );

    $filename =~ s/_\d+$/_$formatedDigit/;

    return $filename;
}    ## --- end sub _incrFilename

sub getNextFilename {
    my ($filename) = @_;

    $filename = File::Spec->catfile($filename);

    unless ( _isIncrFilename($filename) ) {
        $filename = _initIncrFilename($filename);
    }

    if ( -e $filename ) {
        $filename = _incrFilename($filename);
    } else {
        return $filename;
    }
    getNextFilename($filename);
}    ## --- end sub getNextFilename

1;

