#
#===============================================================================
#
#         FILE: require_all.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/22/2017 05:53:22 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use feature 'say';

use Test::More;    # last test to print
use File::Find;

use FindBin;
use lib "$FindBin::Bin/../lib/";

my $options = {
    wanted   => \&wanted,
    no_chdir => 1,
};

find( $options, "$FindBin::Bin/.." );

my @myPMS;
my @myPLS;
my @myTS;

sub wanted {
    return if ( -d $File::Find::name );
    if (/\.pm$/) {
        my $mymodules_file_name = $File::Find::name;    # input file name

        open my $mymodules, '<', $mymodules_file_name
          or die "$0 : failed to open  input file '$mymodules_file_name' : $!\n";

        while (<$mymodules>) {
            if (/^package\s+(PuppeteerSSH[[:alnum:]:]+)\s*;/) {
                push @myPMS, $1;
                last;
            }
        }

        close $mymodules
          or warn "$0 : failed to close input file '$mymodules_file_name' : $!\n";
    } elsif (/\.pl$/) {
        my $myscripts_file_name = $File::Find::name;    # input file name

        open my $myscripts, '<', $myscripts_file_name
          or die "$0 : failed to open  input file '$myscripts_file_name' : $!\n";

        while (<$myscripts>) {
            if (/^return 1 if caller\(\);/) {
                push @myPLS, $File::Find::name;
                last;
            }
        }

        close $myscripts
          or warn "$0 : failed to close input file '$myscripts_file_name' : $!\n";

    } elsif (/\.t$/) {
        return if (/$0/);
        push @myTS, $File::Find::name;
    }

}

foreach my $mod ( @myPMS, @myPLS ) {
    note 'testing' . $mod;
    require_ok $mod;
}

#SKIP: {
#    skip 'i have to come up with a way to test if tests compile', scalar @myTS;
#    foreach my $mod ( @myTS ) {
#        note 'testing tests ' . $mod;
#        require_ok $mod;
#    }
#}

done_testing;

