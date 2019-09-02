#/bin/bash
cd /c0r3/Job
code_to_be_judged=( $(ls | grep *.pas) )
fpc ${code_to_be_judged} -oa.out &> result/compile.out
returner=`echo $?`
echo ${returner} > result/compile.return
