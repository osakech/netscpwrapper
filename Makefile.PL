use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'pussh',
    VERSION_FROM => 'pussh.pl',
    PREREQ_PM => {
        # CPAN Modules
        'File::Slurper' => '0',
        'Net::OpenSSH' => '0.40',
        'File::HomeDir' => '0.50',
        'Getopt::Long::Descriptive' => '0',
        'Parallel::ForkManager' => '0.7.9',
        'IO::Pty' => '0', # need this for travis
 
        # CORE modules
        'File::Copy' => 0,
        'File::Temp' => '0',
        'FindBin' => '0',
        'POSIX' => '0',
        'File::Spec' => '0',
        'Params::Util' => '0',
        'Carp' => '0',
        'File::Path' => '0',
    },
    TEST_REQUIRES => {
        'Test::More' => '0',
        'File::Find'  => '0',
        'Test::File' => '1.35',
        'Test::Exception' => '0.26',
    },
    test => {
        TESTS => 't/*.t t/PuppeteerSSH/*/*.t t/PuppeteerSSH/Util/IncrFilename/*.t '
    },
    LICENSE => 'gpl_3',
    AUTHOR => 'Alexandros Kechagias <osakech@gmail.com>',
)

