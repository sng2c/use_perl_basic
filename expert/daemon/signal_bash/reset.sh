#!/bin/sh

if [ -e 'signal.pl.pid' ]
then
	echo "Reset Count"
	kill -USR2 `cat signal.pl.pid`
else
	echo "Not Running."
fi
