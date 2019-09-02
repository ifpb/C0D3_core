#/bin/bash
cd /c0r3/Job
code_to_be_judged=( $(ls | grep *.cpp) )
g++ ${code_to_be_judged} &> result/compile.out
returner=`echo $?`
echo ${returner} > result/compile.return
