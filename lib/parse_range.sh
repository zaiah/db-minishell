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
			-i|--include-match)
				INCLUDE_MATCH=true
			;;
		esac
		shift
	done

	# Make sure that there is something to search.
	# Get start of the range.
	__SR__=$(( $(grep \
			--fixed \
			--line-number "$__STRING_FROM__" $__BLOCK_TO_SEARCH__ | \
		head -n 1 | \
		awk -F ':' '{print $1}') + 1 ))

	# Get end of the range.
	__ER__=$(( $(grep \
			--fixed \
			--line-number "$__STRING_TO__" $__BLOCK_TO_SEARCH__ | \
		head -n 1 | \
		awk -F ':' '{print $1}') - 1 ))

	# Return the range. 
	sed -n ${__SR__},${__ER__}p $__BLOCK_TO_SEARCH__ 
}
