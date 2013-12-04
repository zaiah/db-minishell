#-----------------------------------------------------#
# tmp_file()
#
# Create a temporary file.
# 
# Usage:
# no args - Passes the handle name back to user.
# (User has to handle deletion of each handle)
# -n <arg> - Creates a temporary file plus record.
# -d      - Deletes last created temporary file.
# -w      - Deletes all leftoever temporary files.
# -z      - List all temporary files.
# -l      - Get handle of last created temporary file.
#
# This is nice...
#echo 'mm' > $(tmp_file)
#
# This is probably nicer.
# echo 'mm' > $(tmp_file -a SQL)
# rm $SQL
#
# This is okay too
# echo 'mm' > $(tmp_file)
# rm $(tmp_file -l)
#
# Neither of those can really work though...because of subshells...
# So, these are the best ways to do it without maintaining state...
# SQL=$(tmp_file)
# echo 'mm' > $SQL
# rm $SQL 
#
# or...
# tmp_file -n SQL < echo 'mm'
# rm $SQL
#
# tmp_file < echo 'mm'
# tmp_file -l > vi -  	# Can't edit the file this way...
# tmp_file -d
#
# tmp_file -n MEGA < echo 'mm'
# cat $MEGA
#-----------------------------------------------------#
tmp_file() {
	# Catch no arguments.
	if [ $# -eq 0 ] 
	then 
		NO_OPT_TMP_SET=true

	else
	# Choose what to do with the handle.
	while [ $# -gt 0 ]
	do
		case "$1" in
			# Bind name to variable.
			-n|--name) 
				OPT_TMP_ASSOC=true
				shift
				OPT_TMP_NAME="$1"
			;;
	
			# Remove a temporary file.
			-r|--rm|--remove) 
				OPT_TMP_REMOVE=true
			;;

			# Remove all temporary files.
			-w|--wipe) 
				OPT_TMP_WIPE=true
			;;

			# Remove all temporary files.
			-z|--all) 
				OPT_TMP_ALL=true
			;;

			# Retrieve the last temporary file. 
			-l|--last)
				OPT_TMP_LAST=true
			;;
		
			# Remove last created file.  
			# No need to create a variable.
			-d|--delete-last-created)
				OPT_TMP_DELETE_LAST=true
			;;
		esac
		shift
	done
	fi

	# Don't want to include...
	# An option within maintlib would be nice, to carry over only
	# function body to a current function.

	# Create a new temporary file.
	if [ ! -z $OPT_TMP_ASSOC ] || [ ! -z $NO_OPT_TMP_SET ]
	then
		# Craft a name.
		RAND_NAME="$(cat /dev/urandom | head -c 20 | base64 | sed 's#[/,=]##g')"
		FILE_NAME="${PROGRAM:-"$(basename $(readlink -f $0))"}"
		__TMPSEED__="$(date +%s).${FILE_NAME}.${RAND_NAME}"
		
		# Move through possible temporary directories.
		for TMP_PS in [ "$HOME/tmp" "/tmp" "/var/tmp" "/usr/tmp" ]
		do	
			# Check if it exists and if it's writeable.
			if [ -d "$TMP_PS" ] && [ -w "$TMP_PS" ] 
			then
				__TMP__="$TMP_PS/$__TMPSEED__"
				touch $__TMP__
				break
			fi
		done

		# Store a record of this file.
		# Create an array that keeps track of each.
		# A `trap` can kill all of them.
		# echo in __TMPARR__: ${#__TMPARR__[@]}
		# [ ${#__TMPARR__[@]} -eq 0 ] && declare -a __TMPARR__

		# Next element in set.
		IND=$(( ${#__TMPARR__[@]} + 1 ))
		__TMPARR__[$IND]="$__TMP__"

		# Return the handle
		[ ! -z $NO_OPT_TMP_SET ] && echo $__TMP__ 

		# Or just make it so we can mess with it.
		[ ! -z $OPT_TMP_ASSOC ] && eval "$OPT_TMP_NAME='$__TMP__'" 

		# Free it.
		unset NO_OPT_TMP_SET

	# Show all temporary files.
	elif [ ! -z $OPT_TMP_ALL ]
	then
		for __TMPH__ in ${__TMPARR__[@]}
		do
			printf "${__TMPH__}\n"
		done

	# Remove last created tempoarary file.
	elif [ ! -z $OPT_TMP_REMOVE_LAST ]
	then
		FILE="${__TMPARR__[${#__TMPARR__}]}"
		[ -f "$FILE" ] && rm -f "$FILE"

	# Removing last modified seems like a good option too.

	# Retrieve last temporary file.
	elif [ ! -z $OPT_TMP_LAST ]
	then
		printf "${__TMPARR__[${#__TMPARR__}]}"

	# Wipe all temporary files.
	elif [ ! -z $OPT_TMP_WIPE ]
	then
		for __TMPH__ in ${__TMPARR__[@]}
		do
			rm -f $__TMPH__
		done
		unset __TMPH__
		unset __TMPARR__	
	fi

	# Unset each for no further conflict.
	unset OPT_TMP_ASSOC
	unset OPT_TMP_HANDLE
	unset OPT_TMP_HANDLE_REF
	unset OPT_TMP_NEW
	unset OPT_TMP_REMOVE
	unset OPT_TMP_WIPE
	unset OPT_TMP_ALL
	unset OPT_TMP_LAST

	# A few tests.
#  tmp_file -n LUKA 
#  echo "binbinbinbinbinb" > $LUKA
#  cat $LUKA
#  
#  tmp_file -n ADRIAN 
#  echo "binbinbinbinbinb" > $ADRIAN
#  
#  tmp_file -n CARMICHAEL 
#  echo "binbinbinbinbinb" > $CARMICHAEL
#  
#  tmp_file --wipe
#  
#  cat $LUKA  # Should result in error.  
}
