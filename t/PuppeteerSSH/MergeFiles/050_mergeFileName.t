#
#===============================================================================
#
#         FILE: 050_mergeFileName.t
#
#  DESCRIPTION: 
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 01/28/2017 02:35:11 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 5;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::MergeFiles;

my $userFileName = undef;
my $useTimeStamp = undef;
my $incrFilename = undef;
my $gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp);
is($gotFilename, 'merged_result', 'default name if nothing is set' );

$userFileName = 'manually_set_name';
$useTimeStamp = undef;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp);
is($gotFilename, 'manually_set_name', 'manually set name' );

$userFileName = undef;
$useTimeStamp = 1;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp);
like($gotFilename, qr/^merged_result_\d{10}$/, 'default filename + timestamp ' );

$userFileName = 'manually_result';
$useTimeStamp = 1;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp);
like($gotFilename, qr/^manually_result_\d{10}$/, 'manually set name + timestamp ' );

$userFileName = '';
$useTimeStamp = 1;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp);
like($gotFilename, qr/^\d{10}$/, 'only timestamp' );

$userFileName = 'manually_set_name';
$useTimeStamp = undef;
$incrFilename = 1;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp,$incrFilename );
like($gotFilename, qr/^manually_set_name_000001$/, 'incrementation initiated' );

$userFileName = 'manually_set_name';
$useTimeStamp = 1;
$incrFilename = 1;
$gotFilename = PuppeteerSSH::MergeFiles::_mergeFileName($userFileName, $useTimeStamp,$incrFilename );
like($gotFilename, qr/^manually_set_name_\d{10}_000001$/, 'incrementation initiated + timestamp' );


