#!/usr/bin/perl

=head1 NAME

dbedia-wurfl-bybrand.pl - generate handsets info by id

=head1 SYNOPSIS

    dbedia-wurfl-bybrand.pl

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
use File::Slurp 'write_file', 'read_file';
use File::Path 'mkpath';
use List::MoreUtils 'uniq';

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
    my $json = JSON::XS->new->utf8->pretty(1);
    
    my @generated_devices;
    foreach my $id (@{$ids}) {
        my $device = $devices->search( 'id' => $id );
                
        # only interested in devices that have brand and model names set
        my $brand_name = $device->brand_name;
        next if not $brand_name;
        my $model_name = $device->model_name;
        next if not $model_name;
        
        # replace non-word characters by underscore
        $model_name =~ s/\W/_/g; 
        
        my $device_folder   = File::Spec->catdir($folder, 'byBrand', $brand_name, 'id');
        my $device_brand    = File::Spec->catdir($folder, 'byBrand', $brand_name, $model_name.'.json');
        my $device_filename = File::Spec->catfile($device_folder, $device->wurfl_id.'.json');
        
        mkpath($device_folder)
            if not -e $device_folder;
        
        my %device_json = %{$device->TO_JSON};
        write_file(
            $device_filename,
            $json->encode(\%device_json)
        );

        # fill brand json
        if (-r $device_brand) {
            my %device_brand_json = %{$json->decode(scalar read_file($device_brand))};
            foreach my $cap_name (keys %device_json) {
                my $cap_value = $device_json{$cap_name};
                $device_json{$cap_name} = [ uniq (
                    @{$device_brand_json{$cap_name}},
                    ($cap_value ne '' ? $cap_value : ()),
                )];
            }
        }
        else {
            foreach my $cap_name (keys %device_json) {
                my $cap_value = $device_json{$cap_name};
                $device_json{$cap_name} = [ ($cap_value ne '' ? $cap_value : ()) ];
            }
        }
        write_file(
            $device_brand,
            $json->encode(\%device_json)
        );

        push @generated_devices, $device->wurfl_id;
    }
    write_file(
        File::Spec->catfile($folder, 'IDs.json'),
        JSON::XS->new->utf8->pretty(1)->encode([ sort @generated_devices ]),
    );

    my $generic = $devices->search( 'id' => 'generic' );
    write_file(
        File::Spec->catfile($folder, 'grpCap.json'),
        JSON::XS->new->utf8->pretty(1)->encode($generic->group_capabilities),
    );

    return 0;
}
