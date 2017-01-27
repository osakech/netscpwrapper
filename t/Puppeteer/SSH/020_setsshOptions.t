#
#===============================================================================
#
#         FILE: 020_setsshOptions.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/27/2017 01:55:14 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 3;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::SSH;

# normal case
my @inputsshOptions = ('test1','test2');
my $got = PuppeteerSSH::SSH::_setsshOptions(\@inputsshOptions);
my @expected = ('-o','test1','-o','test2');
is_deeply($got, \@expected, 'ssh options correct');


# empty array
@inputsshOptions = ();
$got = PuppeteerSSH::SSH::_setsshOptions(\@inputsshOptions);
@expected = undef;
ok(!$got,'empty array returns undef');

# empty array
$got = PuppeteerSSH::SSH::_setsshOptions(undef);
@expected = undef;
ok(!$got,'undef returns undef');
