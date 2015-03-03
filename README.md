[![Build Status](https://travis-ci.org/ruzhnikov/Mojolicious-Plugin-Model.svg?branch=master)](https://travis-ci.org/ruzhnikov/Mojolicious-Plugin-Model)
# NAME

Mojolicious::Plugin::Model - Catalyst-like models in Mojolicious

# SYNOPSIS

    # Mojolicious

    sub startup {
        my $self = shift;

        $self->plugin( 'Model',
            {
                use_base_model => 1,
                create_dir     => 1,
                base_model     => 'Base',
            }
        );
    }

# DESCRIPTION

Mojolicious::Plugin::Model adds the ability to work with models in Catalyst

# LICENSE

Copyright (C) Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Alexander Ruzhnikov <ruzhnikov85@gmail.com>
