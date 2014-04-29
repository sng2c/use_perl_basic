#!/usr/bin/env perl 
use AnyEvent;
use AnyEvent::Cron;
use AnyEvent::HTTPD;

$|++;

my $cv = AE::cv;

my $count = 0;
my $cron = AnyEvent::Cron->new;
$cron->add('1 seconds' => sub{
	$count++;
	print "Cron $count\n";
} );
$cron->run;

my $httpd = AnyEvent::HTTPD->new (port => 9090);
$httpd->reg_cb(
	'/' => sub{
		my ($httpd, $req) = @_;

		$req->respond(
			{
				content=> ['text/plain',"Current Count is $count."]
			}
		);
	},
);
$httpd->run;	

$cv->recv;

