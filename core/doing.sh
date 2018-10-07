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
SLEEP_TIME=5
DEFAULT_MEMORY_LIMIT=$((50*1024)) # in KB
STEP_TIME=10
COLOR_SCHEME=1

BASE_DIR=""

# This function finds the base directory for this script and goes to it!
#
# First it Checks the if the base directory is setted in the configuration file.
# Then, it checks if the directoris JOBS, DOING and DONE exists and if it
# is possible to write in there.
function goto_base_dir()
{
	BASE_DIR=$( dirname $0 )

	cd ${BASE_DIR}

	for req_dir in "JOBS" "DOING" "DONE"; do
		if [ ! -d "${req_dir}" ] || [ ! -w "${req_dir}" ]
		then
			error_debug "Directory ${BASE_DIR}/${req_dir} not found or not writable. Exiting..."
			exit 0
		fi
	done
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

	[ $DEBUG -eq 1 ] && wait_debug "Diff phase between: ${pathd}/out.${ext} and ${pathd}/result/stdout.${ext}"

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
	execode=$3

	old_dir=$(pwd)

	cd DOING
	ext=`echo ${arquivo} | cut -d. -f2`

	if [ ${execode} -eq 127 -o ${execode} -eq 137 ]; then
		echo -e "5\nMEMORY LIMIT EXCEEDED" > $pathj/result/judge.$ext
		cd ${old_dir}
		return
	fi

	if [ ${execode} -eq 1 ]; then
		echo -e "3\nRUNTIME_ERROR" > $pathj/result/judge.$ext
		cd ${old_dir}
		return
	fi

	if [ ${execode} -eq 139 ]; then
		echo -e "3\nRUNTIME_ERROR" > $pathj/result/judge.$ext
		cd ${old_dir}
		return
	fi

	if [ ${execode} -eq 255 ]; then
		echo -e "4\nTIME LIMIT EXCEEDED" > $pathj/result/judge.$ext
		cd ${old_dir}
		return
	fi

	out_size=$(ls -l ${pathj}/result/stdout.${ext} | cut -d " " -f5)
	if [ ${out_size} -ge ${OUTPUT_SIZE_LIMIT} ]; then
		echo -e "6\nOUTPUT SIZE LIMIT EXCEEDED" > $pathj/result/judge.$ext
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
		3) echo -e "3\nRUNTIME_ERROR" > judge ;;
		4) echo -e "4\nTIME LIMIT EXCEEDED" > judge ;;
		5) echo -e "5\nMEMORY LIMIT EXCEEDED" > judge ;;
		6) echo -e "6\nOUTPUT SIZE LIMIT EXCEEDED" > judge ;;
		7) echo -e "7\nCOMPILATION ERROR" > judge ;;
		8) echo -e "8\nCODE SIZE LIMIT EXCEEDED" > judge ;;
		9) echo -e "9\nJOB SUBMISSION ERROR" > judge ;;
		*) echo -e "999\nUNDEFINED ERROR" > judge ;;
	esac

	[ $DEBUG -eq 1 ] && accept_debug "Judge Result: $(cat judge | tr '\n' ' ')"
	
	cd ${old_dir}
}

# This function sets the color scheme for the 'error' messages
#
# It leaves set the default output color of the current terminal
# configuration if the COLOR_SCHEME is set to 0.
# It sets the output color to 'red' if the COLOR_SCHEME is set to any
# other value.

function error_debug()
{
	text=$1
	if [ $COLOR_SCHEME -eq 0 ]; then
		echo -e $text
	else
		echo -e "\e[01;31m$text\e[00m"
	fi
}

# This function sets the color scheme for the 'wait' messages
#
# It sets the output color to 'yellow' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'purple' if the COLOR_SCHEME is set to 2
# ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.

function wait_debug()
{
	text=$1
	if [ $COLOR_SCHEME -eq 1 ]; then
		echo -e "\e[01;33m$text\e[00m"

	elif [ $COLOR_SCHEME -eq 2 ]; then
		echo -e "\e[01;35m$text\e[00m"
	else
		echo -e $text
	fi

}

