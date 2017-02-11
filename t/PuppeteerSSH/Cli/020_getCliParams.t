#
#===============================================================================
#
#         FILE: 020_getCliParams.t
#
#  DESCRIPTION: testing cli params
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 24.10.2016 19:20:03
#     REVISION: ---
#===============================================================================
use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

$ARGV[0] = '--gdsh=test';
$ARGV[1] = '--destination=/tmp';
$ARGV[2] = '--script=/tmp/test.pl';
$ARGV[3] = '--resultfile=/tmp/data_to_collect';

use PuppeteerSSH::Cli;

my $gotConfig = PuppeteerSSH::Cli::getCliParams();

my $expectedConfig = {
    gdsh => 'test',
    destination => '/tmp',
    script => '/tmp/test.pl',
    resultfile => '/tmp/data_to_collect',
    groupfile => 'gdsh',
};

is_deeply($gotConfig,$expectedConfig,'config looks as expected');


done_testing();

