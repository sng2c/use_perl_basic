#!/usr/bin/env perl
use strict;

my $path = '../*';
my @files = glob $path;

my @stack;
push(@stack,@files);
while( my $f = shift(@stack) ){
	if( -d $f ){
		my @files = glob "$f/*";
		push(@stack,@files);
	}
	print $f."\n";
}
