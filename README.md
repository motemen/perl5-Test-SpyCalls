[![Build Status](https://travis-ci.org/motemen/perl5-Test-SpyCalls.png?branch=master)](https://travis-ci.org/motemen/perl5-Test-SpyCalls)
# NAME

Test::SpyCalls - Spies class/instance method calls

# SYNOPSIS

    use Test::SpyCalls;

    my $spy = spy_calls(
        'Foo::Bar' => [ 'foo', 'bar' ],
        'Baz'      => 'foo',
    );

    Foo::Bar->foo(1, 2, 3);
    Foo::Bar->bar('x');
    Baz->foo({});

    $spy->args;
    # => ( [ "Foo::Bar", 1, 2, 3 ], [ "Foo::Bar", "x" ], [ "Baz", {} ] )

    # filter by methods/receivers
    $spy->args('foo');
    # => ( [ "Foo::Bar", 1, 2, 3 ], [ "Baz", {} ] )

    $spy->args('Foo::Bar', 'foo');
    # => [ "Foo::Bar", 1, 2, 3 ]

    # also
    $spy->callers;
    # => ( [ "main", "eg.pl", 13, ... ], ... )

    # Can spy instance methods
    my $foo = Foo::Bar->new;
    my $spy = spy_calls $foo, [ 'foo', 'bar' ];

# DESCRIPTION

Test::SpyCalls spies method call arguments/callers of target class/instance.

# EXPORTED FUNCTIONS

## `my $spy = spy_calls($class_or_instance => \@methods, ...)`

Starting to spy target class/instance's method calls for later inspection.

After $spy has been DESTROYed, the method calls are no longer spied.

# METHODS

## `my @array_of_arguments = $spy->args()`,

## `my @array_of_arguments = $spy->args($method)`,

## `my @array_of_arguments = $spy->args($target, $method)`

Retrieve arguments (`@_`) of spied method calls.
Specify `$target`, `$method` to filter result.



## `my @array_of_callers = $spy->callers()`,

## `my @array_of_callers = $spy->callers($method)`,

## `my @array_of_callers = $spy->callers($target, $method)`

Retrieve caller (`caller(0)`) of method calls. 
Specify `$target`, `$method` to filter result.

# LICENSE

Copyright (C) motemen.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

motemen <motemen@gmail.com>
