#
#===============================================================================
#
#         FILE: 070_mkdirIfPossible.t
#
#       AUTHOR: Alexandros Kechagias (akech), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 05/01/2017 10:06:03 PM
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print
use Test::Exception;
use Test::File;
use File::Temp qw(tempdir tempfile);
use File::Spec;

use FindBin;
use lib "$FindBin::Bin/../../../lib/";

use PuppeteerSSH::Resultfiles;

#-------------------------------------------------------------------------------
#  add subtests
#-------------------------------------------------------------------------------
subtest 'undef in, undef out' => sub {
    ok( !PuppeteerSSH::Resultfiles::_mkdirIfPossible(undef), 'you came from nothing, you go back to nothing, there\'s nothing to lose' );
};

subtest 'die if specified output path is an existing file' => sub {
    my ( $fh_simplefile, $simplefile ) = tempfile();
    $fh_simplefile->flush();
    dies_ok { PuppeteerSSH::Resultfiles::_mkdirIfPossible($simplefile) } 'dies if specified path is an existing file';
};

subtest 'output path is an existing and writable directory' => sub {
    my $simpledir_writeable = tempdir();
    file_writeable_ok($simpledir_writeable);
    lives_ok { PuppeteerSSH::Resultfiles::_mkdirIfPossible($simpledir_writeable) } 'existing and writable directory is ok';
    dir_exists_ok($simpledir_writeable);
};

subtest 'die output path is an existing and  _NON_writable directory' => sub {
    my $simpledir_nonwriteable = tempdir();
    chmod 0444, $simpledir_nonwriteable;
    my $nonwriteable_dir = File::Spec->catdir( $simpledir_nonwriteable, 'dirshouldnotbehere' );
    dies_ok { PuppeteerSSH::Resultfiles::_mkdirIfPossible($nonwriteable_dir) } 'dies if specified path is not writeable';
    file_not_exists_ok($nonwriteable_dir);
};

subtest 'directory created, everything is fine and dandy' => sub {
    my $simpledir_writeable = tempdir();
    my $writable_dir = File::Spec->catdir( $simpledir_writeable, 'dirshouldbehere' );
    file_not_exists_ok($writable_dir);
    lives_ok { PuppeteerSSH::Resultfiles::_mkdirIfPossible($writable_dir) } 'directory created';
    dir_exists_ok($writable_dir);
    file_writeable_ok($writable_dir);
};

done_testing;
