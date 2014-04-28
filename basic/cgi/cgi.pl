#!/usr/bin/env perl
use strict;

use CGI;

my $q = CGI->new;
my $name = $q->param('name');
my $message = $q->param('message');

print "Content-Type: text/html\n\n";

print <<HTML;
<html>
    <body>
        $name, $message.
    </body>
</html>
HTML

