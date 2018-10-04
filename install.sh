#!/bin/bash

# Global Options

COLOR_SCHEME=1

function error_debug()
{
        text=$1
        if [ $COLOR_SCHEME -eq 0 ]; then
                echo -e $text
        else
                echo -e "\e[01;31m$text\e[00m"
        fi
}

function wait_debug()
{
        text=$1
        if [ $COLOR_SCHEME -eq 1 ]; then
                echo -e "\e[01;33m$text\e[00m"

        elif [ $COLOR_SCHEME -eq 2 ]; then
                echo -e "\e[01;35m$text\e[00m"
        else
                echo -e $text
        fi
}
function accept_debug()
{
        text=$1
        if [ $COLOR_SCHEME -eq 1 ]; then
                echo -e "\e[01;32m$text\e[00m"

        elif [ $COLOR_SCHEME -eq 2 ]; then
                echo -e "\e[01;34m$text\e[00m"
        else
                echo -e $text
        fi
}

function information_debug()
{
        text=$1
        if [ $COLOR_SCHEME -eq 1 ]; then
                echo -e "\e[01;34m$text\e[00m"
        elif [ $COLOR_SCHEME -eq 2 ]; then
                echo -e "\e[01;30m$text\e[00m"
        else
                echo -e $text
        fi
}

information_debug "Welcome to C0r3."
information_debug ""
information_debug "This script will install the c0r3 auto-judge in your computer"
information_debug ""

cd basename

read -e -p "Please enter the destination directory [/usr/c0r3]: " destination

# Default response
[ -z "$destination" ] && destination="/usr/c0r3"

# Double checking if the directory was created
mkdir $destination 2> /dev/null

# check 1
if [ $? -ne 0 ]; then
	error_debug "Error: Impossible to create the '$destination' directory. Exiting ..."
	exit 0
fi

# check 2
if [ ! -e $destination ]; then
	error_debug "Error: Impossible to create the '$destination' directory. Exiting ..."
	exit 0
fi

# Copying the necessary files
if [ -e core/doing.sh ]; then
	wait_debug -n "Copying the main files ... "
	cp core/doing.sh ${destination}/
	accept_debug "done"

	wait_debug -n "Copying the documentation files ... "
	cp dependencies LICENSE README README.md ${destination}/
	accept_debug "done"

	wait_debug -n "Creating the necessary subdirectories ... "
	mkdir ${destination}/JOBS
	mkdir ${destination}/DOING
	mkdir ${destination}/DONE
	accept_debug "done"

else
	error_debug "Error: Faild to copy the file 'doing.sh' to '$destination' directory. Exiting ..."
fi

accept_debug "Done"

