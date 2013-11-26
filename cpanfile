requires 'perl', '5.008001';

requires 'Sub::Install';
requires 'Guard';
requires 'Carp';
requires 'Scalar::Util';
requires 'Exporter::Lite';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
