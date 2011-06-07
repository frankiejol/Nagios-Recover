use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Nagios::Recover',
    AUTHOR              => 'Francesc Guasch <frankie@etsetb.upc.edu>',
    VERSION_FROM        => 'lib/Nagios/Recover.pm',
    ABSTRACT_FROM       => 'lib/Nagios/Recover.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Nagios-Recover-* tmp' },
);
