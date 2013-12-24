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
PROGRAM="ms-build"

# References to $SELF
BINDIR="$(dirname "$(readlink -f $0)")"
SELF="$(readlink -f $0)"
FILE="$BINDIR/db-minishell.sh"
source $BINDIR/lib/__.sh

# Just for this build.
source $BINDIR/buildlib/pick_off.sh
source $BINDIR/buildlib/parse_range.sh

# Static
LS="$(which ls 2>/dev/null)"
CAT="$(which cat 2>/dev/null)"
GREP="$(which grep 2>/dev/null)"
SED="$(which sed 2>/dev/null)"
AWK="$(which awk 2>/dev/null)"
WC="$(which wc 2>/dev/null)"
PRINTF="$(which printf 2>/dev/null)"
DEPS=( "$GREP" "$LS" "$CAT" "$SED" "$AWK" "$WC" "$PRINTF" )

# Test shell
TEST_SHELL="$(which bash 2>/dev/null)"
[ -z $TEST_SHELL ] && { 
	printf "How can this be?  Bash does not exist on your system?"
	exit 1
}

# Project Markers 
MKR_LIC="[ LICENSE ]"
MKR_OPT="[ OPTS ]"
MKR_COD="[ CODE ]"

# Subroutine Markers.
MKR_LOC="[ LOCAL ]"
MKR_ORM="[ ORM ]"
MKR_ADM="[ ADMIN ]"
MKR_SER="[ SERIALIZATION ]"
MKR_EXT="[ EXTENSIONS ]"
MKR_SYS="[ SYSTEM ]"
MKR_ALL=( "MKR_LOC" "MKR_ORM" "MKR_ADM" "MKR_SER" "MKR_EXT" "MKR_SYS" )

# usage() - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -bnwielarsto <args> ]

-b | --library                Amalgamates the code base as a library. 
                              (Does not include usage, installation, etc.)
-n | --name <arg>             Names the resultant library.
-w | --whole                  Amalgamates the code base as a library.
-i | --include <arg>          Include <arg> in these. 
-e | --exclude <arg>          Exclude <arg> in these. 
-l | --list-parts             List the parts that comprise the library.
-a | --admin                  Only build the parts needed for administrating 
                              a SQLite 3 database.
-r | --orm                    Only build the parts needed for querying a 
                              SQLite 3 database.
-s | --stdout                 Output library to stdout versus a temporary file.
                              ( Default. )
-t | --at <arg>               Place the new library within this file <arg>.
-o | --omit <arg>             Omit anything within <arg>
                              [ license, summary ]
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
		# This option needs to tie both dbm and dba together and do other stuff...
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
			FILE="$BINDIR/dba.sh"
      ;;
     -r|--orm)
         DO_PACK=true
         DO_ORM=true
			FILE="$BINDIR/dbm.sh"
      ;;
     -s|--stdout)
        TO_STDOUT=true
      ;;
     -t|--at)
		  shift
		  PACK_LIB_AT="$1"
      ;;
     -o|--omit)
		  shift
		  OMIT_THESE="$1"
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

# Break up any omissions.
[ ! -z "$OMIT_THESE" ] && {
	OMISSIONS=( $(break_list_by_delim "$OMIT_THESE") )
	for EACH_OM in ${OMISSIONS[@]}
	do
		case "$EACH_OM" in
			c|comments) NO_COMMENTS=true ;;
			l|license) NO_LICENSE=true ;;
			d|depedencies) NO_DEPS=true ;;
		esac
	done
}

# list the different parts.
[ ! -z $DO_LIST_PARTS ] && $LS --color $BINDIR/{lib,minilib}

# library
if [ ! -z $DO_PACK ]
then
	# Whole needs no options.
	# [ ! -z $DO_WHOLE ] && { }
		
	# Library
	[ ! -z $DO_LIBRARY ] && {
		EXCLUDE=(
			"installation" 
			"eval_flags" 
			"is_element_present_in"
		)
		UNPARSE=(
			MKR_SYS
		)
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
		UNPARSE=(
			MKR_ORM
			MKR_SER
			MKR_EXT
			MKR_SYS
		)
	}

	# ORM only
	[ ! -z $DO_ORM ] && {
		EXCLUDE=(
			"installation"
			"eval_flags"
			"is_element_present_in"
			"parse_schemata"
		)
		UNPARSE=(
			MKR_ADM
			MKR_SYS
		)
	}

	# Exclude or Include certain ones.
	[ ! -z $DO_EXCLUDE ] && [ ! -z "$THESE" ] && {
		THESE="$(break_list_by_delim $THESE)"
	}

	# Generate a temporary file for the new library.
	tmp_file -n LIBTMP
	LIBFN="$LIBTMP"

	# Output where?
	if [ ! -z "$PACK_LIB_AT" ]
	then 
		[[ "$PACK_LIB_AT" == 'dbm.sh' ]] || [[ "$PACK_LIB_AT" == 'dba.sh' ]] && {
			{
				printf -- "Name: $PACK_LIB_AT is an illegal name.  (It will overwrite the libraries already in existence.)\n"
				printf -- "Please choose another.\n"
			} > /dev/stderr
		}
		LIB_FINAL="$PACK_LIB_AT"
	else
		LIB_FINAL="/dev/stdout"
	fi

	# Generate the code for the library.
	{ 
		# Generate a license if asked for.
		[ -z "$NO_LICENSE" ] && parse_range -f "$MKR_LIC" -t "$MKR_LIC END" -w $FILE

		# Generate the library name.
		[ -z "$LIB_NAME" ] && LIB_NAME="db_minishell"
		printf "${LIB_NAME}() {\n"
		printf "\t# Enable library.\n"
		printf "\tDO_LIBRARIFY=true\n\n"

		# Concatenate any external functions.
		[ -z $NO_DEPS ] && {
			for n in $BINDIR/{lib,minilib}/*
			do
				# Don't add if excluded.
				N=$(basename ${n%%.sh})
				[[ $N == "__" ]] || [[ $(is_this_in "EXCLUDE" "$N") == true ]] && {
					continue
				}

				# Output the code.
				printf "\n\n" | $CAT $n - | grep -v '#!/bin/bash' | sed 's/^/\t/g'
			done 
		}

		# Include any dependent code.
		parse_range -f "$MKR_LOC" -t "$MKR_LOC END" -w $FILE | sed 's/^/\t/g'

		# Cycle through options and real code.
		pick_off "$MKR_OPT" #workspace/opt
		pick_off "$MKR_COD" #workspace/cod

		# Wrap up the function. 
		printf "\n}\n"
	} > $LIBFN

	# Remove comments if asked for.
	[ ! -z $NO_COMMENTS ] && printf > /dev/null

	# Test by loading once.
	tmp_file -n FERR
	$TEST_SHELL $LIBFN 2>$FERR
	[ ! $(wc -c $FERR | awk '{print $1}') -eq 0 ] && {
		{ 
			printf "Something went wrong when creating the db_minishell library.\n"
			printf "Please try again or check if any features that were added are not interpreted correctly by the shell.\n" 
			printf "\n"
			printf "Error is as follows:\n"
			printf "====================\n"
			cat $FERR
		} > /dev/stderr

		rm $FERR
		tmp_file -w
		exit 1
	}

	# Create the library.
	cp $CP_FLAGS $LIBFN $LIB_FINAL
fi

# Clean up.
tmp_file -w
