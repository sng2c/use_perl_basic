#!/usr/bin/env perl
use strict;
use lib './lib';
use JSON::PP;

#read 
open( my $fh, '<', 'json.json' );
my @json_lines = <$fh>;
my $json = join('', @json_lines);

my $obj = decode_json( $json );
print $obj->{my}->{test}->{name} . "\n"; # "KHS"
print $obj->{my}->{test}->{message} . "\n"; # "Hello"

#write
my $obj2 = { my => { test => { nick => 'sng2c' } } };
open( my $fh2, '>', 'out.json');
print $fh2 encode_json( $obj2 );
close($fh2);

