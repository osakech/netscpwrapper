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

use Test::More tests => 7;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../../lib/";

use PuppeteerSSH::Util::IncrFilename;

can_ok('PuppeteerSSH::Util::IncrFilename', '_isIncrFilename');

my $filename = '';
my $got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok(!$got,'empty string is not an incremantable filename');

$filename = undef;
$got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok(!$got,'undef is not an incremantable filename');

$filename = 'testname';
$got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok(!$got,'testname is not an incremantable filename, missing suffix');

$filename = 'testname_000001_';
$got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok(!$got,'testname is not an incremantable filename, does not finish with digit');

$filename = 'testname_000001';
$got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok($got,'is valid incremantable filename');

$filename = 'testname_01';
$got = PuppeteerSSH::Util::IncrFilename::_isIncrFilename($filename);
ok(!$got,'is valid incremantable filename');
