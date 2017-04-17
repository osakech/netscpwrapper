#
#===============================================================================
#
#         FILE: 050_parseConnectionString.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (akech), Alexandros.Kechagias@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 03/29/2017 08:43:49 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;    # last test to print

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::SSH;

my $hostline             = 'username:password@hostname:22';
my $expectedScalarResult = {
    user     => 'username',
    password => 'password',
    ipv6     => undef,
    hostname => 'hostname',
    port     => 22
};

my $gotScalarResult = PuppeteerSSH::SSH::_parseConnectionString($hostline);

is_deeply( $gotScalarResult, $expectedScalarResult, 'simple case' );


$hostline             = 'username:password@2001:4860:4860:0:0:0:0:8888:22';
$expectedScalarResult = {
    user     => 'username',
    password => 'password',
    ipv6     => '2001:4860:4860:0:0:0:0:8888',
    hostname => undef,
    port     => 22
};

my $gotScalarResult2 = PuppeteerSSH::SSH::_parseConnectionString($hostline);

is_deeply( $gotScalarResult2, $expectedScalarResult, 'simple ipv6 case' );


$hostline = 'username:password@hostname:22';
my @expectedArrayResult = ( 'username', 'password', undef, 'hostname', 22 );

my @gotArrayResult = PuppeteerSSH::SSH::_parseConnectionString($hostline);

is_deeply( \@gotArrayResult, \@expectedArrayResult, 'simple case return array' );

done_testing();

