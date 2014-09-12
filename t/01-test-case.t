#!perl

use Test::More tests => 4;

use strict; use warnings;
use Calendar::Saka;

my $saka = Calendar::Saka->new(1932,12,26);

is($saka->dow(), 4);

is($saka->days_in_month(1932,12), 30);

is($saka->as_string(), "26, Phalguna 1932");

is($saka->mon, "Phalguna");
