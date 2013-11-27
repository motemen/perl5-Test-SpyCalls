use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::SpyCalls;

subtest 'spy on class methods' => sub {
    my $spy = spy_calls('Foo', [ 'foo' ]);

    is +Foo->foo('bar'), 'foo: bar', 'spied method works as normal';

    cmp_deeply [ $spy->args('Foo', 'foo') ], [
        [ 'Foo', 'bar' ]
    ], '$spy->args';

    cmp_deeply [ $spy->callers('Foo', 'foo') ], [
        [ 'main', __FILE__, 10, (ignore) x 8 ],
    ], '$spy->callers';

    is +Foo->foo(1, 2), 'foo: 1 2', 'spied method works as normal';

    cmp_deeply [ $spy->args('Foo', 'foo') ], [
        [ 'Foo', 'bar' ],
        [ 'Foo', 1, 2 ],
    ], '$spy->args';

    cmp_deeply [ $spy->callers('Foo', 'foo') ], [
        [ 'main', __FILE__, 10, (ignore) x 8 ],
        [ 'main', __FILE__, 20, (ignore) x 8 ],
    ], '$spy->callers';
};

subtest 'spy on instance methods' => sub {
    my $foo1 = Foo->new;
    my $foo2 = Foo->new;

    my $spy1 = spy_calls($foo1, [ 'x' ]);
    my $spy2 = spy_calls($foo2, [ 'x' ]);

    subtest 'spied methods work as normal' => sub {
        is $foo1->x('a'),   'x: a';
        is $foo2->x('b'),   'x: b';
        is +Foo->foo(1, 2), 'foo: 1 2';
    };

    cmp_deeply [ $spy1->args($foo1, 'x') ], [
        [ $foo1, 'a' ]
    ], '$spy->args';

    ok ! $spy1->args($foo2, 'x');
    ok ! $spy1->args('Foo', 'x');

    undef $spy1;

    subtest 'spied methods work as normal' => sub {
        is $foo1->x('a'), 'x: a';
        is $foo2->x('b'), 'x: b';
    };

    cmp_deeply [ $spy2->args($foo2, 'x') ], [
        [ $foo2, 'b' ],
        [ $foo2, 'b' ]
    ], '$spy->args';
};

subtest 'spying multiple objects at once' => sub {
    my $foo1 = Foo->new;
    my $foo2 = Foo->new;

    my $spy = spy_calls(
        $foo1 => 'foo',
        $foo2 => 'foo',
        Foo   => 'foo',
    );

    subtest 'spied methods work as normal' => sub {
        is $foo1->foo('X'), 'foo: X';
        is $foo2->foo('Y'), 'foo: Y';
        is Foo->foo('Z'),   'foo: Z';
    };

    cmp_deeply [ $spy->args('foo') ], [
        [ $foo1, 'X' ],
        [ $foo2, 'Y' ],
        [ 'Foo', 'Z' ],
    ], '$spy->args with only method name';

    pass;
};

subtest 'spying multple methods at once' => sub {
    my $foo = Foo->new;

    my $spy = spy_calls(
        $foo => [ 'x', 'y' ],
    );

    subtest 'spied methods work as normal' => sub {
        is $foo->x('A'), 'x: A';
        is $foo->y('B'), 'y: B';
        is $foo->x('C'), 'x: C';
    };

    cmp_deeply [ $spy->args('x') ], [
        [ $foo, 'A' ],
        [ $foo, 'C' ],
    ], '$spy->args filtered with method name';

    cmp_deeply [ $spy->args('y') ], [
        [ $foo, 'B' ],
    ], '$spy->args filtered with method name';

    cmp_deeply [ $spy->args ], [
        [ $foo, 'A' ],
        [ $foo, 'B' ],
        [ $foo, 'C' ],
    ], '$spy->args without arguments';
};

done_testing;

package Foo;

sub new {
    my ($class) = @_;
    bless +{};
}

sub foo {
    my ($class, @args) = @_;
    return "foo: @args";
}

sub x {
    my ($self, @args) = @_;
    return "x: @args";
}

sub y {
    my ($self, @args) = @_;
    return "y: @args";
}
