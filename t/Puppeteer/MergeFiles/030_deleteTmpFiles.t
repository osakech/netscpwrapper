#
#===============================================================================
#
#         FILE: 030_deleteTmpFiles.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 01/28/2017 11:11:46 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests=> 2;
use Test::File qw(file_exists_ok file_not_exists_ok);
use File::Temp 'tempfile';

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::MergeFiles;

my ( undef, $tmpfile1 ) = tempfile();

file_exists_ok($tmpfile1,'temp file exists');
my $tmpFiles = [$tmpfile1];
PuppeteerSSH::MergeFiles::_deleteTmpFiles($tmpFiles);
file_not_exists_ok($tmpfile1,'temp file succesfully deleted');

