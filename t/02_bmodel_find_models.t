#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use List::Util qw/ first /;
use File::Spec;
use Mojo::Home;

use Test::More;

use_ok( 'Mojolicious::Plugin::BModel' );

my $app_name = 'MyTestApp02';

remove_dir( $app_name ) if -e $app_name;

require 'utils.pl';

my $root_dir   = File::Spec->catfile( $app_name, 'Model' );
my @model_dirs = qw/ SubDir FirstMoreDir SecondMoreDir /;
my $thirt_dir  = 'LocalSubDir';

# prepare local temp directories
make_dir( $root_dir ); # at first, make root dir of our pseudo application
make_subdirs( $root_dir, [ @model_dirs ], [ $thirt_dir ] );

# prepare absolute path to here because we need absolute path for direcotry with models
my $home = Mojo::Home->new;
$home->detect;

my $bmodel        = Mojolicious::Plugin::BModel->new;
my $path_to_model = File::Spec->catfile( $home->to_string, $root_dir );
my $model_path    = $app_name . '::Model';
my $found_models  = $bmodel->find_models( $path_to_model, $model_path );

is( ref $found_models, 'ARRAY', "List of models is array" );
subtest "Check search result" => sub {
    for my $model_dir ( @model_dirs ) {
        my $model_dir_path = $model_path . '::' . $model_dir;
        my $has_model_dir  = first { $_ eq $model_dir_path } @{ $found_models };
        ok( defined $has_model_dir, "Search result contains $model_dir" );

        my $model_subdir_path = $model_dir_path . '::' . $thirt_dir;
        my $has_model_subdir  = first { $_ eq $model_subdir_path } @{ $found_models };
        ok( defined $has_model_subdir, 'Found subdir in models dir' );
    }
};

remove_dir( $app_name );

done_testing();
