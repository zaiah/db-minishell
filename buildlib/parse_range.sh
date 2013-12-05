#------------------------------------------------------
# parse_range.sh 
# 
# Extract a certain range based on keywords.
# 
# Only expects one unique match.  
# More can be used later.
#-----------------------------------------------------#
parse_range() {
	# Handle dependencies (an extension to buildlib can do this well)
	grep="/bin/grep --fixed --line-number"

	# Options
	while [ $# -gt 0 ]
	do
		case "$1" in
			-f|--from)
				shift
				__STRING_FROM__="$1"
			;;
			-t|--to)
				shift
				__STRING_TO__="$1"
			;;
			-w|--within)
				shift
				__BLOCK_TO_SEARCH__="$1"
			;;
			-i|--include-range)
				INCLUDE_RANGE=true
			;;
			-r|--return)
				RETURN_RANGE=true
				shift
				AS="$1"  # commasep, array
			;;	
			# Default option?
			-p|--print)
				PARSE_RANGE=true
			;;
			-d|--delete)
				DELETE_RANGE=true
			;;
		esac
		shift
	done

	# Default is to print the text within the range.
	[ -z $DELETE_RANGE ] && [ -z $RETURN_RANGE ] && PARSE_RANGE=true

	# Stave off option conflict.
	for __OC__ in "$RETURN_RANGE" "$PARSE_RANGE" "$DELETE_RANGE"
	do
		[ ! -z "$__OC__" ] && {
			[ -z $__OCINC__ ] && __OCINC__=0 || {
				printf "Cannot specify more than one of either "
				printf "%s\n" "--return-range, --parse-range or --delete-range."
				exit 1
			}	
		}
	done

	# Make sure that there is something to search.
	[ -z $__BLOCK_TO_SEARCH__ ] && {
		printf "No block to search within parse_range()"
		exit 1
	}

	# Also make sure that both needed arguments are specified.
	[ -z "$__STRING_FROM__" ] || [ -z "$__STRING_TO__" ] && {
		printf "No string specified for either --to or --from "
		printf "arguments within parse_range()"
		exit 1
	}

	# Get start of the range.
	__SR__=$( $grep "$__STRING_FROM__" $__BLOCK_TO_SEARCH__ | \
		head -n 1 | \
		awk -F ':' '{print $1}')

	# Get end of the range.
	__ER__=$($grep "$__STRING_TO__" $__BLOCK_TO_SEARCH__ | \
		head -n 1 | \
		awk -F ':' '{print $1}')

	# Include the range or not?
	[ -z $INCLUDE_RANGE ] && {
		[ ! -z $__SR__ ] && __SR__=$(( $__SR__ + 1 ))
		[ ! -z $__ER__ ] && __ER__=$(( $__ER__ - 1 ))	
	}

	# Return the range. 
	if [ ! -z $RETURN_RANGE ]
	then
		case "$AS" in
			comma|',') printf "$__SR__,$__ER__";;	
			t|test) printf "${__STRING_FROM__}: $__SR__ $__ER__\n";;
			a|array|space) printf "$__SR__ $__ER__";;
			'-'|'|'|'/'|'?'|'+'|'='|'_') printf "${__SR__}${AS}${__ER__}";;
		esac
	elif [ ! -z $DELETE_RANGE ]
	then
		sed -i ${__SR__},${__ER__}d $__BLOCK_TO_SEARCH__
	elif [ ! -z $PARSE_RANGE ]
	then
		sed -n ${__SR__},${__ER__}p $__BLOCK_TO_SEARCH__ 
	fi

	# Unset
	unset DELETE_RANGE
	unset PARSE_RANGE
	unset RETURN_RANGE
	unset __OCINC__
}
