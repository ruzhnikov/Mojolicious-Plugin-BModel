package Mojolicious::Plugin::BModel;

use 5.010;
use strict;
use warnings;
use Carp qw/ carp croak /;
use File::Find qw/ find /;
use List::Util qw/ first /;
use File::Spec;

use Mojo::Loader;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.09_1';

my $DEFAULT_CREATE_DIR = 1;
my $DEFAULT_MODEL_DIR  = 'Model'; # directory of poject for the Model-modules
my %MODULES    = ();
my $BASE_MODEL = 'Mojolicious::BModel::Base';

sub register {
    my ( $self, $app, $conf ) = @_;

    my $app_name  = ref $app; # name of calling Mojo app

    # namespace path to Models dir. By default it is the name of application, but it can be redefine.
    # For example, namespace can be MyPath::ToModel or any other
    my $namespace = $conf->{namespace} ? $conf->{namespace} : $app_name;
    if ( ! $self->_check_namespace( $namespace ) ) {
        croak "Wrong format of namespace $namespace. Exit";
    }

    my $namespace_path = $self->_convert_namespace_to_path( $namespace );

    # work with considering operation system
    my $path_to_model = File::Spec->catfile( $app->home->child('lib')->to_string, $namespace_path, $DEFAULT_MODEL_DIR );
    my $dir_exists    = $self->_check_model_dir( $path_to_model );
    my $to_create_dir = exists $conf->{create_dir} ? $conf->{create_dir} : $DEFAULT_CREATE_DIR;

    if ( ! ( $dir_exists && $to_create_dir ) ) {
        carp "Directory " . File::Spec->catfile( $namespace_path, $DEFAULT_MODEL_DIR ) . " does not exist";
        return 1;
    }
    elsif ( ! $dir_exists && $to_create_dir ) {
        mkdir $path_to_model or croak "Could not create directory $path_to_model : $!";
    }

    $self->load_models( $path_to_model, $namespace, $app );

    $app->helper(
        model => sub {
            my ( $self, $model_name ) = @_;
            croak "Unknown model $model_name" if ! exists $MODULES{ $model_name };
            return $MODULES{ $model_name };
        }
    );

    return 1;
}

# check a path to the 'Model' dir
sub _check_model_dir {
    my ( $self, $path_to_model ) = @_;

    return 1 if -e $path_to_model && -d $path_to_model;
    return;
}

# check for validation of namespace
sub _check_namespace {
    my ( $self, $namespace ) = @_;

    my @splitted_namespace = $self->_separate_namespace_name( $namespace );
    return if ! scalar @splitted_namespace;

    my $found_wrong_name = first { $_ !~ m/[a-zA-Z0-9]/ } @splitted_namespace;
    return if $found_wrong_name;

    return 1;
}

# convert name like 'Aaaa::Bbbbb::Cccc' to 'Aaaa/Bbbbb/Cccc' for Unix-like OS or 'Aaaa\Bbbbb\Cccc' for Windows
sub _convert_namespace_to_path {
    my ( $self, $namespace ) = @_;

    my @splitted_namespace = $self->_separate_namespace_name( $namespace );
    my $path = scalar @splitted_namespace == 1 ? $splitted_namespace[0] : File::Spec->catfile( @splitted_namespace );

    return $path;
}

sub _separate_namespace_name {
    my ( $self, $namespace ) = @_;

    my @splitted_name = split( /\:\:/, $namespace );

    return @splitted_name;
}

sub _convert_model_dirs_array {
    my ( $self, @dirs ) = @_;

    my $canonical_name;

    for my $dir ( @dirs ) {
        next if $dir =~ m/^\s*$/;
        $canonical_name = ( defined $canonical_name ) ? $canonical_name . '::' . $dir : $dir;
    }

    return $canonical_name;
}

sub find_models {
    my ( $self, $path_to_model, $model_path ) = @_;

    my @model_dirs = ( $model_path );

    # find all subdirs in the directory of model
    find(
        sub {
            return if ! -d $File::Find::name || $File::Find::name eq $path_to_model;
            my $dir_name = $File::Find::name;
            $dir_name =~ s/$path_to_model//; # remove path to model from directory

            # split dir path name and convert it into name like 'aaa::bbb::ccc'
            my @dirs = File::Spec->splitdir( $dir_name );
            my $canonical_dir_name = $self->_convert_model_dirs_array( @dirs );
            if ( ! $canonical_dir_name ) {
                carp "Cannot parse dir name $dir_name";
                return;
            }
            push @model_dirs, $model_path . '::' . $canonical_dir_name;
        },
        ( $path_to_model )
    );

    return \@model_dirs;
}

