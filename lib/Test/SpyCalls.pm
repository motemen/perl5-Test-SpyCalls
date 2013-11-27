package Test::SpyCalls;
use 5.008005;
use strict;
use warnings;
use Sub::Install;
use Guard;
use Carp;
use Scalar::Util qw(refaddr);
use Class::Monadic;
use Exporter::Lite;

our $VERSION = '0.01';

our @EXPORT = qw(spy_calls);

our $SPIED_CALLS = {};

sub _pkg ($) {
    my ($target) = @_;

    if (ref $target) {
        my $meta = Class::Monadic->initialize($target);
        return join '::', $meta->name, $meta->id;
    } else {
        return $target;
    }
}

sub calls {
    my ($self, $target, $method) = @_;
    my $pkg = _pkg $target;
    return @{ $SPIED_CALLS->{ "$pkg\::$method" } || [] };
}

sub args {
    my ($self, $target, $method) = @_;
    return map { $_->{args} } $self->calls($target, $method);
}

sub callers {
    my ($self, $target, $method) = @_;
    return map { $_->{caller} } $self->calls($target, $method);
}

# spy_calls($pkg, \@methods);
sub spy_calls (@) {
    my $spy = bless {};

    while (my ($target, $methods) = splice @_, 0, 2) {
        foreach my $method (@$methods) {
            my $pkg = _pkg $target;

            my $original = $target->can($method);

            $spy->{original_codes}->{$pkg}->{$method} = $original;

            Sub::Install::reinstall_sub {
                code => _spied_sub($original, "$pkg\::$method"),
                into => $pkg,
                as   => $method,
            };
        }
    }

    my $original_codes = $spy->{original_codes};

    $spy->{guard} = guard {
        foreach my $pkg (keys %$original_codes) {
            foreach my $method (keys %{ $original_codes->{$pkg} }) {
                Sub::Install::reinstall_sub {
                    code => $original_codes->{$pkg}->{$method},
                    into => $pkg,
                    as   => $method,
                };
            }
        }
    };

    return $spy;
}

sub _spied_sub (\&) {
    my ($sub, $key) = @_;

    croak "$sub is not a coderef" unless ref $sub eq 'CODE';

    return sub {
        push @{ $SPIED_CALLS->{$key} }, {
            args   => [ @_ ],
            caller => [ caller(1) ],
        };
        goto \&$sub;
    };
}

1;

__END__

=encoding utf-8

=head1 NAME

Test::SpyCalls - It's new $module

=head1 SYNOPSIS

    use Test::SpyCalls;

    my $spy = spy_calls('Foo::Bar', [ 'foo', 'bar' ]);

    ...

    my @array_of_args = $spy->args('Foo::Bar', 'foo');

=head1 DESCRIPTION

Test::SpyCalls is ...

=head1 LICENSE

Copyright (C) motemen.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=cut

