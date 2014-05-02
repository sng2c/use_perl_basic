#!/usr/bin/env perl 

my $until = 1;
my $count = 0;

$SIG{INT} = sub{print "INT\n"; $until = 0; };
$SIG{TERM} = sub{print "TERM\n"; $until = 0; };
$SIG{USR1} = sub{print "USR1 : Hello World!\n"; };
$SIG{USR2} = sub{
	print "USR2 : Reset!!\n"; 
	$count = 0;
};

system("echo $$ > $0.pid");

$|++; # STDOUT 바로 출력

print "BEGIN\n";
while($until){
	$count++;
	print "WORK $count\n";
	sleep(1);
}
unlink( "$0.pid" );
print "END\n";
