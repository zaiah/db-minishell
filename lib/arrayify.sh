#------------------------------------------------------
# arrayify()
# 
# Break list up by a particular delimiter.
#-----------------------------------------------------#
arrayify() {
	# Errors.
	ERR_NO_ARG="No argument supplied.\n"

	# Arguments.
	if [ $# -eq 1 ] 
	then 
		__STRSRC__="$1"
	else
		while	[ $# -gt 0 ]
		do
			case "$1" in
				# Store command line flag and add flag to error msg. 
				-d|--delim|--delimiter)
					shift
					[ ! -z "$1" ] && __STRDELIM__="$1"
					[ -z "$1" ] && printf "$ERR_NO_ARG" && exit 1
				;;
				-t|--this|--source)
					shift
					__STRSRC__="$1"
				;;
			esac
			shift
		done
	fi	

#	printf "%s\n" "printf "$__STRSRC__" \| sed "s/${DELIM:-','}/ /g""
	#printf "%s" "$__STRSRC__" | sed "s/${DELIM:-','}/ /g"

	# Return the new "array"
	[ -z $__STRDELIM__ ] && __STRDELIM__=","
	echo "$__STRSRC__" | sed "s/$__STRDELIM__/ /g"
	unset __STRDELIM__
	unset __STRSRC__
}
