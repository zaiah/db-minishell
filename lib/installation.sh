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
	# Local variables. 
	local SW_INSTALL=
	local DO_INSTALL=
	local DO_UNINSTALL=
	local IIDIR=
	local AS_NAME=
	local LN_ARGS=
	local LN_FILE=
	local VERBOSE=
	local SW_INSTALLS=

	# Flags.
	local SW_LN_FLAGS=
	local UN_RM_FLAGS=
	local SW_MKDIR_FLAGS=
	local SW_CHMOD_FLAGS=

	LIBPROGRAM="installation"
	installation_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-d | --do                     Run an install. 
	-u | --undo                   Run an uninstall. 
	-t | --to <arg>              	Install to a particular directory. 
	-a | --as <arg>               Use a different name to link to.
	                              (Currently can only be used on one file)
	-t | --this <arg>             Choose a file to create a symbolic link to. 
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}

	# Need some flags to catch install dir, 
	# arguments for what should be linked...
	while [ $# -gt 0 ]
	do
		case $1 in
			-d|--do) 
				DO_INSTALL=true
			;;
			-u|--undo) 
				DO_UNINSTALL=true
			;;
			-t|--to) 
				shift
				IIDIR=$1
			;;
			-a|--as) 
				shift
				AS_NAME=$1
			;;
			-e|--these|--this) 
				shift
				LN_ARGS=$1
			;;
			-*)
				printf "Unknown argument received: $1\n";
				exit 1	
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

	SW_INSTALL="${BINDIR}/INSTALL"

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


	# Stop if the AS_NAME has been specified and 
	# there is more than one argument.
	[[ "$LN_ARGS" =~ ',' ]] && [ ! -z "$AS_NAME" ] && {
		printf "Can't specify multiple files when using the --as argument."
		exit 1
	} > /dev/stderr


	# Install procedure.
	[ ! -z $DO_INSTALL ] && {
		# Set initial dir if not set.
		IIDIR="${IIDIR}"

		# Die on no permissions if IIDIR is relative to /.
		[ -d "$IIDIR" ] && [ ! -O "$IIDIR" ] && {
			printf "Install directory is not writeable.  Exiting..." >/dev/stderr
			exit 1
		}

		# Assume this directory could be impractically long.
		[ ! -d "$IIDIR" ] && {
			# Failure is unacceptable.
			local SW_MKDIR_FAIL=
			mkdir $SW_MKDIR_FLAGS $IIDIR 2>/dev/null || SW_MKDIR_FAIL=true

			[ ! -z $SW_MKDIR_FAIL ] && {
				printf "Could not create $IIDIR.  Exiting..." >/dev/stderr 
				exit 1
			}	
		}	

		# Check for what type of file exists in $BINDIR
		SW_INSTALLS=( $(printf $LN_ARGS | sed 's/,/ /g') )

		# Link all files.
		for FILE in ${SW_INSTALLS[@]}
		do
			# If a shell script, did we use an extension? 
			# No extensions should exist in the executable directory.
			if [ -f "${BINDIR}/${FILE}.sh" ] 
			then 
				FILE="${BINDIR}/${FILE}.sh" 
			elif [ -f "${BINDIR}/${FILE}" ] 
			then
				FILE="${BINDIR}/${FILE}" 
			fi

			# Create a file. 
			[ ! -z "$AS_NAME" ] && LN_FILE="$AS_NAME" || {
				LN_FILE="$(basename ${FILE%%.sh})" 
			}

			# Quick test.
			[ -L "$LN_FILE" ] && {
				{
				printf "${PROGRAM} already seems to be installed on this machine."
					printf "You'll need to uninstall or remove those links first."
				} > /dev/stderr 
				exit
			}	

			# Set x bit, and link.
			[ ! -x "${FILE}" ] && chmod $SW_CHMOD_FLAGS 744 ${FILE}
			ln $SW_LN_FLAGS ${FILE} ${IIDIR}/$LN_FILE


			# Save the software install location to a file.
			echo "${IIDIR}/$LN_FILE" >> $SW_INSTALL
		done
	}


	# For what install would be complete without an uninstall?.
	[ ! -z $DO_UNINSTALL ] && {
		# Verbosity
		[ ! -z $VERBOSE ] && UN_RM_FLAGS='-v --' || UN_RM_FLAGS='--'

		# Stop on problems accessing our install file 
		# (like it hasn't been created.)
		[ ! -f $SW_INSTALL ] && {
			printf "Can't access INSTALL file." >/dev/stderr
			exit 1
		}

		# Read in the links and trash them.
		while read line
		do
			rm $UN_RM_FLAGS $line
		done < $SW_INSTALL

		# Trash the file.
		rm $UN_RM_FLAGS $SW_INSTALL
	}	

	# Unsets
	unset SW_INSTALL
	unset DO_INSTALL
	unset DO_UNINSTALL
	unset IIDIR
	unset AS_NAME
	unset LN_ARGS
	unset LN_FILE
	unset VERBOSE
	unset SW_INSTALLS

	# Flags.
	unset SW_LN_FLAGS
	unset UN_RM_FLAGS
	unset SW_MKDIR_FLAGS
	unset SW_CHMOD_FLAGS
}
