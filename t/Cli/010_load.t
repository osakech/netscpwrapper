#!/usr/bin/env perl
#
#===============================================================================
#
#         FILE: 010_load.t
#
#  DESCRIPTION: test if the module is loadable
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 24.10.2016 17:11:13
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../../lib";

use Test::More tests => 2;                      # last test to print

require_ok('Cli');
use_ok('Cli');


