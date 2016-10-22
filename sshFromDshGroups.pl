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

#TODO : Add CLI options
#TODO : Support Config files
#TODO : Ignore knownhosts
#TODO : Tests
#TODO : Modular
#TODO : Enable plugins
#TODO : Installable package

use Net::OpenSSH;
use File::Slurp 'read_file';
use Net::SCP;
use Parallel::ForkManager;

my $dshGroupPath = $ENV{'HOME'}.'/.dsh/group/';
my $dshGroup = 'allmyservers';
my $copyToDirOnServer = "/tmp";
my $scriptToExecute = "greolog.pl";
my $fileToGet = "/tmp/grepLog_tmp";

my @serverArray = read_file($dshGroupPath.$dshGroup);

print "Connecting to the following servers :\n" . join "",@serverArray;

my @tmpFilePaths;
my $pm = Parallel::ForkManager->new(scalar @serverArray);

# data structure retrieval and handling
$pm->run_on_finish ( # called BEFORE the first call to start()
  sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;
    push @tmpFilePaths, $$data_structure_reference if ($data_structure_reference);
  }
);

DATA_LOOP:
foreach my $server (@serverArray) {
    $pm->start() and next DATA_LOOP;
    chomp $server;

    putFileOnServer($server,$copyToDirOnServer,$scriptToExecute);
    executeOnServer($server,$copyToDirOnServer,$scriptToExecute);
    my $copiedTo = getFileFromServer($server,$copyToDirOnServer,$fileToGet);

    $pm->finish(0,\$copiedTo);
}

$pm->wait_all_children();
mergeFiles(\@tmpFilePaths);
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
    my($server,$copyToDir,$fileToGet) = @_;
    my $scp = Net::SCP->new( $server);
    $scp->cwd($copyToDir);
    my $copyLocalyPath = join "_" , ($fileToGet,$server);
    unlink $copyLocalyPath;
    $scp->get($fileToGet, $copyLocalyPath );
    return $copyLocalyPath;
}

sub executeOnServer{
    my($server,$copyToDir,$scriptToExecute) = @_;
    my $ssh = Net::OpenSSH->new($server);
    $ssh->error and die "Couldn't establish SSH connection: ". $ssh->error;
    $ssh->system(join '/', ($copyToDir,$scriptToExecute) );
}

sub putFileOnServer {
    my ($server,$copyToDir,$scriptToExecute) = @_;
    my $scp = Net::SCP->new( $server);
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


