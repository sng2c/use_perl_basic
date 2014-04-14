#!/usr/bin/env perl
use strict;
use Encode;
my $euckr = <STDIN>;
my $decoded = Encode::decode('euc-kr',$euckr);
my $utf8 = Encode::encode('utf8',$decoded);
print "$utf8";
