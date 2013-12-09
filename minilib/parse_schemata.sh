#-----------------------------------------------------#
# parse_schemata()
#
# Get the columns of a table.
#-----------------------------------------------------#
parse_schemata(){
	# Saving this is possible, but a lot of work.
	unset __RESULTBUF__

	# Options
	while [ $# -gt 0 ]
	do
		case "$1" in
			# Retrieve schemata in formatted order for quicker development.
			-f|--formattted)
				__RESULT_GET_FMT__=true
			;;

			# Retrieve datatypes only.
			-d|--datatypes)
				__RESULT_GET_DT__=true
			;;

			# Retrieve columns only.
			-c|--columns)
				__RESULT_GET_CS__=true
			;;

			# Choose a table.
			-o|--of)
				shift
				__RESULT_TBL__="$1"
			;;
		esac
		shift
	done

	# Buffer
	__SCHBUF__="$( $__SQLITE__ $DB ".schema ${__RESULT_TBL__}")"

	# Die if no table was supplied.
	[ -z "$__RESULT_TBL__" ] && {
		printf "No table supplied to function: parse_schemata().\n" > /dev/stderr
		# exit is not suitable here.
		# http://www.linuxjournal.com/content/return-values-bash-functions	
	}

	# Die if nothing is there...
	if [ -z "$__SCHBUF__" ] 
	then
		printf "No schemata found within [ $DB ].\n" > /dev/stderr	

	# Only move forward if something exists.
	elif [ $(printf "%s" "$__SCHBUF__" | wc -l) -gt 1 ]
	then
		# Could have an issue with `awk` on other systems.
		# Just grab the column names.
		__COLBUF__="$(printf '%s' "$__SCHBUF__" | \
			sed 's/\t//g' | \
			sed 's/\r//g' | \
			awk '{ print $1 }' | \
			grep -v "CREATE" | \
			sed 's/);//g' )"

		# Get columns. 
		[ ! -z $__RESULT_GET_CS__ ] && {
			# Alterante return - no for...
			printf "%s" "$__COLBUF__"
		}

		# Get datatypes.
		[ ! -z $__RESULT_GET_DT__ ] && {
			# Get the datatypes
			__DTBUF__="$(printf '%s' "$__SCHBUF__" | \
				sed 's/\t//g' | \
				sed 's/\r//g' | \
				awk '{ print $2 }' | \
				grep -v "TABLE" | \
				sed 's/,//g' | \
				sed 's/);//g' )"

			# Should check both __DTBUF__ and __COLBUF__ to make
			# sure they've got the same number of elements.

			# Save both into arrays.

			# Return some giant block and parse from your client.
			printf "%s" "$__DTBUF__"
		}

	# Cannot support SQLite databases created with one line yet.
	else	
		printf "" > /dev/null
	fi
}
