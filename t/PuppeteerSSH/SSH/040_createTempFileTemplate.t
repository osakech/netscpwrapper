#
#===============================================================================
#
#         FILE: 040_createTempFileTemplate.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/29/2017 05:36:28 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 3;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::SSH;

my $got = PuppeteerSSH::SSH::_createTempFileTemplate('test');
like($got,qr/^puppeteer_test_XXXXXXXX$/,'template correctly created');

$got = PuppeteerSSH::SSH::_createTempFileTemplate();
like($got,qr/^puppeteer__XXXXXXXX$/,'template correctly created with undef input'); # this shouldn't happen

$got = PuppeteerSSH::SSH::_createTempFileTemplate('root:&/_%$%§"$"§^\\/@testserver.com:66');
like($got,qr/^puppeteer_\Q_root:&/_%$%§"$"§^\\/@testserver.com:66_\EXXXXXXXX$/,'template correctly created with undef input'); # this shouldn't happen

