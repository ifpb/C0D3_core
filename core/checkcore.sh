#/bin/bash

SLEEPING=5

while true
do
	if [ `pgrep -x doing.sh | wc -l` -ne 1 ]
	then
		rm -r DOING/Job.*
		./doing.sh
	fi
	sleep $SLEEPING
done
