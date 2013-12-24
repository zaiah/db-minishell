
# Perform a table alteration. 
[ ! -z $DO_ALTER ] && {
	# Just change the name.
	[ ! -z $DO_ALTER_NAME ] && {
		if [ ! -z "$RENAME_TO" ]
		then
			$__SQLITE__ $DB "ALTER TABLE $__TABLE RENAME TO $RENAME_TO" 
		else
			printf "No name supplied to flag --to when renaming.\n" > /dev/stderr
		fi
	}

	# Should probably die out with something.

	# Add or remove columns.
	# Notice that we can add and remove.
	if [ ! -z "$COLUMN_TO_ADD" ] && [ -z "$COLUMN_TO_REMOVE" ]
	then
		COLREC=
		UNPROC_CNAME=
		COLUMN_NAME_AND_TYPE=

		# Break each column up.
		for CTA in $(break_list_by_delim $COLUMN_TO_ADD) 
		do
			# Go through each one processing the results.
		   if [[ "$CTA" =~ "=" ]]
			then
				# Break each up.
				# Probably should check that it's a valid datatype.
				COLUMN_NAME_AND_TYPE="$(break_maps_by_delim $CTA)"
			else
				# Automatically assumes text.
				COLUMN_NAME_AND_TYPE="$CTA TEXT"
			fi

			# Make the change.
			[ ! -z $ECHO_BACK ] && {
				printf "$__SQLITE__ $DB"
				printf " 'ALTER TABLE $__TABLE ADD COLUMN $COLUMN_NAME_AND_TYPE'\n"
			}
		
			# Add the column(s) 
			$__SQLITE__ $DB \
				"ALTER TABLE $__TABLE ADD COLUMN $COLUMN_NAME_AND_TYPE" 
			unset CTA
		done

	# Removing is another story.
	elif [ ! -z "$COLUMN_TO_REMOVE" ]
	then
		# Get headers from the table to be altered. 
		# ( A revised parse_schemata will solve this ugliness. )
		HEADERS=( $(parse_schemata --of $__TABLE --columns) )

		# More debugging...
		#parse_schemata --of $__TABLE --columns
		#parse_schemata --of $__TABLE --datatypes
		 
		# Check for --adding statements.
		# Make sure they're not in the HEADERS.
#		[ ! -z "$COLUMN_TO_ADD" ] && {
#			for CTA in $(break_list_by_delim $COLUMN_TO_ADD) 
#			do
#				if [[ "$CTA" =~ "=" ]]
#				then
#					COLUMN_NAME_AND_TYPE="$(break_maps_by_delim $CTA)"
#				else
#					COLUMN_NAME_AND_TYPE="$CTA TEXT"
#				fi
#		
#				COLUMN_NAME_TERM="$(printf "%s" ${COLUMN_NAME_AND_TYPE} | \
#					awk '{print $1}')"
#
#				# Check for the element...
#				is_element_present_in "HEADERS" ${COLUMN_NAME_TERM}
#			done
#	}


for CTA in $(arrayify -d ',' --this "$COLUMN_TO_ADD") 
do
	[[ $CTA =~ "=" ]] && {
	# arr would really help right now....
	# for realllzzz
	# take a quick break and switch it...
#XX=( $(arrayify -d '=' --this "$nn") )
	}
	
done
exit

	# If removing, then pop those elements from HEADERS
##	for TO_POP in ${HEADERS[@]}
#	do
	for TO_POP in ${HEADERS[@]}
	do
		printf "" > /dev/null
	#	[[ "$TO_POP" ==
	#echo "${HEADERS[2]}"
	done
#	done

	# If adding, then push those elements to your new thing...


	# Create a temporary table with current headers and extra fields. 

	# Craft the SELECT statement to get records out of the the table to transfer from.
	
	# Load your temporary table.
		
	# Create the new table (with or without whatever columns are needed)

	# (The temporary table should drop at the end of the transaction)

	# Drop the original table.

	
	## I'd like an option to rename columns as well.  and perhaps reset datatypes...
	fi
#tmp_file -w
	exit

	# Create the new table first.
#	printf "CREATE TABLE $TABLE (" > $CONV
#	printf "\n${HEADER%%,} );" >> $CONV
#	printf "\n.separator ${SEPCHAR}" >> $CONV
#	printf "\n.import $FSV $TABLE" >> $CONV
#
#	# Populate (only if we need strict data types or have a dataset we'd like to move into production.)
#	# This assumes we've already created the table.
#		# Check that the table exists.
#		EXISTS=$(sqlite3 $DB '.schema' | grep "CREATE TABLE $TABLE")
#		if [ -z "$EXISTS" ]
#		then
#			printf "Uh oh!\nTable [$TABLE] was not found in the database [$DB].\nExiting...\n" >&2
#			exit 1
#		fi
#	
#		# Create a temporary table and reindex properly.
#		NO_TYPE_HEADER=$(echo $SRC | sed "s/${SEPCHAR}/, /g" | sed "s/\r//")
#		TMP_TABLE="tmp_$TABLENAME"
#
#		# Generate the file.
#		printf "CREATE TEMP TABLE $TMP_TABLE (" > $CONV
#		printf "\n${HEADER%%,} );" >> $CONV
#		printf "\n.separator ${SEPCHAR}" >> $CONV
#		printf "\n.import $FSV $TMP_TABLE" >> $CONV
#
#		# Populate if we've already made one.
#		printf "\nINSERT INTO $TABLE ( ${NO_TYPE_HEADER} ) SELECT * FROM $TMP_TABLE;" >> $CONV
#		printf "\n.quit" >> $CONV
}
