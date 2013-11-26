[![Build Status](https://travis-ci.org/motemen/perl5-Test-SpyCalls.png?branch=master)](https://travis-ci.org/motemen/perl5-Test-SpyCalls)
# NAME

Test::SpyCalls - It's new $module

# SYNOPSIS

    use Test::SpyCalls;

    my $spy = spy_calls('Foo::Bar', [ 'foo', 'bar' ]);

    ...

    my @array_of_args = $spy->args('Foo::Bar', 'foo');

# DESCRIPTION

Test::SpyCalls is ...

# LICENSE

Copyright (C) motemen.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

motemen <motemen@gmail.com>
