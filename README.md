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
            }
        );
    }

    # in controller:
    sub my_controller {
        my $self = shift;

        my $config_data = $self->model('MyModel')->get_conf_data('field');
    }

    # in <your_app>/lib/Model/MyModel.pm:

    use Mojo::Base 'Mojolicious::Model::Base';

    sub get_conf_data {
        my ( $self, $field ) = @_;
        
        # as example
        return $self->config->{field};
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

# EXAMPLE

    # the example of a new application:
    bash~$ cpan install Mojolicious::Plugin::BModel
    bash~$ mojo generate app MyApp
    bash~$ cd my_app/
    bash~$ vim MyApp.pm

    # edit MyApp.pm:
    package MyApp;

    use Mojo::Base 'Mojolicious';

    sub startup {
        my $self = shift;

        $self->config->{testkey} = 'MyTestValue';

        $self->plugin( 'BModel' ); # used the default options

        my $r = $self->routes;
        $r->get('/')->to( sub {
                my $self = shift;

                my $testkey_val = $self->Model('MyModel')->get_conf_key('testkey');
                $self->render( text => 'Value: ' . $testkey_val );
            }
        );
    }

    1;

    # end of edit file

    bash~$ morbo -v script/my_app

    # When you connect, the plugin will check if the folder "lib/Model". If the folder does not exist,
    # create it.
    # If the 'use_base_model' is set to true will be loaded module "Mojolicious::Model::Base"
    # with the base model.
    # Method 'app' base model will contain a link to your application.
    # Method 'config' base model will contain a link to config of yor application.

    # create a new model
    bash~$ touch lib/MyApp/Model/MyModel.pm
    bash~$ vim lib/MyApp/Model/MyModel.pm

    # edit file

    package MyApp::Model::MyModel;

    use strict;
    use warnings;

    use Mojo::Base 'Mojolicious::Model::Base';

    sub get_key {
        my ( $self, $key ) = @_;

        return $self->config->{ $key } || '';
    }

    1;
    
    # end of edit file

    # Open in your browser address http://127.0.0.1:3000 and you'll see text 'Value: MyTestValue'

# LICENSE

Copyright (C) 2015 Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Alexander Ruzhnikov <ruzhnikov85@gmail.com>
