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
		(
			printf "No table supplied to function: parse_schemata().\n" 
		) > /dev/stderr
		# exit is not suitable here.
		# http://www.linuxjournal.com/content/return-values-bash-functions	
	}

	# Die if nothing is there...
	if [ -z "$__SCHBUF__" ] 
	then
		printf "No schemata found within [ $DB ].\n" > /dev/stderr	

	# Only move forward if something exists.

	# 
	# Currently does not account for errantly created SQLite databases.
	# E.g. stuff like:
	# id integer primary autoincrement,
	# jamon text,
	# beatrice text lawdy text <-- where this is obviously wrong...
	#
	else
		# Check
		__SCHBUF__=$(printf "%s\n" "$__SCHBUF__" | \
			# No tabs
			sed 's/\t//g' | \
			# No commas (single line breakdown is still difficult...)
			sed 's/,/\n/g' | \
			# No single blank lines.
			sed '/^$/d')

		# Some debugging for that azz...
		# printf "$__SCHBUF__"
		# printf "\n"
		# exit

		# Could have an issue with `awk` on other systems.
		# Just grab the column names.
		__COLBUF__="$(printf '%s' "$__SCHBUF__" | \
			sed 's/\t//g' | \
			sed 's/\r//g' | \
			awk '{ print $1 }' | \
			grep -v "CREATE" | \
			sed 's/);//g' )"

		# Perhaps external key checks need to be done here?

		# Get columns. 
		[ ! -z $__RESULT_GET_CS__ ] && {
			# Alterante return - no for...
			printf "%s\n" "$__COLBUF__"
		}

		# Get datatypes.
		# Should check for foreign keys, contstraints and primary keys.
		[ ! -z $__RESULT_GET_DT__ ] && {
			# Get the datatypes
			__DTBUF__="$(printf '%s' "$__SCHBUF__" | \
				sed 's/\t//g' | \
				sed 's/\r//g' | \
				awk '{ print $2 }' | \
				grep -v "TABLE" | \
				sed 's/,//g' | \
				sed 's/);//g' | \
				tr '[a-z]' '[A-Z]')"

			# Should check both __DTBUF__ and __COLBUF__ to make
			# sure they've got the same number of elements.

			# Save both into arrays.
			declare -a __DTARR__
			declare -a __COLARR__
			__DTARR__=( $( printf "%s " $__DTBUF__ ) )
			__COLARR__=( $( printf "%s " $__COLBUF__ ) )
			[ ${#__DTARR__[@]} -ne ${#__COLARR__[@]} ] && {
				(
					printf "Problem encountered when parsing datatypes "
					printf "or column names.\n" 
				) > /dev/stderr
				# return?	
			}

			# Return some giant block and parse from your client.
			# printf "%s" "$__DTBUF__"

			for bbx in `seq 0 $(( ${#__DTARR__[@]} - 1 ))`
			do
				printf "%s\n" "${__COLARR__[$bbx]} = ${__DTARR__[$bbx]}"
			done
		}
	fi

	# Free
	unset __DTARR__
	unset __COLARR__
	unset __DTBUF__
	unset __COLBUF__

	unset __RESULT_GET_FMT__
	unset __RESULT_GET_DT__
	unset __RESULT_GET_CS__
	unset __RESULT_TBL__
}
