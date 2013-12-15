#-----------------------------------------------------#
# in_arr
#
# Peek inside arrays like the nasty man you are.
#-----------------------------------------------------#
in_arr() {
	LIBPROGRAM="in_arr"
	in_arr_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-t | --this <arg>             desc
	-b | --boolean                desc
	-i | --index                  desc
	-a | --at <arg>               desc
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}
	
	
	[ -z "$#" ] && printf "Nothing to do\n" > /dev/stderr && in_arr_usage 1
	
	while [ $# -gt 0 ]
	do
	   case "$1" in
		  -a|--array)
				shift
			  __ARRY__="$1"
			;;
	     -t|--this)
	         shift
	         in_arr_THIS="$1"
	      ;;
			# Default...
	     -b|--boolean)
	         in_arr_DO_BOOLEAN=true
	      ;;
	     -i|--index)
	         in_arr_DO_INDEX=true
	      ;;
		  -f|--first-match)
			   in_arr_FIRST_MATCH=true
			;;
	     -h|--help)
	        in_arr_usage 0
	      ;;
	     --) break;;
	     -*)
	      printf "Unknown argument received: $1\n" > /dev/stderr;
	      in_arr_usage 1
	     ;;
	     *) break;;
	   esac
	shift
	done

	# Load the array.
	__ARR__=( $(eval 'echo ${'$__ARRY__'[@]}') )

	# Set boolean to default...
	[ -z $in_arr_DO_BOOLEAN ] && [ -z $in_arr_DO_INDEX ] && {
		in_arr_DO_BOOLEAN=true
	}

	# Compare each element.
	for __ELE__ in `seq 0 $(( ${#__ARR__[@]} - 1 ))`
	do
		# Does it exist?
		if [[ ${__ARR__[$__ELE__]} == $in_arr_THIS ]]
		then 
			STAT=true
			[ ! -z $in_arr_DO_BOOLEAN ] && printf true && break
			[ ! -z $in_arr_DO_INDEX ] && printf "%d" $__ELE__ && break
		fi
	done

	[ -z $STAT ] && [ ! -z $in_arr_DO_BOOLEAN ] && printf false 

	# Clean up.
	unset __ELE__
	unset __ARR__
	unset __ARRY__
	unset STAT
	unset in_arr_THIS
	unset in_arr_DO_BOOLEAN
	unset in_arr_DO_INDEX
	unset in_arr_DO_AT 
	unset in_arr_VERBOSE
}
