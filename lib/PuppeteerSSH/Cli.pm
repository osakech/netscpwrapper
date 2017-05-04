#
#===============================================================================
#
#         FILE: Cli.pm
#
#  DESCRIPTION: get command line params
#
#       AUTHOR: Alexandros Kechagias, osakech@gmail.com
# ORGANIZATION:
#      VERSION: 0.5
#      CREATED: 24.10.2016 19:06:20
#     REVISION: ---
#===============================================================================
package PuppeteerSSH::Cli;

use strict;
use warnings;

our $VERSION = '0.5';

use Getopt::Long::Descriptive qw(describe_options);

my %opts;

sub getCliParams {
    my ( $opt, $usage ) = describe_options(
        './pussh %o <some-arg>',
        [
            "groupfile" => hidden => {
                one_of => [ [ 'gdsh|g=s', "dsh group name to use" ], [ 'gfile|f=s', "path to file with list of servers" ], ]
            }
        ],
        [
            "outputformat" => hidden => {
                one_of => [
                    [ 'timestamped|t', "adds timestamp as suffix to the resultfile like: somename_1487418208" ],
                    [ 'increment|i',   "adds incrementing number as suffix if file already exists like: somename_000001 ..2 ..3" ],
                ]
            }
        ],
        [ 'destination|d=s',     "path to copy the script on the server", { required => 1 } ],
        [ 'quiet|q',             "quiet mode" ],
        [ 'num-connections|n=i', "max number of parallel connections" ],
        [ 'script|s=s',          "script to execute on server",           { required => 1 } ],
        [ 'ssh-option|o=s@',     "option to pass to ssh, like -o ... -o ..." ],
        [ 'localdir|c=s',        'set path on local machine for output files' ],
        [ 'resultfile|r=s',      "path of result file from server",       { required => 1 } ],
        [
            "localresultfile" => hidden => {
                one_of => [
                    [ 'localpath|l=s', "set path to local result file" ],
                    [ 'no-merge|m',    "don\'t merge all files into one result file, keep one file per server" ],
                ]
            }
        ],

        [ 'help', "print usage message and exit", { shortcircuit => 1 } ],
    );

    print( $usage->text ), exit if $opt->help;

    return $opt;
}

1;
