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

# Static
LS="$(which ls 2>/dev/null)"
CAT="$(which cat 2>/dev/null)"
GREP="$(which grep 2>/dev/null)"
SED="$(which sed 2>/dev/null)"
AWK="$(which awk 2>/dev/null)"
WC="$(which wc 2>/dev/null)"
PRINTF="$(which printf 2>/dev/null)"
DEPS=( "$GREP" "$LS" "$CAT" "$SED" "$AWK" "$WC" "$PRINTF" )


# Markers
MKR_LIC="[ LICENSE ]"
MKR_OPT="[ OPTS ]"

MKR_LOC="[ LOCAL ]"
MKR_ORM="[ ORM ]"
MKR_ADM="[ ADMIN ]"
MKR_SER="[ SERIALIZATION ]"
MKR_EXT="[ EXTENSIONS ]"
MKR_SYS="[ SYSTEM ]"

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
	[ ! -z $DO_WHOLE ] && {
		PARSE=( 
			MKR_LOC 
			MKR_ORM
			MKR_ADM
			MKR_SER
			MKR_EXT
			MKR_SYS
		)
	}

	# Library
	[ ! -z $DO_LIBRARY ] && {
		EXCLUDE=("installation" "eval_flags" "is_element_present_in")
		PARSE=( 
			MKR_LOC 
			MKR_ORM
			MKR_ADM
			MKR_SER
			MKR_EXT
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
		PARSE=( 
			MKR_LOC 
			MKR_ADM
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
		PARSE=( 
			MKR_LOC 
			MKR_ORM
			MKR_SER
			MKR_EXT
		)
	}

	# Exclude or Include certain ones.
	[ ! -z $DO_EXCLUDE ] && [ ! -z "$THESE" ] && {
		THESE="$(break_list_by_delim $THESE)"
	}

	# Generate a license and library name.
	# sed -n 2,31p $FILE
	parse_range -f $MKR_LIC -t "$MKR_LIC END" -w $FILE

	# If nothing else is excluded, then just '# CREATE_LIB'
	[ -z "$LIB_NAME" ] && LIB_NAME="db_minishell"

	# Basic libstuff.
	printf "${LIB_NAME}() {\n"
	printf "\tDO_LIBRARIFY=true\n"

	# Concatenate any external functions.
	for n in $BINDIR/{lib,minilib}/*
	do
		# Don't add if we've excluded.
		N=$(basename ${n%%.sh})
		[[ $N == "__" ]] || [[ $(is_this_in "EXCLUDE" "$N") == true ]] && {
			continue
		}

		# Output the code.
		printf "\n\n" | $CAT $n - | grep -v '#!/bin/bash' | sed 's/^/\t/g'
	done

	# Process needed options by extracting from temporary file.
	tmp_file -n DD
	parse_range -f $MKR_LIC -t "$MKR_LIC END" -w $FILE > $DD

	# Only take needed options and actions from the code.
	# Loop through an array, according to what was thrown above...
	# Beginning of our range.
	for EACH_MKR in ${PARSE[@]}
	do
		# Define the marker.
		MKR="${!EACH_MKR}"

		# Remove the portions not asked for.
		sed -i "s/$(parse_range -f $MKR -t "$MKR END" -w $FILE)//" $DD
		#sed -n ${CAT_START},${CAT_END}p $FILE | sed 's/^/\t/' #> $TMPFILE
	done

	# Wrap last statement.
	printf "\n}\n"
fi

# Clean up.
tmp_file -w
