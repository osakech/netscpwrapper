#
#===============================================================================
#
#         FILE: 010_basic.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 02/01/2017 02:47:25 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

require_ok('PuppeteerSSH::Groupfiles');

