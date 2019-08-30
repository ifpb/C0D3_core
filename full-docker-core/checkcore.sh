#!/bin/bash

SLEEPING=5

while true
do
	if [ `ps -x | grep "doing.sh" | grep -v grep | wc -l` -ne 1 ]
	then
		rm -r DOING/Job.* &>> /dev/null
		sudo -u c0r3 bash -c "/c0r3/doing.sh"
	fi
	sleep $SLEEPING
done
