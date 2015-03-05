package Mojolicious::Model::Base;

use Mojo::Base -base;

has config => sub {
    my $self = shift;
    return $self->app->config
};

1;
