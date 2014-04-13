#!/usr/bin/env perl
use strict;

my @files = glob '../*';

foreach my $file (@files){
    print $file . "\n";
}
