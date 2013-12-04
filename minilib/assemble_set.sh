#-----------------------------------------------------#
# assemble_set() 
#
# Assemble a SET clause. 
#-----------------------------------------------------#
assemble_set() {
	# My Term
	__SETTERM__=
	__MYSET__="$SET"

	# Get rid of backslashes.
	[[ "$__MYSET__" =~ '\' ]] && \
		__MYSET__="$(echo "$__MYSET__" | sed 's/\\//')"

	# If it's one term, we can speed it up by just running a check for the |
	if [[ "$__MYSET__" =~ '|' ]]
	then
		# Using a '|' to mark the arguments, chop up our string accordingly.

		# Create a buffer and save the first position.
		declare -a __CHOP_SET__
		__CHOP_SET__[0]=0	 			


		# Loop through each character in our clause to mark break points.
		for __C__ in $(seq 0 "${#__MYSET__}")
		do
			[[ ${__MYSET__:$__C__:1} == "|" ]] && \
				__CHOP_SET__[${#__CHOP_SET__[@]}]=$__C__ 
		done
		__CHOP_SET__[${#__CHOP_SET__[@]}]=${#__MYSET__}


		# Iterate through each of the clauses.
		CC_COUNT=1
		for __DD__ in ${__CHOP_SET__[@]}
		do
			# Break if we've reached the end.
			[ $__DD__ == ${#__MYSET__} ] && break

			# Get more creative...
			if [ ! $__DD__ == 0 ] 
			then
				__DD__=$(( $__DD__ + 1 )) # Cut the char.
				__EE__=$(( ${__CHOP_SET__[$CC_COUNT]} - $__DD__ ))
				WHERE_TERM=${__MYSET__:$__DD__:$__EE__}
			else
				__EE__=$(( ${__CHOP_SET__[$CC_COUNT]} - $__DD__ ))
				WHERE_TERM=${__MYSET__:$__DD__:$__EE__}
			fi
		
			# Increment again.
			CC_COUNT=$(( $CC_COUNT + 1 ))

			# Chop up this particular part of the clause.
			#case "$(chop_by_position "$WHERE_TERM")" in
			chop_by_position "$WHERE_TERM"

			# Build/append to the clause.
			[ -z "$__SETTERM__" ] && \
				__SETTERM__="$__KEY__ $(convert "$__VALUE__")" || \
				__SETTERM__="$__SETTERM__, $__KEY__ $(convert "$__VALUE__")" 
		done 

	# Process one clause 
	else
		# Chop up the single clause. 
		chop_by_position "$__MYSET__"

		# Build/append to the clause.
		__SETTERM__="$__KEY__ $(convert "$__VALUE__")" 
	fi # [[ $__MYSET__ =~ '|' ]]

	ST_TM="$__SETTERM__"
}
