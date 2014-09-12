#!perl

use Test::More tests => 3;

use strict; use warnings;
use Calendar::Saka;

my ($calendar);

eval { $calendar = Calendar::Saka->new(-2011, 1, 1); };
like($@, qr/ERROR: Invalid year \[\-2011\]./);

eval { $calendar = Calendar::Saka->new(2011, 13, 1); };
like($@, qr/ERROR: Invalid month \[13\]./);

eval { $calendar = Calendar::Saka->new(2011, 12, 32); };
like($@, qr/ERROR: Invalid day \[32\]./);