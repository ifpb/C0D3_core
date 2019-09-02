#/bin/bash

cd /c0r3/Job
total_time_limit=`cat meta/time_limit`
DEFAULT_MEMORY_LIMIT=`cat meta/DEFAULT_MEMORY_LIMIT`
step_time_in_seconds=`cat meta/STEP_TIME_IN_SECONDS`
OUTPUT_SIZE_LIMIT=`cat meta/OUTPUT_SIZE_LIMIT`
STEP_TIME=`cat meta/STEP_TIME`
arquivo=`cat meta/ARQUIVO`
pathe=`cat meta/PATH`
ext=`cat meta/EXT`
step_time_in_seconds=`echo "scale=2; ${STEP_TIME} / 1000.0" | bc`
total_running_time=0
memory_limit=`cat meta/memory_limit`

rm meta/DEFAULT_MEMORY_LIMIT
rm meta/STEP_TIME_IN_SECONDS
rm meta/OUTPUT_SIZE_LIMIT
rm meta/STEP_TIME
rm meta/ARQUIVO
rm meta/PATH
rm meta/EXT

if [ ${memory_limit} -gt ${DEFAULT_MEMORY_LIMIT} ]
then
	memory_limit=${DEFAULT_MEMORY_LIMIT}
fi

(
	ulimit -v $(( 2 * 1024 * 1024 ))
	memory_limit_mb=`echo "${memory_limit} / 1024" | bc`
	echo ${BASHPID} > exec.pid;
	{
		echo "0" > result/retcode.$ext;
		java -Xmx${memory_limit_mb}M Main < ${arquivo} | head -c ${OUTPUT_SIZE_LIMIT} > result/stdout.$ext;
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
wait ${sub_shell_pid} 2> /dev/null

execcode=$(cat result/retcode.$ext)

if [ "${total_running_time}" -ge "${total_time_limit}" ]; then
	execcode=255
fi

if [ $(cat result/stderr.$ext | grep -c "java.lang.OutOfMemoryError") -ge 1 ]; then
	execcode=127
fi

echo ${total_running_time} > result/running_time.$ext
echo ${execcode} > result/execcodetemp
