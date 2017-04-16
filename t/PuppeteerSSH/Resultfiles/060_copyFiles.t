#
#===============================================================================
#
#         FILE: 060_copyFiles.t
#
#  DESCRIPTION: 
#       AUTHOR: Alexandros Kechagias (akech), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 04/15/2017 11:51:59 AM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;
use File::Slurper 'read_text';
use File::Temp 'tempfile';
use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Resultfiles;

#    my %connectionData = (
#        localTempPath => $copiedTo,                         # TODO use filehandle instead of filename in v0.6
#        cleanHostline => $sshConnection->getCleanHostline,
#    );
#

my ($tmpfh1,$tmpfn1) = tempfile();
my ($tmpfh2,$tmpfn2) = tempfile();
my ($resultfh1,$resultfn1) = tempfile();
my ($resultfh2,$resultfn2) = tempfile();
print $tmpfh1 'content1';
print $tmpfh2 'content2';
$tmpfh1->flush();
$tmpfh2->flush();
my $cleanHostline1 = 'copiedfile1';
my $cleanHostline2 = 'copiedfile2';

my $connectionData = [
{
    localTempPath => $tmpfn1,
    cleanHostline => $resultfn1,
},
{
    localTempPath => $tmpfn2,
    cleanHostline => $resultfn2,
},
];

PuppeteerSSH::Resultfiles::_copyFiles($connectionData);

my $gottext1 = read_text($resultfn1);
my $gottext2 = read_text($resultfn2);
my $expectedtext1 = "content1";
my $expectedtext2 = "content2";

is($gottext1,$expectedtext1,'contents of file 1 copied');
is($gottext2,$expectedtext2,'contents of file 2 copied');


