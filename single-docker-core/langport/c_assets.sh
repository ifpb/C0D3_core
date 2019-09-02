#/bin/bash

# This function compiles the problem code given within the Job directory
#
# First it Checks the size of the code file.
# Then, it finds the code file on the Job directory, generates two files $
# compile.out and compile.return in the 'result' directory which
# respectively have the output of the compiling command and the return
# code of the execution of the same command. The function then return
# this code too, indicating success or failure in compiling the code.

function c_compile()
{
	pathc=$1
	old_dir=$(pwd)
	cd DOING/$pathc

	# find the code_file on the folder
	code_to_be_judged=( $(ls | grep *.c) )
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

	pathdocker=`pwd`

	docker run -v "${pathdocker}":/c0r3/Job --name c_compile1 c_compile
	docker rm -f c_compile1

	returner=`cat result/compile.return`
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

function c_execut()
{
	arquivo=$1
	pathe=$2
	old_dir=$(pwd)

	ext=`echo ${arquivo} | cut -d. -f2`
	cd DOING/$pathe

	echo ${arquivo} > meta/ARQUIVO
	echo ${pathe} > meta/PATH
	echo $ext > meta/EXT
	echo ${STEP_TIME} > meta/STEP_TIME
	echo ${OUTPUT_SIZE_LIMIT} > meta/OUTPUT_SIZE_LIMIT
	echo ${step_time_in_seconds} > meta/STEP_TIME_IN_SECONDS
	echo ${DEFAULT_MEMORY_LIMIT} > meta/DEFAULT_MEMORY_LIMIT

	[ $DEBUG -eq 1 ] && wait_debug "Exec phase: stdout > result/stdout.$ext and stderr > result/stderr.$ext"

	pathdocker=`pwd`

	docker run -v "${pathdocker}":/c0r3/Job --name c_execut1 c_execut
	docker rm -f c_execut1

	execcode=`cat result/execcodetemp`
	rm result/execcodetemp

	cd ${old_dir}
	return ${execcode}
}
