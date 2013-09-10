#!/bin/bash

# == Simplified BSD *** MODIFIED FOR NON-COMMERCIAL USE ONLY!!! *** ==
# Copyright (c) 2013, David Santiago <demanuel@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice, this 
#      list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, 
#      this list of conditions and the following disclaimer in the documentation and/or 
#      other materials provided with the distribution.
#    * Any redistribution, use, or modification is done solely for personal benefit 
#      and not for any commercial purpose or for monetary gain except with the authors
#      permision
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Permission granted for comercial use to: Rui Cabete <rui.cabete@gmail.com> (valid until 2015)


# To use this program just put this script in a "bin" folder and add to your ~/.bashrc the
# following lines (only one time!):
# for file in /path/to/bin/folder/*.sh
# do
#     . $file
# done 
#
# Then you'll need to logout and then login again. Now everytime you put a script in that "bin"
# folder the script will be fired up when you login. Now you can do: 
# $ findDependents -s pub.log:tracePipeline -l /opt/webmethods7/IntegrationServer


find_deps(){

    show_disabled=$1
    pattern=$2
    file=$3

    filename="${file##*/}"                      # Strip longest match of */ from start
    dir="${file:0:${#file} - ${#filename}}" # Substring from 0 thru pos of filename
    base="${filename%.[^.]*}"                       # Strip shortest match of . plus at least one non-dot char from end
    ext="${filename:${#base} + 1}"                  # Substring from len of base thru end



    i_ext=$( tr '[:upper:]' '[:lower:]' <<<"$ext" )



    string_pattern="<.*INVOKE.*SERVICE=\"$pattern\"";


    case $i_ext in 
	java)
             echo "Searching in JAVA files not supported!"
             ;;
        xml)
	     string_pattern_disabled="$string_pattern.*DISABLED=\"$show_disabled\".*>"

	     if grep -qi "$string_pattern_disabled" "$file"; then
		print_FQDN "disabled: " $file
	     else
		 if [ $show_disabled == "false" ]; then 

		     grep "$string_pattern" "$file" | grep -qvi "disabled"
		     code=$?

		     if [ "$code" == "0" ]; then
			print_FQDN "enabled: " $file
		     fi
		 fi

	     fi
	    
	    ;;
    esac

}


print_FQDN(){

	message = $1;
	file = $2;
	
	folder=$(dirname $file)
	temp_var=${folder##*/ns/}
	temp_var=${temp_var//\//.}

	temp_var=$(rev <<<"$temp_var")

	temp_var=${temp_var/./:}
	temp_var=$(rev <<<"$temp_var")

	echo "$message $temp_var"
}

usage()
{
cat <<EOF

# This program is licensed over a modified BSD License
# NON-COMMERCIAL USE ONLY!

usage: $0 options

This script will search the dependencies of a webmethod's service through the file system.


OPTIONS:
   -h Show this message
   -s <full.service:FQDN> which service you want to search
   -l </opt/webMethods/IntegrationServer/packages/> where are the packages installed in the filesystem
   -d If you want to find disabled services (-d to search disabled ones, without -d to search the enabled ones)
EOF
}


findDependents(){
    SERVICE=
    LOCATION=
    SHOW_DISABLED="false"

    while getopts "hds:l:" OPTION
    do
	case $OPTION in
            h)
		usage
		exit 1
		;;
            s)
		SERVICE=$OPTARG
		;;
            l)
		LOCATION=$OPTARG
		;;
            d)
		SHOW_DISABLED="true"
		;;
	    
            ?)
		usage
		exit
		;;
	esac
    done
    
    if [[ -z $LOCATION ]] || [[ -z $SERVICE ]]
    then
	usage
	exit 1
    fi
    
    
    export -f find_deps print_FQDN
    export SERVICE SHOW_DISABLED
    
    
    find $LOCATION -type f -iname flow.xml -exec bash -c 'find_deps "$SHOW_DISABLED" "$SERVICE" "{}"' \;

}

export -f findDependents
