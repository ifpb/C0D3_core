#/bin/bash

# Compiles and executes the problem code
function execut()
{
	arquivo=$1
	ext=`echo ${arquivo} | cut -d. -f2`
	if [ "${comando}" = "c" ]
	then
		gcc input.$ext
		cat $arquivo | a.out > a.$ext 
		diff out.$ext a.$ext > diff.$ext
		echo "$?\n" >> out.lst
	elif [ "${comando}" = "py" ]
	then
		python3 ... -o a.$ext
		diff out.$ext a.$ext > /dev/null
		echo "$?\n" >> out.lst
	elif [ "${comando}" = "java" ]
	then
		java ... -o a.$ext
		diff out.$ext a.$ext > /dev/null
		echo "$?\n" >> out.lst
	elif [ "${comando}" = "cpp" ]
	then
		g++ input.$ext -o a.$ext
		diff out.$ext a.$ext > /dev/null
		echo "$?\n" >> out.lst
	fi
}

# Main loop: look for new jobs every 1 sec
while :; do

	sleep 1

	# if there are new jobs
	if [ `ls JOBS/ | wc -l` > 0 ]
	then
		path=`ls JOBS/ | head -1`
		ext=`echo $path | cut -d. -f2`
		mv -r JOBS/$path doing/
		for i in $(ls in.*);
		do
			execut $i
		done
		number=`cat out.lst | wc -l`
		count=0
		for ((i=0; i<${number}; i++))
		do
			if [ `cat out.lst | head -$i | tail -1` = 1 ]
			then
				count++
			fi
		done
		if [ ${count} = ${number} ]
		then
			echo "Beleza!"
		else
			echo "Deu merda!"
		fi
	fi
done
