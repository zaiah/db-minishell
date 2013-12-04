#!/bin/bash -
#-----------------------------------------------------#
# build
#
# Creates a library out of db_minishell.
#-----------------------------------------------------#
#-----------------------------------------------------#
# Licensing
# ---------
# 
# Copyright (c) 2013 Vokayent
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
PROGRAM="build"

# References to $SELF
BINDIR="$(dirname "$(readlink -f $0)")"
SELF="$(readlink -f $0)"
source $BINDIR/lib/__.sh

# Static
LS="$(which ls 2>/dev/null)"
CAT="$(which cat 2>/dev/null)"

# usage() - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-b | --library                Amalgamates the code base as a library. 
                              (Does not include usage, installation, etc.)
-n | --name <arg>             Names the resultant library.
-w | --whole                  Amalgamates the code base as a library.
-i | --include <arg>          Include <arg> in these. 
-e | --exclude <arg>          Exclude <arg> in these. 
-l | --list-parts             List the parts that comprise the library.
-a | --admin                  Only build the parts needed for administrating 
                              a SQLite 3 database.
-o | --orm                    Only build the parts needed for querying a 
                              SQLite 3 database.
-v | --verbose                Be verbose in output.
-h | --help                   Show this help and quit.
"
   exit $STATUS
}


# Die if no arguments received.
[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" && usage 1


# Process options.
while [ $# -gt 0 ]
do
   case "$1" in
     -b|--library)
         DO_PACK=true
         DO_LIBRARY=true
      ;;
     -n|--name)
		  shift
		  LIB_NAME="$1"
		;;
     -l|--list-parts)
         DO_LIST_PARTS=true
      ;;
     -w|--whole)
         DO_PACK=true
         DO_WHOLE=true
      ;;
     -i|--include)
         DO_PACK=true
         DO_INCLUDE=true
         shift
         THESE="$1"
      ;;
     -e|--exclude)
         DO_PACK=true
         DO_EXCLUDE=true
         shift
         THESE="$1"
      ;;
     -a|--admin)
         DO_PACK=true
         DO_ADMIN=true
      ;;
     -o|--orm)
         DO_PACK=true
         DO_ORM=true
      ;;
     -v|--verbose)
        VERBOSE=true
      ;;
     -h|--help)
        usage 0
      ;;
     --) break;;
     -*)
      printf "Unknown argument received.\n";
      usage 1
     ;;
     *) break;;
   esac
shift
done


DELIM=","


# list the different parts.
if [ ! -z $DO_LIST_PARTS ]
then
	$LS --color $BINDIR/{lib,minilib}
fi

# library
if [ ! -z $DO_PACK ]
then
	# Whole needs no options.

	# Library
	[ ! -z $DO_LIBRARY ] && {
		EXCLUDE=("installation" "eval_flags" "is_element_present_in")
	}

	# Admin only
	[ ! -z $DO_ADMIN ] && {
		EXCLUDE=(
			"installation"
			"eval_flags"
			"is_element_present_in"
			"assemble_set"
			"assemble_clause"
			"convert"
			"chop_by_position"
		)
	}

	# ORM only
	[ ! -z $DO_ORM ] && {
		EXCLUDE=(
			"installation"
			"eval_flags"
			"is_element_present_in"
			"get_columns"
			"get_datatypes"
		)
	}

	# Exclude or Include certain ones.
	[ ! -z $DO_EXCLUDE ] && [ ! -z "$THESE" ] && {
		THESE="$(break_list_by_delim $THESE)"
	}

	# Concatenate
	for n in $BINDIR/{lib,minilib}/*
	do
		# Don't add if we've excluded.
		N=$(basename ${n%%.sh})
		[[ $N == "__" ]] || [[ $(is_this_in "EXCLUDE" "$N") == true ]] && {
			continue
		}
		
		printf "\n\n" | $CAT $n -
	done

	exit
	# Only take needed options and actions from the code.

	# Find first instance of x 
	# If nothing else is excluded, then just '# CREATE_LIB'
	[ -z "$LIB_NAME" ] && LIB_NAME="db_minishell"

	# Generate a license.
	sed -n 2,30p $SELF 

	# Basic libstuff.
	printf "${LIB_NAME}() {\n"
	printf "\tDO_LIBRARIFY=true\n"

	# Let's give some options to make certain things simpler.
	# Like if we're just using one database.

	# Or if we plan to only use one table.

	# The term will change, but libraries and functions can be incldued
	# on the fly with this.

	# Beginning of our range.
	CAT_START=$(( $(grep --line-number '# CREATE_LIB' $SELF | \
		head -n 1 | \
		awk -F ':' '{print $1}') + 1 ))

	# End of our range.
	CAT_END=$(wc -l $SELF | awk '{print $1}')

	# Output the document.
	sed -n ${CAT_START},${CAT_END}p $SELF | sed 's/^/\t/' 

	# Wrap last statement.
	printf "\n}\n"
fi
