package Mojolicious::BModel::Base;

use Mojo::Base -base;

our $VERSION = '0.04';

has config => sub {
    my $self = shift;
    return $self->app->config
};

has model => sub {
    my $self = shift;
    return $self->app->model;
};

1;
