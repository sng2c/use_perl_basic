#!/usr/bin/env perl
use strict;
open FILE, '<', 'data.txt';

while( my $line = <FILE> ){
    chomp($line);
    
    # 한줄씩 처리
	print ">> $line\n";	
}
close(FILE);
