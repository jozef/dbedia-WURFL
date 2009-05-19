use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'dbedia::WURFL',
    license             => 'perl',
    dist_author         => 'Jozef Kutej <jkutej@cpan.org>',
    dist_version_from   => 'lib/dbedia/WURFL.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'dbedia-WURFL-*' ],
    create_readme       => 1,
    sign                => 1,
);

$builder->create_build_script();
