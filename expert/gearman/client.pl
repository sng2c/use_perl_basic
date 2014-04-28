#!/usr/bin/env perl 
use Gearman::Client;
use Storable qw( freeze );
my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1');
my $tasks = $client->new_task_set;
my $handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {

    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});







$tasks->wait;
print "DONE\n";
