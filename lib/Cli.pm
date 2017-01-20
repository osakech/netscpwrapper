#
#===============================================================================
#
#         FILE: Cli.pm
#
#  DESCRIPTION: get command line params
#
#       AUTHOR: Alexandros Kechagias, osakech@gmail.com
# ORGANIZATION: 
#      VERSION: 0.2
#      CREATED: 24.10.2016 19:06:20
#     REVISION: ---
#===============================================================================
package Cli;

use strict;
use warnings;

our $VERSION = '0.2';

use Getopt::Long;

my %opts;

use Getopt::Long::Descriptive qw(describe_options);
 
sub getCliParams {
    my ( $opt, $usage ) = describe_options(
        'sshFromDshGroups %o <some-arg>',
        [
            "groupfile" => hidden => {
                one_of => [
                    [ 'gdsh|g=s', "dsh group name to use" ],
                    [ 'gfile|f=s', "path to file with list of servers" ],
                ]
            }
        ],
        [ 'destination|d=s', "path to copy the script on the server", { required => 1 } ],
        [ 'num-connections|n=i', "number of parallel connections"],
        [ 'script|s=s', "script to execute on server", { required => 1 } ],
        [
            'resultfile|r=s',
            "path of result file from server",
            { required => 1 }
        ],
        [ 'help', "print usage message and exit", { shortcircuit => 1 } ],
    );

    print( $usage->text ), exit if $opt->help;

    return $opt;
}

1;
