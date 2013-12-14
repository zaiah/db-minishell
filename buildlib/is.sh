#-----------------------------------------------------#
# is
#
# Check if an element is of particular type.
#-----------------------------------------------------#
is() {
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
	     -t|--temporary)
	         DO_TEMPORARY=true
	         shift
	         TEMPORARY="$1"
	      ;;
	     -f|--fifo)
	         DO_FIFO=true
	         shift
	         FIFO="$1"
	      ;;
	     -p|--pipe)
	         DO_PIPE=true
	         shift
	         PIPE="$1"
	      ;;
	     -d|--device)
	         DO_DEVICE=true
	         shift
	         DEVICE="$1"
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
	
	[ ! -z $DO_WHAT ] && {
	   printf '' > /dev/null
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
	
	[ ! -z $DO_TEMPORARY ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_FIFO ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_PIPE ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_DEVICE ] && {
	   printf '' > /dev/null
	}
}
