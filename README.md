[![Actions Status](https://github.com/lizmat/Method-Also/workflows/test/badge.svg)](https://github.com/lizmat/Method-Also/actions)

NAME
====

Method::Also - add "is also" trait to Methods

SYNOPSIS
========

    use Method::Also;

    class Foo {
        has $.foo;
        method foo() is also<bar bazzy> { $!foo }
    }

    Foo.new(foo => 42).bar;       # 42
    Foo.new(foo => 42).bazzy;     # 42

    # separate multi methods can have different aliases
    class Bar {
        multi method foo()     is also<bar>   { 42 }
        multi method foo($foo) is also<bazzy> { $foo }
    }

    Bar.foo;        # 42
    Bar.foo(666);   # 666
    Bar.bar;        # 42
    Bar.bazzy(768); # 768

DESCRIPTION
===========

This module adds a `is also` trait to `Method`s, allowing you to specify other names for the same method.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Method-Also . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2019, 2021, 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

