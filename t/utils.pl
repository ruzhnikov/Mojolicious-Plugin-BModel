#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use File::Spec;
use File::Path qw/ remove_tree /;
use Carp qw/ croak carp /;

sub make_subdirs {
    my ( $root_dir, $subdirs, $thirt_dirs ) = @_;

    if ( ! $root_dir ) {
        croak "Root directory does not exist";
    }

    if ( ref $subdirs ne 'ARRAY' ) {
        croak "Parameter subdirs has to be ARRAYref";
    }

    # make subdirs and, if neccessary, thirt dir in each subdir
    for my $subdir ( @{ $subdirs } ) {
        File::Path::make_path( File::Spec->catfile( $root_dir, $subdir ) ) or croak "Cannot create subdir $subdir: $!";
        if ( $thirt_dirs && ref $thirt_dirs eq 'ARRAY' ) {
            for my $thirt_dir ( @{ $thirt_dirs } ) {
                File::Path::make_path( File::Spec->catfile( $root_dir, $subdir, $thirt_dir ) ) or carp "Cannot create thirt dir $thirt_dir in subdir $subdir: $!";
            }
        }
    }

    return 1;
}

sub make_dir {
    my $root_dir = shift;

    File::Path::make_path( $root_dir ) or croak "Cannot create root dir: $!";

    return 1;
}

sub make_mojo_app {
    my $app_name = shift;

    # ...
}

sub make_model_classes {
    # ...
}

sub remove_dir {
    my $dir = shift;

    return if ! $dir;

    remove_tree( $dir ) if -e $dir;

    return 1;
}

1;
