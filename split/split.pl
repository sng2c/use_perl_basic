#!/usr/bin/env perl
use strict;

while( my $line = <STDIN> ){
    chomp($line);
    my @cols = split(/\s+/, $line);

    print "$cols[0] $cols[1] $cols[2]\n";
}
