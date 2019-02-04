function c_docker_execut()
{
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
}
