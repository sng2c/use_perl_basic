#!/usr/bin/env perl
use strict;
use Encode;

binmode(STDOUT,":utf8");

my $euckr = <STDIN>;
my $decoded = Encode::decode('euc-kr',$euckr);
print "$decoded";
