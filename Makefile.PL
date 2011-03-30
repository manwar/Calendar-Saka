use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Calendar::Saka',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/Calendar/Saka.pm',
    ABSTRACT_FROM => 'lib/Calendar/Saka.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Calendar-Saka-*' },
    PREREQ_PM     => {
        'Test::More'      => 0,
        'Readonly'        => 0,
        'Time::localtime' => 1.02,
        'List::Util'      => 1.21,
        'Date::Calc'      => 5.7,
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);