#-----------------------------------------------------#
# db-minishell
#
# Manages simple SQL queries via Bash.
#
# ---------
# Licensing
# ---------
# 
# Copyright (c) 2013 Vokayent
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-----------------------------------------------------#
db_minishell() {
	DO_LIBRARIFY=true
	declare -a OR_X_AND			# Is it an OR or AND clause?
	
	#-----------------------------------------------------#
	# break_list_by_delim
	#
	# Creates an array based on a string containing 
	# delimiters.
	#-----------------------------------------------------#
	# break-list - creates an array based on some set of delimiters.
	break_list_by_delim() {
		mylist=(`printf $1 | sed "s/${DELIM}/ /g"`)
		echo ${mylist[@]}		# Return the list all ghetto-style.
	}
	
	
	#-----------------------------------------------------#
	# break_maps_by_delim
	#
	# Creates a key to value pair based on a string 
	# containing delimiters.
	#-----------------------------------------------------#
	break_maps_by_delim() {
		join="${2-=}"			# Allow for an alternate map marker.
		local m=(`printf $1 | sed "s/${join}/ /g"`)
		echo ${m[@]}			# Return the list all ghetto-style.
	}
	
	
	
	#-----------------------------------------------------#
	# get_columns()
	#
	# Get the columns of a table.
	#-----------------------------------------------------#
	get_columns() {
		# Start fresh
		unset __RESULTBUF__
	
		# Hold the schema results in the buffer.
		__RESULTBUF__="$( $SQLITE $DB ".schema ${__TABLE}")"
	
		# Die if nothing is there...
		if [ -z "$__RESULTBUF__" ]
		then
			exit 1
	
		# If tables were written with newlines, use the below.
		elif [ $(printf "%s" "$__RESULTBUF__" | wc -l) -gt 1 ]
		then
			# Process and reload the buffer.
			# Could have an issue with `awk` on other systems.
			__RESULTBUF__="$(printf '%s' "$__RESULTBUF__" | \
				sed 's/\t//g' | \
				sed 's/\r//g' | \
				awk '{ print $1 }' | \
				grep -v "CREATE" | \
				sed 's/);//g' )"
	
			# Alterante return - no for...
			printf "%s" "$__RESULTBUF__"
	
		# If tables were written with single line, use this...
		else	
			echo '...'
			exit 1    # Can't handle this right now.
	
		fi
	}
	
	
	#-----------------------------------------------------#
	# load_from_db_columns
	#
	# Create a variable in Bash out of each column header 
	# in a table and fill it with information found in 
	# that column.
	#-----------------------------------------------------#
	load_from_db_columns() {
		# Die if no table name.
		#__TABLE="$1"
		if [ -z "$__TABLE" ]
		then
			echo "In function: load_from_db_columns()"
			echo "\tNo table name supplied, You've made an error in coding."
			exit 1
	
		else
			# Get column names 
			MEGA_COLUMNS=( $(get_columns) )
			MEGA_RES="$1"
	
			# ...
			for CINC in $(seq 0 ${#MEGA_COLUMNS[@]})
			do
				printf "%s" ${MEGA_COLUMNS[$CINC]} | \
					tr '[a-z]' '[A-Z]' | sed 's/$/=/'
				printf "%s" $MEGA_RES | \
					awk -F '|' "{print \$$(( $CINC + 1 ))}"
			done
	
			# Load these within the program.
			#cat $TMPFILE
			#source $TMPFILE
			#[ -e $TMPFILE ] && rm $TMPFILE
			#get_columns
			exit
		fi
	}
	
	
	#-----------------------------------------------------#
	# modify_from_db_columns
	#
	# Load data from database and edit from a temporary file, writing back the results.
	#-----------------------------------------------------#
	modify_from_db_columns() {
		# Catch input.
		TABLE="$1"
	
		# Die if no table name.
		if [ -z "$TABLE" ]
		then
			echo "In function: load_from_db_columns()"
			echo "\tNo table name supplied, You've made an error in coding."
			exit 1
	
		else
			# Use Some namespace...
			# LFDB
			TMP="/tmp"
			TMPFILE=$TMP/__lfdb.sql
			[ -e $TMPFILE ] && rm $TMPFILE
			touch $TMPFILE
	
			# Choose a table and this function should: 
			# Get column titles and create variable names.
			if [ ! -z "$CLAUSE" ]
			then
	#			printf ".headers ON\nSELECT * FROM ${TABLE} $CLAUSE;\n" >> $TMPFILE
				printf ".headers ON\nSELECT * FROM ${TABLE} $CLAUSE;\n" 
			else
				printf ".headers ON\nSELECT * FROM ${TABLE};\n" >> $TMPFILE
			fi
				exit
			LFDB_HEADERS=( $( $__SQLITE $DB < $TMPFILE | \
				head -n 1 | \
				tr '|' ',' ) )
	
			LFDB_VARS=( $( $__SQLITE $DB < $TMPFILE | \
				head -n 1 | \
				tr '|' ' ' | \
				tr [a-z] [A-Z] ) )
	
			LFDB_ID=$( $__SQLITE $DB < $TMPFILE | \
				tail -n 1 | \
				awk -F '|' '{ print $1 }')
	
			[ -e $TMPFILE ] && rm $TMPFILE
	
	
			# Get all items.
			printf "SELECT ${LFDB_HEADERS[@]} FROM ${TABLE};\n" >> $TMPFILE
			LFDB_RES=$( $__SQLITE $DB < $TMPFILE | tail -n 1 )
			[ -e $TMPFILE ] && rm $TMPFILE
	
	
			# Need a few traps to get rid of these files if things go wrong.
	
	
			# Output database values as variables within temporary file.
			TMPFILE=$TMP/__dbvar.sh
			COUNTER=0
			for XX in ${LFDB_VARS[@]}
			do
				if [[ ! $XX == 'ID' ]]
				then
					# Needs some basic string / number checking
					( printf "${XX}='"
					echo $LFDB_RES | \
						awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
						sed "s/$/'/"
					#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
					) >> $TMPFILE
				fi
				COUNTER=$(( $COUNTER + 1 ))
			done
	
	
			# Load these within the program.
			MODIFY=true
			[ ! -z $MODIFY ] && $EDITOR $TMPFILE
			source $TMPFILE
			[ -e $TMPFILE ] && rm $TMPFILE
	
	
			# Check through the list and see what's changed.
			# Output database values as variables within temporary file.
			TMPFILE=$TMP/__cmp.sh
			COUNTER=0
			for XX in ${LFDB_VARS[@]}
			do
				if [[ ! $XX == 'ID' ]]
				then
					# Needs some basic string / number checking
					( printf "ORIG_${XX}='"
					echo $LFDB_RES | \
						awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
						sed "s/$/'/"
					#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
					) >> $TMPFILE
				fi
				COUNTER=$(( $COUNTER + 1 ))
			done
			source $TMPFILE
			[ -e $TMPFILE ] && rm $TMPFILE
	
	
			# Load stuff.
			TMPFILE=$TMP/__load.sh
			COUNTER=0
			printf "SQL_LOADSTRING=\"UPDATE $TABLE SET " >> $TMPFILE
			for XX in ${LFDB_VARS[@]}
			do
				if [[ ! $XX == 'ID' ]]
				then
					# Variables...
					USER="${!XX}"
					VAR_NAME="ORIG_$XX"
					ORIG="${!VAR_NAME}"
					COLUMN_NAME="$(echo ${XX} | tr [A-Z] [a-z])"
	
					# Check values and make sure they haven't changed.
					FV=
					if [[ "$USER" == "$ORIG" ]]
					then
						FV=$ORIG
					else
						FV=$USER
					fi
	
					# Evaluate with that neat little typechecking function.
					VAR_TYPE=$(typecheck $USER)
					printf "$COLUMN_NAME = "  >> $TMPFILE
					[[ $VAR_TYPE == "null" ]] && printf "''" >> $TMPFILE
					[[ $VAR_TYPE == "string" ]] && printf "'$FV'" >> $TMPFILE
					[[ $VAR_TYPE == "integer" ]] && printf "$FV" >> $TMPFILE
	
					# Wrap final clause in the statement.
					if [ $COUNTER == $(( ${#LFDB_VARS[@]} - 1 )) ] 
					then
						( printf '\n' 
						printf "WHERE id = $LFDB_ID;\"\n" ) >> $TMPFILE
					else
						printf ',\n' >> $TMPFILE
					fi	
				fi
				COUNTER=$(( $COUNTER + 1 ))
			done
			unset COUNTER
	
			# Load the new stuff.
			source $TMPFILE
			[ -e $TMPFILE ] && rm $TMPFILE
			
			# Only write if they've changed?
			# (You'll need the id of whatever is being modified as well...)
	
			# Do the write.
			#echo $SQL_LOADSTRING
			$__SQLITE $DB "$SQL_LOADSTRING"
	
			#vi -O $TMP/__{cmp,dbvar}.sh
			# Write stuff to database 
			[ -e $TMPFILE ] && rm $TMPFILE
		fi
	
		unset CLAUSE
	}
	
	
	#-----------------------------------------------------#
	# get_datatypes()
	#
	# Get the datatypes of a table.
	#-----------------------------------------------------#
	get_datatypes() {
		# Start fresh
		# unset __RESULTBUF__
		for __COL__ in ${__DTBUF__[@]}
		do
			$__COL__
		done
	
		# Hold the schema results in buffer.
		__DTBUF__="$( $SQLITE $DB ".schema ${__TABLE}")"
	
		# Die if nothing is there...
		if [ -z "$__DTBUF__" ]
		then
			exit 1
	
		# If tables were written with newlines, use the below.
		elif [ $(printf "%s" "$__DTBUF__" | wc -l) -gt 1 ]
		then
			# Process and reload the buffer.
			# Could have an issue with `awk` on other systems.
			__DTBUF__="$(printf '%s' "$__DTBUF__" | \
				sed 's/\t//g' | \
				sed 's/\r//g' | \
				awk '{ print $2 }' | \
				grep -v "TABLE" | \
				sed 's/,//g' | \
				sed 's/);//g' )"
	
			# Alterante return - no for...
			printf "%s" "$__DTBUF__"
	
		# If tables were written with single line, use this...
		else	
			echo '...'
			exit 1    # Can't handle this right now.
	
		fi
	}
	
	
	
	#-----------------------------------------------------#
	# convert
	#
	# Prepares either the records to be placed into or
	# the queries interacting with a SQLite 3 database.
	#-----------------------------------------------------#
	convert() {
		# Is this null?
		if [ -z "$1" ]
		then
			# Return empty string (but you might need to evaluate the column too)
			printf "''"
	
		# Check other types.
		else
			# Search for spaces within long strings / sentences. 
			if [[ "$1" =~ ' ' ]] 
			then
				# Differentiate between strings that already have single or double quotes.
				[[ ${1:0:1} == "'" ]] || \
					[[ ${1:0:1} == '"' ]] && \
					printf "$1" || printf "'$1'"
	
			# Check for other characters.
			# Always going to throw an error.
			elif [[ ${1:0:1} == '!' ]] || \
				[[ ${1:0:1} == '@' ]] || \
				[[ ${1:0:1} == '#' ]] || \
				[[ ${1:0:1} == '$' ]] || \
				[[ ${1:0:1} == '%' ]] || \
				[[ ${1:0:1} == '^' ]] || \
				[[ ${1:0:1} == '&' ]] || \
				[[ ${1:0:1} == '*' ]] || \
				[[ ${1:0:1} == '(' ]] || \
				[[ ${1:0:1} == ')' ]] || \
				[[ ${1:0:1} == '+' ]] || \
				[[ ${1:0:1} == '/' ]] || \
				[[ ${1:0:1} == '\' ]] || \
				[[ ${1:0:1} == '.' ]] || \
				[[ ${1:0:1} == '-' ]] 
			then
				printf "'$1'"
	
			# Catch integers.
			elif [ ! $(echo $(( $1 * 1 )) 2>/dev/null) == 0 ]
			then
				# Is integer (most likely) 
				printf $1 
	
			# Handle single words.
			else
				# Differentiate between strings that already have single or double quotes.
				[[ ${1:0:1} == "'" ]] || \
					[[ ${1:0:1} == '"' ]] && \
					printf "$1" || printf "'$1'"
			fi
		fi
	}
	
	
	
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
		if [ ! -z $__BETWEEN ] 
		then
			BETWEEN_COL=${__BETWEEN%%=*}
			BETWEEN_VAL=${__BETWEEN##*=}
			[ -z "$STMT" ] && STMT="WHERE $BETWEEN_COL BETWEEN ${BETWEEN_VAL%%-*} AND ${BETWEEN_VAL##*-}" || \
				STMT=" ${STMT} BETWEEN $__BETWEEN"
		fi
	
		# LIMIT  
		if [ ! -z $__LIM ] 
		then
			[ -z "$STMT" ] && STMT="LIMIT $__LIM" || STMT=" ${STMT} LIMIT $__LIM"
		fi
	
		# ... ORDER BY
		if [ ! -z $__ORDER_BY ]
		then
			[ -z "$STMT" ] && STMT="ORDER BY $__ORDER_BY" || STMT=" ${STMT} ORDER BY $__ORDER_BY"
		fi
	
		# ... HAVING
		if [ ! -z $__HAVING ]
		then
			[ -z "$STMT" ] && STMT="HAVING $__ORDER_BY" || STMT=" ${STMT} HAVING $__ORDER_BY"
		fi
	
		# ... GROUP BY
		if [ ! -z $__GROUP_BY ]
		then
			[ -z "$STMT" ] && STMT="GROUP BY $__ORDER_BY" || STMT=" ${STMT} GROUP BY $__ORDER_BY"
		fi
	
		# Prepare the clause (begin with space, then WHERE, and end with ';')
		[ -z "$STMT" ] && STMT=';' || STMT=" ${STMT};"
	
	
		# Clause
	}
	
	
	# Die if no arguments received.
	if [ -z $DO_LIBRARIFY ]
	then
		# This will kill ksh
		__EXIT__="usage"
		[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" && $__EXIT__ 1
	
	else
		__EXIT__="exit"
		[ $# -le 0 ] && $__EXIT__ 1							# Exit if no args given to library.
		[ -z "$SQLITE" ] && SQLITE="$(which sqlite3)"  	# Define SQLite if not.
		LOGFILE="/dev/stderr"									# Set a log file.
	fi
	
	
	# Array
	declare -a WHERE_CLAUSE 
	declare -a NOT_CLAUSE 
	
	
	# Process options.
	# Can use a DO_LIB to evaluate which list to show...
	while [ $# -gt 0 ]
	do
		case "$1" in
			-b|--between)
				shift
				__BETWEEN="$1"
			;;
	
			-c|--columns)
				DO_GET_COLUMNS=true
				shift
				__TABLE="$1"
			;;
	
			# Serialization would save a ton of time....
			# tables for bash
	
	#     -y|--types)
	#         DO_GET_COLUMN_TYPES=true
	#			shift
	#			__TABLE="$1"
	#		;;
	
			-s|--select)
				DO_SEND_QUERY=true
				DO_SELECT=true
				shift
				SELECT="$1"
			;;
	
			-f|--from)
				DO_FROM=true
				shift
				__TABLE="$1"
			;;
	
			-t|--into)
				shift
				__TABLE="$1"
			;; 
	
			-im|--insert-from-mem)
				DO_SEND_QUERY=true
				DO_WRITE=true
				DO_WRITE_FROM_MEM=true
			;;
	
	
			-sa|--show-as)
				DO_SERIALIZATION=true
				shift
				SERIALIZATION_TYPE="$1"
			;;
	
			-i|--write|--insert)
				DO_SEND_QUERY=true
				DO_WRITE=true
				shift
				WRITE="$1"
			;;
	
			-u|--update)
				DO_SEND_QUERY=true
				DO_UPDATE=true
				shift
				__TABLE="$1"
			;;
	
			-e|--set)
				shift
				if [[ "$1" =~ "|" ]]
				then
					[ -z $DO_LIBRARIFY ] && \
						printf "This argument can't have a pipe character (|)."
					$__EXIT__ 1
				fi
				[ -z "$SET" ] && SET="$1" || SET="$SET|$1"
			;;
	
			-o|--or)
				OR_X_AND[${#OR_X_AND[@]}]="or"
				shift
				if [[ "$1" =~ "|" ]]
				then
					[ -z $DO_LIBRARIFY ] && \
						printf "This argument can't have a pipe character (|)."
					$__EXIT__ 1
				fi
				if [ -z "$CLAUSE" ]
				then 
					[ -z $DO_LIBRARIFY ] && \
						printf "Must specify at least one --where clause."
					$__EXIT__ 1
				else
					CLAUSE="$CLAUSE|$1"
				fi
			;;
	
			-w|--where)
				DO_WHERE=true
				OR_X_AND[${#OR_X_AND[@]}]="and"
				shift
				if [[ "$1" =~ "|" ]]
				then
					[ -z $DO_LIBRARIFY ] && \
						printf "This argument can't have a pipe character (|)."
					$__EXIT__ 1
				fi
				[ -z "$CLAUSE" ] && CLAUSE="$1" || CLAUSE="$CLAUSE|$1"
			;;
	
			-r|--remove|--delete)
				DO_SEND_QUERY=true
				DO_REMOVE=true
			;;
	
			-dt|--datatypes)
				DO_GET_DATATYPES=true
			;;
	
			-d|--database)
				shift
				DB="$1"
			;;
	
			--id)
				DO_SEND_QUERY=true
				DO_ID=true
				OR_X_AND[${#OR_X_AND[@]}]="and"
				shift
				if [[ "$1" =~ "|" ]]
				then
					[ -z $DO_LIBRARIFY ] && \
						printf "This argument can't have a pipe character (|)."
					$__EXIT__ 1
				fi
				[ -z "$CLAUSE" ] && CLAUSE="$1" || CLAUSE="$CLAUSE|$1"
			;;
	
			--set-id)
				shift
				ID_IDENTIFIER="$1"
			;;
	
			-v|--verbose)
				VERBOSE=true
				;;
	
			--tables)
				DO_SHOW_TABLES=true
			;;
	
			--vardump)
				DO_VARDUMP=true
				shift
				QUERY_ARG="$1"
			;;
	
			# I figured out how to do this...
			--install|--librarify|--libname|--verbose|--help)
				if [ -z $DO_LIBRARIFY ]
				then
					case "$1" in
					--install)
							DO_INSTALL=true
							shift
							INSTALL_DIR=$1
						;;
	
					--librarify)
							CREATE_LIB=true
						;;
	
					-l|--libname)
							CREATE_LIB=true
							shift
							LIB_CRNAME="$1"		
						;;
	
	
					-h|--help)
						$__EXIT__ 0
						;;
					esac
				else
					break
				fi
			;;
	
			--) break;;
	
			-*)
			printf "Unknown argument received.\n";
			$__EXIT__ 1
			;;
	
			*) break;;
		esac
		shift
	done
	
	
	# Set table properly.
	[ ! -z "$TABLE" ] && __TABLE="$TABLE"
	
	
	# get a column listing 
	if [ ! -z $DO_GET_COLUMNS ]
	then
		[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
	
		# Anywhere a __TABLE is present, check the first chars and make
		# sure they're not flags.
		get_columns
	fi
	
	
	# get a datatype listing 
	if [ ! -z $DO_GET_COLUMN_TYPES ]
	then
		[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
		$SQLITE $DB ".schema ${__TABLE}"
	fi
	
	
	# Install
	if [ ! -z $DO_INSTALL ] 
	then
		if [ -f "$INSTALL_DIR/$(basename ${SELF%%.sh})" ] 
		then
			echo "$PROGRAM already is installed at $INSTALL_DIR"
			$__EXIT__ 1
		fi
		[ -d "$INSTALL_DIR" ] && ln -s "$SELF" "$INSTALL_DIR/$(basename ${SELF%%.sh})"
	fi
	
	
	# spit out a library of this with needed functionality. 
	if [ ! -z $CREATE_LIB ] 
	then
		# Find first instance of x 
		# If nothing else is excluded, then just '# CREATE_LIB'
		[ -z "$LIB_CRNAME" ] && LIB_CRNAME="db_minishell"
	
		# Generate a license.
		sed -n 2,30p $SELF 
	
		# Basic libstuff.
		printf "${LIB_CRNAME}() {\n"
		printf "\tDO_LIBRARIFY=true\n"
	
		# Let's give some options to make certain things simpler.
		# Like if we're just using one database.
	
		# Or if we plan to only use one table.
	
		# The term will change, but libraries and functions can be incldued
		# on the fly with this.
	
		# Beginning of our range.
		CAT_START=$(( $(grep --line-number '# CREATE_LIB' $SELF | \
			head -n 1 | \
			awk -F ':' '{print $1}') + 1 ))
	
		# End of our range.
		CAT_END=$(wc -l $SELF | awk '{print $1}')
	
		# Output the document.
		sed -n ${CAT_START},${CAT_END}p $SELF | sed 's/^/\t/' 
	
		# Wrap last statement.
		printf "\n}\n"
	fi
	
	# ...
	if [ ! -z $DO_SHOW_TABLES ]
	then
		$SQLITE $DB '.tables'
	fi
	
	# ...
	if [ ! -z $DO_GET_DATATYPES ]
	then
		get_datatypes
	fi
	
	# test 
	if [ ! -z $DO_VARDUMP ]
	then
		#$SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
		#$SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
		load_from_db_columns "$QUERY_ARG"
	fi
	
	# Send a query onto the db.
	if [ ! -z $DO_SEND_QUERY ]
	then
		# Make sure that we've actually asked for a clause.
		if [ -z "$DB" ] || [ -z "$__TABLE" ] 
		then
			if [ -z $DO_LIBRARIFY ] 
			then
				[ ! -z $DO_SELECT ] && [ -z "$SELECT" ] && NO_STMT_SPECIFIED="SELECT" 
				[ ! -z $DO_REMOVE ] && [ -z "$CLAUSE" ] && NO_STMT_SPECIFIED="DELETE FROM" 
				[ ! -z $DO_ID ] && [ -z "$CLAUSE" ] && NO_STMT_SPECIFIED="SELECT" 
				[ ! -z $DO_WRITE ] && NO_STMT_SPECIFIED="INSERT INTO" 
				[ ! -z $DO_UPDATE ] && [ -z "$SET" ] && NO_STMT_SPECIFIED="UPDATE" 
				printf "Either no database, no table or no columns specified in the ${NO_STMT_SPECIFIED} statement.\n"
				$__EXIT__ 1
			else
				# No messages need to print.
				$__EXIT__ 1
			fi
		fi
	
		# 1. pull vars from current env (in shell script)
		# e.g. RAM = ram, and reorganize so that query writes correctly...
		# 2. pull vars from command line (with key=value pairs)
		# ram=$RAM 
		if [ ! -z $DO_WRITE ]
		then
			# Write from global variables mapped to column names.
			# Probably the preffered method.
			if [ ! -z $DO_WRITE_FROM_MEM ]
			then
				# I'm converting from variables to column names here.
				__INSTR__=
				for col_name in $(get_columns) 
				do
					# Skip IDs, id,uid?
					if [[ "$col_name" == "id" ]] || \
						[[ "$col_name" == "uid" ]] || \
						[[ "$col_name" == "ID" ]] || \
						[[ "$col_name" == "UID" ]]
					then 
						__INSTR__="null"
						continue
					fi
	
	
					# If any of these are null, we should probably stop.
					# Or at least come up with a way to specify what
					# does not need a record.
	
					# Get the var's value.
					#__VARVAL__="\$$(echo ${col_name} | tr '[a-z]' '[A-Z]')"
					__VARVAL__="\$(convert \"\$$(echo ${col_name}\" | \
						tr '[a-z]' '[A-Z]'))"
	
					# Create a INSERT string.
					if [ -z "$__INSTR__" ]
					then 
						__INSTR__="$__VARVAL__" 
						continue 
					fi
	
					# Append to an INSERT string.
					__INSTR__="$__INSTR__, $__VARVAL__" 
				done
			
				echo "$SQLITE $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				eval "echo \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				eval "$SQLITE $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				# Should probably be careful here.  
				# Mostly just path stuff to worry about.
	#				eval "$SQLITE $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
	
			# Allow the ability to craft a more standard INSERT own.
			else
				# We break only by a comma, but we need to make 
				# sure that said comma isn't within a text string. 
	#			unset __CHAR__
	#			__CHARCOUNT__=0
	#			declare -a __CHARPOS__
	#			__CHARPOS__[0]=0
	#				
	#			# Debug
	#			echo Length of \$WRITE: ${#WRITE}
	#
	#			# Move through the entire string.
	#			for __CHAR__ in `seq 0 "${#WRITE}"`
	#			do
	#				# Extract one character at a time.
	#				# I'm thinking I need a string find library.
	#				CHAR_1=${WRITE:$__CHARCOUNT__:1}
	#				CHAR_C=${#__CHARPOS__[@]}
	#
	#				# Get that character. 
	#				if [[ $CHAR_1 == "'" ]] || [[ $CHAR_1 == '"' ]] 
	#				then
	#					echo Quote found: $CHAR_1
	#					__CHARCOUNT__=$(( $__CHARCOUNT__ + 1 ))
	#					
	#					# Skip until we reach the end of the text delimiter.
	#					__STRENC__="$CHAR_1"
	#					while [[ ! ${WRITE:$__CHARCOUNT__:1} == $__STRENC__ ]]
	#					do
	#						__CHARCOUNT__=$(( $__CHARCOUNT__ + 1 ))
	#					done
	#			
	#					# Do yet another increment.
	#					# unset __STRENC__
	#				fi
	#
	#				# Save the comma.	
	#				if [[ $CHAR_1 == ',' ]] 
	#				then 
	#					echo $CHAR_C 
	#					__CHARPOS__[$CHAR_C]=$__CHARCOUNT__ 
	#					echo $__CHARCOUNT__
	#				fi
	#				__CHARCOUNT__=$(( $__CHARCOUNT__ + 1 ))
	#			done
	
				# Debug
				# echo At pos: ${WRITE:35:1}
				# echo ${#__CHARPOS__}
	
				# Gonna need some pretty serious recursion.
				# Check string first for "'" or '"'
				#		If found, then check for the next one, and after a match find the next ','
				# Check string for ","
				# Writing this recursively would involve knowing where the string is...
	
				# Just taking a command line dump here.
				echo $SQLITE $DB "INSERT INTO ${__TABLE} VALUES ( $WRITE )"
			fi
		fi
	
		# By this point, this program needs to check for and craft a clause.
		[ ! -z "$CLAUSE" ] || [ ! -z "$__BETWEEN" ] && assemble_clause
	
		# select
		if [ ! -z $DO_SELECT ]
		then
			case "$SERIALIZATION_TYPE" in
				line) SR_TYPE="-line" ;;
				html) SR_TYPE="-html" ;;
				list) SR_TYPE="-list" ;;
				*) SR_TYPE="-list" ;;
			esac
	
			# Headers?
			# Select all the records asked for.
	
			# From this function, if I want "prefilled" values,
			# then I'll have to work at it.
			$SQLITE $DB $SR_TYPE "SELECT $SELECT FROM ${__TABLE}${STMT}"
	
			# This is the only place where serialization is even an intelligent choice.
		fi
	
		# select only id
		if [ ! -z $DO_ID ]
		then
			# Select all the records asked for.
			$SQLITE $DB "SELECT ${ID_IDENTIFIER:-id} FROM ${__TABLE}${STMT}"
		fi
	
		# update
		if [ ! -z $DO_UPDATE ]
		then
			# Compound your SET statements, same rules apply as in regular statment
			assemble_set
			$SQLITE $DB "UPDATE ${__TABLE} SET ${ST_TM}${STMT}"
		fi
	
	
		# remove
		if [ ! -z $DO_REMOVE ]
		then
			#$SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
			$SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
		fi
	
	fi # END [ DO_SEND_QUERY ]

}
