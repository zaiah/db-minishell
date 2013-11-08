#!/bin/bash -
#-----------------------------------------------------#
# db-minishell
#
# Manages simple SQL queries via Bash.
#-----------------------------------------------------#
PROGRAM="db-minishell"

# References to $SELF
BINDIR="$(dirname "$(readlink -f $0)")"
SELF="$(readlink -f $0)"


# Other vars
FIRST_TERM=
__KEY__=
__VALUE__=
SQLITE="/usr/bin/sqlite3"


# usage() - Show usage message and die with $STATUS
# -y | --datatypes <arg>        List the column datatypes in a table <arg>. 
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -csfiuewrxzbdvh ]

-b | --between <arg>          Use the BETWEEN clause.
                              Format: <col>=<min>-<max>
-c | --columns <arg>          List the columns in a table <arg>. 
-s | --select <arg>           Select columns from a table. 
     --distinct <arg>         Select distinct rows from a table. 
     --limit <arg>            Limit result set.
     --offset <arg>           Use an offset when using the limit.
     --having <arg>           Having ?
     --order-by [asc|desc]    Order the rows.
-f | --from <arg>             If \$__TABLE not set, set this to choose a
                              table to use in a SELECT statement.
-i | --write <arg>            Commit records in <arg> to database. 
-u | --update <arg>           If \$__TABLE not set, set this to choose a
                              table to use in an UPDATE statement.
-e | --set <arg>              Set <column> = <value>
-w | --where <arg>            Supply a clause to tune result set. 
-r | --remove                 Remove entry or entries depending on clause. 
     --delete                 Synonym for --remove
-x | --remove-where <arg>     Remove entry or entries depending on <arg>.
     --delete-where <arg>     Allows specification of clause from here.
-z | --id <arg>               Affect an id or ids. 
-b | --between <arg>          Affect records between range.
-d | --database <arg>         Choose a database to work with. 
-v | --verbose                Be verbose in output.
-h | --help                   Show this help and quit.
"
   exit $STATUS
}


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
			[ -z "$STMT" ] && \
				STMT="WHERE $__KEY__ $(convert "$__VALUE__")" || \
				STMT="$STMT AND $__KEY__ $(convert "$__VALUE__")" 
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


#-----------------------------------------------------#
# die_on_char_recvd() 
#
# Die when a particular character is received.
#-----------------------------------------------------#
die_on_char_recvd() {
	if [ -z "$1" ] || [ -z "$2" ]
	then 
		echo "Characters not received.\nExiting." >> /dev/stderr
	fi

	if [[ "$1" =~ "$2" ]]
	then
		printf "This argument can't receive a '$2' character."
		exit 1
	fi 
}


# Die if no arguments received.
[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" && usage 1


# Array
declare -a WHERE_CLAUSE 
declare -a NOT_CLAUSE 


# Process options.
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
				printf "This argument can't have a pipe character (|)."
				usage 1
			fi
			[ -z "$SET" ] && SET="$1" || SET="$SET|$1"
      ;;

     -w|--where)
         DO_WHERE=true
         shift
			if [[ "$1" =~ "|" ]]
			then
				printf "This argument can't have a pipe character (|)."
				usage 1
			fi
			[ -z "$CLAUSE" ] && CLAUSE="$1" || CLAUSE="$CLAUSE|$1"
      ;;
     -r|--remove|--delete)
         DO_SEND_QUERY=true
         DO_REMOVE=true
      ;;
	  -d|--database)
			shift
			DB="$1"
		;;
     --id)
         DO_ID=true
         shift
         ID="$1"
      ;;
	  -l|--librarify)
			DO_LIBRARIFY=true
		;;
     -v|--verbose)
        VERBOSE=true
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


# get a column listing 
if [ ! -z $DO_GET_COLUMNS ]
then
	[ -z "${__TABLE}" ] && echo "No table to operate on!" && usage 1

	# Anywhere a __TABLE is present, check the first chars and make
	# sure they're not flags.
 	$SQLITE -header $DB "SELECT * FROM ${__TABLE} LIMIT 1" | \
		head -n 1 | \
		sed 's/|/ /g'	
fi


# get a datatype listing 
if [ ! -z $DO_GET_COLUMN_TYPES ]
then
	[ -z "${__TABLE}" ] && echo "No table to operate on!" && usage 1
 	$SQLITE $DB ".schema ${__TABLE}"
fi


# spit out a library of this with needed functionality. 
if [ ! -z $DO_LIBRARIFY ]
then
   echo '...'
fi


# Send a query onto the db.
if [ ! -z $DO_SEND_QUERY ]
then
	# Make sure that we've actually asked for a clause.
	if [ -z "$__TABLE" ] 
	then
		if [ -z $DO_LIBRARIFY ] 
		then
			[ ! -z $DO_SELECT ] && NO_STMT_SPECIFIED="SELECT" 
			[ ! -z $DO_DELETE ] && NO_STMT_SPECIFIED="DELETE FROM" 
			[ ! -z $DO_INSERT ] && NO_STMT_SPECIFIED="INSERT INTO" 
			[ ! -z $DO_UPDATE ] && NO_STMT_SPECIFIED="UPDATE" 
			printf "Either no table or no columns specified in the ${NO_STMT_SPECIFIED} statement.\n"
			usage 1
		fi
	fi

	# write
	if [ ! -z $DO_WRITE ]
	then
 		echo $SQLITE $DB "INSERT INTO ${__TABLE} VALUES (  )"
	fi

	# By this point, this program needs to check for and craft a clause.
	[ ! -z "$CLAUSE" ] || [ ! -z "$__BETWEEN" ] && assemble_clause

	# select
	if [ ! -z $DO_SELECT ]
	then
		# Handle LIMIT, ORDER BY

		# Select all the records asked for.
 		echo $SQLITE $DB "SELECT $SELECT FROM ${__TABLE}${STMT}"
	fi

	# update
	if [ ! -z $DO_UPDATE ]
	then
		# Compound your SET statements, same rules apply as in regular statment
		assemble_set
 		echo $SQLITE $DB "UPDATE ${__TABLE} SET ${ST_TM}${STMT}"
	fi


	# remove
	if [ ! -z $DO_REMOVE ]
	then
 		$SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
 		echo $SQLITE $DB "DELETE FROM ${__TABLE}${STMT}"
	fi
fi # END [ DO_SEND_QUERY ]
