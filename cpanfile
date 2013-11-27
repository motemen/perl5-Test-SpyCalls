requires 'perl', '5.008001';

requires 'Carp';
requires 'Exporter::Lite';
requires 'Sub::Install';
requires 'Class::Monadic';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Deep';
};
