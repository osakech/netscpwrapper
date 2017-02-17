#
#===============================================================================
#
#         FILE: 040_generateServerList.t
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 02/02/2017 12:16:14 PM
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print


use File::Temp qw(tempfile);

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Groupfiles;

my ($tempfileFH,$tempfilePATH) = tempfile();

print $tempfileFH 'a:b@c:1';
$tempfileFH->flush();

my $gotServers = PuppeteerSSH::Groupfiles::_generateServerList( $tempfilePATH, undef );
my $expectedServers = ['a:b@c:1'];
is_deeply( $gotServers, $expectedServers, 'user provided group file returned correctly' );


$gotServers = PuppeteerSSH::Groupfiles::_generateServerList( undef, $tempfilePATH );
is_deeply( $gotServers, $expectedServers, 'dsh group file returned correctly' );

File::Temp::cleanup();

