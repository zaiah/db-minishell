#-----------------------------------------------------#
# load_from_db_columns
#
# Create a variable in Bash out of each column header 
# in a table and fill it with information found in 
# that column.
#-----------------------------------------------------#
load_from_db_columns() {
	# Die if no table name.
	#__TABLE="$1"
	if [ -z "$__TABLE" ]
	then
		echo "In function: load_from_db_columns()"
		echo "\tNo table name supplied, You've made an error in coding."
		exit 1

	else
		# Get column names 
		MEGA_COLUMNS=( $(get_columns) )
		MEGA_RES="$1"

		# ...
		for CINC in $(seq 0 ${#MEGA_COLUMNS[@]})
		do
			printf "%s" ${MEGA_COLUMNS[$CINC]} | \
				tr '[a-z]' '[A-Z]' | sed 's/$/=/'
			printf "%s" $MEGA_RES | \
				awk -F '|' "{print \$$(( $CINC + 1 ))}"
		done

		# Load these within the program.
		#cat $TMPFILE
		#source $TMPFILE
		#[ -e $TMPFILE ] && rm $TMPFILE
		#get_columns
		exit
	fi
}
