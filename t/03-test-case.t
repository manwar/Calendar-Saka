#!perl

use Test::More tests => 2;

use strict; use warnings;
use Calendar::Saka;

my $saka = Calendar::Saka->new(1932,1,1);

$saka->add_months(3);
is($saka->as_string(), "01, Asadha 1932");

$saka->minus_months(1);
is($saka->as_string(), "01, Jyaistha 1932");