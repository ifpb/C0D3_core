#/bin/bash
while :; do
	python3 automate.py input files/
	if [ $? == 0 ]
	then
		tstmp=`date +%s`
		ext=`cat res.txt`
		mkdir -p ../../core/Jobs/Job.${ext}.${tstmp}
		mv files/input.$ext ../../core/Jobs/Job.${ext}.${tstmp}
		md5sum -b ../../core/Jobs/Job.${ext}.${tstmp}/input.$ext | sed "s/\ \*input.$ext//g" > ../../core/Jobs/Job.${ext}.${tstmp}/ID.${tstmp}
	fi
done
