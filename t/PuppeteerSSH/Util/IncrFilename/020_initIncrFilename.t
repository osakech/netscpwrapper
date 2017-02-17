#
#===============================================================================
#
#         FILE: 020_initIncrFilename.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/11/2017 04:00:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 4;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../../lib/";

use PuppeteerSSH::Util::IncrFilename;

can_ok('PuppeteerSSH::Util::IncrFilename', '_initIncrFilename');

my $filename = 'test';
my $expectedFilename = 'test_000001';
my $gotFilename = PuppeteerSSH::Util::IncrFilename::_initIncrFilename($filename);
is($gotFilename, $expectedFilename, 'initialized incrementation format correctly');


$filename = '';
$expectedFilename = '_000001';
$gotFilename = PuppeteerSSH::Util::IncrFilename::_initIncrFilename($filename);
is($gotFilename, $expectedFilename, 'empty string, doesn\'t set the underscore');

$filename = undef;
$expectedFilename = '_000001';
$gotFilename = PuppeteerSSH::Util::IncrFilename::_initIncrFilename($filename);
is($gotFilename, $expectedFilename, 'undef string, doesn\'t set the underscore');

1;

