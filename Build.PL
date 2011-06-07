use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Nagios::Recover',
    license             => 'perl',
    dist_author         => 'Francesc Guasch <frankie@etsetb.upc.edu>',
    dist_version_from   => 'lib/Nagios/Recover.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Nagios-Recover-*' ],
);

$builder->create_build_script();
