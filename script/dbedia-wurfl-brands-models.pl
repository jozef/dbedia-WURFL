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

exit main();

sub main {
    my $help;
    my $lib;
    GetOptions(
        'help|h'  => \$help,
        'lib|l=s' => \$lib,
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
        
        if (my $brand_name = $device->brand_name) {
            $brands{$brand_name} ||= [];
            if ($device->model_name) {
                push @{$brands{$brand_name}}, {
                    'id'             => $id,
                    'model_name'     => $device->model_name,
                    (
                        $device->marketing_name
                        ? ('marketing_name' => $device->marketing_name)
                        : ()
                    )
                };
            }
        }
    }
    print JSON::XS->new->utf8->pretty(1)->encode(\%brands);

    return 0;
}
