#!/bin/bash -
#-----------------------------------------------------#
# dbm-install
#
# Installs db-minishell.
#-----------------------------------------------------#
#-----------------------------------------------------#
# Licensing
# ---------
# Copyright (c) <year> <copyright holders>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-----------------------------------------------------#
PROGRAM="dbm-install"

# References to $SELF
BINDIR="$(dirname "$(readlink -f $0)")"
SELF="$(readlink -f $0)"
source $BINDIR/lib/__.sh

# usage - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./$PROGRAM
	[ -fciutvh ]

-i | --install <dir>          Install to <dir> 
-u | --uninstall              Uninstall from <dir> 
-t | --total                  Uninstall and get rid of sources in system. 
-v | --verbose                Be verbose in output.
-h | --help                   Show this help and quit.
"
   exit $STATUS
}


# Die if no arguments received.
[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" > /dev/stderr && usage 1

# Process options.
while [ $# -gt 0 ]
do
   case "$1" in
     -i|--install)
         DO_INSTALL=true
			shift
			INSTALL_DIR="$1"
      ;;
     -u|--uninstall)
         DO_UNINSTALL=true
      ;;
     -t|--total)
         DO_TOTAL=true
      ;;
     -v|--verbose)
        VERBOSE=true
      ;;
     -h|--help)
        usage 0
      ;;
     --) break;;
     -*)
      printf "Unknown argument received.\n" > /dev/stderr;
      usage 1
     ;;
     *) break;;
   esac
shift
done

# Eval
eval_flags

# install
[ ! -z $DO_INSTALL ] && {
	[ -z "$INSTALL_DIR" ] && {
<<<<<<< HEAD
		{
			printf "No installation directory specified."
			printf "Exiting..."
		} > /dev/stderr
	}

	installation --do --these "dbkv,dbm,dba" --to "$INSTALL_DIR"
}

# uninstall
[ ! -z $DO_UNINSTALL ] && {
  	installation --undo
}

# total
[ ! -z $DO_TOTAL ] && {
	# Check the INSTALL file, to see if any files exist. 
  	installation --undo
  	
	# Destroy the sources.
	rm -rf $BINDIR 
}
