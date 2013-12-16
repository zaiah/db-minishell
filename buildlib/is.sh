#-----------------------------------------------------#
# is
#
# Check if an element is of particular type.
#-----------------------------------------------------#

# Includes extract_real_match() 
# for now...

#-----------------------------------------------------#
# extract_real_match ()
#
# Find an exact match.
# Grep fails for searches like this.
#-----------------------------------------------------#
extract_real_match () {
	# Make stuff local
	local NAME=
	local NAME=
	local VERBOSE=
	local DO_FUNCTION=
	local DO_INCLUDE_COMMENTS=
	local FILE=

	# Options.
	while [ $# -gt 0 ]
	do
		case "$1" in
		-f|--find)
				shift
				NAME="$1"
			;;
		-i|--include-comments)
				DO_INCLUDE_COMMENTS=true
			;;
		-f|--function)
				DO_FUNCTION=true
			;;
		-w|--within)
			shift
			FILE="$1"
			;;
		-v|--verbose)
			VERBOSE=true
			;;
		-h|--help)
			exit 0
			;;
		--) break;;
		-*)
			printf "Unknown argument received.\n" > /dev/stderr;
			exit 1
		;;
		*) break;;
		esac
	shift
	done

	# Set to stdin if not some other file.
	[ -z "$FILE" ] && FILE=/dev/stdin
	# cat $FILE

	# Set a name.
	[ -z "$NAME" ] && { 
		printf "No term to search for." > /dev/stderr
	} 

	# Some overrides.

	# Find the function name within the file.
	# (Example: $PROGRAM -x pear --from mega.sh)
	# 
	# What if there are multiple of the same name?
	# If a conflict like this is found, best to examine
	# both functions as temporary files or let the user know.
	#
	# Find the line number containing our name, if more
	# than one match, handle it properly.
	SLA="$(grep --line-number "$NAME" "$FILE" | \
		awk -F ':' '{ print $1 }')"

	# Could have many matches.
	[ ! -z "$SLA" ] && SLA=( $SLA )
#cat $FILE
	grep "$NAME" "$FILE" 
#	echo ${SLA[@]}
	exit
	# In said line, check to make sure that $NAME 
	# is actually $NAME and not part of something else.
	for POSS_RANGE in ${SLA[@]}
	do
		# Process this one line.
		FEXSRC="$(sed -n ${POSS_RANGE}p ${FROM} 2>/dev/null)"

		# Disregard comment blocks.
		[[ "$FEXSRC" =~ "#" ]] && {
			# Check everything before the first comment.
			FEXSRC="${FEXSRC%%#*}"
		}

		# If matched line doesn't contain (), next match. 
		[[ ! "$FEXSRC" =~ "(" ]] || [[ ! "$FEXSRC" =~ ")" ]] && {
			continue	
		}

		# Remove leading white space and function wraps...
		FEXLINE="$( printf "%s" $FEXSRC | \
			sed "s/^[ \t]*\($NAME\).*/\1/g")" 

		# ... to check if script received an accurate match.
		[[ ! "$FEXLINE" == $NAME ]] && {
			continue	
		}

		# If all checks are good, there's the line range.
		SL=$POSS_RANGE
		break
	done

	# Unset mania!
	unset FIND
	unset VERBOSE
	unset DO_FUNCTION
	unset DO_INCLUDE_COMMENTS
}


is() {
	local DO_WHAT=
	local DO_INTEGER=
	local DO_STRING=
	local DO_ARRAY=
	local WHAT= 
	local STRING= 
	local INTEGER= 
	local ARRAY= 
	local VERBOSE= 

	LIBPROGRAM="is"
	is_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-w | --what <arg>             desc
	-i | --integer <arg>          desc
	-s | --string <arg>           desc
	-a | --array <arg>            desc
	-t | --temporary <arg>        desc
	-f | --fifo <arg>             desc
	-p | --pipe <arg>             desc
	-d | --device <arg>           desc
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}
	
	# Usage if asked...	
	[ -z "$#" ] && printf "Nothing to do\n" > /dev/stderr && is_usage 1
	
	while [ $# -gt 0 ]
	do
	   case "$1" in
	     -w|--what)
	         DO_WHAT=true
	         shift
	         WHAT="$1"
	      ;;
	     -i|--integer)
	         DO_INTEGER=true
	         shift
	         INTEGER="$1"
	      ;;
	     -s|--string)
	         DO_STRING=true
	         shift
	         STRING="$1"
	      ;;
	     -a|--array)
	         DO_ARRAY=true
	         shift
	         ARRAY="$1"
	      ;;
	     -v|--verbose)
	        VERBOSE=true
	      ;;
	     -h|--help)
	        is_usage 0
	      ;;
	     --) break;;
	     -*)
	      printf "Unknown argument received.\n" > /dev/stderr;
	      is_usage 1
	     ;;
	     *) break;;
	   esac
	shift
	done

	# ...
	
	[ ! -z $DO_WHAT ] && {
		# Is it blank?
		WHAT=${WHAT:-"null"}		

		# Something.
		#[[ ! "$WHAT" == "null" ]] && {
		[ ! -z "$WHAT" ] && {
			# You need something to evaluate what type...
			# After the grep...
#			declare | grep "$WHAT" | \
#				extract_real_match --find "$WHAT"
			declare | grep "$WHAT" 

			# Evaluate the type.
			# Remember that using grep could result in false positives all day.
			declare | grep "$WHAT" | (
				echo "Value: [ ${!WHAT} ]"

				# String
				if [ ! -z "$( grep "${WHAT}='" )" ]
				then
					echo "string"

				# Empty string.
				elif [ ! -z "$( grep "${WHAT}=''" )" ]
				then
					echo "empty"

				# Function 
				elif [ ! -z "$( grep --fixed-strings "${WHAT} ()" )" ]
				then
					echo "function"

				# Array 
				elif [ ! -z "$( grep "${WHAT}=(" )" ]
				then
					echo "array"

				# Integer
				elif [ ! -z "$( grep "${WHAT}=" )" ]
				then
					echo "integer"

				# ...
				else
					echo "nothing"
				fi
			)


#				# If matched line doesn't contain (), next match. 
#				[[ ! "$FEXSRC" =~ "(" ]] || [[ ! "$FEXSRC" =~ ")" ]] && {
#					continue	
#				}
#
#				# Remove leading white space and function wraps...
#				FEXLINE="$( printf "%s" $FEXSRC | \
#					sed "s/^[ \t]*\($NAME\).*/\1/g")" 
#
#				# ... to check if script received an accurate match.
#				[[ ! "$FEXLINE" == $NAME ]] && {
#					continue	
#				}
#
#				# String
#				if [ grep "$WHAT=" ]
#
#				# Array
#				elif [ ]
#
#				# Function 
#				elif [ ]
#
#				# Integer
#				else
#				fi
		}  
	}
	
	[ ! -z $DO_INTEGER ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_STRING ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_ARRAY ] && {
	   printf '' > /dev/null
	}

	# Mass unset.	
	unset DO_WHAT
	unset DO_INTEGER
	unset DO_STRING
	unset DO_ARRAY
	unset WHAT 
	unset STRING 
	unset INTEGER 
	unset ARRAY 
	unset VERBOSE 
}

function etcbob() {
	echo "hello"
}

function bb() 
{
	echo "hello"
}

ETC="your mom"
is --what "ETC"
is --what "bb"
