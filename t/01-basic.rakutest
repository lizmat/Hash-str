use Test;
use Hash::str;

plan 14;

my %h is Hash::str = fortytwo => "foo", sixsixsix => "bar";
is %h<fortytwo>, "foo",  'can we access existing key (1)';
is %h<sixsixsix>, "bar", 'can we access existing key (2)';

is-deeply %h<fortytwo>:exists, True,  'can we check existence of existing';
is-deeply %h<sixsixfive>:exists, False, 'can we check existence of non-existing';

is (%h<fortytwo> = "zippo"), "zippo", 'can we assign existing';
is (%h<fortyone> = "zappo"), "zappo", 'can we assign non-existing';

is (%h<sixsixsix> := "dinko"), "dinko", 'can we bind existing';
is (%h<sixsixfive> := "danko"), "danko", 'can we bind non-existing';

is        %h<sixsixsix>:delete, "dinko", 'can we delete existing (1)';
is-deeply %h<sixsixsix>:exists,   False, 'can we delete existing (2)';

is-deeply %h.push("fortytwo","frobnob"), %h, 'does push return self';
is-deeply %h<fortytwo>, <zippo frobnob>, 'did it create a list';

%h.push("fortythree","nicate");
is %h<fortythree>, "nicate", 'does push on an unexisting just add';
%h.push("fortythree","nocate");
is-deeply %h<fortythree>, <nicate nocate>, 'did it create a list 2nd time';

# vim: expandtab shiftwidth=4
