#!/bin/bash -
#-----------------------------------------------------#
# db_minishell.sh 
#
# Manages simple SQL queries via Bash
#-----------------------------------------------------#

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
         FROM="$1"
      ;;
     -t|--to)
         DO_TO=true
         shift
         TO="$1"
      ;;
     -w|--write)
         DO_WRITE=true
         shift
         WRITE="$1"
      ;;
     -u|--update)
         DO_UPDATE=true
         shift
         UPDATE="$1"
      ;;
     -t|--this)
         DO_THIS=true
         shift
         THIS="$1"
      ;;
     -t|--that)
         DO_THAT=true
         shift
         THAT="$1"
      ;;
     -w|--where)
         DO_WHERE=true
         shift
         WHERE="$1"
      ;;
     -r|--remove)
         DO_REMOVE=true
      ;;
     -i|--id)
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
		  echo "db_minishell.sh: No help!"
        exit 0
       ;;
     --) break;;
     -*)
      printf "Unknown argument received.\n";
      exit 1
     ;;
     *) break;;
   esac
shift
done

if [ ! -z $DO_SELECT ]
then
   echo '...'
fi

if [ ! -z $DO_WRITE ]
then
   echo '...'
fi

if [ ! -z $DO_UPDATE ]
then
   echo '...'
fi

if [ ! -z $DO_REMOVE ]
then
   echo '...'
fi
