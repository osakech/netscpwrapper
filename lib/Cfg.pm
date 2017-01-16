#
#===============================================================================
#
#         FILE: Cfg.pm
#
#  DESCRIPTION: sets the configs
#
#       AUTHOR: Alexandros Kechagias (), osakech@gmail.com
#      VERSION: 1.0
#      CREATED: 25.10.2016 23:39:52
#===============================================================================
package Cfg;

die 'wip!';

use strict;
use warnings;

sub new {
    my $class = shift;
    my $params = shift;
    my $self = bless { params => $params }, $class;
    return $self;
}

sub _setCliParams {
    my ( $self ) = @_;
    $self->{config} = $self->{params};
    return $self;
}

#TODO setPaths
#TODO checkPaths

sub getConfig {
    my ($self, $params) = @_;
    $self->_setCliParams();

}

1;

