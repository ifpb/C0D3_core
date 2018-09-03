#/bin/bash

# This runnable file checks if a new Job has arrived and automatically
# move it to the 'DOING' directory.
#
# Then it find the code file in the Job directory, creates a new
# directory named 'result' where it creates the files related to the
# output of the compiling command and the return code of the compiling
# process.
#
# Also executes the code with the input files received within the Job
# directory, then it creates files with the results and files with
# the error output of the code execution for each input received,
# then compares this files with the output files received within the
# Job directory. For each comparing process done, it creates a file
# with the differences between these output files.
#
# This runnable file creates judge files with the number code and the
# description related to this number according to the result got from
# the analysis of the diff files, for example, if the diff file
# related to the first input file got nothing on it, then it means
# the execution of the code is correct to that test case, which means
# the answer is right and the test case was accepted. In this case the
# judge file related to this test case receives the content "0 ACCEPTED"
# in case that diff file has something on it, it means it got wrong
# answer to that test case, then the judge file receives the content
# "1 WRONG ANSWER".
#
# In case the code have compilation error, the functions execut, differ
# and judge do not run and is created a file named 'judge' inside the
# 'result' directory with the content "2 COMPILATION ERROR", which
# the errors can be seen in the file 'compile.out'. The function compile
# analyzes the return code of the compiling to determine if is a case of
# compilation error.
#
# In case the compilation of the code goes well and all that other files
# are generated by the functions execut, differ and judge, the function
# general_judge is runned to check if one of the judge files have a code
# "1" which means it is a wrong answer test case, if the function do not
# find any code "1" within all the judge files, a file named 'judge' is
# created and receives the content "0 ACCEPTED", in other case, the file
# receives the content "1 WRONG ANSWER".
#
# All the generated files above are created within the 'result'
# directory.
#
# Finally it deletes the runnable file generated by the compiling
# process and moves the Job directory to the 'DONE' directory.
#
# If the 'DEBUG' flag is set to 1, messages that indicates the step
# by step of this runnable file are printed to the output environment.

# Global Options
DEBUG=1
OUTPUT_SIZE_LIMIT=$((1024*1024+1))
CODE_SIZE_LIMIT=$((50*1024))

# This function compiles the problem code given within the Job directory
#
# First it Checks the size of the code file.
# Then, it finds the code file on the Job directory, generates two files named
# compile.out and compile.return in the 'result' directory which
# respectively have the output of the compiling command and the return
# code of the execution of the same command. The function then return
# this code too, indicating success or failure in compiling the code.
function compile()
{
	pathc=$1
	old_dir=$(pwd)
	cd DOING/$pathc

	# find the code_file on the folder
	code_to_be_judged=( $(ls | grep *.c) )
	code_to_be_judged=${code_to_be_judged[0]}

	[ $DEBUG -eq 1 ] && echo "code to be judged=${code_to_be_judged}"

	mkdir result
	
	# Code size limit 
	code_size=$(ls -l ${code_to_be_judged} | cut -d " " -f 5)
	
	[ $DEBUG -eq 1 ] && echo "Code size=${code_size}"
	
	if [ ${code_size} -gt ${CODE_SIZE_LIMIT} ]; then
		cd ${old_dir}
		return 255
	fi
	
	gcc ${code_to_be_judged} &> result/compile.out
	returner=`echo $?`
	echo ${returner} > result/compile.return
	cd ${old_dir}
	return ${returner}
}

# This function registers the differences between two outputs
#
# In this function, the command diff is executed to say the differences
# between the output file that came within the Job directory and the
# output file from the execution of the code with the given inputs that
# came within the Job directory too. It registers the output of the diff
# command within files related to each input file received. The files
# are created within the 'result' directory in the Job directory.

function differ()
{
	arquivo=$1
	pathd=$2
	ext=`echo ${arquivo} | cut -d. -f2`

	[ $DEBUG -eq 1 ] && echo "Diff phase between: ${pathd}/out.${ext} and ${pathd}/result/stdout.${ext}"

	diff DOING/${pathd}/out.${ext} DOING/${pathd}/result/stdout.${ext} > DOING/${pathd}/result/diff.${ext}
}

# This function registers the answer of a test case
#
# It analyzes the content of the diff file related to a specific input,
# if the file is empty, then it creates a file wth the content
# "0 ACCEPTED" within the 'result' directory in the Job directory, if
# the file is not empty, then it creates a file with the content
# "1 WRONG ANSWER" at the same directory it would be the other way.

function judge()
{
	arquivo=$1
	pathj=$2
	old_dir=$(pwd)

	cd DOING
	ext=`echo ${arquivo} | cut -d. -f2`

	out_size=$(ls -l ${pathj}/result/stdout.${ext} | cut -d " " -f5)
	if [ ${out_size} -ge ${OUTPUT_SIZE_LIMIT} ]; then
		echo -e "5\nOUTPUT SIZE LIMIT EXCEEDED" > $pathj/result/judge.$ext
		cd ${old_dir}
		return
	fi
	
	if [ `cat $pathj/result/diff.$ext | wc -l` -gt 0 ]
	then
		pe=$(diff -w -E -B ${pathj}/out.${ext} ${pathj}/result/stdout.${ext})
		if [ -z "$pe" ]; then
			echo -e "1\nPRESENTATION ERROR" > $pathj/result/judge.$ext
		else
			echo -e "2\nWRONG ANSWER" > $pathj/result/judge.$ext
		fi
	else
		echo -e "0\nACCEPTED" > $pathj/result/judge.$ext
	fi
	cd ${old_dir}
}