# This function sets the color scheme for the 'accept' messages
#
# It sets the output color to 'green' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'blue' if the COLOR_SCHEME is set to 2
# ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.

function accept_debug()
{
	text=$1
	if [ $COLOR_SCHEME -eq 1 ]; then
		echo -e "\e[01;32m$text\e[00m"

	elif [ $COLOR_SCHEME -eq 2 ]; then
		echo -e "\e[01;34m$text\e[00m"
	else
		echo -e $text
	fi
}

# This function sets the color scheme for the 'information' messages
#
# It sets the output color to 'blue' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'dark gray' if the COLOR_SCHEME is set
# to 2 ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.

function information_debug()
{
	text=$1
	if [ $COLOR_SCHEME -eq 1 ]; then
		echo -e "\e[01;34m$text\e[00m"
	elif [ $COLOR_SCHEME -eq 2 ]; then
		echo -e "\e[01;30m$text\e[00m"
	else
		echo -e $text
	fi
}

# This function reads the values from the core configuration file
#
# This function searches for the configuration file in the system, and
# if it founds it, it reads the names and values within the file and
# the global variables within the 'doing.sh' receive the values which
# they are related.

function read_config()
{
	config_file="c0r3.cfg"
	if [ ! -r "${config_file}" ]; then
		error_debug "Configuration file ${BASE_DIR}/${config_file} not found. Using default values..."
	else
		rm -rf /tmp/c0r3.cfg 2> /dev/null
		cat ${config_file} | sed -r 's/#.*$//g' | awk 'NF==2 {print $0}' > /tmp/c0r3.cfg
		while read a b; do
			case $a in
				"DEBUG") DEBUG=${b} ;;
				"OUTPUT_SIZE_LIMIT") OUTPUT_SIZE_LIMIT=${b} ;;
				"CODE_SIZE_LIMIT") CODE_SIZE_LIMIT=${b} ;;
				"SLEEP_TIME") SLEEP_TIME=${b};;
				"STEP_TIME") STEP_TIME=${b};;
				"DEFAULT_MEMORY_LIMIT") DEFAULT_MEMORY_LIMIT=${b};;
				"COLOR_SCHEME") COLOR_SCHEME=${b};;
			esac
		done < /tmp/c0r3.cfg
		rm -rf /tmp/c0r3.cfg 2> /dev/null
	fi
}
# ----------------------------------------------------------------------
# Main function of the script
# ----------------------------------------------------------------------

# Checking if running as root user (id =0)
if [ $(id -u) -eq 0 ]; then
   error_debug "You should NOT run this script as root user. Exiting..."
   exit 1
fi

# Going to BASE_DIR
goto_base_dir

# Checking the configuration file
read_config

# Importing functions related to compiling and execution of different
# programming languages

source ./langport/c_assets.sh
source ./langport/cpp_assets.sh
source ./langport/py2_assets.sh
source ./langport/py3_assets.sh
source ./langport/pas_assets.sh


[ $DEBUG -eq 1 ] && wait_debug  "Starting the script..."


