#-----------------------------------------------------#
# get_datatypes()
#
# Get the datatypes of a table.
#-----------------------------------------------------#
get_datatypes() {
	# Start fresh
	# unset __RESULTBUF__
	for __COL__ in ${__DTBUF__[@]}
	do
		$__COL__
	done

	# Hold the schema results in buffer.
	__DTBUF__="$( $SQLITE $DB ".schema ${__TABLE}")"

	# Die if nothing is there...
	if [ -z "$__DTBUF__" ]
	then
		exit 1

	# If tables were written with newlines, use the below.
	elif [ $(printf "%s" "$__DTBUF__" | wc -l) -gt 1 ]
	then
		# Process and reload the buffer.
		# Could have an issue with `awk` on other systems.
		__DTBUF__="$(printf '%s' "$__DTBUF__" | \
			sed 's/\t//g' | \
			sed 's/\r//g' | \
			awk '{ print $2 }' | \
			grep -v "TABLE" | \
			sed 's/,//g' | \
			sed 's/);//g' )"

		# Alterante return - no for...
		printf "%s" "$__DTBUF__"

	# If tables were written with single line, use this...
	else	
		echo '...'
		exit 1    # Can't handle this right now.

	fi
}
