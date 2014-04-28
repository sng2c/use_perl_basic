#!/usr/bin/env perl
use strict;

my $line;
while( $line = <STDIN> ) # 줄단위의 데이터가 들어올 때까지 Block 된다.
{
    chomp($line);
    print ">> $line\n";
}
