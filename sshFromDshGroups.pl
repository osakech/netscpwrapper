#!/usr/bin/env perl
#===============================================================================
#
#         FILE: sshFromDshGroups.pl
#
#        USAGE: ./sshFromDshGroups.pl
#
#  DESCRIPTION: Lets you copy a program of your choice on multiple servers and then execute it and then collect the output data from the server and merge the output on your local machine.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alexandros Kechagias (osakech@gmail.com),
#      VERSION: 0.1
#      CREATED: 22.10.2016 20:35:17
#===============================================================================

use strict;
use warnings;
use feature 'say';

#TODO : Support Config files
#TODO : Ignore knownhosts
#TODO : Modular
#TODO : Tests TDD and regression
#TODO : Enable plugins
#TODO : Installable package
#TODO : Pipe output from Servers
#TODO : use GroupFiles; # write a module for importing group files. thinking about merging multiple group files and lists and ignore empty lines, maybe check for validity of the lines? 

use Net::OpenSSH;
use File::Slurp 'read_file';
use Net::SCP;
use Parallel::ForkManager;

use FindBin;
use lib "$FindBin::Bin/lib";
use Cli;

my $params = Cli::getCliParams();

my $dshGroupPath = $ENV{HOME}."/.dsh/group/";
my $serverpath  = $params->{gfile} || $dshGroupPath.$params->{gdsh};

my @serverArray = read_file( $serverpath );
say @serverArray;

print "Connecting to the following servers :\n" . join "", @serverArray;

my $pm = Parallel::ForkManager->new( scalar @serverArray );

# data structure retrieval and handling
my @tmpFilePaths;
$pm->run_on_finish(    # called BEFORE the first call to start()
    sub {
        my ( $pid, $exit_code, $ident, $exit_signal, $core_dump,
            $data_structure_reference )
          = @_;
        push @tmpFilePaths, $$data_structure_reference
          if ($data_structure_reference);
    }
);

DATA_LOOP:
foreach my $server (@serverArray) {
    $pm->start() and next DATA_LOOP;
    chomp $server;

    putFileOnServer( $server, $params->{destination}, $params->{script});
    executeOnServer( $server, $params->{destination}, $params->{script});
    my $copiedTo = getFileFromServer( $server, $params->{destination}, $params->{resultfile} );

    $pm->finish( 0, \$copiedTo );
}

$pm->wait_all_children();
mergeFiles( \@tmpFilePaths );

#TODO: deleteFilesOnServer();

exit;

sub mergeFiles {
    my ($tmpFilePaths) = @_;
    my $filesToMerge = join ' ', @$tmpFilePaths;
    my $ts = time();
    `cat $filesToMerge > grepLog_sids_$ts`;

    #    `cat greplog_header $filesToMerge > grepLog_results_$ts`;
}

sub getFileFromServer {
    my ( $server, $copyToDir, $fileToGet ) = @_;
    my $scp = Net::SCP->new($server);
    $scp->cwd($copyToDir);
    my $copyLocalyPath = join "_", ( $fileToGet, $server );
    unlink $copyLocalyPath;
    $scp->get( $fileToGet, $copyLocalyPath );
    return $copyLocalyPath;
}

sub executeOnServer {
    my ( $server, $copyToDir, $scriptToExecute ) = @_;
    my $ssh = Net::OpenSSH->new($server);
    $ssh->error and die "Couldn't establish SSH connection: " . $ssh->error;
    $ssh->system( join '/', ( $copyToDir, $scriptToExecute ) );
}

sub putFileOnServer {
    my ( $server, $copyToDir, $scriptToExecute ) = @_;
    my $scp = Net::SCP->new($server);
    $scp->cwd($copyToDir);
    $scp->put($scriptToExecute);
}

#sub executeOnServerAndPipe{
#    my($server,$copyToDir,$scriptToExecute) = @_;
#    my $ssh = Net::OpenSSH->new($server);
#    $ssh->error and die "Couldn't establish SSH connection: ". $ssh->error;
#    my ($rout, $err) = $ssh->pipe_out(join '/', ($copyToDir,$scriptToExecute) );
#    $ssh->error and die "remote command failed: " . $ssh->error;
#    my @dataRows;
#    while (<$rout>) {
#        push @dataRows , $_;
#    }
#    close $rout;
#    return \@dataRows;
#
#}

