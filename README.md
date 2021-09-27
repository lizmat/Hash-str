[![Actions Status](https://github.com/lizmat/Hash-str/workflows/test/badge.svg)](https://github.com/lizmat/Hash-str/actions)

NAME
====

Hash::str - provide a hash with native string keys

SYNOPSIS
========

```raku
use Hash::str;

my %hash is Hash::str = fortytwo => "foo", sixsixsix => "bar";
```

DESCRIPTION
===========

Hash::str is module that provides the `Hash::str` class to be applied to the initialization of an Associative, making it limit the keys to native string. This allows this module to take some shortcuts, but only have a very limited (a few %_) performance improvement, so you should really only use this module if you're looking at getting those last few percent.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-str . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

