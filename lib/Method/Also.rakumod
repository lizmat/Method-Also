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

    method specialize(
      Mu \r, Mu:U \obj, *@pos_args, *%named_args
    ) is hidden-from-backtrace {
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
        $r
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

# vim: expandtab shiftwidth=4
