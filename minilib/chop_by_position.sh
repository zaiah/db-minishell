#-----------------------------------------------------#
# chop_by_position 
#
# Chop a string based on positional parameters.
#-----------------------------------------------------#
chop_by_position() {
	# My Term
	__MY_TERM__="$1"

	# Get rid of backslashes.
	[[ "$__MY_TERM__" =~ '\' ]] && \
		__MY_TERM__="$(echo "$__MY_TERM__" | sed 's/\\//')"

	# Find the first non-alpha character in the string 
	# Must localize every string.
	# echo Clause length: ${#__MY_TERM__}
	# echo Clause: $__MY_TERM__
	for __CHAR__ in `seq 0 ${#__MY_TERM__}`
	do
		# Characters.
		CHAR_1=${__MY_TERM__:$__CHAR__:1}
		
		# Loop through each and find the term.
		if [[ ${CHAR_1} == '=' ]] || \
			[[ ${CHAR_1} == '!' ]] || \
			[[ ${CHAR_1} == '~' ]] || \
			[[ ${CHAR_1} == '>' ]] || \
			[[ ${CHAR_1} == '<' ]]
		then
			# Smack.
			CHAR_2=${__MY_TERM__:$(( $__CHAR__ + 1 )):1}

			# Get the next character if match was !
			# If not move on.
			if [[ ${CHAR_1} == '!' ]] && \
				( [[ ${CHAR_2} == '~' ]] || [[ ${CHAR_2} == '=' ]] )
			then
				FIRST_TERM="${CHAR_1}${CHAR_2}"
				__KEY__=${__MY_TERM__:0:$(( $__CHAR__ + 2 ))}
				__VALUE__=${__MY_TERM__:$(( $__CHAR__ + 2 )):${#__MY_TERM__}}
				break
			else	
				FIRST_TERM=$CHAR_1
				__KEY__=${__MY_TERM__:0:$(( $__CHAR__ + 1 ))}
				__VALUE__=${__MY_TERM__:$(( $__CHAR__ + 1 )):${#__MY_TERM__}}
				break
			fi
		fi
	done

	# Evaluate the clause type.
	case "$FIRST_TERM" in
		'=') 	__KEY__="$(printf "$__KEY__" | sed 's/=/ =/')";; 
		'>') 	__KEY__="$(printf "$__KEY__" | sed 's/>/ >/')";;
		'<')  __KEY__="$(printf "$__KEY__" | sed 's/</ </')";;
		'~')  __KEY__="$(printf "$__KEY__" | sed 's/~/ LIKE/')";;
		'!=') __KEY__="$(printf "NOT $__KEY__" | sed 's/!=/ =/')";;
		'!~') __KEY__="$(printf "NOT $__KEY__" | sed 's/!~/ LIKE/')";;
	esac
}
