#!/usr/bin/env perl 
use AnyEvent;
use AnyEvent::Filesys::Notify;
use Data::Dumper;

$|++;

my $cv = AE::cv;

my $notifier = AnyEvent::Filesys::Notify->new(
    dirs     => [ 'files' ],
    cb       => sub {
        my (@events) = @_;
        print "File Changed\n";
		print Dumper @events;
    },
);

$cv->recv;
