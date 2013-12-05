#------------------------------------------------------
# not_more_than_one.sh 
# 
# Checks if more than one value in a set has been 
# modified.
#-----------------------------------------------------#
not_more_than_one() {
	# How else (besides the local keyword) to avoid name conflicts?

	# Options
	while [ $# -gt 0 ]
	do
		case "$1" in
			-t|--of)
				shift
				__OF__="$1"
			;;
			-i|--should-be)
				shift
				__TESTOR__="$1"
			;;
		esac
		shift
	done

	# true is default.
	[ -z $__TESTOR__ ] && __TESTOR__=true

	# Check an array.
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

	# Unset
	unset __OCINC__
}
