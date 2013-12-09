#-----------------------------------------------------#
# typical_insert() 
#
# Insert through "standard" method.
#-----------------------------------------------------#
typical_insert() {
	# Find each of the markers.
	chop --this "$WRITE" --delimiter '|'

	# Use the correct delimiter. 
	WRITE="$(printf "%s" "$WRITE" | sed 's/|/,/g' )"

	# Echo back if asked.
	[ ! -z $ECHO_BACK ] && {
		printf "%s\n" $__SQLITE__ $DB "\"INSERT INTO ${__TABLE} VALUES ( $(printf "%s" "$WRITE" | sed 's/|/,/g' ) )\"" 
	}

	# Insert a new row.
	$__SQLITE__ $DB "INSERT INTO ${__TABLE} VALUES ( $WRITE )" 
}

#
# id = *integer	(* denotes autoincrement, so null is fine)
# instance_name = text
# srv_path = text
# dev_path = text
# date_created = integer
# version = text
# last_version = text
# user_owner = text
# description = text
