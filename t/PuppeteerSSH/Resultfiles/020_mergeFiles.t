#
#===============================================================================
#
#         FILE: 020_mergeFiles.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 01/28/2017 12:33:43 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;    # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Resultfiles;

my $mkdirIfPossible;
my $copyFiles;
my $concatFiles;
my $getFileName;

my $options1->{no_merge} = 1;
PuppeteerSSH::Resultfiles::create( undef, $options1 );
ok( $mkdirIfPossible && $copyFiles && ! $concatFiles , 'functions for copying files called' );

resetMarkers();

my $options2->{no_merge} = undef;
PuppeteerSSH::Resultfiles::create( undef, $options2 );
ok( ! ($mkdirIfPossible && $copyFiles) && $concatFiles, 'functions for merging files called' );


sub resetMarkers { undef $_ for ($copyFiles,$concatFiles,$mkdirIfPossible) }
no warnings 'redefine';
sub PuppeteerSSH::Resultfiles::_mkdirIfPossible { $mkdirIfPossible = 1 }
sub PuppeteerSSH::Resultfiles::_copyFiles       { $copyFiles       = 1 }
sub PuppeteerSSH::Resultfiles::_concatFiles     { $concatFiles     = 1 }
sub PuppeteerSSH::Resultfiles::_getFileName     { $getFileName     = 1 }

done_testing;
