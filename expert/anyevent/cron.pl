#!/usr/bin/env perl 
use AnyEvent;
use AnyEvent::Cron;

$|++;

my $cv = AE::cv;

my $count = 0;
my $cron = AnyEvent::Cron->new;
$cron->add('1 seconds' => sub{
	$count++;
	print "Cron $count\n";
} );

$cron->add('5 seconds' => sub{
	print "Cron 5 seconds!!\n";
} );


$cron->add('* * * * *' => sub{
    print "Cron 1 minutes!!\n";
} );
	
$cron->run;

$cv->recv;

