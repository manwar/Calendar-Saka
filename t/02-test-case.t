#!perl

use Test::More tests => 2;

use strict; use warnings;
use Calendar::Saka;

my $saka = Calendar::Saka->new(1932,12,1);
$saka->add_days(10);
is($saka->as_string(), "11, Phalguna 1932");

$saka->minus_days(5);
is($saka->as_string(), "06, Phalguna 1932");