#
#===============================================================================
#
#         FILE: 020_getUserGroupFile.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 02/01/2017 02:01 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 6;                      # last test to print
use Test::Exception;
use File::Temp qw(tempfile tempdir);


use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Groupfiles;

# * param -> undef
my $groupFile = PuppeteerSSH::Groupfiles::_getUserGroupFile();
ok(!defined($groupFile),'undef in, undef out');

# * param -> empty
$groupFile = PuppeteerSSH::Groupfiles::_getUserGroupFile('');
ok(!defined($groupFile),'empty in, undef out');

# * valid path
my (undef,$validFilePath) = tempfile();
$groupFile = PuppeteerSSH::Groupfiles::_getUserGroupFile($validFilePath);
ok(-f $groupFile ,'normal');

# * unvalid path -> does not exist
my $tmpdir = tempdir( CLEANUP => 1 );
dies_ok{ PuppeteerSSH::Groupfiles::_getUserGroupFile($tmpdir.'/notexists')} 'die if file specified but is not valid';

# * unvalid path -> is not readable
my (undef,$notReadableFilePath) = tempfile();
#r=4
#w=2
#x=1
#user/group/all
chmod '077', $notReadableFilePath;
dies_ok{ PuppeteerSSH::Groupfiles::_getUserGroupFile($notReadableFilePath)} 'die if file specified but is not readable';

# * unvalid path -> is directory
$tmpdir = tempdir( CLEANUP => 1 );
dies_ok{ PuppeteerSSH::Groupfiles::_getUserGroupFile($tmpdir)} 'die if file specified but is directory';