# recursive search and download modules with models
sub load_models {
    my ( $self, $path_to_model, $namespace, $app ) = @_;

    my $model_path = $namespace . '::' . $DEFAULT_MODEL_DIR;
    my @model_dirs = @{ $self->find_models( $path_to_model, $model_path ) };

    my $base_load_err = Mojo::Loader::load_class( $BASE_MODEL );
    croak "Loading base model $BASE_MODEL failed: $base_load_err" if ref $base_load_err;
    {
        no strict 'refs';
        *{ "$BASE_MODEL\::app" } = sub { $app };
    }

    # load modules from every dirs and subdirs of model
    for my $dir ( @model_dirs ) {
        my @model_packages = Mojo::Loader::find_modules( $dir );
        for my $pm ( @model_packages ) {
            my $load_err = Mojo::Loader::load_class( $pm );
            croak "Loading '$pm' failed: $load_err" if ref $load_err;
            my ( $basename ) = $pm =~ /$model_path\::(.*)/;
            $MODULES{ $basename } = $pm->new;
        }
    }

    return 1;
}

1;

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::BModel - Catalyst-like models in Mojolicious

=head1 SYNOPSIS

    # Mojolicious

    # in your app:
    sub startup {
        my $self = shift;

        $self->plugin( 'BModel', { %Options } );
    }

    # in controller:
    sub my_controller {
        my $self = shift;

        my $config_data = $self->model('MyModel')->get_conf_data('field');
    }

    # in <your_app>/lib/<namespace>/Model/MyModel.pm:

    use Mojo::Base 'Mojolicious::BModel::Base';

    sub get_conf_data {
        my ( $self, $field ) = @_;

        # as example
        return $self->config->{field};
    }

=head1 DESCRIPTION

    This module provides you an ability to separate a business-logic from controllers into a 'model' class
    and use this one by the method 'model' of a controller object.
    This approach is using in the L<Catalyst framework|https://metacpan.org/pod/Catalyst>.

    All model classes have to be inherited from the class 'Mojolicious::BModel::Base', examples see below.

    This module works in Unix-like and Windows systems.

=head2 Options

=over

=item B<create_dir>

    A boolean flag that determines automatically create the folder '<yourapp>/lib/<namespace>/Model'
    if it does not exist. 0 - do not create, 1 - create. Enabled by default

=item B<namespace>

    A place in the '/lib' folder of application where there are your model classes. By default it is the name of application.
    The value of this parameter should be in the format with a delimiter '::', for example 'Aaaaa::Bbbb::Cccc'.
    This string(in format 'Aaaaa::Bbbb::Cccc') will be converted to the path 'Aaaaa/Bbbb/Cccc'(or 'Aaaaa\Bbbb\Cccc' for Microsoft Windows) and
    the absolute path to the your Model dir will looks like '<your app>/lib/Aaaaa/Bbbb/Cccc/Model' and all Model classes will be sought in this direcory.

=back

=cut

=head1 EXAMPLE

    # the example of a new application:
    % cpan install Mojolicious::Plugin::BModel
    % mojo generate app MyApp
    % cd my_app/
    % vim lib/MyApp.pm

    # edit file:
    package MyApp;

    use Mojo::Base 'Mojolicious';

    sub startup {
        my $self = shift;

        $self->config->{testkey} = 'MyTestValue';

        $self->plugin( 'BModel' ); # used the default options

        my $r = $self->routes;
        $r->get('/')->to( 'root#index' );
    }

    1;

    # end of edit file

    # create a new controller

    % touch lib/Controller/Root.pm
    % vim lib/Controller/Root.pm

    # edit file

    package MyApp::Controller::Root;

    use Mojo::Base 'Mojolicious::Controller';

    sub index {
        my $self = shift;

        my $testkey_val = $self->model('MyModel')->get_conf_key('testkey');
        $self->render( text => 'Value: ' . $testkey_val );
    }

    1;

    # end of edit file

    # When you connect, the plugin will check the folder "lib/MyApp/Model" exists.
    # By defaut the namespace 'MyApp' will be used.
    # If the folder 'lib/MyApp/Model' does not exist, this will be created.
    # The method 'app' of base model contains a link to your application.
    # The method 'config' of base model contains a link to config of yor application.

    # create a new model
    % touch lib/MyApp/Model/MyModel.pm
    % vim lib/MyApp/Model/MyModel.pm

    # edit file

    package MyApp::Model::MyModel;

    use strict;
    use warnings;

    use Mojo::Base 'Mojolicious::BModel::Base';

    sub get_conf_key {
        my ( $self, $key ) = @_;

        return $self->config->{ $key } || '';
    }

    1;

    # end of edit file

    % morbo -v script/my_app

    # Open in your browser address http://127.0.0.1:3000 and
    # you'll see text 'Value: MyTestValue'


=head1 LICENSE

Copyright (C) 2015-2017 Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Alexander Ruzhnikov E<lt>ruzhnikov85@gmail.comE<gt>

=cut

