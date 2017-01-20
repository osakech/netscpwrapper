#
#===============================================================================
#
#         FILE: 010_load.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 25.10.2016 23:35:37
#===============================================================================

use strict;
use warnings;

use Test::More skip_all => 'not used atm';                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../lib";

require_ok('Cfg');
use_ok('Cfg');

