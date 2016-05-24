#!perl

use 5.006;
use Test::More tests => 2;
use strict; use warnings;
use Calendar::Saka;

eval { Calendar::Saka->new({ year => -2011, month => 1 }); };
like($@, qr/ERROR: Invalid year \[\-2011\]./);

eval { Calendar::Saka->new({ year => 2011, month => 13 }); };
like($@, qr/ERROR: Invalid month \[13\]./);
