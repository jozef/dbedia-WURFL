#!/usr/bin/perl

=head1 NAME

dbedia-wurfl-ids.pl - generate handsets brands with models

=head1 SYNOPSIS

    dbedia-wurfl-ids.pl

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
use List::Util 'first';
use File::Slurp 'write_file';
use File::Path 'mkpath';

exit main();

sub main {
    my $help;
    my $lib;
    my $folder;
    GetOptions(
        'help|h'  => \$help,
        'lib|l=s' => \$lib,
        'folder|f=s' => \$folder,
    ) or pod2usage;
    pod2usage if $help;
    
    unshift(@INC, $lib)
        if defined $lib;
    
    eval 'use Mobile::Devices::IDs';
    die $@ if $@;
    
    my $ids = Mobile::Devices::IDs->all;
    my $devices = Mobile::Devices->new();
    
    my %brands;
    foreach my $id (@{$ids}) {
        my $device = $devices->search( 'id' => $id );
        
        # only interested in devices that have brand and model names set
        my $brand_name = $device->brand_name;
        next if not $brand_name;
        my $model_name = $device->model_name;
        next if not $model_name;
        
        $brands{$brand_name} ||= [];
        
        # skip already seen models
        if (my $record = first { $_->{'model_name'} eq $model_name  } @{$brands{$brand_name}}) {
            push @{$record->{'id'}}, $id;
            next;
        }
        
        # add model
        push @{$brands{$brand_name}}, {
            'id'             => [ $id ],
            'model_name'     => $device->model_name,
            (
                $device->release_date
                ? ('release_date' => $device->release_date)
                : ()
            ),
            (
                $device->marketing_name
                ? ('marketing_name' => $device->marketing_name)
                : ()
            )
        };
    }
    write_file(
        File::Spec->catfile($folder, 'brandsModels.json'),
        JSON::XS->new->utf8->pretty(1)->encode(\%brands),
    );
    
    write_file(
        File::Spec->catfile($folder, 'brands.json'),
        JSON::XS->new->utf8->pretty(1)->encode([ sort keys %brands ]),
    );    
    
    foreach my $brand_name (keys %brands) {
        my $brand_folder    = File::Spec->catdir($folder, 'byBrand', $brand_name);
        my $models_filename = File::Spec->catfile($brand_folder, 'models.json');
        
        mkpath($brand_folder)
            if not -e $brand_folder;
        
        my %models =
            map { delete $_->{'model_name'} => $_ }
            @{$brands{$brand_name}};
        write_file(
            $models_filename,
            JSON::XS->new->utf8->pretty(1)->encode(\%models)
        );
    }

    return 0;
}
