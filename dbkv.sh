#!/bin/bash -
# [ LICENSE ] 
#-----------------------------------------------------#
# dbkv
#
# Allows creating and manipulating a key-value store with an SQL engine.
#-----------------------------------------------------#
#-----------------------------------------------------#
# Licensing
# ---------
# Copyright (c) <year> <copyright holders>
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
# [ LICENSE ] END
PROGRAM="dbkv"

# References to $SELF
[ -z $DO_LIBRARIFY ] && {
	BINDIR="$(dirname "$(readlink -f $0)")"
	SELF="$(readlink -f $0)"
	source $BINDIR/lib/__.sh
	source $BINDIR/minilib/__.sh
}

# usage - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./$PROGRAM
	[ -  ]

-d | --database <arg>         Choose a database to work with. 
     --table <arg>            Set table <arg> as the active table. 
-k | --key(s) <arg>           Choose a key or keys to affect.
-v | --value(s) <arg>         Choose a value or values to affect. 
-a | --add                    Add keys or values. 
-s | --select <arg>           desc
-r | --remove <arg>           desc
-u | --update <arg>           desc
-t | --to <arg>               desc
-r | --remove-all             desc
-b | --belonging_to <arg>     desc
-d | --description <arg>      desc
-f | --for <arg>              desc
-a | --autodate               desc
-a | --add_field <arg>        desc
-r | --remove_field <arg>     desc
-e | --edit_field <arg>       desc
-v | --verbose                Be verbose in output.
-h | --help                   Show this help and quit.
"
   exit $STATUS
}


# Die if no arguments received.
[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" > /dev/stderr && usage 1

# Process options.
while [ $# -gt 0 ]
do
   case "$1" in
     -d|--database)
         DO_DATABASE=true
         shift
         DATABASE="$1"
      ;;
     -t|--table)
         DO_TABLE=true
         shift
         TABLE="$1"
      ;;
     -k|--keys)
         DO_KEYS=true
         shift
         KEYS="$1"
      ;;
     -v|--values)
         DO_VALUES=true
         shift
         VALUES="$1"
      ;;
     -a|--add)
         DO_ADD=true
      ;;
     -s|--select)
         DO_SELECT=true
         shift
         SELECT="$1"
      ;;
     -r|--remove)
         DO_REMOVE=true
         shift
         REMOVE="$1"
      ;;
     -u|--update)
         DO_UPDATE=true
         shift
         UPDATE="$1"
      ;;
     -t|--to)
         DO_TO=true
         shift
         TO="$1"
      ;;
     -r|--remove-all)
         DO_REMOVE_ALL=true
      ;;
     -b|--belonging-to)
         DO_BELONGING_TO=true
         shift
         BELONGING_TO="$1"
      ;;
     -d|--description)
         DO_DESCRIPTION=true
         shift
         DESCRIPTION="$1"
      ;;
     -f|--for)
         DO_FOR=true
         shift
         FOR="$1"
      ;;
     -a|--autodate)
         DO_AUTODATE=true
      ;;
     -a|--add-field)
         DO_ADD_FIELD=true
         shift
         ADD_FIELD="$1"
      ;;
     -r|--remove-field)
         DO_REMOVE_FIELD=true
         shift
         REMOVE_FIELD="$1"
      ;;
     -e|--edit-field)
         DO_EDIT_FIELD=true
         shift
         EDIT_FIELD="$1"
      ;;
     -v|--verbose)
        VERBOSE=true
      ;;
     -h|--help)
        usage 0
      ;;
     --) break;;
     -*)
      printf "Unknown argument received.\n" > /dev/stderr;
      usage 1
     ;;
     *) break;;
   esac
shift
done

# add
[ ! -z $DO_ADD ] && {
   printf '' > /dev/null
}

# select
[ ! -z $DO_SELECT ] && {
   printf '' > /dev/null
}

# remove
[ ! -z $DO_REMOVE ] && {
   printf '' > /dev/null
}

# update
[ ! -z $DO_UPDATE ] && {
   printf '' > /dev/null
}

# remove_all
[ ! -z $DO_REMOVE_ALL ] && {
   printf '' > /dev/null
}

# add_field
[ ! -z $DO_ADD_FIELD ] && {
   printf '' > /dev/null
}

# remove_field
[ ! -z $DO_REMOVE_FIELD ] && {
   printf '' > /dev/null
}

# edit_field
[ ! -z $DO_EDIT_FIELD ] && {
   printf '' > /dev/null
}
