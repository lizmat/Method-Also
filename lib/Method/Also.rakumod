my %aliases;
my %aliases-composed;

constant %no_handles = $*RAKU.compiler.version >= v2022.06.60.ga.7.e.9.b.1938 ?? :!handles !! Empty;

my role AliasableClassHOW {

    method compose (Mu \o, :$compiler_services) is hidden-from-backtrace {
      for %aliases{o.^name}[] {
        o.^add_method(.key, .value, |%no_handles) if $_;
      }
      nextsame;
    }

}

my role AliasableRoleHOW {

    method specialize(Mu \r, Mu:U \obj, *@pos_args, *%named_args)
        is hidden-from-backtrace
    {
        obj.HOW does AliasableClassHOW unless obj.HOW ~~ AliasableClassHOW;

        my $*TYPE-ENV;
        my $r := callsame;
        unless %aliases-composed{r.^name} {
            for %aliases{r.^name}[] -> $p {
                # cw: This should never happen, but somehow it is... 
                next unless $p;
                next unless $p.value.is_dispatcher;

                obj.^add_method($p.key, $p.value, |%no_handles);
                for r.^multi_methods_to_incorporate {
                    obj.^add_multi_method(
                        $p.key,
                        .code.instantiate_generic($*TYPE-ENV)
                    );
                }
            }
            %aliases-composed{r.^name} = True;
        }
        $r;
    }

    method specialize_with(Mu $, Mu \old_type_env, Mu \type_env, |) {
        $*TYPE-ENV := old_type_env.^name eq 'BOOTContext'
          ?? old_type_env
          !! type_env;
        nextsame;
    }

}

multi sub trait_mod:<is>(Method:D \meth, :$also!) is export {
    if $*PACKAGE.HOW ~~ Metamodel::ClassHOW {
        $*PACKAGE.HOW does AliasableClassHOW
            unless $*PACKAGE.HOW ~~ AliasableClassHOW
    }

    if $*PACKAGE.HOW ~~ Metamodel::ParametricRoleHOW {
        $*PACKAGE.HOW does AliasableRoleHOW
            unless $*PACKAGE.HOW does AliasableRoleHOW
    }

    if $also {
        if $also ~~ List {
            %aliases{$*PACKAGE.^name}.push: Pair.new(.Str, meth) for @$also;
        }
        else {
            %aliases{$*PACKAGE.^name}.push: Pair.new($also.Str, meth);
        }
    }
}

=begin pod

=head1 NAME

Method::Also - add "is also" trait to Methods

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

This module adds a C<is also> trait to C<Method>s, allowing you to specify
other names for the same method.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Method-Also .
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019, 2021, 2022, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
