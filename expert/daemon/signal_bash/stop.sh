#!/bin/sh

if [ -e 'signal.pl.pid' ]
then
	echo "Stopped"
	kill -TERM `cat signal.pl.pid`
else
	echo "Not Running"
fi
