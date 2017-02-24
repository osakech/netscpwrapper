#
#===============================================================================
#
#         FILE: 010_load.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/22/2017 05:07:37 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

require_ok('PuppeteerSSH::CopyFiles');

