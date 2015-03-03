requires 'perl', '5.010';
requires 'Mojolicious', '5.0';
requires 'Mojo::Loader', '0';
requires 'Carp', '0';
requires 'File::Find', '0';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
