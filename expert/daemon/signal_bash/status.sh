#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	kill -0 `cat signal.pl.pid`
	if [ "$?" -eq "0" ]
	then
		echo 'Running...'
	else
		echo 'Not Running'	
	fi
else
	echo 'Not Running'
fi