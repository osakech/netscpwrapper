#!/usr/bin/env perl
#===============================================================================
#
#         FILE: pussh.pl
#
#        USAGE: ./pussh.pl
#
#  DESCRIPTION: Lets you copy a program of your choice on multiple servers and
#               then execute it and then collect the output data from the server
#               and merge the output on your local machine.
#
#       AUTHOR: Alexandros Kechagias (osakech@gmail.com),
#      VERSION: 0.5
#      CREATED: 22.10.2016 20:35:17
#===============================================================================

use strict;
use warnings;
use feature 'say';

return 1 if caller();

our $VERSION = 0.6;

use Parallel::ForkManager;

use FindBin;
use lib "$FindBin::Bin/lib";
use PuppeteerSSH::Cli 0.3;
use PuppeteerSSH::SSH 0.4;
use PuppeteerSSH::Resultfiles 0.3;
use PuppeteerSSH::Groupfiles 0.1;

my $cliParams = PuppeteerSSH::Cli::getCliParams();

my $inputData = PuppeteerSSH::Groupfiles->new( $cliParams->{gfile}, $cliParams->{gdsh} );
my $serverArray = $inputData->getServers;

my $numberOfServers = scalar @$serverArray;
my $numberOfConnections = $cliParams->{'num_connections'} ? $cliParams->{'num_connections'} : $numberOfServers;

unless ( $cliParams->{'quiet'} ){
    say "Number of servers from the configfiles : $numberOfServers";
    say "Number of maximum parallel connections : $numberOfConnections";
    say "Connecting to the following servers :\n" . join "\n", map { " * " . $_ } @$serverArray;
}

my $pm = Parallel::ForkManager->new($numberOfConnections);

# data structure retrieval and handling
my @tmpResultfileMeta;
$pm->run_on_finish(    # called BEFORE the first call to start()
    sub {
        my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference ) = @_;
        push @tmpResultfileMeta, $data_structure_reference
          if ($data_structure_reference);
    }
);

DATA_LOOP:
foreach my $server (@$serverArray) {
    $pm->start() and next DATA_LOOP;
    chomp $server;
    my $sshConnection = PuppeteerSSH::SSH->new( $server, $cliParams->{ssh_option} ); # TODO don't spawn a new one for every fork
    $sshConnection->putFileOnServer( $cliParams->{destination}, $cliParams->{script} );
    $sshConnection->executeOnServer( $cliParams->{destination}, $cliParams->{script} );
    my $copiedTo       = $sshConnection->getFileFromServer( $cliParams->{resultfile} );
    my %connectionData = (
        localTempPath => $copiedTo,                         # TODO use filehandle instead of filename in v0.6
        cleanHostline => $sshConnection->getCleanHostline,
    );
    $pm->finish( 0, \%connectionData );
}

$pm->wait_all_children();
my $resultfileOptions = {
    localfile   => $cliParams->{localfile},
    localdir    => $cliParams->{localdir},
    timestamped => $cliParams->{timestamped},
    increment   => $cliParams->{increment},
    no_merge    => $cliParams->{no_merge},
};

PuppeteerSSH::Resultfiles::create( \@tmpResultfileMeta, $resultfileOptions );

exit;

