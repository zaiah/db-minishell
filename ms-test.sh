#!/bin/bash -
#-----------------------------------------------------#
# minishell-test
#
# Run some tests . 
#-----------------------------------------------------#
PROGRAM="ms-test"

# References to $SELF
BINDIR="$(dirname "$(readlink -f $0)")"
SELF="$(readlink -f $0)"
BUILD="$BINDIR/ms-build.sh"
DB="$BINDIR/tests/mytest.db"
SQLITE="/usr/bin/sqlite3"
TABLE="tests"
CALLNAME="dbm"

#-----------------------------------------------------#
# get_random_number()
#
# Grab a random number.
#-----------------------------------------------------#
get_random_number() {
	printf '' > /dev/null
}

#-----------------------------------------------------#
# get_word()
#
# Retrieve a word from /usr/share/dict/words or
# whatever word bank exists on whatever *nix you
# prefer to use at the time.
#-----------------------------------------------------#
get_word() {
	printf '' > /dev/null
}

#-----------------------------------------------------#
# get_word()
#
# Retrieve a random punctuation character for testing
# purposes. 
#-----------------------------------------------------#
get_punct_char() {
	__CHARS__='~!@#$%^&*()_-+={}[]|\;:<>,.?/'
	printf '' > /dev/null
}

#-----------------------------------------------------#
# tmp_file()
#
# Create a temporary file.
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
}


# usage() - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -idaresh ] [ -f <n> ]

-i | --init                   Initialize a database. 
-d | --delete                 Delete a test database. 
-f | --fill <n>               Populate the test database with <n> records. 
-w | --with <arg>             Use <arg> as lib to test against, rather than
                              a dynamically generated copy.

-a | --add                    Test adds. (--fill does the same.)
-r | --remove                 Test removals.
-e | --modify                 Modify some records.
-s | --select                 Selects all records.
-h | --help                   Show this help and quit.
"
   exit $STATUS
}


# Die if no arguments received.
[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" && usage 1

# Process options.
while [ $# -gt 0 ]
do
   case "$1" in
     -i|--init)
         DO_INIT=true
      ;;
     -d|--delete)
         DO_DELETE=true
      ;;
     -f|--fill)
         DO_FILL=true
			shift
			FILL_THIS_MANY="$1"
      ;;
     -a|--add)
         DO_ADD=true
      ;;
     -r|--remove)
         DO_REMOVE=true
      ;;
     -m|--modify)
         DO_MODIFY=true
      ;;
     -s|--select)
         DO_SELECT=true
      ;;
     -w|--with)
        shift
		  WITH_THIS="$1"
      ;;
     -e|--entire)
       	# Run all tests.
			DO_ENTIRE=true 
      ;;
     -h|--help)
        usage 0
      ;;
     --) break;;
     -*)
      printf "Unknown argument received.\n";
      usage 1
     ;;
     *) break;;
   esac
shift
done


# init
if [ ! -z $DO_INIT ]
then
	# Create temporary file.
	tmp_file -n DB_STREAM

	# Create a SQL load statement.
	#	 id integer primary key autoincrement,
	echo "CREATE TABLE $TABLE (
		 instance_name text,
		 srv_path text,
		 dev_path text,
		 date_created integer,
		 version text,
		 last_version text,
		 user_owner text,
		 description text
	);" > $DB_STREAM

	# Save records.	
	$SQLITE $DB < $DB_STREAM 
fi


# delete
if [ ! -z $DO_DELETE ]
then
	[ -f $DB ] && rm -v $DB 
fi


# fill
if [ ! -z $DO_FILL ]
then
	# A database must exist.
	[ ! -f $DB ] && {
		echo "Database must exist!  Run ./ms-test.sh --init first!"
		usage 1
	}

	# Make sure that fill exists.
	[ -z $FILL_THIS_MANY ] && {
		echo "Argument to --fill can't be null."
		usage 1
	}

	# Make sure that fill is a number.
	[[ $FILL_THIS_MANY =~ [a-z] ]] && {
		echo "Argument to --fill must be a number."
		usage 1
	}

	# Create a temporary file and place the dbm build there.
	# Or use a compiled library.
	[ ! -z "$WITH_THIS" ] && DBM="$WITH_THIS" || {
		tmp_file -n DBM
		$BUILD -b -n $CALLNAME > $DBM
	}	

	source $DBM

	# Populate the database.
	tmp_file -n DATA_LOAD
	( 
	for EACH in $(seq 0 $FILL_THIS_MANY)
	do
		# Is this quicker to run once each time?  or load each array depending on how many results are there?
		# Grendel is going to use this...
		INSTANCE='jericurl'					# Grep one word from $WORDS
		SRV_PATH='/home/bob/jericurl'		# ...
		DEV_PATH='/home/bob/jericurl'		# More arbitrary numbers of words
		DATECREATED='23894723947329'		# UNIX TIME!!!
		VERSION="1.00"							# Make up stuff
		LAST_VERSION="1.01"					# make up stuff
		USER_OWNER="zaiah"					# Grep one word from $WORDS 
		DESCRIPTION='Button up, bro.'		# Grep arbitrary number of words from $WORDS
		
		printf "$INSTANCE|"
		printf "$SRV_PATH|"
		printf "$DEV_PATH|"
		printf "$DATECREATED|"
		printf "$VERSION|"
		printf "$LAST_VERSION|"
		printf "$USER_OWNER|"
		printf "$DESCRIPTION"
		printf "\n"
	done
	) > $DATA_LOAD

	# Run the update.
	tmp_file -n RECORD_IMPORT
	printf ".separator |\n" > $RECORD_IMPORT
	printf ".import $DATA_LOAD $TABLE\n" >> $RECORD_IMPORT
	printf ".quit\n" >> $RECORD_IMPORT

	# Load each record.
	$SQLITE $DB < $RECORD_IMPORT
fi


# Some queries.
[ ! -z $DO_SELECT ] && $SQLITE $DB -line "SELECT * FROM $TABLE"
#[ ! -z $DO_REMOVE ] && $SQLITE $DB "SELECT * FROM $TABLE"
#[ ! -z $DO_MODIFY ] && $SQLITE $DB "SELECT * FROM $TABLE"

	#	$CALLNAME --insert-from-mem

# Clean up.
tmp_file -w
