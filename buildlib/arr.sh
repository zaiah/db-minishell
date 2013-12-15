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
	     -x|--pop)
	         DO_POP=true
	         shift
	         POP="$1"
	      ;;
	     --strict-pop)
	         DO_POP_LAST=true
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
		echo "eval 'echo \"\${'$__ARRY__'[@]}\"') )"
		__ARY__=( $(eval 'echo "${'$__ARRY__'[@]}"') )
		echo ${__ARY__[@]}
		eval 'echo "${'$__ARRY__'[@]}"'
#		echo ${__ARRY__}
#		__ARY__=( $(eval "echo \"${${!__ARRY__}[@]}\"") )


	} || printf "No array supplied to arr().\n" > /dev/stderr

	# This can handle multiple arguments.  Maybe...
	# Bash arrays can be sparse, so...this is hard to deal with...

	# Push to array.
	[ ! -z $DO_PUSH ] && {
		# Add like normal.
		__ARY__[${#__ARY__[@]}]="$PUSH"
		# printf "%d" ${#__ARY__[@]}

		# Reload 
		eval $__ARRY__'="'${__ARY__[@]}'"'
	}

	# Pop from array.
	[ ! -z $DO_POP ] && [ ! -z "$POP" ] && {
		# Let the code go through and find the element to pop.
		for __CPOP__ in `seq 0 ${#__ARY__[@]}`
		do
			[[ ${__ARY__[$__CPOP__]} == $POP ]] && {
				unset __ARY__[$__CPOP__]
			}
		done
		unset __CPOP__
		
		# Reload 
		eval $__ARRY__'="'${__ARY__[@]}'"'

		# Clean up.
		unset __POP_ELEMENTS__
	}

	# Pop last element from array.
	[ ! -z $DO_POP_LAST ] && {
		unset __ARY__[$(( ${#__ARY__[@]} - 1 ))]
	}
	
	# Show what's in an array.
	[ ! -z $DO_REVEAL ] && {
		printf "%s " ${__ARY__[@]}
		printf "\n"
	}

	# Destroy the array.
	[ ! -z $DO_DESTROY ] && {
		unset $__ARRY__
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
	unset __ARY__
	unset __ARRY__  # What happens when we start working with MANY arrays...
	unset DO_PUSH
	unset DO_POP
	unset DO_POP_LAST
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
