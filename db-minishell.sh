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

# usage() - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-s | --select <arg>           desc
-f | --from <arg>             desc
-t | --to <arg>               desc
-w | --write <arg>            desc
-u | --update <arg>           desc
-t | --this <arg>             desc
-t | --that <arg>             desc
-w | --where <arg>            desc
-r | --remove                 desc
-x | --id <arg>               desc
-d | --database <arg>         desc
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
FIRST_TERM=
__KEY__=
__VALUE__=
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

		# Evaluate the clause type.
#		case "$FIRST_TERM" in
#			'=') 	__KEY__="$(printf "$__KEY__" | sed 's/=/ = /')";; 
#			'>') 	__KEY__="$(printf "$__KEY__" | sed 's/>/ > /')";;
#			'<')  __KEY__="$(printf "$__KEY__" | sed 's/</ < /')";;
#			'~')  __KEY__="$(printf "$__KEY__" | sed 's/~/ LIKE /')";;
#			'!=') __KEY__="$(printf "NOT $__KEY__" | sed 's/!=/ = /')";;
#			'!~') __KEY__="$(printf "NOT $__KEY__" | sed 's/!~/ LIKE /')";;
#		esac
	done
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
     -s|--select)
         DO_SELECT=true
         shift
         SELECT="$1"
      ;;
     -f|--from)
         DO_FROM=true
         shift
         __TABLE="$1"
      ;;
     -t|--to)
         DO_TO=true
         shift
         TO="$1"
      ;;
     -i|--write)
         DO_WRITE=true
         shift
         WRITE="$1"
      ;;
     -u|--update)
         DO_UPDATE=true
         shift
         UPDATE="$1"
      ;;
     --this)
         DO_THIS=true
         shift
         THIS="$1"
      ;;
     --that)
         DO_THAT=true
         shift
         THAT="$1"
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
     #    CLAUSE[${#CLAUSE[@]}]="$1"
      ;;
     -r|--remove)
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


# select
if [ ! -z $DO_SELECT ]
then
	# Make sure that we've actually asked for a clause.
	if [ -z "$__TABLE" ] || [ -z "$SELECT" ] 
	then
		if [ -z $DO_LIBRARIFY ] 
		then 
			printf "Either no table or no columns "
			printf "specified in the SELECT statement.\n" 
			usage 1
		fi
	fi

	# Buffer for our final STMT
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


		# Iterate through each of the terms.
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
		
			# Incremenet again.
			# echo Clause: $WHERE_TERM
			CC_COUNT=$(( $CC_COUNT + 1 ))

			# Get rid of backslashes.
#			[[ "$WHERE_TERM" =~ '\' ]] && \
#				WHERE_TERM="$(echo "$WHERE_TERM" | sed 's/\\//')"

	# done (This code looks like it's done its job.

			# Find the first non-alpha character in the string 
			# Must localize every string.
			# echo Clause length: ${#WHERE_TERM}
			# echo Clause: $WHERE_TERM
#			for __CHAR__ in `seq 0 ${#WHERE_TERM}`
#			do
#				# Characters.
#				CHAR_1=${WHERE_TERM:$__CHAR__:1}
#				
#				# Loop through each and find the term.
#				if [[ ${CHAR_1} == '=' ]] || \
#					[[ ${CHAR_1} == '!' ]] || \
#					[[ ${CHAR_1} == '~' ]] || \
#					[[ ${CHAR_1} == '>' ]] || \
#					[[ ${CHAR_1} == '<' ]]
#				then
#					# Smack.
#					CHAR_2=${WHERE_TERM:$(( $__CHAR__ + 1 )):1}
#
#					# Get the next character if match was !
#					# If not move on.
#					if [[ ${CHAR_1} == '!' ]] && \
#						( [[ ${CHAR_2} == '~' ]] || [[ ${CHAR_2} == '=' ]] )
#					then
#						FIRST_TERM="${CHAR_1}${CHAR_2}"
#						__KEY__=${WHERE_TERM:0:$(( $__CHAR__ + 1 ))}
#						__VALUE__=${WHERE_TERM:$(( $__CHAR__ + 2 )):${#WHERE_TERM}}
#						break
#					else	
#						FIRST_TERM=$CHAR_1
#						__KEY__=${WHERE_TERM:0:$(( $__CHAR__ + 1 ))}
#						__VALUE__=${WHERE_TERM:$(( $__CHAR__ + 1 )):${#WHERE_TERM}}
#						break
#					fi
#				fi
#			done

			# Chop up this particular part of the clause.
			#case "$(chop_by_position "$WHERE_TERM")" in
			chop_by_position "$WHERE_TERM"
			case "$FIRST_TERM" in
				'=') 	__KEY__="$(printf "$__KEY__" | sed 's/=/ = /')";; 
				'>') 	__KEY__="$(printf "$__KEY__" | sed 's/>/ > /')";;
				'<')  __KEY__="$(printf "$__KEY__" | sed 's/</ < /')";;
				'~')  __KEY__="$(printf "$__KEY__" | sed 's/~/ LIKE /')";;
				'!=') __KEY__="$(printf "NOT $__KEY__" | sed 's/!=/ = /')";;
				'!~') __KEY__="$(printf "NOT $__KEY__" | sed 's/!~/ LIKE /')";;
			esac

			# Build/append to the clause.
			[ -z "$STMT" ] && \
				STMT="WHERE $__KEY__ $(convert "$__VALUE__")" || \
				STMT="$STMT AND $__KEY__ $(convert "$__VALUE__")" 
		done 

	# Process one clause 
	else
		# ....
		chop_by_position "$WHERE_TERM"
		case "$FIRST_TERM" in
			'=') 	__KEY__="$(printf "$__KEY__" | sed 's/=/ = /')";; 
			'>') 	__KEY__="$(printf "$__KEY__" | sed 's/>/ > /')";;
			'<')  __KEY__="$(printf "$__KEY__" | sed 's/</ < /')";;
			'~')  __KEY__="$(printf "$__KEY__" | sed 's/~/ LIKE /')";;
			'!=') __KEY__="$(printf "NOT $__KEY__" | sed 's/!=/ = /')";;
			'!~') __KEY__="$(printf "NOT $__KEY__" | sed 's/!~/ LIKE /')";;
		esac

		# Build/append to the clause.
		STMT="$(echo "$WHERE_TERM" $__KEY__ $(convert "$__VALUE__"))" 
	fi # [[ $CLAUSE =~ '|' ]]

	echo $STMT
	exit
	# Consider writing something to prepare the clause (begin with space, then WHERE, and end with ';')

	# Select all the records asked for.
  # $SQLITE $DB "SELECT $SELECT FROM ${__TABLE}"
fi


# write
if [ ! -z $DO_WRITE ]
then
   echo '...'
fi


# update
if [ ! -z $DO_UPDATE ]
then
   echo '...'
fi


# remove
if [ ! -z $DO_REMOVE ]
then
   echo '...'
fi


# spit out a library of this with needed functionality. 
if [ ! -z $DO_LIBRARIFY ]
then
   echo '...'
fi
