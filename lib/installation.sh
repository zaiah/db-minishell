#-----------------------------------------------------#
# installation()
#
# Install, uninstall and more of a program.
# 
# Usage:
# --do            - Carry out the install routine.
# --to <arg>      - Set a directory to install to.
# --these <arg>   - Name items to link from. 
# --undo          - Carry out the uninstall routine.
#-----------------------------------------------------#
installation() {
	# A file to keep track of where files have been linked.
	# Pretty sure PROGRAM_DIR is supposed to be INSTALL_DIR
	if [ ! -z "${PROGRAM_DIR}" ] 
	then
		# Is it a directory?
		if [ -d "${PROGRAM_DIR}" ] 
		then 
			if [ ! -O "$PROGRAM_DIR" ] 
			then
				echo "Program directory is not writeable.  "
				echo "Exiting..." 
				exit 1
			else
				SW_INSTALL="${PROGRAM_DIR}/INSTALL" 
			fi
		else
			echo "Program directory does not exist." 
			echo "Exiting..." 
			exit 1
		fi
	# This is more than likely a single file.
	else
		SW_INSTALL="${BINDIR}/INSTALL"
	fi

	# Need some flags to catch install dir, 
	# arguments for what should be linked...
	while [ $# -gt 0 ]
	do
		case $1 in
			--do) 
				EXECUTE_INSTALL_ROUTINE=true
			;;
			--undo) 
				EXECUTE_UNINSTALL_ROUTINE=true
			;;
			--to) 
				shift
				INITIAL_INSTALL_DIR=$1
			;;
			--these|--this) 
				shift
				LN_ARGS=$1
			;;
			-*)
			break
			;;
			*)
				printf "This function must have the --to and "
				printf "(--this or --these) flags populated with an argument."
				printf "Giving up...\n"
				exit 1
			;;
		esac
		shift
	done

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

	# Install procedure.
	if [ ! -z $EXECUTE_INSTALL_ROUTINE ]
	then	
		# Set initial dir if not set.
		INITIAL_INSTALL_DIR="${INITIAL_INSTALL_DIR:-/usr/local/bin}"

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
		SW_INSTALLS=( $(printf $LN_ARGS | sed 's/,/ /g') )
		declare -a SW_LOCATIONS

		# Link all files.
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
			LNFILE="$(basename ${FILE%%.sh})" 

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


	# For what install would be complete without an uninstall?.
	elif [ ! -z $EXECUTE_UNINSTALL_ROUTINE ]
	then
	
		# Verbosity
		if [ ! -z $VERBOSE ] 
		then
			UN_RM_FLAGS='-v --'	
		else
			UN_RM_FLAGS='--'	
		fi

		# Stop on problems accessing our install file (like it hasn't been created.)
		[ ! -f $SW_INSTALL ] && echo "Can't access INSTALL file." && exit 1

		# Read in the links and trash them.
		while read line
		do
			rm $UN_RM_FLAGS $line
		done < $SW_INSTALL

		# Trash the file.
		rm $UN_RM_FLAGS $SW_INSTALL
	fi
}
