#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib ( "$Bin", "$Bin/../lib" );

use Test::More;

use_ok( 'Mojolicious::Plugin::BModel' );

my $model_path = 'Model';
my $bmodel = Mojolicious::Plugin::BModel->new;

require 'utils.pl';

subtest "folder of Model exists and it is folder" => sub {

    ok( $bmodel->can( '_check_model_dir' ), 'we can call this method' );

    make_dir( $model_path );
    ok( $bmodel->_check_model_dir( $model_path ), 'folder exists' );

    remove_dir( $model_path )
};

subtest "folder of Model exists but it is a simple file" => sub {
    SKIP: {
        skip "Skip for Windows" if $^O eq 'Win32';

        system( "touch $model_path" );

        ok( -e $model_path && ! -d $model_path, "$model_path is a simple file" );
        ok( ! $bmodel->_check_model_dir( $model_path ), 'method returned false' );

        system( "rm -f $model_path" ) if -e $model_path;
    }
};

subtest "folder of Model does not exist" => sub {
    remove_dir( $model_path );
    ok( ! -e $model_path, 'file does not exist' );
    ok( ! $bmodel->_check_model_dir( $model_path ), 'method again returned false' );
};

done_testing();
