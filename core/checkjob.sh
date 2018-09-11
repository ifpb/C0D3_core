#/bin/bash

# This runnable file checks if the Job directory passed by parameter
# has all the required files following the defaults of this core.
#
# First it checks if the 'meta' directory and all the files that must be
# within this directory exists.
#
# Then it checks if the code file exists within the Job directory.
#
# Then it checks if there are the same quantity of input files and
# output files within the Job directory and checks if the input files
# and output files have the same extension, checking if they are all
# related.
#
# Last of all it checks the content of the language file, checks if the
# language of this file is supported by this core, and then checks if
# the language indicated by the file and the extension of the code file
# are of the same language.

PATH=$1
old_dirjob=`pwd`
cd $PATH

# This part of the code checks the state of the 'meta' directory within
# the Job directory
#
# It checks if the 'meta' directory exists within the Job directory and
# if so, checks if all the default files that should be within the
# 'meta' directory are really there. The files that must be in this
# directory are 'comments', 'done_url', 'processing_url', 'ID',
# 'language', 'memory_limit' and 'time_limit'. In case the 'meta'
# directory doesn't exists within the Job directory, this script
# returns the exit code 1, if the one of the files that must be within
# the 'meta' directory doesn't exist, this script returns the exit code
# 2.

if [ `ls -d meta/ | wc -l` -eq 0 ]
then
	exit 1
elif [ `ls meta/ | grep -w comments | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w done_url | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w processing_url | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w ID | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w language | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w memory_limit | wc -l` -eq 0 ] || \
[ `ls meta/ | grep -w time_limit | wc -l`-eq 0 ]
then
	exit 2
fi

# This part of the code checks if there is a code file within the Job
# directory
#
# It returns the exit code 3 if there is no code file within the Job
# directory.

if [ `ls | grep code.* | wc -l` -eq 0 ]
then
	cd ${old_dirjob}
	exit 3
fi

# This part of the code checks the relation between the in and out files
#
# First it collects all the input and output files within the Job
# directory and list them in two different files, then it checks if the
# number of input files and output files are the same, returns the exit
# code 4 in case they have different quantity. In case they have the
# same quantity, it checks if the input files and output files have the
# same extension, in case are all related, it continues the execution of
# this script, in other case it returns the exit code 5.

ls | grep in.* > inputs
ls | grep out.* > outputs
num_inputs=`cat inputs | wc -l`
num_outputs=`cat outputs | wc -l`
if [ ${num_inputs} -eq ${num_outputs} ]
then
	cd ${old_dirjob}
	exit 4
fi

cat inputs | while read line
do
	jobext=`echo $line | cut -d. -f2-`
	if [ `cat outputs | grep out.$jobext | wc -l` -eq 0 ]
	then
		cd ${old_dirjob}
		exit 5
	fi
done

# This part of the code checks if the language is supported by the core
#
# It checks the content of the file 'language' located within the 'meta'
# directory which is within the Job directory, and checks if it is one
# of the languages supported by this core and, then in case is onde of
# these languages it checks if the code file have the extension related
# to the language found in the 'language' file. In case the language
# doesn't make part of the languages supported by the core, this script
# returns the exit code 6. If the language is supported but the code
# file extension doesn't match with the language, this script returns
# the exit code 7.

lang=`cat meta/language`
case $lang in
	c)
		if [ `ls | grep code.c | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	c++)
		if [ `ls | grep code.cpp | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	java)
		if [ `ls | grep code.java | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	python2)
		if [ `ls | grep code.py | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	python3)
		if [ `ls | grep code.py | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	pascal)
		if [ `ls | grep code.pas | wc -l` -eq 0 ]
		then
			return 7
		fi
		;;
	*)
		cd ${old_dirjob}
		exit 6
	;;
esac

cd ${old_dirjob}
exit 0
