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

use strict;
use warnings;

sub _isIncrFilename {
    my	( $filename )	= @_;
    if ( $filename and $filename =~ /_\d{6}$/ ){
        return 1;
    }
    return;
} ## --- end sub _isIncrFilename

sub _initIncrFilename {
    my	( $filename )	= @_;
    $filename //= '';
    return $filename.'_000001';
} ## --- end sub _initIncrFilename


sub _incrFilename {
    my	( $filename )	= @_;

    $filename =~ /_(\d+)$/;
    my $digit = $1;
    $digit++;

    my $formatedDigit = sprintf("%06d", $digit);

    $filename =~ s/_\d+$/_$formatedDigit/;

    return $filename;
} ## --- end sub _incrFilename

1;

