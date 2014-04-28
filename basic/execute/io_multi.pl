#!/usr/bin/env perl 

use strict;
use IO::Pipe;
use IO::Select;

my $sel = IO::Select->new;

my $out1 = IO::Pipe->new;
$out1->reader('ls -l');
$sel->add($out1);

my $out2 = IO::Pipe->new;
$out2->reader('ls -l ');
$sel->add($out2);

my @ready;
while( @ready = $sel->can_read() ){
    foreach my $pipe (@ready){
        my $line = <$pipe>;
        unless( defined($line) ){
            $sel->remove($pipe);
            next;
        }
       	print ">> $line";
    }
}
