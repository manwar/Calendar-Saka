use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Calendar::Saka',
    AUTHOR             => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM       => 'lib/Calendar/Saka.pm',
    ABSTRACT_FROM      => 'lib/Calendar/Saka.pm',
    LICENSE            => 'artistic_2',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM     => {
        'Moo'                     => 0,
        'namespace::clean'        => 0,
        'Date::Utils'             => '0.06',
        'Date::Saka::Simple'      => 0,
        'Term::ANSIColor::Markup' => '0.06'
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Calendar-Saka-*' },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/Manwar/Calendar-Saka.git',
                web  => 'https://github.com/Manwar/Calendar-Saka',
            },
        }})
     : ()
    ),
);
