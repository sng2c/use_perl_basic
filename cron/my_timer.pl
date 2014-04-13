#!/usr/bin/env perl 

use strict;


my $tick=0;
while(1){

	#   0    1    2     3     4    5     6     7     8
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year += 1900;
	$mon  += 1;

	# interval
	if( $tick % 10 == 0 ){ # 10초에 한번
		printf('%02d:%02d:%02d ',$hour,$min,$sec);
		print "per 10\n";
	}

	# schedule
	if( $sec =~ /3$/ || $sec =~ /6$/ || $sec =~ /9$/ ){
		printf('%02d:%02d:%02d ',$hour,$min,$sec);
		print "3 6 9\n";
	}

	sleep(1); # 1초쉬고
	$tick++;
}
