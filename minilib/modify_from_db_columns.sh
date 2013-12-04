#-----------------------------------------------------#
# modify_from_db_columns
#
# Load data from database and edit from a temporary file, writing back the results.
#-----------------------------------------------------#
modify_from_db_columns() {
	# Catch input.
	TABLE="$1"

	# Die if no table name.
	if [ -z "$TABLE" ]
	then
		echo "In function: load_from_db_columns()"
		echo "\tNo table name supplied, You've made an error in coding."
		exit 1

	else
		# Use Some namespace...
		# LFDB
		TMP="/tmp"
		TMPFILE=$TMP/__lfdb.sql
		[ -e $TMPFILE ] && rm $TMPFILE
		touch $TMPFILE

		# Choose a table and this function should: 
		# Get column titles and create variable names.
		if [ ! -z "$CLAUSE" ]
		then
#			printf ".headers ON\nSELECT * FROM ${TABLE} $CLAUSE;\n" >> $TMPFILE
			printf ".headers ON\nSELECT * FROM ${TABLE} $CLAUSE;\n" 
		else
			printf ".headers ON\nSELECT * FROM ${TABLE};\n" >> $TMPFILE
		fi
			exit
		LFDB_HEADERS=( $( $__SQLITE $DB < $TMPFILE | \
			head -n 1 | \
			tr '|' ',' ) )

		LFDB_VARS=( $( $__SQLITE $DB < $TMPFILE | \
			head -n 1 | \
			tr '|' ' ' | \
			tr [a-z] [A-Z] ) )

		LFDB_ID=$( $__SQLITE $DB < $TMPFILE | \
			tail -n 1 | \
			awk -F '|' '{ print $1 }')

		[ -e $TMPFILE ] && rm $TMPFILE


		# Get all items.
		printf "SELECT ${LFDB_HEADERS[@]} FROM ${TABLE};\n" >> $TMPFILE
		LFDB_RES=$( $__SQLITE $DB < $TMPFILE | tail -n 1 )
		[ -e $TMPFILE ] && rm $TMPFILE


		# Need a few traps to get rid of these files if things go wrong.


		# Output database values as variables within temporary file.
		TMPFILE=$TMP/__dbvar.sh
		COUNTER=0
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Needs some basic string / number checking
				( printf "${XX}='"
				echo $LFDB_RES | \
					awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
					sed "s/$/'/"
				#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
				) >> $TMPFILE
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done


		# Load these within the program.
		MODIFY=true
		[ ! -z $MODIFY ] && $EDITOR $TMPFILE
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE


		# Check through the list and see what's changed.
		# Output database values as variables within temporary file.
		TMPFILE=$TMP/__cmp.sh
		COUNTER=0
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Needs some basic string / number checking
				( printf "ORIG_${XX}='"
				echo $LFDB_RES | \
					awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
					sed "s/$/'/"
				#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
				) >> $TMPFILE
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE


		# Load stuff.
		TMPFILE=$TMP/__load.sh
		COUNTER=0
		printf "SQL_LOADSTRING=\"UPDATE $TABLE SET " >> $TMPFILE
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Variables...
				USER="${!XX}"
				VAR_NAME="ORIG_$XX"
				ORIG="${!VAR_NAME}"
				COLUMN_NAME="$(echo ${XX} | tr [A-Z] [a-z])"

				# Check values and make sure they haven't changed.
				FV=
				if [[ "$USER" == "$ORIG" ]]
				then
					FV=$ORIG
				else
					FV=$USER
				fi

				# Evaluate with that neat little typechecking function.
				VAR_TYPE=$(typecheck $USER)
				printf "$COLUMN_NAME = "  >> $TMPFILE
				[[ $VAR_TYPE == "null" ]] && printf "''" >> $TMPFILE
				[[ $VAR_TYPE == "string" ]] && printf "'$FV'" >> $TMPFILE
				[[ $VAR_TYPE == "integer" ]] && printf "$FV" >> $TMPFILE

				# Wrap final clause in the statement.
				if [ $COUNTER == $(( ${#LFDB_VARS[@]} - 1 )) ] 
				then
					( printf '\n' 
					printf "WHERE id = $LFDB_ID;\"\n" ) >> $TMPFILE
				else
					printf ',\n' >> $TMPFILE
				fi	
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done
		unset COUNTER

		# Load the new stuff.
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE
		
		# Only write if they've changed?
		# (You'll need the id of whatever is being modified as well...)

		# Do the write.
		#echo $SQL_LOADSTRING
		$__SQLITE $DB "$SQL_LOADSTRING"

		#vi -O $TMP/__{cmp,dbvar}.sh
		# Write stuff to database 
		[ -e $TMPFILE ] && rm $TMPFILE
	fi

	unset CLAUSE
}
