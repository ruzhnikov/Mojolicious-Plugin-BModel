package Mojolicious::BModel::Base;

use Mojo::Base -base;

our $VERSION = '0.010';

has config => sub {
    my $self = shift;
    return $self->app->config
};

1;

__END__

=encoding utf-8

=head1 NAME

Mojolicious::BModel::Base -- base class for models

=head1 SYNOPSIS

    package MyApp::Model::MyModel;

    use strict;
    use warnings;

    use Mojo::Base 'Mojolicious::BModel::Base';

    sub my_method {
        my $self = shift;

        say $self->app;     # your mojo application
        say $self->config;  # your application config. It can be also called through $self->app->config
    }

    1;

=head1 DESCRIPTION

    This is the base class for model classes. All model classes have to be inherited from this class

=head1 LICENSE

Copyright (C) 2015-2017 Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Alexander Ruzhnikov E<lt>ruzhnikov85@gmail.comE<gt>

=cut
