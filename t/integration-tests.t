#
#===============================================================================
#
#         FILE: 010_basic_test.t
#
#       AUTHOR: Alexandros Kechagias (akech), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 04/17/2017 10:52:41 AM
#===============================================================================

use strict;
use warnings;

use Test::More;
use Test::File; # exactly what i need!
use Test::Exception;
use File::Temp qw(tempfile tempdir);
use File::Spec;
use FindBin;
use File::Slurper qw(read_lines);
use Net::OpenSSH;




my $file_temps;

chdir("$FindBin::Bin/..");

foreach my $line ( read_lines('local_test_files/mygroupfile') ) {
    my $ssh = Net::OpenSSH->new( $line, master_opts => [ -o => "StrictHostKeyChecking=no", -o => "UserKnownHostsFile=/dev/null", -o => "LogLevel=QUIET" ] );
    $ssh->error and BAIL_OUT 'not all servers we require for testing are online';
}

my $tests = {
    'localpath set' => {
        'opts'  => [ '--localpath', ],
        'tests' => [ 
            'merged_correct' 
        ],
    },
    'localpath and time timestamp set' => {
        'opts'  => [ '--localpath', '--timestamped' ],
        'tests' => [ 
            'merged_correct', 
            'filename_looks_like=_\d{10}$', 
        ],
    },

    'localpath and increment set' => {
        'opts'  => [ '--localpath', '--increment' ],
        'tests' => [ 
            'merged_correct', 
            'filename_looks_like=_000001$', 
        ],
    }
};

foreach my $testname ( keys %$tests ) {
    subtest $testname => sub {
        my $test           = $tests->{$testname};
        my $mergedTestFile = get_merge_filename();
        my $cmd            = join ' ', ( set_tool_name(), set_fix_opts(), replace_tmpfile_placeholder( $test->{'opts'}, $mergedTestFile ) );
        lives_ok { system($cmd) and die } ' tool executed succesfully';
        foreach my $filetest ( @{ $test->{'tests'} } ) {
            my ($newname) = glob("$mergedTestFile*");
            if ( $filetest eq 'merged_correct' ) {
                file_contains_like(
                    $newname,
                    qr/^ssh session\sssh session\sssh session\sssh session$/m,
                    ' => merged data sucessfully, from at least 4 ssh sessions, in one file'
                );
            }
            if ( $filetest =~ /^filename_looks_like=(.*)/ ) {
                like( $newname, qr/$1/, " => filename matches $1 " );
            }
        }
      }
}
done_testing();
exit;

sub get_merge_filename {
    File::Spec->catfile(tempdir(),'mergedtestfile')
}

sub replace_tmpfile_placeholder {
    my ($array,$filepath) = @_;
    foreach my $el (@$array){
        $el =~ s/(--localpath)/$1 $filepath/;
    }
    return @$array;
}

sub create_test_script {
    my ( $tscriptfh, $tscriptfn ) = tempfile();
    print $tscriptfh 'if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then echo "ssh session" > /tmp/isSSH; fi';
    $tscriptfh->flush();
    chmod 777, $tscriptfh;
    return $tscriptfn;
}

sub set_fix_opts {
    "--destination /tmp",
      "--resultfile /tmp/isSSH",
      '-o "StrictHostKeyChecking=no"',
      '-o "UserKnownHostsFile=/dev/null"',
      '-o "LogLevel=QUIET"',
      "--script ".create_test_script(),
      "--gfile local_test_files/mygroupfile",
      "--quiet"
}

sub set_tool_name {
    './pussh.pl'
}

