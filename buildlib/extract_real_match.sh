#-----------------------------------------------------#
# extract_real_match ()
#
# Find an exact match.
# Grep fails for searches like this.
#-----------------------------------------------------#
extract_real_match () {
	# Make stuff local
	local NAME=
	local FEXNAME=
	local VERBOSE=
	local DO_FUNCTION=
	local DO_INCLUDE_COMMENTS=
	local FILE=

	# Options.
	while [ $# -gt 0 ]
	do
		case "$1" in
		-f|--find)
				shift
				NAME="$1"
			;;
		-i|--include-comments)
				DO_INCLUDE_COMMENTS=true
			;;
		-f|--function)
				DO_FUNCTION=true
			;;
		-w|--within)
			shift
			FILE="$1"
			;;
		-v|--verbose)
			VERBOSE=true
			;;
		-h|--help)
			exit 0
			;;
		--) break;;
		-*)
			printf "Unknown argument received.\n" > /dev/stderr;
			exit 1
		;;
		*) break;;
		esac
	shift
	done

	# Set to stdin if not some other file.
	[ -z "$FILE" ] && FILE=/dev/stdin
	# cat $FILE

	# Set a name.
	[ -z "$NAME" ] && NAME="$FEXNAME"

	# Some overrides.

	# Find the function name within the file.
	# (Example: $PROGRAM -x pear --from mega.sh)
	# 
	# What if there are multiple of the same name?
	# If a conflict like this is found, best to examine
	# both functions as temporary files or let the user know.
	#
	# Find the line number containing our name, if more
	# than one match, handle it properly.
	SLA="$(grep --line-number "$FEXNAME" "$FILE" | \
		awk -F ':' '{ print $1 }')"

	# Could have many matches.
	[ ! -z "$SLA" ] && SLA=( $SLA )

	echo ${SLA[@]}
	exit
	# In said line, check to make sure that $FEXNAME 
	# is actually $FEXNAME and not part of something else.
	for POSS_RANGE in ${SLA[@]}
	do
		# Process this one line.
		FEXSRC="$(sed -n ${POSS_RANGE}p ${FROM} 2>/dev/null)"

		# Disregard comment blocks.
		[[ "$FEXSRC" =~ "#" ]] && {
			# Check everything before the first comment.
			FEXSRC="${FEXSRC%%#*}"
		}

		# If matched line doesn't contain (), next match. 
		[[ ! "$FEXSRC" =~ "(" ]] || [[ ! "$FEXSRC" =~ ")" ]] && {
			continue	
		}

		# Remove leading white space and function wraps...
		FEXLINE="$( printf "%s" $FEXSRC | \
			sed "s/^[ \t]*\($FEXNAME\).*/\1/g")" 

		# ... to check if script received an accurate match.
		[[ ! "$FEXLINE" == $FEXNAME ]] && {
			continue	
		}

		# If all checks are good, there's the line range.
		SL=$POSS_RANGE
		break
	done

	# Unset mania!
	unset FIND
	unset VERBOSE
	unset DO_FUNCTION
	unset DO_INCLUDE_COMMENTS
}


