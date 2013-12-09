#-----------------------------------------------------#
# db-minishell
#
# Manages simple SQL queries via Bash.
#-----------------------------------------------------#
#-----------------------------------------------------#
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
my_namespace() {
	# Enable library.
	DO_LIBRARIFY=true

	#-----------------------------------------------------#
	# break_list_by_delim
	#
	# Creates an array based on a string containing delimiters.
	#-----------------------------------------------------#
	break_list_by_delim() {
		mylist=(`printf $1 | sed "s/${DELIM}/ /g"`)
		echo ${mylist[@]}		# Return the list all ghetto-style.
	}
	
	#-----------------------------------------------------#
	# break_maps_by_delim
	#
	# Creates a key to value pair based on a string containing delimiters.
	#-----------------------------------------------------#
	break_maps_by_delim() {
		join="${2-=}"			# Allow for an alternate map marker.
		local m=(`printf $1 | sed "s/${join}/ /g"`)
		echo ${m[@]}			# Return the list all ghetto-style.
	}
	
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
		
	
		# ... ORDER BY
		[ ! -z "$__ORDER_BY" ] && {
			# Include __ORDER_ORDER
			[ -z "$STMT" ] && STMT="ORDER BY $__ORDER_BY ${__ORDER_AD:-"desc"}" || STMT=" ${STMT} ORDER BY $__ORDER_BY ${__ORDER_AD:-"desc"}"
		}	
	
		# ... HAVING
		[ ! -z "$__HAVING" ] && {
			[ -z "$STMT" ] && STMT="HAVING $__ORDER_BY" || STMT=" ${STMT} HAVING $__ORDER_BY"
		}	
	
		# ... GROUP BY
		[ ! -z "$__GROUP_BY" ] && {
			[ -z "$STMT" ] && STMT="GROUP BY $__ORDER_BY" || STMT=" ${STMT} GROUP BY $__GROUP_BY"
		}	
	
		# LIMIT  
		[ ! -z "$__LIM" ] && {
			[ -z "$STMT" ] && STMT="LIMIT $__LIM" || STMT=" ${STMT} LIMIT $__LIM"
	
			# Include any offset.
			[ ! -z "$__OFFSET" ] && STMT=" ${STMT} OFFSET $__OFFSET"
		}
		
		# Prepare the clause (begin with space, then WHERE, and end with ';')
		[ -z "$STMT" ] && STMT=';' || STMT=" ${STMT};"
	
		# Clause
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
			MEGA_COLUMNS=( $(parse_schemata --of $__TABLE --columns) )
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
	# parse_schemata()
	#
	# Get the columns of a table.
	#-----------------------------------------------------#
	parse_schemata(){
		# Saving this is possible, but a lot of work.
		unset __RESULTBUF__
	
		# Options
		while [ $# -gt 0 ]
		do
			case "$1" in
				# Retrieve schemata in formatted order for quicker development.
				-f|--formattted)
					__RESULT_GET_FMT__=true
				;;
	
				# Retrieve datatypes only.
				-d|--datatypes)
					__RESULT_GET_DT__=true
				;;
	
				# Retrieve columns only.
				-c|--columns)
					__RESULT_GET_CS__=true
				;;
	
				# Choose a table.
				-o|--of)
					shift
					__RESULT_TBL__="$1"
				;;
			esac
			shift
		done
	
		# Buffer
		__SCHBUF__="$( $__SQLITE__ $DB ".schema ${__RESULT_TBL__}")"
	
		# Die if no table was supplied.
		[ -z "$__RESULT_TBL__" ] && {
			printf "No table supplied to function: parse_schemata().\n" > /dev/stderr
			# exit is not suitable here.
			# http://www.linuxjournal.com/content/return-values-bash-functions	
		}
	
		# Die if nothing is there...
		if [ -z "$__SCHBUF__" ] 
		then
			printf "No schemata found within [ $DB ].\n" > /dev/stderr	
	
		# Only move forward if something exists.
		elif [ $(printf "%s" "$__SCHBUF__" | wc -l) -gt 1 ]
		then
			# Could have an issue with `awk` on other systems.
			# Just grab the column names.
			__COLBUF__="$(printf '%s' "$__SCHBUF__" | \
				sed 's/\t//g' | \
				sed 's/\r//g' | \
				awk '{ print $1 }' | \
				grep -v "CREATE" | \
				sed 's/);//g' )"
	
			# Get columns. 
			[ ! -z $__RESULT_GET_CS__ ] && {
				# Alterante return - no for...
				printf "%s\n" "$__COLBUF__"
			}
	
			# Get datatypes.
			[ ! -z $__RESULT_GET_DT__ ] && {
				# Get the datatypes
				__DTBUF__="$(printf '%s' "$__SCHBUF__" | \
					sed 's/\t//g' | \
					sed 's/\r//g' | \
					awk '{ print $2 }' | \
					grep -v "TABLE" | \
					sed 's/,//g' | \
					sed 's/);//g' )"
	
				# Should check both __DTBUF__ and __COLBUF__ to make
				# sure they've got the same number of elements.
	
				# Save both into arrays.
				declare -a __DTARR__
				declare -a __COLARR__
				__DTARR__=( $( printf "%s " $__DTBUF__ ) )
				__COLARR__=( $( printf "%s " $__COLBUF__ ) )
				[ ${#__DTARR__[@]} -ne ${#__COLARR__[@]} ] && {
					printf "Problem encountered when parsing datatypes or column names.\n" > /dev/stderr
					# return?	
				}
	
				# Return some giant block and parse from your client.
				# printf "%s" "$__DTBUF__"
	
				for bbx in `seq 0 $(( ${#__DTARR__[@]} - 1 ))`
				do
					printf "%s\n" "${__COLARR__[$bbx]} = ${__DTARR__[$bbx]}"
				done
			}
	
		# Cannot support SQLite databases created with one line yet.
		else	
			printf "" > /dev/null
		fi
	
		# Free
		unset __DTARR__
		unset __COLARR__
		unset __DTBUF__
		unset __COLBUF__
	
		unset __RESULT_GET_FMT__
		unset __RESULT_GET_DT__
		unset __RESULT_GET_CS__
		unset __RESULT_TBL__
	}
	
	
	# Die if no arguments received.
	if [ -z $DO_LIBRARIFY ]
	then
		# Define proper exit command.
		__EXIT__="usage"
	
		# This will kill ksh
		[ -z "$BASH_ARGV" ] && {
			printf "Nothing to do\n" 
			$__EXIT__ 1
		}
	
	else
		# Define proper exit command.
		__EXIT__="exit"
	
		# Exit if no args given to library.
		[ $# -le 0 ] && $__EXIT__ 1	
	
		# If SQLite has not previously been defined, define it.
		[ -z "$__SQLITE__" ] && __SQLITE__="$(which sqlite3 2>/dev/null)" 
	
		# Use something as a log file.
		LOGFILE="/dev/stderr"
	fi
	
	# Arrays
	declare -a WHERE_CLAUSE 
	declare -a NOT_CLAUSE 
	declare -a OR_X_AND			# Is it an OR or AND clause?
	# Process options.
	while [ $# -gt 0 ]
	do
		case "$1" in
			-d|--database)
				shift
				DB="$1"
			;;
	
			-c|--columns)
				DO_GET_COLUMNS=true
			;;
	
			-dt|--datatypes)
				DO_GET_DATATYPES=true
			;;
	
			--tables)
				DO_SHOW_TABLES=true
			;;
			
			--tables-and-columns)
				DO_SHOW_TABLES_AND_COLUMNS=true
			;;
	
			--of)
				shift
				__TABLE="$1"
			;;
			# [ ADMIN ] END
			-s|--select)
				DO_SEND_QUERY=true
				DO_SELECT=true
				shift
				SELECT="$1"
			;;
	
			--select-all)
				DO_SEND_QUERY=true
				DO_SELECT=true
				SELECT="*"
			;;
	
			--distinct)
				DO_SEND_QUERY=true
				DO_DISTINCT=true
				DO_SELECT=true
				shift
				SELECT="$1"
			;;
	
			--limit)
				DO_SEND_QUERY=true
				shift
				__LIM="$1"
			;;
			--having)
				DO_SEND_QUERY=true
				shift
				__HAVING="$1"
			;;
	
			--offset)
				DO_SEND_QUERY=true
				shift
				__OFFSET="$1"
			;;
	
			--order-by)
				DO_SEND_QUERY=true
				shift
				__ORDER_BY="$1"
				
				# Is next argument a flag or an order modifier.
				[ ! -z "$2" ] && [[ ! "$2" =~ "-" ]] && {
					shift
					__ORDER_AD="$1"	# ASC or DESCENDING
				}
			;;
	
			--group-by)
				DO_SEND_QUERY=true
				shift
				__GROUP_BY="$1"
			;;
	
			-f|--from)
				DO_FROM=true
				shift
				__TABLE="$1"
			;;
	
			-i|--insert)
				DO_SEND_QUERY=true
				DO_WRITE=true
				shift
				WRITE="$1"
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
	
			-r|--remove)
				DO_SEND_QUERY=true
				DO_REMOVE=true
			;;
	
			-b|--between)
				shift
				__BETWEEN="$1"
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
	
			-sa|--show-as)
				shift
				SERIALIZATION_TYPE="$1"
			;;
			# [ ORM ] END
			-z|--id)
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
	
			--vardump)
				DO_VARDUMP=true
				shift
				QUERY_ARG="$1"
			;;
			# [ EXTENSIONS ] END
	
			--) break;;
	
			-*)
				printf "Unknown argument received.\n";
				$__EXIT__ 1
			;;
	
			*) break;;
		esac
		shift
	done
	# [ CODE ]
	# Set table properly.
	[ ! -z "$TABLE" ] && __TABLE="$TABLE"
	
	
	
	# get a column listing 
	[ ! -z $DO_GET_COLUMNS ] && {
		[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
	
		# Anywhere a __TABLE is present, check the first chars and make
		# sure they're not flags.
		parse_schemata --of $__TABLE --columns	
	}
	
	
	# get a datatype listing 
	if [ ! -z $DO_GET_DATATYPES ]
	then
		[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
		#$__SQLITE__ $DB ".schema ${__TABLE}"
		parse_schemata --of $__TABLE --datatypes
	fi
	
	
	# Retrieve tables. 
	[ ! -z $DO_SHOW_TABLES ] && $__SQLITE__ $DB '.tables'
	
	
	# Retrieve tables and columns...
	[ ! -z $DO_SHOW_TABLES_AND_COLUMNS ] && {
		for __XX__ in $($__SQLITE__ $DB '.tables')
		do
			printf "%s\n" $__XX__
			printf "%s" $__XX__ | tr '[a-z]' '=' | sed 's/$/\n/'
			parse_schemata --of $__XX__ --columns
		done
	}
	# [ ADMIN ] END
	# test 
	[ ! -z $DO_VARDUMP ]	&& load_from_db_columns "$QUERY_ARG"
	# [ EXTENSIONS ] END
	# Send a query onto the db.
	if [ ! -z $DO_SEND_QUERY ]
	then
		# Make sure that we've actually asked for a clause.
		if [ -z "$DB" ] || [ -z "$__TABLE" ] 
		then
			if [ -z $DO_LIBRARIFY ] 
			then
				[ ! -z $DO_SELECT ] && [ -z "$SELECT" ] && {
					NO_STMT_SPECIFIED="SELECT" 
				}
				[ ! -z $DO_REMOVE ] && [ -z "$CLAUSE" ] && {
					NO_STMT_SPECIFIED="DELETE FROM" 
				}
				[ ! -z $DO_ID ] && [ -z "$CLAUSE" ] && {
					NO_STMT_SPECIFIED="SELECT" 
				}
				[ ! -z $DO_WRITE ] && NO_STMT_SPECIFIED="INSERT INTO" 
				[ ! -z $DO_UPDATE ] && [ -z "$SET" ] && {
					NO_STMT_SPECIFIED="UPDATE" 
				}
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
		# Give an error on columns that can't be empty.
		if [ ! -z $DO_WRITE ]
		then
			# Write from global variables mapped to column names.
			# Probably the preffered method.
			if [ ! -z $DO_WRITE_FROM_MEM ]
			then
				# I'm converting from variables to column names here.
				__INSTR__=
				for col_name in $(parse_schemata --of $__TABLE --columns) 
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
		
				# Debugger output if requested.
				[ ! -z $ECHO_BACK ] && {
					printf "%s" "$__SQLITE__ $DB "
					printf "%s" "\"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				}
	
				eval "echo \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				eval "$__SQLITE__ $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
				# Should probably be careful here.  
				# Mostly just path stuff to worry about.
	#				eval "$__SQLITE__ $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""
	
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
				echo $__SQLITE__ $DB "INSERT INTO ${__TABLE} VALUES ( $WRITE )"
			fi
		fi
	
		# By this point, this program needs to check for and craft a clause.
		[ ! -z "$CLAUSE" ] || \
			[ ! -z "$__BETWEEN" ] || \
			[ ! -z "$__LIM" ] || \
			[ ! -z "$__HAVING" ] || \
			[ ! -z "$__OFFSET" ] || \
			[ ! -z "$__ORDER_BY" ] || \
			[ ! -z "$__GROUP_BY" ] && assemble_clause
	
		# select
		[ ! -z $DO_SELECT ] && {
			# Evaluate for a serialization type.
			[ ! -z "$SERIALIZATION_TYPE" ] && {
				case "$SERIALIZATION_TYPE" in
					line) SR_TYPE="-line" ;;
					html) SR_TYPE="-html" ;;
					list) SR_TYPE="-list" ;;
					*) SR_TYPE="-list" ;;
				esac
			}
	
			# Any modifiers? 
			[ ! -z $DO_DISTINCT ] && SELECT_DISTINCT="SELECT DISTINCT"
	
			# Debugging output.
			[ ! -z $ECHO_BACK ] && {
				printf "%s" "$__SQLITE__ $DB $SR_TYPE" 
				printf "%s" "'${SELECT_DISTINCT:-SELECT} $SELECT FROM ${__TABLE}${STMT}'"
				printf "\n"
			}
	
			# Select all the records asked for.
			$__SQLITE__ $DB \
				$SR_TYPE \
				"${SELECT_DISTINCT:-SELECT} $SELECT FROM ${__TABLE}${STMT}"
		}	
	
		# select only id
		# Select all the records asked for.
		[ ! -z $DO_ID ] && {
			$__SQLITE__ $DB "SELECT ${ID_IDENTIFIER:-id} FROM ${__TABLE}${STMT}"
		}
		
		# update
		[ ! -z $DO_UPDATE ] && {
			# Compound your SET statements, same rules apply as in regular statment
			assemble_set
			$__SQLITE__ $DB "UPDATE ${__TABLE} SET ${ST_TM}${STMT}"
		}	
	
		# remove
		[ ! -z $DO_REMOVE ] && $__SQLITE__ $DB "DELETE FROM ${__TABLE}${STMT}"
	fi 
	# [ ORM ] END

}
