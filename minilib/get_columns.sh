#-----------------------------------------------------#
# get_columns()
#
# Get the columns of a table.
#-----------------------------------------------------#
get_columns() {
	# Start fresh
	unset __RESULTBUF__

	# Hold the schema results in the buffer.
	__RESULTBUF__="$( $SQLITE $DB ".schema ${__TABLE}")"

	# Die if nothing is there...
	if [ -z "$__RESULTBUF__" ]
	then
		exit 1

	# If tables were written with newlines, use the below.
	elif [ $(printf "%s" "$__RESULTBUF__" | wc -l) -gt 1 ]
	then
		# Process and reload the buffer.
		# Could have an issue with `awk` on other systems.
		__RESULTBUF__="$(printf '%s' "$__RESULTBUF__" | \
			sed 's/\t//g' | \
			sed 's/\r//g' | \
			awk '{ print $1 }' | \
			grep -v "CREATE" | \
			sed 's/);//g' )"

		# Alterante return - no for...
		printf "%s" "$__RESULTBUF__"

	# If tables were written with single line, use this...
	else	
		echo '...'
		exit 1    # Can't handle this right now.

	fi
}
