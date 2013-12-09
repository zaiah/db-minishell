#-----------------------------------------------------#
# col_wrap() 
#
# Wrap columns to an arbitrary length.
#-----------------------------------------------------#
col_wrap() {
	# ...
	while [ $# -gt 0 ]
	do
		case "$1" in
			-t|--this)
			shift
			TERM="$1"
			;;
			-c|--truncate)
			DO_TRUNCATE=true
			;;
			-w|--width)
			shift
			WIDTH="$1"
			;;
			-p|--prepend)
			shift
			PREPEND_THIS="$1"
			;;
			-a|--append)
			shift
			PREPEND_THIS="$1"
			;;
		esac
		shift
	done

	# All your blanks.
	[ -z $TERM ] && {
		exit 1
	}
	
	[ -z $WIDTH ] && {
		exit 1
	}

	# Find word breaks

	# Return the string. 
	echo $TERM
}
