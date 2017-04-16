#
#===============================================================================
#
#         FILE: 060_getcleanhostline.t
#
#  DESCRIPTION: 
#
#       AUTHOR: Alexandros Kechagias (akech), Alexandros.Kechagias@gmail.com
#      VERSION: 1.0
#      CREATED: 04/15/2017 10:35:22 AM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::SSH;

my $expectedcleanLine = 'uname_servername.de_22';
my $gotcleanline = PuppeteerSSH::SSH->getCleanHostline('uname:password@servername.de:22');
is($gotcleanline,$expectedcleanLine,'basic');

$expectedcleanLine = 'uname_2001:4860:4860:0:0:0:0:8888_22';
$gotcleanline = PuppeteerSSH::SSH->getCleanHostline('uname:password@2001:4860:4860:0:0:0:0:8888:22');
is($gotcleanline,$expectedcleanLine,'ipv6-name');
