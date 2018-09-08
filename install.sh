#!/bin/bash

echo "Welcome to C0r3."
echo ""
echo "This script will install the c0r3 auto-judge in your computer"
echo ""

cd basename

read -e -p "Please enter the destination directory [/usr/c0r3]: " destination

# Default response
[ -z "$destination" ] && destination="/usr/c0r3"

# Double checking if the directory was created
mkdir $destination 2> /dev/null

# check 1
if [ $? -ne 0 ]; then
	echo "Error: Impossible to create the '$destination' directory. Exiting ..."
	exit 0
fi

# check 2
if [ ! -e $destination ]; then
	echo "Error: Impossible to create the '$destination' directory. Exiting ..."
	exit 0
fi

# Copying the necessary files
if [ -e core/doing.sh ]; then
	echo -n "Copying the main files ... "
	cp core/doing.sh ${destination}/
	echo "done"
	
	echo -n "Copying the documentation files ... "
	cp dependencies LICENSE README README.md ${destination}/
	echo "done"
	
	echo -n "Creating the necessary subdirectories ... "
	mkdir ${destination}/JOBS
	mkdir ${destination}/DOING
	mkdir ${destination}/DONE
	echo "done"
	
else
	echo "Error: Faild to copy the file 'doing.sh' to '$destination' directory. Exiting ..."
fi

echo "Done"
