use strict;
use lib './lib';
use Config::Properties;
use Data::Dumper;

#read
my $props = Config::Properties->new(file=>'props.properties');
my %all = $props->properties; # 전체 
print Dumper \%all;

my $name = $props->getProperty('my.test.name'); # 'KHS'
my $message = $props->getProperty('my.test.message'); # 'Hello'
print $name."\n";
print $message."\n";

#write
my $props2 = Config::Properties->new();
$props2->setProperty('my.test.nick', 'sng2c');

open my $fh, '>' , 'props2.properties';
$props2->store($fh);
close($fh);
