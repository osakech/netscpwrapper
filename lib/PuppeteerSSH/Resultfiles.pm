#
#===============================================================================
#
#         FILE: MergeFiles.pm
#
#  DESCRIPTION: This is the play where we merge files
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 0.1
#      CREATED: 01/20/2017 04:36:24 PM
#===============================================================================
package PuppeteerSSH::Resultfiles;

our $VERSION = '0.3';

use strict;
use warnings;
use Carp qw(carp croak);
use File::Copy 'copy';
use PuppeteerSSH::Util::IncrFilename 0.1;

sub create {
    my ( $tmpResultfileMeta, $filename, $addTimestamp, $incrFilename, $noMerge ) = @_;
    if ($noMerge){
        _copyFiles($tmpResultfileMeta, $incrFilename, $addTimestamp);
    } else {
        my $resultfile_file_name = _getFileName( 'merged_result', $filename, $addTimestamp, $incrFilename );
        _concatFiles($resultfile_file_name, $tmpResultfileMeta);
    }
    return;
}

sub _deleteTmpFiles {
    my ($tmpResultfileMeta) = @_;

    foreach my $file (@$tmpResultfileMeta) {
        unlink $file or carp "Could not unlink $file: $!";
    }

    return;
}    ## --- end sub _deleteTmpFiles


sub _copyFiles {
    my	( $tmpResultfileMeta , $incrFilename, $addTimestamp)	= @_;

    foreach my $tmpFileMeta (@$tmpResultfileMeta) {
      my $resultfilename = _getFileName( $tmpFileMeta->{cleanHostline}, undef, $addTimestamp, $incrFilename );
      copy($tmpFileMeta->{localTempPath}, $resultfilename ) or die "Copy failed: $!";
    }

    return;
} ## --- end sub _copyFiles

sub _concatFiles {
    my ( $resultfile_file_name, $tmpResultfileMeta ) = @_;
    open my $resultfile, '>', $resultfile_file_name
      or croak "$0 : failed to open  output file '$resultfile_file_name' : $!\n";
    foreach my $tmpFileMeta (@$tmpResultfileMeta) {
        open my $tmpFile, '<', $tmpFileMeta->{localTempPath}
          or croak "$0 : failed to open  input file '$tmpFileMeta->{localTempPath}' : $!\n";
        foreach my $line (<$tmpFile>) {
            print $resultfile $line;
        }
        close $tmpFile
          or carp "$0 : failed to close input file '$tmpFileMeta' : $!\n";
    }
    close $resultfile
      or carp "$0 : failed to close output file '$resultfile_file_name' : $!\n";
    return;
}    ## --- end sub _concatFiles

sub _getFileName {
    my ( $defaultname , $userFilename, $addTimestamp, $incrFilename ) = @_;
    my $resultfile_file_name = $defaultname;
    if ($userFilename) {
        $resultfile_file_name = _setCustomName($resultfile_file_name,$userFilename);
    }
    if ($addTimestamp) {
        $resultfile_file_name = _addTimestamp($resultfile_file_name)
    }
    if ($incrFilename) {
        $resultfile_file_name = PuppeteerSSH::Util::IncrFilename::getNextFilename($resultfile_file_name);
    }
    return $resultfile_file_name;
}    ## --- end sub _mergeFileName


sub _setCustomName {
    my	( $resultfile_file_name,$filename )	= @_;
    return $filename;
} ## --- end sub _setCustomName

sub _addTimestamp {
    my	( $resultfile_file_name )	= @_;
    my $ts = time();
    $resultfile_file_name .= ( ( not $resultfile_file_name ) ? '' : '_' ) . $ts;
    return $resultfile_file_name;
} ## --- end sub _addTimestamp
1;

