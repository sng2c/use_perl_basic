#!/usr/bin/env perl
use strict;

while( my $line = <STDIN> ){
    chomp($line);
    $line =~ s/sng2c/내꺼/g;
    print $line . "\n";
}
