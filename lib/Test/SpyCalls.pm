package Test::SpyCalls;
use 5.008005;
use strict;
use warnings;
use Sub::Install;
use Guard;
use Carp;
use Scalar::Util qw(refaddr);
use Exporter::Lite;

our $VERSION = '0.01';

our @EXPORT = qw(spy_calls);

our $SPIED_CALLS = {};

sub calls {
    my ($self, $pkg, $method) = @_;
    my $original = $self->{original_codes}->{$pkg}->{$method};
    return @{ $SPIED_CALLS->{ refaddr $original } || [] };
}

sub args {
    my ($self, $pkg, $method) = @_;
    return map { $_->{args} } $self->calls($pkg, $method);
}

sub callers {
    my ($self, $pkg, $method) = @_;
    return map { $_->{caller} } $self->calls($pkg, $method);
}

# spy_calls($pkg, \@methods);
sub spy_calls (@) {
    my $spy = bless {};

    while (my ($pkg, $methods) = splice @_, 0, 2) {
        foreach my $method (@$methods) {
            my $original = $pkg->can($method);

            $spy->{original_codes}->{$pkg}->{$method} = $original;

            Sub::Install::reinstall_sub {
                code => _spied_sub($original),
                into => $pkg,
                as   => $method,
            };
        }
    }

    $spy->{guard} = guard {
        foreach my $pkg (keys %{ $spy->{original_codes} }) {
            foreach my $method (keys %{ $spy->{original_codes}->{$pkg} }) {
                Sub::Install::reinstall_sub {
                    code =>  $spy->{original_codes}->{$pkg}->{$method},
                    into => $pkg,
                    as   => $method,
                };
            }
        }
    };

    return $spy;
}

sub _spied_sub (\&) {
    my $sub = shift;

    croak "$sub is not a coderef" unless ref $sub eq 'CODE';

    return sub {
        push @{ $SPIED_CALLS->{ refaddr $sub } }, {
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

=head1 DESCRIPTION

Test::SpyCalls is ...

=head1 LICENSE

Copyright (C) motemen.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=cut

