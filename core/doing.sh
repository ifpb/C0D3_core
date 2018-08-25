#/bin/bash

# Compiles and executes the problem code
function compile()
{
	path=$1
	cd DOING/$path
	mkdir result
	gcc code.c &> result/compile.out
	echo $? > result/compile.return
	cd ../..
}

function differ()
{
	arquivo=$1
	path=$2
	ext=`echo ${arquivo} | cut -d. -f2`
	diff DOING/$path/out.$ext DOING/$path/result/stdout.$ext > DOING/$path/result/diff.$ext
}

function execut()
{
	arquivo=$1
	path=$2
	ext=`echo ${arquivo} | cut -d. -f2`
	cd DOING/$path
	echo ${arquivo} > a.out > result/stdout.$ext
	echo ${arquivo} > a.out 2> result/stderr.$ext
	cd ../..
}

# Main loop: look for new jobs every 1 sec
while :; do

	sleep 5

	# if there are new jobs
	if [ `ls JOBS/ | grep -E ^Job. | wc -l` -gt 0 ]
	then
		path=`ls JOBS/ | head -1`
		mv JOBS/$path DOING/
		compile $path
		for i in `ls DOING/$path/ | grep -E ^in.*`;
		do
			execut $i $path
			differ $i $path
		done
		mv DOING/$path DONE/
	else
		echo "Nothing to do..."
	fi
done
