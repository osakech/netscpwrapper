#
#===============================================================================
#
#         FILE: 030_setCliParams.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 26.10.2016 00:27:56
#===============================================================================

use strict;
use warnings;

use Test::More skip_all => 'not used atm';                      # last test to print
use FindBin;

use lib "$FindBin::Bin/../../../lib";

use PuppeteerSSH::Cfg;
my $cliParams = { a => 'test' };
my $cfg = PuppeteerSSH::Cfg->new( $cliParams );

my $gotCfg = $cfg->_setCliParams();

my $expectedCfg = {
    params => {
        a => 'test'
    },
    config => {
        a => 'test'
    }
};

is_deeply($gotCfg,$expectedCfg, 'params get copied into config attribute');

