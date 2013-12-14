#-----------------------------------------------------#
# arr
#
# Manipulates arrays.
#-----------------------------------------------------#
arr() {
	LIBPROGRAM="arr"
	arr_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-p | --push <arg>             desc
	-p | --pop <arg>              desc
	-t | --to <arg>               desc
	-f | --from <arg>             desc
	-r | --reveal                 desc
	-d | --destroy <arg>          desc
	-p | --pull-unique            desc
	-e | --elements               desc
	-w | --within <arg>           desc
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}
	
	
	[ -z "$#" ] && printf "Nothing to do\n" > /dev/stderr && arr_usage 1
	
	while [ $# -gt 0 ]
	do
	   case "$1" in
	     -p|--push)
	         DO_PUSH=true
	         shift
	         PUSH="$1"
	      ;;
	     -p|--pop)
	         DO_POP=true
	         shift
	         POP="$1"
	      ;;
	     -t|--to)
	         DO_TO=true
	         shift
	         __ARRY__="$1"
	      ;;
	     -f|--from)
	         DO_FROM=true
	         shift
	         __ARRY__="$1"
	      ;;
	     -r|--reveal)
	         DO_REVEAL=true
	      ;;
	     -d|--destroy)
	         DO_DESTROY=true
	         shift
	         __ARRY__="$1"
	      ;;
	     -p|--pull-unique)
	         DO_PULL_UNIQUE=true
	      ;;
	     -e|--elements)
	         DO_ELEMENTS=true
	      ;;
	     -w|--within)
	         shift
	         __ARRY__="$1"
	      ;;
	     -v|--verbose)
	        VERBOSE=true
	      ;;
	     -h|--help)
	        arr_usage 0
	      ;;
	     --) break;;
	     -*)
	      printf "Unknown argument received.\n" > /dev/stderr;
	      arr_usage 1
	     ;;
	     *) break;;
	   esac
	shift
	done

	# Die on lack of array.
	[ ! -z "$__ARRY__" ] && {
		__ARY__=( $(eval 'echo "${'$__ARRY__'[@]}"') )
	} || printf "No array supplied to arr().\n" > /dev/stderr

	# This can handle multiple arguments.  Maybe...
	# Bash arrays can be sparse, so...this is hard to deal with...
	[ ! -z $DO_PUSH ] && {
		__ARY__[${#__ARY__[@]}]="$PUSH"
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_POP ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_REVEAL ] && {
		ti '${__ARRY__} (arrname)' "${__ARRY__}"
		ti '${__ARY__}' "${__ARY__}"
		ti '${__ARY__[@]}' "${__ARY__[@]}"
		ti '${#__ARY__[@]}' "${#__ARY__[@]}"
		echo ${#__ARY__[@]}
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_DESTROY ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_PULL_UNIQUE ] && {
	   printf '' > /dev/null
	}
	
	[ ! -z $DO_ELEMENTS ] && {
		printf "%d\n" "${#__ARY__[@]}"
	   printf '' > /dev/null
	}

	# Do all unsets...
	# __ARY__ is now the active array...
	unset __ARRY__  # What happens when we start working with MANY arrays...
	unset DO_PUSH
	unset DO_POP
	unset DO_TO
	unset DO_FROM
	unset DO_REVEAL
	unset DO_DESTROY
	unset DO_PULL_UNIQUE
	unset DO_ELEMENTS
	unset DO_WITHIN
	unset PUSH
	unset POP
}
