#!/usr/bin/perl

=head1 NAME

dbedia-wurfl-byid.pl - generate handsets info by id

=head1 SYNOPSIS

    dbedia-wurfl-byid.pl

=head1 DESCRIPTION

=cut

use strict;
use version;

use Template;
use File::Spec;
use FindBin '$Bin';
use Pod::Usage;
use Mobile::Devices;
use JSON::XS;
use Getopt::Long;
use Pod::Usage;
use File::Slurp 'write_file';
use File::Path 'mkpath';

exit main();

sub main {
    my $help;
    my $lib;
    my $folder;
    GetOptions(
        'help|h'     => \$help,
        'lib|l=s'    => \$lib,
        'folder|f=s' => \$folder,
    ) or pod2usage;
    pod2usage if $help;
    pod2usage if not $folder;
    
    unshift(@INC, $lib)
        if defined $lib;
    
    eval 'use Mobile::Devices::IDs';
    die $@ if $@;
    
    my $ids = Mobile::Devices::IDs->all;
    my $devices = Mobile::Devices->new();
    
    my @generated_devices;
    foreach my $id (@{$ids}) {
        my $device = $devices->search( 'id' => $id );
        
        my $brand_name = $device->brand_name;
        
        # skip devices without brand_name
        next if not $brand_name;
        
        my $device_folder   = File::Spec->catdir($folder, $brand_name);
        my $device_filename = File::Spec->catfile($device_folder, $device->wurfl_id.'.json');
        
        mkpath($device_folder)
            if not -e $device_folder;
        write_file(
            $device_filename,
            JSON::XS->new->utf8->pretty(1)->encode($device->TO_JSON)
        );
        push @generated_devices, $device->wurfl_id;
    }
    write_file(
        File::Spec->catfile($folder, 'IDs.json'),
        JSON::XS->new->utf8->pretty(1)->encode([ sort @generated_devices ]),
    );

    return 0;
}
