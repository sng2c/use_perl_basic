#!/usr/bin/env perl 
use HTTP::Proxy;
my $proxy = HTTP::Proxy->new( 
	host=>'0.0.0.0',
	port => 8800, 
	max_clients=>10 
);
$proxy->start;
