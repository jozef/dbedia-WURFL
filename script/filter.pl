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
use Scalar::Util 'blessed';
use List::MoreUtils 'any';

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
    
    my @keep_ids = qw(generic_xhtml generic);
    my $apple = blessed $devices->search( 'id' => 'apple_generic' );
    #my $nokia = blessed $devices->search( 'id' => 'nokia_generic' );
    my $sony  = blessed $devices->search( 'id' => 'sony_generic' );
    
    foreach my $id (@{$ids}) {
        if (any { $_ eq $id } @keep_ids) {
            print $id, "\n";
            next;
        }
        my $device = $devices->search( 'id' => $id );
        
        print $id, "\n"
            if $device->isa($apple) or $device->isa($sony);
    }

    return 0;
}
