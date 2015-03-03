package Mojolicious::Plugin::BModel;

use 5.010;
use strict;
use warnings;
use Carp qw/ croak /;
use File::Find qw/ find /;

use Mojo::Loader;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = 0.011;

my $MODEL_DIR  = 'Model'; # directory in poject for Model-modules
my $BASE_MODEL = 'Base';  # default name for Base model
my $CREATE_DIR = 1;
my $USE_BASE_MODEL = 1;
my %MODULES = ();

sub register {
    my ( $self, $app, $conf ) = @_;

    my $app_name      = ref $app;
    my $path_to_model = $app->home->lib_dir . '/' . $app_name . '/' . $MODEL_DIR;
    my $dir_exists    = $self->check_model_dir( $path_to_model );
    my $create_dir    = $conf->{create_dir} || $CREATE_DIR;

    if ( exists $conf->{use_base_model} && $conf->{use_base_model} == 0 ) {
        $USE_BASE_MODEL = 0;
    }
    if ( $USE_BASE_MODEL && $conf->{base_model} ) {
        $BASE_MODEL = $conf->{base_model};
    }

    if ( ! $dir_exists && ! $create_dir ) {
        warn "Directory $app_name/$MODEL_DIR does not exist";
        return 1;
    }
    elsif ( ! $dir_exists && $create_dir ) {
        mkdir $path_to_model or croak "Could not create directory $path_to_model : $!";
    }

    $self->generate_base_model( $path_to_model, $app_name ) if $USE_BASE_MODEL;
    $self->load_models( $path_to_model, $app_name, $app );

    $app->helper(
        model => sub {
            my ( $self, $model_name ) = @_;
            $model_name =~ s/\/+/::/g;
            croak "Unknown model $model_name" unless $MODULES{ $model_name };
            return $MODULES{ $model_name };
        }
    );

    return 1;
}

sub check_model_dir {
    my ( $self, $path_to_model ) = @_;

    return 1 if -e $path_to_model && -d $path_to_model;
    return;
}

sub load_models {
    my ( $self, $path_to_model, $app_name, $app ) = @_;

    my $model_path = "$app_name\::$MODEL_DIR";
    my @model_dirs = ( $model_path );

    find(
        sub {
            return if ! -d $File::Find::name || $File::Find::name eq $path_to_model;
            my $dir_name = $File::Find::name;
            $dir_name =~ s/$path_to_model\/?(.+)/$1/;
            $dir_name =~ s/(\/)+/::/g;
            push @model_dirs, $model_path . '::' . $dir_name;
        },
        ( $path_to_model )
    );

    my $base_model = '';

    if ( $USE_BASE_MODEL ) {
        $base_model  = $model_path . '::' . $BASE_MODEL;
        my $base_load_err = Mojo::Loader->load( $base_model );
        croak "Loading base model $base_model failed: $base_load_err" if ref $base_load_err;
        {
            no strict 'refs';
            *{ "$base_model\::app" } = sub { $app };
            use strict 'refs';
        }
    }

    for my $dir ( @model_dirs ) {
        my $model_packages = Mojo::Loader->search( $dir );
        for my $pm ( grep { $_ ne $base_model } @{ $model_packages } ) {
            my $load_err = Mojo::Loader->load( $pm );
            croak "Loading '$pm' failed: $load_err" if ref $load_err;
            my ( $basename ) = $pm =~ /$model_path\::(.*)/;
            $MODULES{ $basename } = $USE_BASE_MODEL ? $pm->new : $pm->new( app => $app );
        }
    }

    return 1;
}

sub generate_base_model {
    my ( $self, $path_to_model, $app_name ) = @_;

    my $base_model = $path_to_model . '/' . $BASE_MODEL . '.pm';
    return if -e $base_model;

    system( "touch $base_model" );

    my $base_model_name  = $app_name . '::' . $MODEL_DIR . '::' . $BASE_MODEL;
    my $module_data = "package $base_model_name;\n\nuse strict;\nuse warnings;\n\n";
    $module_data .= "use Mojo::Base -base;\n\n";
    $module_data .= "has config => sub { my \$self = shift; return \$self->app->config };\n\n1;\n";

    open( BASE_MODEL, '>', $base_model ) or croak "Can't open $base_model: $!";
    print BASE_MODEL $module_data;
    close( BASE_MODEL );

    return 1;
}

1;

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::BModel - Catalyst-like models in Mojolicious

=head1 SYNOPSIS

    # Mojolicious

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

=head1 DESCRIPTION

Mojolicious::Plugin::BModel adds the ability to work with models in Catalyst

=head1 LICENSE

Copyright (C) Alexander Ruzhnikov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Alexander Ruzhnikov E<lt>ruzhnikov85@gmail.comE<gt>

=cut

