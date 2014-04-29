#!/usr/bin/env perl 

use AnyEvent;

my $cv = AE::cv;

my $until = 1;
my $count = 0;

my $w1 = AE::signal INT=>sub{print "INT\n"; $cv->send; };
my $w2 = AE::signal TERM=> sub{print "TERM\n"; $cv->send; };
my $w3 = AE::signal USR1=> sub{print "USR1 : Hello World!\n"; };
my $w4 = AE::signal USR2=> sub{
	print "USR2 : Reset!!\n"; 
	$count = 0;
};

$|++; # STDOUT 바로 출력

print "BEGIN\n";

my $w5 = AE::timer 0, 1, sub{
	$count++;
	print "WORK $count\n";
};

$cv->recv; # LOOP

print "END\n";
