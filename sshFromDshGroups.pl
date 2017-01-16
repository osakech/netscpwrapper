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
#      VERSION: 0.2
#      CREATED: 22.10.2016 20:35:17
#===============================================================================

use strict;
use warnings;
use feature 'say';

use constant DEBUG => 0;
our $VERSION = 0.2;

#TODO : Documentation(!)
#TODO : User Documentation(!)
#TODO : Support Config files with default values?
#TODO : StrictHostKeyChecking no option?
#TODO : more Modular?
#TODO : Tests TDD and regression
#TODO : Enable plugins?
#TODO : Installable package?
#TODO : activate Pipe output from Servers?
#TODO : use GroupFiles and merge cli servers?; # write a module for importing group files. thinking about merging multiple group files and lists and ignore empty lines, maybe check for validity of the lines? 
#TODO : come up with a good name for this tool ... like sexecuter ... tehehe (!)
#TODO : Config module or params enough?
#TODO : deleteFilesOnServer()

use Net::OpenSSH;
use File::Slurp 'read_file';
use Parallel::ForkManager;

use FindBin;
use lib "$FindBin::Bin/lib";
use Cli '0.1';

my $params = Cli::getCliParams();

my $dshGroupPath = $ENV{HOME}."/.dsh/group/";
my $serverpath  = $params->{gfile} || $dshGroupPath.$params->{gdsh};

my @serverArray = read_file( $serverpath );

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

exit;

sub mergeFiles {
    my ($tmpFilePaths) = @_;
    my $filesToMerge = join ' ', @$tmpFilePaths;
    my $ts = time();
    `cat $filesToMerge > merged_result_$ts`;

    #    `cat greplog_header $filesToMerge > grepLog_results_$ts`;
}

sub getFileFromServer {
    my ( $server, $copyToDir, $fileToGet ) = @_;
#    my $scp = Net::SCP->new($server);
    my $scp = Net::OpenSSH->new($server);
    #$scp->cwd($copyToDir);
    my $copyLocalPath = join "_", ( $fileToGet, $server );
    unlink $copyLocalPath;
    $scp->scp_get($fileToGet, $copyLocalPath );
    return $copyLocalPath;
}
#$ssh->scp_get(\%opts, $remote1, $remote2,..., $local_dir_or_file)
#$ssh->scp_put(\%opts, $local, $local2,..., $remote_dir_or_file)

sub executeOnServer {
    my ( $server, $copyToDir, $scriptToExecute ) = @_;
    my $ssh = Net::OpenSSH->new($server);
    $ssh->error and die "Couldn't establish SSH connection: " . $ssh->error;
    if (DEBUG){
        say $$.' executeOnServer -> server -> '. $server;
        say $$.' executeOnServer -> copyToDir -> '. $copyToDir;
        say $$.' executeOnServer -> scriptToExecute -> '. $scriptToExecute;
    }
    $ssh->system( join '/', ( $copyToDir, $scriptToExecute ) );
}

sub putFileOnServer {
    my ( $server, $copyToDir, $scriptToExecute ) = @_;
    my $ssh = Net::OpenSSH->new($server);
    $ssh->error and die "Couldn't establish SSH connection: " . $ssh->error;
#    $scp->cwd($copyToDir);
#    $scp->put($scriptToExecute);
    if (DEBUG){
	    say $$.' putFileOnServer -> server -> '. $server;
	    say $$.' putFileOnServer -> copyToDir -> '. $copyToDir;
	    say $$.' putFileOnServer -> scriptToExecute -> '. $scriptToExecute;
    }
    $ssh->scp_put($scriptToExecute,$copyToDir);
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

