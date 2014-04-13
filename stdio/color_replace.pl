#!/usr/bin/env perl
use strict;
use Term::ANSIColor;

my $bold = color('bold green');
my $reset = color('reset');

while( my $line = <STDIN> ){
    chomp($line);
    $line =~ s/(\d+)/$bold$1$reset/g;
    print "$line\n";
}

