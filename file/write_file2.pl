#!/usr/bin/env perl
use strict;
open FILE, '>>', 'output.txt'; # APPEND 모드
print FILE "Hello File Again!!\n";
close(FILE);
