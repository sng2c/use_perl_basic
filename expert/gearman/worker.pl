use Gearman::Worker;
use Storable qw( thaw );
use List::Util qw( sum );
my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1');
$worker->register_function(sum => sub { 
sleep 1;
sum @{ thaw($_[0]->arg) } 
});
$worker->work while 1;

