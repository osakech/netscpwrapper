#
#===============================================================================
#
#         FILE: 010_basic.t
#
#  DESCRIPTION: 
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/27/2017 01:40:23 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

require_ok('PuppeteerSSH::SSH');
use_ok('PuppeteerSSH::SSH');

