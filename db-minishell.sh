#!/bin/bash -xv
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


# Die if no arguments received.
[ -z $BASH_ARGV ] && printf "Nothing to do\n" && usage 1


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
		[ -z $DO_LIBRARIFY ] && echo "Either no table or no columns specified in the SELECT statement." && usage 1
		exit 1
	fi

	# Terms
	# =: Equal 
	# >: Greater Than
	# <: Less Than
	# ~: LIKE
	# !=: NOT
	# !~: NOT LIKE
	__TERMS__=( '=' '!=' '!~' '>' '<' '~' )


	# description
	# srv_path
	# id
	# instance


	# Use a '|' to mark the arguments.
#	echo Bash length: ${#CLAUSE}
#	echo Actual length: 
#	echo -n "${CLAUSE}" | wc -c 
	declare -a __CHOP_CLAUSE__
	__CHOP_CLAUSE__[0]=0	 			# Always save the first position.

	# If it's one term, we can speed it up by just running a check for the |
	if [[ "$CLAUSE" =~ '|' ]]
	then
		for __C__ in $(seq 0 "${#CLAUSE}")
		do
			[[ ${CLAUSE:$__C__:1} == "|" ]] && \
				__CHOP_CLAUSE__[${#__CHOP_CLAUSE__[@]}]=$__C__ 
		done
	fi
	__CHOP_CLAUSE__[${#__CHOP_CLAUSE__[@]}]=${#CLAUSE}


	# Create a clause.
	CC_COUNT=1
	for __DD__ in ${__CHOP_CLAUSE__[@]}
	do
		# Break if we've reached the end.
		[ $__DD__ == ${#CLAUSE} ] && break

		# Get more creative...
		if [ ! $__DD__ == 0 ] 
		then
			# Define a term.
			#echo ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ 
			__DD__=$(( $__DD__ + 1 )) # Cut the char.
			__EE__=$(( ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ ))
			WHERE_TERM=${CLAUSE:$__DD__:$__EE__}
		else
			#echo ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ 
			__EE__=$(( ${__CHOP_CLAUSE__[$CC_COUNT]} - $__DD__ ))
			WHERE_TERM=${CLAUSE:$__DD__:$__EE__}
		fi
	
		# Incremenet again.
		# echo Clause: $WHERE_TERM
		CC_COUNT=$(( $CC_COUNT + 1 ))

		# Get rid of backslashes.
		[[ "$WHERE_TERM" =~ '\' ]] && \
			WHERE_TERM="$(echo "$WHERE_TERM" | sed 's/\\//')"

		# Find the first non-alpha character in the string 
		# Must localize every string.
		# echo Clause length: ${#WHERE_TERM}
		# echo Clause: $WHERE_TERM
		for __CHAR__ in `seq 0 ${#WHERE_TERM}`
		do
			# Characters.
			CHAR_1=${WHERE_TERM:$__CHAR__:1}
			
			# Loop through each and find the term.
			if [[ ${CHAR_1} == '=' ]] || \
				[[ ${CHAR_1} == '!' ]] || \
				[[ ${CHAR_1} == '~' ]] || \
				[[ ${CHAR_1} == '>' ]] || \
				[[ ${CHAR_1} == '<' ]]
			then
				# Smack.
				CHAR_2=${WHERE_TERM:$(( $__CHAR__ + 1 )):1}

				# Get the next character if match was !
				# If not move on.
				if [[ ${CHAR_1} == '!' ]] && \
					( [[ ${CHAR_2} == '~' ]] || [[ ${CHAR_2} == '=' ]] )
				then
					FIRST_TERM="${CHAR_1}${CHAR_2}"
					__KEY__=${WHERE_TERM:0:$(( $__CHAR__ + 1 ))}
					__VALUE__=${WHERE_TERM:$(( $__CHAR__ + 2 )):${#WHERE_TERM}}
					break
				else	
					FIRST_TERM=$CHAR_1
					__KEY__=${WHERE_TERM:0:$(( $__CHAR__ + 1 ))}
					__VALUE__=${WHERE_TERM:$(( $__CHAR__ + 1 )):${#WHERE_TERM}}
					break
				fi
			fi

			# I think you need to break if your term is not found.
		done
echo $__KEY__
echo $__VALUE__

		# Catch the end of the term (because we'll have to convert it).

		# Need to find the first match of each of the above and evaluate that way.
		case "$FIRST_TERM" in
			'=') 	__KEY__="$(printf "$__KEY__" | sed 's/=/ = /')";; 
			'>') 	__KEY__="$(printf "$__KEY__" | sed 's/>/ > /')";;
			'<')  __KEY__="$(printf "$__KEY__" | sed 's/</ < /')";;
			'~')  __KEY__="$(printf "$__KEY__" | sed 's/~/ LIKE /')";;
			'!=') __KEY__="$(printf "NOT $__KEY__" | sed 's/!=/ = /')";;
			'!~') __KEY__="$(printf "NOT $__KEY__" | sed 's/!~/ LIKE /')";;
		esac

echo $__KEY__ $__VALUE__
continue
		# Encapsulate strings.
		# convert() should do it.

		# Build/append to the clause.
		[ -z "$CLAUSE" ] && CLAUSE="$(echo "$WHERE_TERM" sed 's/=/ = /')"
		[ ! -z "$CLAUSE" ] && CLAUSE="$CLAUSE AND $(echo "$WHERE_TERM" sed 's/=/ = /')" 
	done 

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
