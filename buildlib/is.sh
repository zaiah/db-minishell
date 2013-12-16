#-----------------------------------------------------#
# is
#
# Check if an element is of particular type.
#
# Right now, `is` is blitheringly slow.
#-----------------------------------------------------#
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
	
	-w | --what <arg>             Find the type of <arg>. 
	-i | --integer <arg>          Check if <arg> is an integer. 
	-s | --string <arg>           Check if <arg> is a string. 
	-a | --array <arg>            Check if <arg> is an array. 
	-f | --function <arg>         Check if <arg> is a function.
	-r | --return <arg>           Supply the value in the return message.
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
		   -d|--diag|--diagnostic)
				DIAG=true
			;;
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
	     -f|--function)
	         DO_FUNCT=true
	         shift
	         FUNCT="$1"
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
	      printf "Unknown argument received: $1\n" > /dev/stderr;
	      is_usage 1
	     ;;
	     *) break;;
	   esac
	shift
	done

	# ...
	
	[ ! -z $DO_WHAT ] && {
		# Something.
		[ ! -z "$WHAT" ] && {
			declare | grep "$WHAT" | ( \
				# I can only use /dev/stdin once?
				STDIN=$(</dev/stdin)

				# 
				EMP=$( printf "%s" "$STDIN" | grep "$WHAT=''" )
				STR=$( printf "%s" "$STDIN" | grep "$WHAT='" )
				FUN=$( printf "%s" "$STDIN" | grep "$WHAT ()")
				ARR=$( printf "%s" "$STDIN" | grep "$WHAT=(" )
				OTH=$( printf "%s" "$STDIN" | grep "$WHAT=" )

				# Debugging's sake
				[ ! -z $DIAG ] && {
					(
					 printf -- "%s\n" "stdin: $STDIN"

					 printf -- "%s\n" "string: $STR"
					 printf -- "%s\n" "empty string: $EMP"
					 printf -- "%s\n" "array: $ARR"
					 printf -- "%s\n" "integer: $INT"
					 printf -- "%s\n" "function: $FUN"
					 printf -- "%s\n" "other: $OTH"
					 printf -- "%s\n" "null: $NIL"
					) > /dev/stderr
				}

				# Strings are still returning false positives.
				# POUND and APOUND are both returned.

				# Function
				if [ ! -z "$FUN" ]; then
					echo "function"

				# String
				elif [ ! -z "$STR" ]; then
					echo "string"

				# Empty (on some architectures)
				elif [ ! -z "$EMP" ]; then
					echo "empty"

				# Array 
				elif [ ! -z "$ARR" ]; then
					echo "array"

				# Any other test.
				elif [ ! -z "$OTH" ]; then
					# Empty (nothing, the var has simply been set...) 
					if [ -z "${!WHAT}" ]; then 
						echo "empty"  

					# Test for strings and integers.
					else
						WHAT_VALUE="${!WHAT}"
						for CHAR_INC in `seq 0 $(( ${#WHAT_VALUE} - 1 ))`
						do
							# echo ${WHAT_VALUE:${CHAR_INC}:1}
							[[ ! ${WHAT_VALUE:${CHAR_INC}:1} == [0-9] ]] && {
								IS_STR=true	
								break
							}
						done
					
						# Return type.	
						[ ! -z $IS_STR ] && echo "string" || echo "integer"
						unset CHAR_INC
						unset IS_STR
					fi	

				# ...
				else
					# The variable isn't defined yet.
					# Not sure what status to return?
					echo "undefined"
				fi

				# Free (not sure if our memory usage actually goes down or not)
				unset STDIN
				unset STR
				unset EMP
				unset FUN
				unset ARR
				unset INT	
			) 
		} || echo "undefined"  
	}

	# Do a function test.
	[ ! -z $DO_FUNCT ] && {
		declare | grep "$FUNCT ()"
#		FUN=$( printf "%s" "$STDIN" | grep "$WHAT ()")
		[ 0 ] && echo true || echo false
	}

	# Do an integer test.	
	[ ! -z $DO_INTEGER ] && {
		WHAT_VALUE="${!WHAT}"
		for CHAR_INC in `seq 0 $(( ${#WHAT_VALUE} - 1 ))`
		do
			[[ ! ${WHAT_VALUE:${CHAR_INC}:1} == [0-9] ]] && {
				IS_STR=true	
				break
			}
		done

		# Return 
		[ ! -z $IS_STR ] && echo false || echo true

		# Free and unset
		unset CHAR_INC
		unset IS_STR
	}

	# Do a string test.	
	[ ! -z $DO_STRING ] && {
		EMP=$( printf "%s" "$STDIN" | grep "$WHAT=''" )
		STR=$( printf "%s" "$STDIN" | grep "$WHAT='" )
	}

	# Do an array test.	
	[ ! -z $DO_ARRAY ] && {
		STR=$( printf "%s" "$STDIN" | grep "$WHAT=('" )
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

