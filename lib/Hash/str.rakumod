# Need to be using NQP ops here to get the desired efficiency, and
# hopefully this will be integrated into Rakudo before soon.
use nqp;

class Hash::str:ver<0.0.1>:auth<zef:lizmat> {
    has $!hash handles <gist raku Str values pairs iterator>;

    method new() {
        nqp::p6bindattrinvres(nqp::create(self),self,'$!hash',nqp::hash)
    }

    method STORE(::?CLASS:D: \to-store, :$INITIALIZE) {
        my $iterator := to-store.iterator;
        my $hash     := $INITIALIZE ?? $!hash !! ($!hash := nqp::hash);
        my Mu $x;
        my Mu $y;

        nqp::until(
          nqp::eqaddr(($x := $iterator.pull-one),IterationEnd),
          nqp::if(
            nqp::istype($x,Pair),
            nqp::bindkey(
              $hash,
              nqp::getattr(nqp::decont($x),Pair,'$!key').Str,
              (nqp::getattr(nqp::decont($x),Pair,'$!value'))
            ),
            nqp::if(
              (nqp::istype($x,Map) && nqp::not_i(nqp::iscont($x))),
              self.STORE($x),
              nqp::if(
                nqp::eqaddr(($y := $iterator.pull-one),IterationEnd),
                nqp::if(
                  nqp::istype($x,Failure),
                  $x.throw,
                  X::Hash::Store::OddNumber.new(
                    found => nqp::add_i(nqp::mul_i(nqp::elems($hash),2),1),
                    last  => $x
                  ).throw
                ),
                nqp::bindkey($hash,$x.Str,$y)
              )
            )
          )
        );
        self
    }

    method AT-KEY(::?CLASS:D: str $key) is raw {
        nqp::atkey($!hash,$key)
    }
    method ASSIGN-KEY(::?CLASS:D: str $key, \value) is raw {
        nqp::bindkey($!hash,$key,value)
    }
    method BIND-KEY(::?CLASS:D: str $key, \value) is raw {
        nqp::bindkey($!hash,$key,value)
    }
    method DELETE-KEY(::?CLASS:D: str $key) is raw {
        my $value := nqp::atkey($!hash,$key);
        nqp::deletekey($!hash,$key);
        $value
    }
    method EXISTS-KEY(::?CLASS:D: str $key) is raw {
        nqp::hllbool(nqp::existskey($!hash,$key))
    }
    method keys(::?CLASS:D:) {
        nqp::hllize($!hash).keys
    }
    method kv(::?CLASS:D:) {
        nqp::hllize($!hash).map: { (.key, .value).Slip }
    }
}

=begin pod

=head1 NAME

Hash::int - provide a hash with native string keys

=head1 SYNOPSIS

=begin code :lang<raku>

use Hash::str;

my %hash is Hash::str = fortytwo => "foo", sixsixsix => "bar";

=end code

=head1 DESCRIPTION

Hash::str is module that provides the C<Hash::str> class to be applied
to the initialization of an Associative, making it limit the keys to
native string.  This allows this module to take some shortcuts, but
only have a very limited (a few %_) performance improvement, so you
should really only use this module if you're looking at getting those
last few percent.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-int . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
