#!perl

use Test::More tests => 2;

use strict; use warnings;
use Calendar::Saka;

my $saka = Calendar::Saka->new(1932,1,1);

$saka->add_years(3);
is($saka->as_string(), "01, Chaitra 1935");

$saka->minus_years(2);
is($saka->as_string(), "01, Chaitra 1933");