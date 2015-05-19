package Mojolicious::BModel::Base;

use Mojo::Base -base;

our $VERSION = '0.05';

has config => sub {
    my $self = shift;
    return $self->app->config
};

1;
