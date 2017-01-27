#
#===============================================================================
#
#         FILE: 030_getLocalPath.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/27/2017 02:33:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 3;                      # last test to print
use Test::Exception;


use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::SSH;

my $got = PuppeteerSSH::SSH::_getLocalPath('p1','p2');
is($got,'p1_p2', 'concatination is ok');

dies_ok( sub{PuppeteerSSH::SSH::_getLocalPath(undef,'p2')},'dies if first param undef');
dies_ok( sub{PuppeteerSSH::SSH::_getLocalPath('p1',undef)},'dies if second param undef');

