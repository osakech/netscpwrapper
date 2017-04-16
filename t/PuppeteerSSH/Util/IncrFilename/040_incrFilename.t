#
#===============================================================================
#
#         FILE: 030_isIncrFilename.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/12/2017 01:23:59 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 4;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../../lib/";

use PuppeteerSSH::Util::IncrFilename;

can_ok('PuppeteerSSH::Util::IncrFilename', '_incrFilename');

my $filename = 'testname_000006';
my $gotInrementedFilename = PuppeteerSSH::Util::IncrFilename::_incrFilename($filename);
my $expectedIncrementedFilename = 'testname_000007';
is($gotInrementedFilename,$expectedIncrementedFilename, 'normal case');

$filename = 'testname_999999';
$gotInrementedFilename = PuppeteerSSH::Util::IncrFilename::_incrFilename($filename);
$expectedIncrementedFilename = 'testname_1000000';
is($gotInrementedFilename,$expectedIncrementedFilename, 'over 999999 > 1000000');


$filename = 'testname_001_000001';
$gotInrementedFilename = PuppeteerSSH::Util::IncrFilename::_incrFilename($filename);
$expectedIncrementedFilename = 'testname_001_000002';
is($gotInrementedFilename,$expectedIncrementedFilename, 'ignore first number, increment only last');