# This function determines the result for a Job
#
# It analyzes all the judge files created and if at least one of the
# judge files have the content "1 WRONG ANSWER" then it stops
# analyzing and create a file named judge within the 'result'
# directory in the Job directory with the content "1 WRONG ANSWER",
# if it doesn't find any judge file with that content, then it
# creates a file named judge with the content "0 ACCEPTED" in the
# same directory it would be the other way.

function general_judge()
{
	pathg=$1
	old_dir=$(pwd)

	cd DOING/$path/result/

	worst_code=999
	for i in `ls | grep -E ^judge.*`;
	do
		[ `cat $i | head -1` -gt $worst_code ] & worst_code=$(cat $i | head -1)
	done
	
	case $worst_code in
		0) echo -e "0\nACCEPTED" > judge ;;
		1) echo -e "1\nPRESENTATION ERROR" > judge ;;
		2) echo -e "2\nWRONG ANSWER" > judge ;;
		3) echo -e "3\nTIME LIMIT EXCEEDED" > judge ;;
		4) echo -e "4\nMEMORY LIMIT EXCEEDED" > judge ;;
		5) echo -e "5\nOUTPUT SIZE LIMIT EXCEEDED" > judge ;;
		6) echo -e "6\nCOMPILATION ERROR" > judge ;;
		7) echo -e "7\nCODE SIZE LIMIT EXCEEDED" > judge ;;
		8) echo -e "8\nJOB SUBMISSION ERROR" > judge ;;
		*) echo -e "999\nUNDEFINED ERROR" > judge ;;
	esac
	
	cd ${old_dir}
}

# This function runs the executable file got from the compiling
#
# It runs the executable file got from the compiling process of the code
# file, it creates two files for each test case, both files are created
# within the 'result' directory in the Job directory. The files are
# created with the content of the default output from the execution and
# the error output of the execution.

function execut()
{
	arquivo=$1
	pathe=$2
	old_dir=$(pwd)

	ext=`echo ${arquivo} | cut -d. -f2`
	cd DOING/$pathe

	[ $DEBUG -eq 1 ] && echo "Exec phase: stdout > result/stdout.$ext and stderr > result/stderr.$ext"

	#cat ${arquivo} | ./a.out > result/stdout.$ext 2> result/stderr.$ext
	{ ./a.out < ${arquivo} | head -c ${OUTPUT_SIZE_LIMIT} > result/stdout.$ext; } 2> result/stderr.$ext

	cd ${old_dir}
}

# ----------------------------------------------------------------------
# Main function of the script
# ----------------------------------------------------------------------

# Checking if running as root user (id =0)
if [ $(id -u) -eq 0 ]; then
   echo "You should NOT run this script as root user. Exiting..."
   exit 1
fi

[ $DEBUG -eq 1 ] && echo "Starting the script..."

# Main loop: look for new jobs every X sec
while :; do

	# Verify if there are new jobs
	njobs=`ls JOBS | grep ^Job 2> /dev/null | wc -l`
	[ $DEBUG -eq 1 ] && echo "Number of Jobs: $njobs"

	# No new jobs found.
	if [ ${njobs} -eq 0 ]
	then
		[ $DEBUG -eq 1 ] && echo "Nothing to be done (Sleeping...)"
		
		# Waiting for new jobs
		sleep 5
		continue
	fi

	# At least one new job
	path=`ls JOBS | grep ^Job | head -1`
	[ $DEBUG -eq 1 ] && echo -e "\nPATH=$path"

	mv JOBS/$path DOING/
	compile $path
	retcode=$?

	# Code size error
	if [ ${retcode} -eq 255 ]
	then
		echo -e "7\nCODE SIZE LIMIT EXCEEDED" > DOING/$path/result/judge
		
		[ $DEBUG -eq 1 ] && echo "Moving JOB to DONE folder"
		mv DOING/$path DONE/
		continue
	fi

	# Compilation error
	if [ ${retcode} -ne 0 ]
	then
		echo -e "6\nCOMPILATION ERROR" > DOING/$path/result/judge
		
		[ $DEBUG -eq 1 ] && echo "Moving JOB to DONE folder"
		mv DOING/$path DONE/
		continue
	fi

	# The compiling phase was well done
	for i in `ls DOING/$path/ | grep -E ^in.*`;
	do
		execut $i $path
		differ $i $path
		judge $i $path
	done

	# General Judging
	general_judge $path
	rm DOING/$path/a.out

	# All done
	[ $DEBUG -eq 1 ] && echo "Moving JOB to DONE folder"
	mv DOING/$path DONE/
		
done
