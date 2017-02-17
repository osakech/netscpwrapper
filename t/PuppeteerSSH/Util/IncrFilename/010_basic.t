#
#===============================================================================
#
#         FILE: 010_basic.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/11/2017 03:29:03 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print


use FindBin;
use lib "$FindBin::Bin/../../../../lib/";


require_ok('PuppeteerSSH::Util::IncrFilename');
use_ok('PuppeteerSSH::Util::IncrFilename');

