function c_docker_execut()
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

        mkdir container
        mv ${arquivo} container
        mv a.out container
        out_of_container=`pwd`
        cd container

        echo ${ext} > ext
	echo ${memory_limit} > memory_limit
        echo ${arquivo} > arquivo
        echo ${BASHPID} > bashpid
        echo ${OUTPUT_SIZE_LIMIT} > output_size_limit
        echo ${PIPESTATUS[0]} > pipestatus

------------------------------------------
        mkdir result
        ext=`cat ext`
        memory_limit=`cat memory_limit`
        arquivo=`cat arquivo`
        bashpid=`cat bashpid`
        output_size_limit=`cat output_size_limit`
        pipestatus=`cat pipestatus`

        (
                ulimit -v ${memory_limit}
                echo ${bashpid} > exec.pid;
                {
                        echo "0" > result/retcode.$ext;
                        ./a.out < ${arquivo} | head -c ${output_size_limit} > result/stdout.$ext;
                        echo ${pipestatus} > result/retcode.$ext;
        } 2> result/stderr.$ext
        ) 2> /dev/null &

------------------------------------------

        cd ${out_of_container}
        mv container/result/* result/
        rmdir container/result/
	mv container/* .
        rmdir container

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
