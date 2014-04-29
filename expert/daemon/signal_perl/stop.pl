#!/usr/bin/env perl

if ( -e 'signal.pl.pid'){
	print "Stopped\n";
	kill TERM => `cat signal.pl.pid`;
}
else{
	print "Not Running.\n";
}
