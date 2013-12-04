#-----------------------------------------------------#
# convert
#
# Prepares either the records to be placed into or
# the queries interacting with a SQLite 3 database.
#-----------------------------------------------------#
convert() {
	# Is this null?
	if [ -z "$1" ]
	then
		# Return empty string (but you might need to evaluate the column too)
		printf "''"

	# Check other types.
	else
		# Search for spaces within long strings / sentences. 
		if [[ "$1" =~ ' ' ]] 
		then
			# Differentiate between strings that already have single or double quotes.
			[[ ${1:0:1} == "'" ]] || \
				[[ ${1:0:1} == '"' ]] && \
				printf "$1" || printf "'$1'"

		# Check for other characters.
		# Always going to throw an error.
		elif [[ ${1:0:1} == '!' ]] || \
			[[ ${1:0:1} == '@' ]] || \
			[[ ${1:0:1} == '#' ]] || \
			[[ ${1:0:1} == '$' ]] || \
			[[ ${1:0:1} == '%' ]] || \
			[[ ${1:0:1} == '^' ]] || \
			[[ ${1:0:1} == '&' ]] || \
			[[ ${1:0:1} == '*' ]] || \
			[[ ${1:0:1} == '(' ]] || \
			[[ ${1:0:1} == ')' ]] || \
			[[ ${1:0:1} == '+' ]] || \
			[[ ${1:0:1} == '/' ]] || \
			[[ ${1:0:1} == '\' ]] || \
			[[ ${1:0:1} == '.' ]] || \
			[[ ${1:0:1} == '-' ]] 
		then
			printf "'$1'"

		# Catch integers.
		elif [ ! $(echo $(( $1 * 1 )) 2>/dev/null) == 0 ]
		then
			# Is integer (most likely) 
			printf $1 

		# Handle single words.
		else
			# Differentiate between strings that already have single or double quotes.
			[[ ${1:0:1} == "'" ]] || \
				[[ ${1:0:1} == '"' ]] && \
				printf "$1" || printf "'$1'"
		fi
	fi
}
