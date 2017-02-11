#
#===============================================================================
#
#         FILE: 020_getDshGroupFile.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 02/01/2017 02:51:47 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 10;    # last test to print
use Test::Exception;
use File::Temp qw(tempfile tempdir);

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Groupfiles;

# to test:

# * param -> undef
my $groupFile = PuppeteerSSH::Groupfiles::_getDshGroupFile();
ok( !defined($groupFile), 'undef in, undef out' );

# * param -> empty
$groupFile = PuppeteerSSH::Groupfiles::_getDshGroupFile('');
ok( !defined($groupFile), 'empty in, undef out' );

# * valid path
my ( undef, $validFilePathtempfile ) = tempfile();
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = $validFilePathtempfile;
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = '';
$groupFile                                         = PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy');
ok( -f $groupFile, 'normal' );

# * invalid path -> does not exist
my $tmpdir = tempdir( CLEANUP => 1 );
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = $tmpdir . '/invalidfile';
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = '';
dies_ok { PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy') } 'die if dsh user file doesn\'t exist';

# * invalid path -> is not readable
my ( undef, $notReadableFilePath ) = tempfile();

#r=4
#w=2
#x=1
#user/group/all
chmod '077', $notReadableFilePath;
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = $notReadableFilePath;
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = '';
dies_ok { PuppeteerSSH::Groupfiles::_getDshGroupFile( 'dummy' ) } 'die if dsh user file isn\'t readable';

# * invalid path -> is directory
$tmpdir                                            = tempdir( CLEANUP => 1 );
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = $tmpdir;
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = '';
dies_ok { PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy') } 'die if dsh user file is directory';

# * user group file first, then system
my ( $userfilehandle,   $userfilepath )   = tempfile();
my ( $systemfilehandle, $systemfilepath ) = tempfile();
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = $userfilepath;
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = $systemfilepath;
print $userfilehandle 'this is the userfile';
print $systemfilehandle 'this is the systemfile';
$systemfilehandle->flush();
$userfilehandle->flush();
$groupFile = PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy');
use File::Slurper 'read_text';
my $file_content = read_text($groupFile);
like( $file_content, qr/^this is the userfile$/, 'the user file gets first' );

# * system dsh # valid path
( undef, $validFilePathtempfile ) = tempfile();
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = '';
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = $validFilePathtempfile;
$groupFile                                         = PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy');
ok( -f $groupFile, 'normal usage of system groupfile' );

# * system dsh # invalid path -> does not exist
$tmpdir                                            = tempdir( CLEANUP => 1 );
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = '';
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = $tmpdir.'/does not exist';
dies_ok { PuppeteerSSH::Groupfiles::_getDshGroupFile('dummy') } 'die if system dsh file doesn\'t exist';

# * invalid path -> is not readable
( undef, $notReadableFilePath ) = tempfile();

#r=4
#w=2
#x=1
#user/group/all
chmod '077', $notReadableFilePath;
$PuppeteerSSH::Groupfiles::setUserPathForTesting   = '';
$PuppeteerSSH::Groupfiles::setGlobalPathForTesting = $notReadableFilePath;
dies_ok { PuppeteerSSH::Groupfiles::_getDshGroupFile( 'dummy') } 'die if dsh system file isn\'t readable';
