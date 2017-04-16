#
#===============================================================================
#
#         FILE: 050getNextFilename.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/17/2017 01:39:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 5;                      # last test to print
use File::Temp qw(tempfile tempdir);
use POSIX;
use File::Spec;

use FindBin;
use lib "$FindBin::Bin/../../../../lib/";

use PuppeteerSSH::Util::IncrFilename;


can_ok('PuppeteerSSH::Util::IncrFilename', 'getNextFilename');

#continue incrementation
my ($fh, $filename) = tempfile( "tmpfileXXXXXX", SUFFIX => '_000003', TMPDIR => 1 );
$fh->flush();
my $gotNextFilename = PuppeteerSSH::Util::IncrFilename::getNextFilename($filename);
like($gotNextFilename,qr/tmpfile.{6}_000004$/,'normal use case');

#init incrementation
($fh, $filename) = tempfile( "tmpfileXXXXXX", TMPDIR => 1 );
$fh->flush();
$gotNextFilename = PuppeteerSSH::Util::IncrFilename::getNextFilename($filename);
like($gotNextFilename,qr/tmpfile.{6}_000001$/,'init incrementation');

my $tmpdir = File::Spec->tmpdir();

#continue incrementation with existing files 000001-3 already exist, next 000004
unlink($tmpdir."/testfile_000001");
unlink($tmpdir."/testfile_000002");
unlink($tmpdir."/testfile_000003");
unlink($tmpdir."/testfile_000004");
POSIX::creat($tmpdir."/testfile_000001","0611");
POSIX::creat($tmpdir."/testfile_000002","0611");
POSIX::creat($tmpdir."/testfile_000003","0611");
$gotNextFilename = PuppeteerSSH::Util::IncrFilename::getNextFilename($tmpdir.'/testfile');
like($gotNextFilename,qr/testfile_000004$/,'continue incrementation with existing files');
unlink($tmpdir."/testfile_000001");
unlink($tmpdir."/testfile_000002");
unlink($tmpdir."/testfile_000003");
unlink($tmpdir."/testfile_000004");


# if 000001 and 000003 already exist then continue with 000002. At least atm
unlink($tmpdir."/testfile_000001");
unlink($tmpdir."/testfile_000002");
unlink($tmpdir."/testfile_000003");
POSIX::creat($tmpdir."/testfile_000001","0611");
POSIX::creat($tmpdir."/testfile_000003","0611");
$gotNextFilename = PuppeteerSSH::Util::IncrFilename::getNextFilename($tmpdir.'/testfile');
like($gotNextFilename,qr/testfile_000002$/,'continue incrementation after lowest suffix value');
unlink($tmpdir."/testfile_000001");
unlink($tmpdir."/testfile_000002");
unlink($tmpdir."/testfile_000003");

File::Temp::cleanup();


