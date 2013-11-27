use strict;
use warnings;
use Test::More;
use Test::SpyCalls;

subtest 'spy on class methods' => sub {
    my $spy = spy_calls('Foo', [ 'foo' ]);

    is +Foo->foo('bar'), 'foo: bar';
    is_deeply [ $spy->args('Foo', 'foo') ], [
        [ 'Foo', 'bar' ]
    ];

    is +Foo->foo(1, 2), 'foo: 1 2';
    is_deeply [ $spy->args('Foo', 'foo') ], [
        [ 'Foo', 'bar' ],
        [ 'Foo', 1, 2 ],
    ];
};

subtest 'spy on instance methods' => sub {
    my $foo1 = Foo->new(1);
    my $foo2 = Foo->new(2);

    my $spy1 = spy_calls($foo1, [ 'x' ]);
    my $spy2 = spy_calls($foo2, [ 'x' ]);

    is $foo1->x('a'),   'x: a';
    is $foo2->x('b'),   'x: b';
    is +Foo->foo(1, 2), 'foo: 1 2';

    is_deeply [ $spy1->args($foo1, 'x') ], [
        [ $foo1, 'a' ]
    ];

    ok ! $spy1->args($foo2, 'x');
    ok ! $spy1->args('Foo', 'x');

    undef $spy1;

    is $foo1->x('a'), 'x: a';
    is $foo2->x('b'), 'x: b';

    is_deeply [ $spy2->args($foo2, 'x') ], [
        [ $foo2, 'b' ],
        [ $foo2, 'b' ]
    ];
};

done_testing;

package Foo;

sub new {
    my ($class, $id) = @_;
    bless +{ id => $id };
}

sub foo {
    my ($class, @args) = @_;
    return "foo: @args";
}

sub x {
    my ($self, @args) = @_;
    return "x: @args";
}
