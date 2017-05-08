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
use Test::File;    # exactly what i need!
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
    'localfile set' => {
        'opts'  => [ 
            '--localfile', 
        ],
        'tests' => [ 
            'filecontent_looks_like=^ssh session\sssh session\sssh session\sssh session$'
        ],
    },
    'localfile and time timestamp set' => {
        'opts'  => [ 
            '--localfile',
            '--timestamped' 
        ],
        'tests' => [ 
            'filecontent_looks_like=^ssh session\sssh session\sssh session\sssh session$', 
            'filename_looks_like=_\d{10}$', 
        ],
    },
    'localfile and increment set' => {
        'opts'  => [ 
            '--localfile',
            '--increment' 
        ],
        'tests' => [ 
            'filecontent_looks_like=^ssh session\sssh session\sssh session\sssh session$', 
            'filename_looks_like=_000001$', 
        ],
    },
    'localdir and no-merge' => {
        'opts'  => [ '--localdir',                         '--no-merge' ],
        'tests' => [ 
            'filecontent_looks_like=ssh session', 
            'filename_looks_like=\w+_\w+_\d+$', 
        ],
    },
};

## Please see file perltidy.ERR
foreach my $testname ( keys %$tests ) {
    subtest $testname => sub {
        my $test           = $tests->{$testname};
        my $mergedTestFile = get_merge_filename();
        my $cmd            = join ' ', ( set_tool_name(), set_fix_opts(), replace_tmpfile_placeholder( $test->{'opts'}, $mergedTestFile ) );
        lives_ok { system($cmd) and die } 'tool executed succesfully';
        foreach my $filetest ( @{ $test->{'tests'} } ) {
            foreach my $newname ( glob( set_glob_string($mergedTestFile) ) ) {    # TODO use readdir see perlport
                if ( $filetest =~ /^filename_looks_like=(.*)/ ) {
                    like( $newname, qr/$1/, " => filename $newname matches regex /$1/ " );
                }
                if ( $filetest =~ /^filecontent_looks_like=(.*)/ ) {
                    file_contains_like( $newname, qr/$1/, " => filecontent of $newname look like regex /$1/" );
                }
            }
        }
      }
}
done_testing();
exit;

sub get_merge_filename {
    File::Spec->catfile( tempdir(), 'testdata' );
}

sub replace_tmpfile_placeholder {
    my ( $array, $filepath ) = @_;
    foreach my $el (@$array) {
        $el =~ s/(--localfile)/$1 $filepath/;
        $el =~ s/(--localdir)/$1 $filepath/;
    }
    return @$array;
}

sub create_test_script {
    my ( $tscriptfh, $tscriptfn ) = tempfile();
    print $tscriptfh 'if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then echo "ssh session" > /tmp/isSSH; fi';
    $tscriptfh->flush();
    chmod 0777, $tscriptfh;
    return $tscriptfn;
}

sub set_fix_opts {
    "--destination /tmp",
      "--resultfile /tmp/isSSH",
      '-o "StrictHostKeyChecking=no"',
      '-o "UserKnownHostsFile=/dev/null"',
      '-o "LogLevel=QUIET"',
      "--script " . create_test_script(),
      "--gfile local_test_files/mygroupfile",
      "--quiet";
}

sub set_tool_name {
    './pussh.pl';
}

sub set_glob_string {
    my ($mergeTestFile) = @_;
    if ( -d $mergeTestFile ) {
        $mergeTestFile .= '/*';
    } else {
        $mergeTestFile .= '*';
    }
    return $mergeTestFile;
}    ## --- end sub set_glob_string
