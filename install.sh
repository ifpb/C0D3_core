#!/bin/bash

# This runnable file installs c0r3 auto-judges on the computer.
# First, the script requires to inform the destination directory, and if no error
# has occured, copies the necessary files.
# Case no error be found during the process, the c0r3 is correctly installed.

# Global Options

COLOR_SCHEME=1

# This function sets the color scheme for the 'error' messages
#
# It leaves set the default output color of the current terminal
# configuration if the COLOR_SCHEME is set to 0.
# It sets the output color to 'red' if the COLOR_SCHEME is set to any
# other value.

function error_debug()
{
	opt=""
	text=$1

	if [ "$1" = "-n" ]; then
		opt="-n"
		text=$2
	fi

	case $COLOR_SCHEME in
		0) echo -e ${opt} "$text" ;;
		*) echo -e ${opt} "\e[01;31m$text\e[00m" ;;
	esac
}

# This function sets the color scheme for the 'wait' messages
#
# It sets the output color to 'yellow' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'purple' if the COLOR_SCHEME is set to 2
# ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.


function wait_debug()
{
	opt=""
	text=$1

	if [ "$1" = "-n" ]; then
		opt="-n"
		text=$2
	fi

	case $COLOR_SCHEME in
		1) echo -e ${opt} "\e[01;33m$text\e[00m" ;;
		2) echo -e ${opt} "\e[01;35m$text\e[00m" ;;
		*) echo -e ${opt} "$text" ;;
	esac
}

# This function sets the color scheme for the 'accept' messages
#
# It sets the output color to 'green' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'blue' if the COLOR_SCHEME is set to 2
# ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.

function accept_debug()
{
	opt=""
	text=$1

	if [ "$1" = "-n" ]; then
		opt="-n"
		text=$2
	fi

	case $COLOR_SCHEME in
		1) echo -e ${opt} "\e[01;32m$text\e[00m" ;;
		2) echo -e ${opt} "\e[01;34m$text\e[00m" ;;
		*) echo -e ${opt} "$text" ;;
	esac
}

# This function sets the color scheme for the 'information' messages
#
# It sets the output color to 'blue' if the COLOR_SCHEME is set to 1
# ("ideal for dark background colors in terminal").
# It sets the output color to 'dark gray' if the COLOR_SCHEME is set
# to 2 ("ideal for light background colors in terminal").
# If the COLOR_SCHEME is set to some other value it leaves set the
# default output color of the current terminal configuration.

function information_debug()
{
	opt=""
	text=$1

	if [ "$1" = "-n" ]; then
		opt="-n"
		text=$2
	fi

	case $COLOR_SCHEME in
		1) echo -e ${opt} "\e[01;34m$text\e[00m" ;;
		2) echo -e ${opt} "\e[01;30m$text\e[00m" ;;
		*) echo -e ${opt} "$text" ;;
	esac
}

information_debug "Welcome to C0r3."
information_debug ""
information_debug "This script will install the c0r3 auto-judge into your computer"
information_debug ""

cd $(dirname $0)

information_debug "Please enter the destination directory [/usr/c0r3]: "
read destination

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
	wait_debug -n "Copying the main file ... "
	cp core/doing.sh ${destination}/
	accept_debug "done"

	wait_debug -n "Copying langport files ... "
	cp -r core/langport ${destination}/
	accept_debug "done"

	wait_debug -n "Creating configuration file ... "
	cp core/c0r3.cfg.default ${destination}/c0r3.cfg
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

accept_debug "All done! Hope you enjoy it!"

