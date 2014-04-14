#!/usr/bin/env perl 
use strict;
print "PID : $$\n";
print "--system--\n";
system('ps | grep ps');
print "--exec  --\n";
exec('ps | grep ps');
