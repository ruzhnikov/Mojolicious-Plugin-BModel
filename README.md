[![Build Status](https://travis-ci.org/ruzhnikov/Mojolicious-Plugin-BModel.svg?branch=master)](https://travis-ci.org/ruzhnikov/Mojolicious-Plugin-BModel)
# NAME

Mojolicious::Plugin::BModel - Catalyst-like models in Mojolicious

# SYNOPSIS

    # Mojolicious

    # in your app:
    sub startup {
        my $self = shift;

        $self->plugin( 'BModel',
            {
                use_base_model => 1,
                create_dir     => 1,
                base_model     => 'Base',
            }
        );
    }

    # in controller:
    sub my_controller {
        my $self = shift;

        my $config_data = $self->model('MyModel')->get_conf_data('field');
    }

    # in <your_app>/lib/Model/MyModel.pm:
    sub get_conf_data {
        my ( $self, $field ) = @_;
        
        # as example
        return $self->app->config->{field};
    }

# DESCRIPTION

Mojolicious::Plugin::BModel adds the ability to work with models in Catalyst

# LICENSE

Copyright (C) Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Alexander Ruzhnikov <ruzhnikov85@gmail.com>
