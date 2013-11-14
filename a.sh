# Library and directory name
LIBNAME="aa"
PROGRAM_DIR="$HOME/.${LIBNAME}"
DB="${PROGRAM_DIR}/${LIBNAME}.db"
BIN_SQL_DIR="${BINDIR}/sql"

# Initial deployment.
initial_deploy() {
	if [ ! -z $VERBOSE ] 
	then
		ID_MKDIR_FLAGS='-pv'	
	else
		ID_MKDIR_FLAGS='-p'	
	fi

	# Create all directories in $HOST_DIRS
	for D in ${HOST_DIRS[@]}
	do
		mkdir $ID_MKDIR_FLAGS "$D"
	done

	# Create tables	
	for SD in $( ls $BIN_SQL_DIR )
	do
		[ ! -z $VERBOSE ] && echo "Loading tables in: ${BIN_SQL_DIR}/$SD"
		$SQLITE $DB < ${BIN_SQL_DIR}/$SD
	done
}

# Install program where?
# ('/usr/bin', '/usr/local/bin', '$HOME/bin' or another directory entirely.)
INITIAL_INSTALL_DIR="/home/ancollins/bin"

# Initial install of program.
SW_INSTALL="${PROGRAM_DIR}/INSTALL"
initial_install() {
	# Verbosity flags.
	if [ ! -z $VERBOSE ] 
	then
		SW_LN_FLAGS='-sv'	
		SW_MKDIR_FLAGS='-pv'	
		SW_CHMOD_FLAGS='--verbose'	
	else
		SW_LN_FLAGS='-s'	
		SW_MKDIR_FLAGS='-p'	
		SW_CHMOD_FLAGS='--'	
	fi

	if [ ! -d "$PROGRAM_DIR" ] 
		echo "Program directory does not exist." 
		echo "Exiting..." 
		exit 1
	elif [ -d "$PROGRAM_DIR" ] && [ ! -O "$PROGRAM_DIR" ] 
	then
		echo "Program directory is not writeable.  "
		echo "Exiting..." 
		exit 1
	fi

	# Set initial dir if not set.
	INITIAL_INSTALL_DIR="${INITIAL_INSTALL_DIR:-'/usr/local/bin'}"

	# Die on no permissions if INITIAL_INSTALL_DIR is relative to /.
	if [ -d "$INITIAL_INSTALL_DIR" ] && [ ! -O "$INITIAL_INSTALL_DIR" ] 
	then
		echo "Install directory is not writeable.  Exiting..." 
		exit 1
	fi

	# Assume this directory could be impractically long.
	if [ ! -d "$INITIAL_INSTALL_DIR" ] 
	then
		mkdir $SW_MKDIR_FLAGS $INITIAL_INSTALL_DIR 2>/dev/null || SW_MKDIR_FAIL=true
		if [ ! -z $SW_MKDIR_FAIL ] 
		then 
			echo "Could not create $INITIAL_INSTALL_DIR.  Exiting..." 
			exit 1
		fi
	fi

	# Check for what type of file exists in $BINDIR
	SW_INSTALLS=( $(printf $1 | sed 's/,/ /g') )
	declare -a SW_LOCATIONS
	for FILE in ${SW_INSTALLS[@]}
	do
		# If a shell script, did we use an extension? (goal is to have no .sh in /bin)
		if [ -f "${BINDIR}/${FILE}.sh" ] 
		then 
			FILE="${BINDIR}/${FILE}.sh" 
		elif [ -f "${BINDIR}/${FILE}" ] 
		then
			FILE="${BINDIR}/${FILE}" 
		fi


		# Link 
		LNFILE="$(basename ${FILE})" 

		# Quick test.
		if [ -L "$LNFILE" ] 
		then 
			echo "${PROGRAM} already seems to be installed on this machine."
			echo "You'll need to uninstall or remove those links first."
			exit
		fi


		# Set x bit, and link.
		[ ! -x "${FILE}" ] && chmod $SW_CHMOD_FLAGS 744 ${FILE}
		ln $SW_LN_FLAGS ${FILE} ${INITIAL_INSTALL_DIR}/$LNFILE


		# Save the software install location to a file.
		echo "${INITIAL_INSTALL_DIR}/$LNFILE" >> $SW_INSTALL
	done
}

# For what install would be complete without an uninstall?.
uninstall() {
	if [ ! -z $VERBOSE ] 
	then
		UN_RM_FLAGS='-v --'	
	else
		UN_RM_FLAGS='--'	
	fi

	[ ! -f $SW_INSTALL ] && echo "Can't access INSTALL file." && exit 1
	while read line
	do
		echo line
		rm $UN_RM_FLAGS line
	done < $SW_INSTALL
}

# Set the right internal field seperator for command line args.
IFS=' 
	'

# Limits file creation permissions.
UMASK=002
umask $UMASK

# Set a normal path.
PATH="/usr/local/bin:/bin:/usr/bin"
export PATH

# Library functions
#-----------------------------------------------------#
# break_list_by_delim
#
# Creates an array based on a string containing delimiters.
#-----------------------------------------------------#
# break-list - creates an array based on some set of delimiters.
break_list_by_delim() {
	mylist=(`printf $1 | sed "s/${DELIM}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

