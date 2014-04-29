#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	kill -0 `cat signal.pl.pid`
	if [ "$?" -eq "0" ]
	then
		echo 'Already Running...';
		exit
	fi

fi
nohup perl signal.pl 2> /dev/null &
