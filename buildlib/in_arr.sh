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
	     -t|--this)
	         DO_THIS=true
	         shift
	         THIS="$1"
	      ;;
	     -b|--boolean)
	         DO_BOOLEAN=true
	      ;;
	     -i|--index)
	         DO_INDEX=true
	      ;;
	     -a|--at)
	         DO_AT=true
	         shift
	         AT="$1"
	      ;;
	     -v|--verbose)
	        VERBOSE=true
	      ;;
	     -h|--help)
	        in_arr_usage 0
	      ;;
	     --) break;;
	     -*)
	      printf "Unknown argument received.\n" > /dev/stderr;
	      in_arr_usage 1
	     ;;
	     *) break;;
	   esac
	shift
	done
	
	[ ! -z $DO_BOOLEAN ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_INDEX ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_AT ] && {
	   printf '' > /dev/null
	}
}
