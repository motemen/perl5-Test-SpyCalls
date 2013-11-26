use strict;
use warnings;
use Test::More;
use Test::SpyCalls;

my $spy = spy_calls('Foo', [ 'foo' ]);

is +Foo->foo, 'foo';
is_deeply [ $spy->args('Foo', 'foo') ], [ [ 'Foo' ] ];

done_testing;

package Foo;

sub foo { 'foo' }
