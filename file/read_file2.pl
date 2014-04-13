#!/usr/bin/env perl
use strict;
open FILE, '<', 'data.txt';
my @lines = <FILE>; # 메모리 걱정이 없다면 간편하게~
close(FILE);


foreach my $line (@lines){
    chomp($line);

    # 한줄씩 처리
	print ">> $line\n";
}
