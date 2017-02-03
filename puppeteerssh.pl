#!/usr/bin/env perl
#===============================================================================
#
#         FILE: puppeteerssh.pl
#
#        USAGE: ./puppeteerssh.pl
#
#  DESCRIPTION: Lets you copy a program of your choice on multiple servers and
#               then execute it and then collect the output data from the server
#               and merge the output on your local machine.
#
#       AUTHOR: Alexandros Kechagias (osakech@gmail.com),
#      VERSION: 0.3
#      CREATED: 22.10.2016 20:35:17
#===============================================================================

use strict;
use warnings;
use feature 'say';

our $VERSION = 0.4;

use Parallel::ForkManager;
use File::Spec;
use Carp 'croak';

use FindBin;
use lib "$FindBin::Bin/lib";
use PuppeteerSSH::Cli 0.2;
use PuppeteerSSH::SSH 0.4;
use PuppeteerSSH::Util 0.2;
use PuppeteerSSH::Groupfiles 0.1;

my $cliParams = PuppeteerSSH::Cli::getCliParams();

# move to Groupfiles
my $inputData = PuppeteerSSH::Groupfiles->new( $cliParams->{gfile}, $cliParams->{gdsh} );
my $serverArray = $inputData->getServers;

my $numberOfServers = scalar @$serverArray;
my $numberOfConnections = $cliParams->{'num_connections'} ? $cliParams->{'num_connections'} : $numberOfServers;
say "Number of servers from the configfiles : $numberOfServers";
say "Number of maximum parallel connections : $numberOfConnections";
say "Connecting to the following servers :\n" . join "\n", map { " * " . $_ } @$serverArray;

my $pm = Parallel::ForkManager->new($numberOfConnections);

# data structure retrieval and handling
my @tmpFilePaths;
$pm->run_on_finish(    # called BEFORE the first call to start()
    sub {
        my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference ) = @_;
        push @tmpFilePaths, $$data_structure_reference
          if ($data_structure_reference);
    }
);

DATA_LOOP:
foreach my $server (@$serverArray) {
    $pm->start() and next DATA_LOOP;
    chomp $server;
    my $sshConnection = PuppeteerSSH::SSH->new( $server, $cliParams->{ssh_option} ) or croak "Couldn't connect to server $server";
    $sshConnection->putFileOnServer( $cliParams->{destination}, $cliParams->{script} );
    $sshConnection->executeOnServer( $cliParams->{destination}, $cliParams->{script} );
    my $copiedTo = $sshConnection->getFileFromServer( $cliParams->{resultfile} );
    $pm->finish( 0, \$copiedTo );
}

$pm->wait_all_children();

PuppeteerSSH::Util::mergeFiles( \@tmpFilePaths, $cliParams->{localname}, $cliParams->{timestamped});

exit;

