#!/usr/bin/env perl

if( -e 'signal.pl.pid' ){
	print "Reset Count\n";
	kill USR2 => `cat signal.pl.pid`;
}
else{
	print "Not Running.\n";
}
