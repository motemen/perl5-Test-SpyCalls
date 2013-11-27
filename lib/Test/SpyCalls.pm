package Test::SpyCalls;
use 5.008005;
use strict;
use warnings;
use Exporter::Lite;
use Carp;

our $VERSION = '0.01';

our @EXPORT = qw(spy_calls);

# spy_calls($pkg => \@methods, ...);
sub spy_calls (@) {
    return __PACKAGE__->new(@_);
}

sub new {
    my $class = shift;
    my $self  = bless {}, $class;

    my @overrides;
    while (my ($target, $methods) = splice @_, 0, 2) {
        $methods = [ $methods ] unless ref $methods eq 'ARRAY';

        push @overrides, (
            $target => +{
                map +( $_ => $self->_mk_spied_sub($target, $_) ), @$methods
            }
        );
    }

    $self->{guard} = Test::SpyCalls::MethodOverride->new(@overrides);
    $self->{calls} = [];

    return $self;
}

sub calls {
    my $self = shift;

    my $pred;
    if (@_ == 1) {
        my ($method) = @_;
        $pred = sub { $_->{method} eq $method };
    } elsif (@_ >= 2) {
        my ($target, $method) = @_;
        $pred = sub { $_->{target} eq $target && $_->{method} eq $method };
    }

    my @calls = @{ $self->{calls} };
    return @calls unless $pred;
    return grep &$pred, @calls;
}

sub args {
    my $self = shift;
    return map { $_->{args} } $self->calls(@_);
}

sub callers {
    my $self = shift;
    return map { $_->{caller} } $self->calls(@_);
}

sub _mk_spied_sub (\&) {
    my ($self, $target, $method) = @_;

    my $orig = $target->can($method);
    croak "$target->$method is not a coderef" unless ref $orig eq 'CODE';

    return sub {
        push @{ $self->{calls} }, +{
            target => $target,
            method => $method,
            args   => [ @_ ],
            caller => [ caller(0) ],
        };
        goto \&$orig;
    };
}

package
    Test::SpyCalls::MethodOverride;
use Class::Monadic qw(monadic);
use Sub::Install qw(reinstall_sub);

sub _pkg_for ($) {
    my ($target) = @_;
    return ref $target ? do { monadic($target); ref $target } : $target;
}

sub new {
    my ($class, @defs) = @_;

    my @overrides;

    while (my ($target, $methods) = splice @defs, 0, 2) {
        my $pkg = _pkg_for $target;

        foreach my $method (keys %$methods) {
            my $code = $methods->{$method};

            push @overrides, +{
                original => $target->can($method),
                target   => $target,
                method   => $method,
            };

            reinstall_sub +{
                code => $code,
                into => $pkg,
                as   => $method,
            };
        }
    }

    return bless +{ overrides => \@overrides }, $class;
}

# TODO: check other overrides of same target
sub DESTROY {
    local $@;

    my $self = shift;
    my @overrides = @{ $self->{overrides} };

    foreach (@overrides) {
        reinstall_sub +{
            code => $_->{original},
            into => _pkg_for($_->{target}),
            as   => $_->{method},
        };
    }
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

