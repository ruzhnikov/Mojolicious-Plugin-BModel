#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use File::Path qw/ rmtree /;
use List::Util qw/ first /;
use File::Spec;
use Mojo::Home;

use Test::More tests => 3;

use_ok( 'Mojolicious::Plugin::BModel' );

my $home = Mojo::Home->new;
$home->detect;

my $app_name      = 'MyTestApp02';
my $model_path    = $app_name . '::Model';
my @model_dirs    = qw/ SubDir FirstMoreDir SecondMoreDir /;
my $subdir        = 'LocalSubDir';
my $path_to_model = File::Spec->catfile( $home->to_string, $app_name, 'Model' );
my $bmodel        = Mojolicious::Plugin::BModel->new;

rmtree( $app_name ) if -e $app_name;

mkdir $home->to_string . '/' . $app_name or die "can't create folder $app_name: $!";
mkdir $path_to_model or die "can't create folder $path_to_model: $!";
for my $model_dir ( @model_dirs ) {
    mkdir "$path_to_model/$model_dir" or die "can't create folder $path_to_model/$model_dir: $!";
    mkdir "$path_to_model/$model_dir/$subdir" or die "$!";
}

my $found_models = $bmodel->find_models( $path_to_model, $model_path );

is( ref $found_models, 'ARRAY', "List of models is array" );

subtest "Check search result" => sub {
    for my $model_dir ( @model_dirs ) {
        my $model_dir_path = $model_path . '::' . $model_dir;
        my $has_model_dir  = first { $_ eq $model_dir_path } @{ $found_models };
        ok( defined $has_model_dir, "Search result contains $model_dir" );

        my $model_subdir_path = $model_dir_path . '::' . $subdir;
        my $has_model_subdir  = first { $_ eq $model_subdir_path } @{ $found_models };
        ok( defined $has_model_subdir, 'Found subdir in models dir' );
    }
};

rmtree( $app_name );

done_testing();
