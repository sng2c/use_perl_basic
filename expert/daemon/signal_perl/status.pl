#!/usr/bin/env perl

if(-e 'signal.pl.pid'){
	if ( kill(0,`cat signal.pl.pid`) == 1 ) {
		print "Running...\n";
	}
	else{
		print "Not Running\n";
	}
}
else{
	print "Not Running\n";
}
