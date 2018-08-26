#/bin/bash

# Global Options
DEBUG=1

# Compiles and executes the problem code
function compile()
{
	path=$1
    old_dir=$(pwd)
	cd DOING/$path
    
    # find the code_file on the folder
    code_to_be_judged=( $(ls | grep *.c) )
    code_to_be_judged=${code_to_be_judged[0]}
    
    [ $DEBUG -eq 1 ] && echo "code to be judged=${code_to_be_judged}"
    
	mkdir result
	gcc ${code_to_be_judged} &> result/compile.out
	echo $? > result/compile.return
	cd ${old_dir}
}

function differ()
{
	arquivo=$1
	path=$2
	ext=`echo ${arquivo} | cut -d. -f2`
    
    [ $DEBUG -eq 1 ] && echo "Diff phase between: ${path}/out.${ext} and ${path}/result/stdout.${ext}"
    
	diff DOING/${path}/out.${ext} DOING/${path}/result/stdout.${ext} > DOING/${path}/result/diff.${ext}
}

function execut()
{
	arquivo=$1
	path=$2
    old_dir=$(pwd)
        
	ext=`echo ${arquivo} | cut -d. -f2`
	cd DOING/$path
    
    [ $DEBUG -eq 1 ] && echo "Exec phase: stdout > result/stdout.$ext and stderr > result/stderr.$ext"
    
	cat ${arquivo} | ./a.out > result/stdout.$ext 2> result/stderr.$ext

	cd ${old_dir}
}

# ----------------------------------------------------------------------
# Main function of the script
# ----------------------------------------------------------------------

[ $DEBUG -eq 1 ] && echo "Starting the script..."
    
# Main loop: look for new jobs every X sec
while :; do

	sleep 5

	# if there are new jobs
    njobs=`ls JOBS | grep ^Job 2> /dev/null | wc -l`
    [ $DEBUG -eq 1 ] && echo "Number of Jobs: $njobs"

	if [ ${njobs} -gt 0 ]
	then
		path=`ls JOBS/ | head -1`
        [ $DEBUG -eq 1 ] && echo "PATH=$path"
        
		mv JOBS/$path DOING/
		compile $path
		for i in `ls DOING/$path/ | grep -E ^in.*`;
		do
			execut $i $path
			differ $i $path
		done

        [ $DEBUG -eq 1 ] && echo "Moving JOB to DONE folder"
		rm DOING/$path/a.out
        mv DOING/$path DONE/
        

	else
		[ $DEBUG -eq 1 ] && echo "Nothing to be done (Sleeping...)"
	fi
done
