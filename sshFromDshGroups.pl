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

our $VERSION = 0.3;

use Net::OpenSSH;
use File::Slurp 'read_file';
use Parallel::ForkManager;

use FindBin;
use lib "$FindBin::Bin/lib";
use Cli 0.2;
use SSH 0.3;
use Carp 'croak';


my $params = Cli::getCliParams();

my $dshGroupPath = $ENV{HOME}."/.dsh/group/";
my $serverpath  = $params->{gfile} || $dshGroupPath.$params->{gdsh};

my @serverArray = read_file( $serverpath );
my $numberOfServers = scalar @serverArray;
my $numberOfConnections = $params->{'num_connections'} ? $params->{'num_connections'} : $numberOfServers;

say "Number of servers from the configfiles : $numberOfServers";
say "Number of maximum parallel connections : $numberOfConnections";
say "Connecting to the following servers :\n" . join "", @serverArray;

my $pm = Parallel::ForkManager->new( $numberOfConnections );

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
    my $sshConnection = SSH->new( $server ) or croak "Couldn't connect to server $server";
    $sshConnection->putFileOnServer( $params->{destination}, $params->{script});
    $sshConnection->executeOnServer( $params->{destination}, $params->{script});
    my $copiedTo = $sshConnection->getFileFromServer( $params->{destination}, $params->{resultfile} );

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
    unlink for (@$tmpFilePaths);
}