# Main loop: look for new jobs every X sec
while :; do

	# Verify if there are new jobs
	njobs=`ls JOBS | grep ^Job 2> /dev/null | wc -l`
	[ $DEBUG -eq 1 ] && information_debug "Number of Jobs: $njobs"

	# No new jobs found.
	if [ ${njobs} -eq 0 ]
	then
		[ $DEBUG -eq 1 ] && information_debug "Nothing to be done (Sleeping...)"

		# Waiting for new jobs
		sleep ${SLEEP_TIME}
		continue
	fi

	# At least one new job
	# look for ready jobs. i.e. the file job/meta/lockfree exists
	the_first_10_jobs=( $(ls JOBS | grep ^Job | head -10) )
	path=""
	for job in ${the_first_10_jobs[*]}; do
		if [ -e "JOBS/${job}/meta/lockfree" ]; then
			path=$job;
			break
		fi
	done

	if [ -z "${path}" ]; then
		[ $DEBUG -eq 1 ] && information_debug "There are no ready Jobs (Sleeping...)"
		sleep ${SLEEP_TIME}
		continue
	fi

	./checkjob.sh $path
	reschkjob=$?

	case ${reschkjob} in
		0)	[ $DEBUG -eq 1 ] && accept_debug "The format of the Job is OK!"	;;
		1)	[ $DEBUG -eq 1 ] && error_debug "The meta directory doesn't seems to exist..."	;;
		2)	[ $DEBUG -eq 1 ] && error_debug "One of the files that should be within the meta directory doesn't exist..." ;;
		3)	[ $DEBUG -eq 1 ] && error_debug "The code file doesn't exist..." ;;
		4)	[ $DEBUG -eq 1 ] && error_debug "The quantity of the input files and output files is different..." ;;
		5)	[ $DEBUG -eq 1 ] && error_debug "One, some or all of the input files and output files are not related..." ;;
		6)	[ $DEBUG -eq 1 ] && error_debug "The language of the code is not supported by this core..." ;;
		7)	[ $DEBUG -eq 1 ] && error_debug "The language indicated by the 'language' file and the extension of the code file doesn't match..." ;;
		*)	[ $DEBUG -eq 1 ] && error_debug "Unknown return code D:|" ;;
	esac

	[ $DEBUG -eq 1 ] && information_debug "\nPATH=$path"

	# Moving the Job to the Working directory
	mv JOBS/$path DOING/

	# Job Format error
	if [ ${reschkjob} -ne 0 ]
	then
		mkdir DOING/$path/result 2> /dev/null
		echo -e "9\nJOB SUBMISSION ERROR" > DOING/$path/result/judge

		[ $DEBUG -eq 1 ] && wait_debug "Moving JOB to DONE folder"
		mv DOING/$path DONE/
		continue
	fi

	# Search for the language the code was submitted
	current_language=`cat DOING/$path/meta/language`

	[ $DEBUG -eq 1 ] && information_debug "\nLanguage of submission: ${current_language}"

	case $current_language in
		"c")		COMPILE_FUNCTION=c_compile
					EXEC_FUNCTION=c_execut
					;;
		"c++")		COMPILE_FUNCTION=cpp_compile
					EXEC_FUNCTION=cpp_execut
					;;
		"java")		COMPILE_FUNCTION=java_compile
					EXEC_FUNCTION=java_execut
					;;
		"python2")	COMPILE_FUNCTION=py2_compile
					EXEC_FUNCTION=py2_execut
					;;
		"python3")	COMPILE_FUNCTION=py3_compile
					EXEC_FUNCTION=py3_execut
					;;
		"pascal")	COMPILE_FUNCTION=pas_compile
					EXEC_FUNCTION=pas_execut
					;;
	esac


	# Compiling the code -----------------------------------------------
	${COMPILE_FUNCTION} $path
	retcode=$?


	# Code size error
	if [ ${retcode} -eq 255 ]
	then
		echo -e "8\nCODE SIZE LIMIT EXCEEDED" > DOING/$path/result/judge

		[ $DEBUG -eq 1 ] && wait_debug "Moving JOB to DONE folder"
		mv DOING/$path DONE/
		continue
	fi

	# Compilation error
	if [ ${retcode} -ne 0 ]
	then
		echo -e "7\nCOMPILATION ERROR" > DOING/$path/result/judge

		[ $DEBUG -eq 1 ] && wait_debug "Moving JOB to DONE folder"
		mv DOING/$path DONE/
		continue
	fi

	# The compiling phase was well done, execute! ----------------------

	for i in $(ls DOING/$path/ | grep -E ^in.*);
	do
		${EXEC_FUNCTION} $i $path
		execcode=$?

		[ ${execcode} -eq 0 ] && differ $i $path 
		judge $i $path ${execcode}
	done


	# General Judging
	general_judge $path
	rm DOING/$path/a.out   2> /dev/null
	rm DOING/$path/a.py    2> /dev/null
	rm DOING/$path/a.class 2> /dev/null

	# All done
	[ $DEBUG -eq 1 ] && wait_debug "Moving JOB to DONE folder"
	mv DOING/$path DONE/

done

