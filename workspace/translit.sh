#!/bin/bash
#-----------------------------------------------------#
# translit
#
# Switch two files around. 
#-----------------------------------------------------#
#translit() {

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
		  }

	LIBPROGRAM="translit"
	
	# translit_usage - Show usage message and die with $STATUS
	translit_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-s | --suffix <arg>           Add a suffix.
	-p | --prefix <arg>           Add a prefix. 
	-f | --file                   Specify a file.
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}
	
	
	# Die if no arguments received.
	[ -z "$#" ] && printf "Nothing to do\n" > /dev/stderr && translit_usage 1

	# Catch only first two if asked.
	if [ -f "$1" ] && [ -f "$2" ] && \
		[[ ! "${1:0:2}" == '--' ]] && [[ ! "${2:0:2}" == '--' ]]
	then
		tmp_file -n COPY_1
		cat $1 > $COPY_1
		tmp_file -n COPY_2
		cat $2 > $COPY_2

		# Move.
		mv $COPY_1 $2
		mv $COPY_2 $1

		# 
		tmp_file -w

	# Process options and proceed another way...
	else	
		  while [ $# -gt 0 ]
		  do
			  case "$1" in
				 -a|--at)
				  ;;
				 -s|--suffix)
					  DO_SUFFIX=true
				  ;;
				 -p|--prefix)
					  DO_PREFIX=true
				  ;;
				 -f|--file)
					  DO_FILE=true
				  ;;
				 -v|--verbose)
				 VERBOSE=true
				  ;;
				 -h|--help)
					 translit_usage 0
				  ;;
				 --) break;;
				 -*)
				  printf "Unknown argument received: $1\n" > /dev/stderr;
				  translit_usage 1
				 ;;
				 *) break;;
			  esac
		  shift
		  done
		  
		  # suffix
		  [ ! -z $DO_SUFFIX ] && {
			  printf '' > /dev/null
		  }
		  
		  # prefix
		  [ ! -z $DO_PREFIX ] && {
			  printf '' > /dev/null
		  }
		  
		  # file
		  [ ! -z $DO_FILE ] && {
			  printf '' > /dev/null
		  }

	  # ...
	fi
#}
