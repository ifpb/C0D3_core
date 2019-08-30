#/bin/bash

# This function compiles the problem code given within the Job directory
#
# First it Checks the size of the code file.
# Then, it finds the code file on the Job directory, generates two files $
# compile.out and compile.return in the 'result' directory which
# respectively have the output of the compiling command and the return
# code of the execution of the same command. The function then return
# this code too, indicating success or failure in compiling the code.

function pas_compile()
{
	pathc=$1
	old_dir=$(pwd)
	cd DOING/$pathc

	# find the code_file on the folder
	code_to_be_judged=( $(ls | grep *.pas) )
	code_to_be_judged=${code_to_be_judged[0]}

	[ $DEBUG -eq 1 ] && wait_debug "code to be judged=${code_to_be_judged}"

	mkdir result

	# Code size limit
	code_size=$(ls -l ${code_to_be_judged} | cut -d " " -f 5)

	[ $DEBUG -eq 1 ] && information_debug "Code size=${code_size}"

	if [ ${code_size} -gt ${CODE_SIZE_LIMIT} ]; then
        	cd ${old_dir}
        	return 255
	fi

	fpc ${code_to_be_judged} -oa.out &> result/compile.out
	returner=`echo $?`
	echo ${returner} > result/compile.return

	cd ${old_dir}
	return ${returner}
}

# This function runs the executable file got from the compiling
#
# It runs the executable file got from the compiling process of the code
# file, it creates two files for each test case, both files are created
# within the 'result' directory in the Job directory. The files are
# created with the content of the default output from the execution and
# the error output of the execution.
#
# This function also returns the running time of the execution to a
# file named 'return_time.$ext' in which '$ext' refers to the extension
# of the test case. An example would be, when the input file is 'in.0',
# the running time related file will be 'running_time.0'.

function pas_execut()
{
	arquivo=$1
	pathe=$2
	old_dir=$(pwd)

	ext=`echo ${arquivo} | cut -d. -f2`
	cd DOING/$pathe

	[ $DEBUG -eq 1 ] && wait_debug "Exec phase: stdout > result/stdout.$ext and stderr > result/stderr.$ext"

	# miliseconds
	total_time_limit=`cat meta/time_limit`
	step_time_in_seconds=`echo "scale=2; ${STEP_TIME} / 1000.0" | bc`
	total_running_time=0
	memory_limit=`cat meta/memory_limit`

	if [ ${memory_limit} -gt ${DEFAULT_MEMORY_LIMIT} ]
	then
		memory_limit=${DEFAULT_MEMORY_LIMIT}
	fi

	(
		ulimit -v ${memory_limit}
		echo ${BASHPID} > exec.pid;
		{
			echo "0" > result/retcode.$ext;
			./a.out < ${arquivo} | head -c ${OUTPUT_SIZE_LIMIT} > result/stdout.$ext;
			echo ${PIPESTATUS[0]} > result/retcode.$ext;
		} 2> result/stderr.$ext
	) 2> /dev/null &

	sleep ${step_time_in_seconds}
	sub_shell_pid=$(cat exec.pid)
	rm exec.pid

	while [ "${total_running_time}" -lt "${total_time_limit}" ]
	do
		kill -0 ${sub_shell_pid} &> /dev/null
		[ $? -ne 0 ] && break;
		sleep ${step_time_in_seconds}
		total_running_time=$((${total_running_time} + ${STEP_TIME}))
	done

	kill -9 ${sub_shell_pid} &> /dev/null
	wait ${sub_shell_pid} 2>/dev/null

	execcode=$(cat result/retcode.$ext)

	if [ "${total_running_time}" -ge "${total_time_limit}" ]; then
		execcode=255
	fi

	echo ${total_running_time} > result/running_time.$ext

	cd ${old_dir}
	return ${execcode}
}
