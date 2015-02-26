requires 'perl', '5.010';
requires 'Mojolicious';
requires 'Mojo::Loader';
requires 'Carp', '0';
requires 'File::Find'

on 'test' => sub {
    requires 'Test::More', '0.98';
};

