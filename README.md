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

## Options

- **use\_base\_model**

        A flag that specifies the use of the basic model.
        0 - do not use, 1 - use. Enabled by default

- **create\_dir**

        A flag that determines automatically create the folder '<yourapp>/lib/Model'
        if it does not exist. 0 - do not create, 1 - create. Enabled by default

- **base\_model**

        Name of basic model. By default is 'Base' (<yourapp>/lib/Model/Base.pm).
        This file is automatically created if it does not exist.

# LICENSE

Copyright (C) 2015 Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Alexander Ruzhnikov <ruzhnikov85@gmail.com>
