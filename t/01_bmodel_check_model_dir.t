#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

use Test::More tests => 4;

use_ok( 'Mojolicious::Plugin::BModel' );

my $model_path = 'Model';
my $bmodel = Mojolicious::Plugin::BModel->new;

subtest "folder of Model does exists and is folder" => sub {

    ok( $bmodel->can( '_check_model_dir' ), 'run one' );

    mkdir $model_path or die "can't create folder $model_path: $!";

    ok( $bmodel->_check_model_dir( $model_path ), 'run two' );

    rmdir $model_path if -e $model_path;
};

subtest "folder of Model does exists but is simple file" => sub {

    system( "touch $model_path" );

    ok( -e $model_path && ! -d $model_path, "$model_path is simple file" );
    ok( ! $bmodel->_check_model_dir( $model_path ), 'method return false' );

    system( "rm -f $model_path" ) if -e $model_path;
};

subtest "folder of Model does not exists" => sub {
    ok( ! -e $model_path, 'file does not exist' );
    ok( ! $bmodel->_check_model_dir( $model_path ), 'method again return false' );
};

done_testing();
