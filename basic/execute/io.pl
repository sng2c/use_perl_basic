#!/usr/bin/env perl 

use strict;

use IO::Pipe;

my $out = IO::Pipe->new;
$out->reader('ls -l');

while( <$out> ){
	print ">> $_";
}
