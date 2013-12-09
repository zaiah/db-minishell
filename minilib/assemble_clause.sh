#-----------------------------------------------------#
# assemble_clause() 
#
# Assemble a clause. 
#-----------------------------------------------------#
assemble_clause() {
	# Buffer for our final text. 
	STMT=

	# Terms
	# =: Equal 
	# >: Greater Than
	# <: Less Than
	# ~: LIKE
	# !=: NOT
	# !~: NOT LIKE
	__TERMS__=( '=' '!=' '!~' '>' '<' '~' )


	# Logic:
	# Figure out if the clause has multiple items or not.
	# If so, mark where it needs to be broken up.
	# 
	# Regardless:
	# Rid the clause of backslashes
	# If clause is multiple terms loop through each part; 
	# else loop through the clause to figure out negation.
	#
	# Convert the value side of the clause
	# Build the statement.

	# If it's one term, we can speed it up by just running a check for the |
	if [ ! -z "$CLAUSE" ]
	then
		if [[ "$CLAUSE" =~ '|' ]]
		then
			# Using a '|' to mark the arguments, chop up our string accordingly.

			# Create a buffer and save the first position.
			declare -a __CHOP_CLAUSE__
			__CHOP_CLAUSE__[0]=0	 			


			# Loop through each character in our clause to mark break points.
			for __C__ in $(seq 0 "${#CLAUSE}")
			do
				[[ ${CLAUSE:$__C__:1} == "|" ]] && \
					__CHOP_CLAUSE__[${#__CHOP_CLAUSE__[@]}]=$__C__ 
			done
			__CHOP_CLAUSE__[${#__CHOP_CLAUSE__[@]}]=${#CLAUSE}


			# Have to process AND's or OR's
			AO_INC=0			# An ugly little marker to track these...

			# Iterate through each of the clauses.
			CC_COUNT=1

			for __DD__ in ${__CHOP_CLAUSE__[@]}
			do
				# Break if we've reached the end.
				[ $__DD__ == ${#CLAUSE} ] && break

				# Get more creative...
				if [ ! $__DD__ == 0 ] 
				then
					__DD__=$(( $__DD__ + 1 )) # Cut the char.
					__EE__=$(( ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ ))
					WHERE_TERM=${CLAUSE:$__DD__:$__EE__}
				else
					__EE__=$(( ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ ))
					WHERE_TERM=${CLAUSE:$__DD__:$__EE__}
				fi
		
				# Increment again.
				CC_COUNT=$(( $CC_COUNT + 1 ))

				# Chop up this particular part of the clause.
				#case "$(chop_by_position "$WHERE_TERM")" in
				chop_by_position "$WHERE_TERM"

				# Build/append to the clause.
				if [ ! -z "$STMT" ] && [[ ${OR_X_AND[$AO_INC]} == 'and' ]]
				then
					STMT="$STMT AND $__KEY__ $(convert "$__VALUE__")" 
				elif [ ! -z "$STMT" ] && [[ ${OR_X_AND[$AO_INC]} == 'or' ]]
				then
					STMT="$STMT OR $__KEY__ $(convert "$__VALUE__")" 
				else
					STMT="WHERE $__KEY__ $(convert "$__VALUE__")" 
				fi

				AO_INC=$(( $AO_INC + 1 ))
			done 

		# Process one clause 
		else
			# Chop up the single clause. 
			chop_by_position "$CLAUSE"

			# Build/append to the clause.
			STMT="WHERE $__KEY__ $(convert "$__VALUE__")" 
		fi # [[ $CLAUSE =~ '|' ]]
	fi


	# Also check for ...
	# ...LIMIT 
	# Case statements allow you to tune the lang more.

	# Test for empty string, (but how?)

	# BETWEEN 
	[ ! -z $__BETWEEN ] && {
		BETWEEN_COL=${__BETWEEN%%=*}
		BETWEEN_VAL=${__BETWEEN##*=}
		[ -z "$STMT" ] && STMT="WHERE $BETWEEN_COL BETWEEN ${BETWEEN_VAL%%-*} AND ${BETWEEN_VAL##*-}" || \
			STMT=" ${STMT} BETWEEN $__BETWEEN"
	}	
	
	# LIMIT  
	[ ! -z "$__LIM" ] && {
		[ -z "$STMT" ] && STMT="LIMIT $__LIM" || STMT=" ${STMT} LIMIT $__LIM"

		# Include any offset.
		[ ! -z "$__OFFSET" ] && STMT=" ${STMT} OFFSET $__OFFSET"
	}	

	# ... ORDER BY
	[ ! -z "$__ORDER_BY" ] && {
		[ -z "$STMT" ] && STMT="ORDER BY $__ORDER_BY" || STMT=" ${STMT} ORDER BY $__ORDER_BY"
	}	

	# ... HAVING
	[ ! -z "$__HAVING" ] && {
		[ -z "$STMT" ] && STMT="HAVING $__ORDER_BY" || STMT=" ${STMT} HAVING $__ORDER_BY"
	}	

	# ... GROUP BY
	[ ! -z "$__GROUP_BY" ] && {
		[ -z "$STMT" ] && STMT="GROUP BY $__ORDER_BY" || STMT=" ${STMT} GROUP BY $__GROUP_BY"
	}	

	# Prepare the clause (begin with space, then WHERE, and end with ';')
	[ -z "$STMT" ] && STMT=';' || STMT=" ${STMT};"


	# Clause
}
