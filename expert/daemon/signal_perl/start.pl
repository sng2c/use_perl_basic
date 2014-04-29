#!/usr/bin/env perl

if( -e 'signal.pl.pid'){
	if( kill(0,`cat signal.pl.pid`) == 1 ){
		print "Already Running...\n";
		exit;
	}
}
system( "nohup perl signal.pl 2> /dev/null &" );

