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
#      CREATED: 01/27/2017 05:03:47 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

require_ok ('PuppeteerSSH::MergeFiles');
use_ok ('PuppeteerSSH::MergeFiles');

