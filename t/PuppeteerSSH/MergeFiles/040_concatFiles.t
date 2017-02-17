#
#===============================================================================
#         FILE: 040_concatFiles.t
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 01/28/2017 11:09:27 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;
use File::Temp 'tempfile';
use File::Slurper 'read_text';

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::MergeFiles;

$| = 1;

my ( $gotInputFh1, $gotInputFilepath1 ) = tempfile();
my ( $gotInputFh2, $gotInputFilepath2 ) = tempfile();
my ( $gotResultFh3, $gotResultFilepath3 ) = tempfile();

print $gotInputFh1 "a\n";
print $gotInputFh2 "b\n";
$gotInputFh1->flush();
$gotInputFh2->flush();

my $tmpFiles = [ $gotInputFilepath1, $gotInputFilepath2 ];

PuppeteerSSH::MergeFiles::_concatFiles( $gotResultFilepath3, $tmpFiles );

my $gotText = read_text($gotResultFilepath3);

is($gotText, "a\nb\n",'contents files are concatinated');

File::Temp::cleanup();

