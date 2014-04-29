#!/usr/bin/env perl 
use Daemon::Control;
sub Daemon::Control::do_reset{
    my ( $self ) = @_;
    $self->read_pid;
    if ( $self->pid && $self->pid_running  ) {
        kill USR2 => $self->pid;
        $self->pretty_print( "Reset" );
        return 0;
    }
}
Daemon::Control->new({
        name        => "Signal Sample Control",
        program     => "perl signal.pl",
        pid_file    => "./signal.pl.pid",
        stderr_file => "./signal.pl.err",
        stdout_file => "./signal.pl.out",
})->run;
