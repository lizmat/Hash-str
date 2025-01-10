# Need to be using NQP ops here to get the desired efficiency, and
# hopefully this will be integrated into Rakudo before soon.
use nqp;

class Hash::str {
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
    method push(::?CLASS:D: +values) {
        my $iterator := values.iterator;
        my $previous := nqp::null;
        nqp::until(
          nqp::eqaddr((my $pulled := $iterator.pull-one),IterationEnd),
          nqp::if(
            nqp::isnull($previous),
            nqp::if(
              nqp::istype($pulled,Pair),
              self!push(.key, .value),
              $previous := $pulled
            ),
            nqp::stmts(
              self!push($previous, $pulled),
              $previous := nqp::null
            )
          )
        );

        warn "Trailing item in {self.^name}.push"
          unless nqp::isnull($previous);
        self
    }
    method !push(str $key, $value --> Nil) {
        nqp::if(
          nqp::isnull(my $old := nqp::atkey($!hash,$key)),
          nqp::bindkey($!hash,$key,$value),
          nqp::if(
            nqp::istype($old,List),
            nqp::push(nqp::getattr($old,List,'$!reified'),$value),
            nqp::bindkey($!hash,$key,nqp::stmts(
              (my $buffer := nqp::create(IterationBuffer)),
              nqp::push($buffer,$old),
              nqp::push($buffer,$value),
              $buffer.List
            ))
          )
        )
    }
}

# vim: expandtab shiftwidth=4
