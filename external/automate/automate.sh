#/bin/bash
while :; do
	python3 automate.py input files/
	if [ $? == 0 ]
	then
		tstmp=`date +%s`
		ext=`cat res.txt`
		mkdir -p ../../core/JOBS/Job.${ext}.${tstmp}
		mv files/input.$ext ../../core/JOBS/Job.${ext}.${tstmp}
		md5sum -b ../../core/JOBS/Job.${ext}.${tstmp}/input.$ext | sed "s/\ \*input.$ext//g" > ../../core/JOBS/Job.${ext}.${tstmp}/ID.${tstmp}
	fi
done
