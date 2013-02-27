#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);
use lib qw(lib ../lib);

use Test::More tests    => 7;
use Test::Debian;

system_is_debian;
while(<DATA>) {
    s/\s*//g;
    next unless $_;
    package_is_installed $_;
}

__DATA__
libtest-compile-perl
libtest-debian-perl
liblocale-po-perl
liblocales-perl
libmojolicious-perl
libmouse-perl
