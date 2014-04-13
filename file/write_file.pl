#!/usr/bin/env perl
use strict;
open FILE, '>', 'output.txt';
print FILE "Hello File!!\n";
close(FILE);
