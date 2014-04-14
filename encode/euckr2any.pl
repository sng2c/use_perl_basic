#!/usr/bin/env perl
use strict;
use Encode;
my $euckr = <STDIN>;
my $decoded = Encode::decode('euc-kr',$euckr);
print "$decoded";
