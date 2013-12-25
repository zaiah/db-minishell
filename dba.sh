#!/bin/bash -
# [ LICENSE ] 
#-----------------------------------------------------#
# dbms-admin 
#
# A shell tool for administration tasks.
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
# [ LICENSE ] END
PROGRAM="dba"

# References to $SELF
[ -z $DO_LIBRARIFY ] && {
	BINDIR="$(dirname "$(readlink -f $0)")"
	SELF="$(readlink -f $0)"
	source $BINDIR/lib/__.sh
	source $BINDIR/minilib/__.sh
}


# usage() - Show usage message and die with $STATUS
usage() {
   echo "Usage: ./${PROGRAM}
	[ - ]

-d | --database <arg>        Choose a database to work with. 
-e | --table <arg>           Set table <arg> as the active table. 
-c | --columns               List the columns of tables within database.
     --tables                List all tables in a database.
     --tables-and-columns    List both the columns and tables within a database.
-p | --datatypes             List datatypes of all columns of all tables 
                             in database.
-s | --schemata              List schema for all tables in database.
-o | --of <arg>              Specifies a table to use to limit output of 
                             --columns and --datatypes commands.
     --set-id <colname>      Set the id column name ('id' is default 
	                          column name.)
     --vardump               List results as a variable dump.
-n | --rename <arg>          Rename table <arg>. (Use in concert with --to) 
     --to <arg>              Name to rename table to. 
-t | --alter <arg>           If \$__TABLE not set, use this to choose a table 
                             to alter.
-a | --adding <arg>          Add column(s) <arg> to a table.
-r | --removing <arg>        Remove column(s) <arg> from a table.
-x | --drop <arg>            Drop a table <arg> from a database.
-w | --raw <arg>             Send this raw statement onto the SQLite database. 
     --echo                  Echo back SQL statements for debugging.
-v | --verbose               Be verbose in output.
-h | --help                  Show this help and quit.
"

	exit $STATUS
}


# Items that should never be unset.
__SQLITE__="$(which sqlite3 2>/dev/null)"

# [ LOCAL ] 
__EXIT__=

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
# [ LOCAL ] END


# [ OPTS ] 
# Process options.
while [ $# -gt 0 ]
do
	case "$1" in
		-d|--database)
			shift
			DB="$1"
		;;

		--table)
			shift
			__TABLE="$1"
		;;

		# [ ADMIN ]
		-c|--columns)
			DO_GET_COLUMNS=true
		;;

		-p|--datatypes)
			DO_GET_DATATYPES=true
		;;

		--tables)
			DO_SHOW_TABLES=true
		;;
		
		--tables-and-columns)
			DO_SHOW_TABLES_AND_COLUMNS=true
		;;

		-s|--schemata)
			DO_GET_SCHEMATA=true
		;;

		-o|--of)
			shift
			__TABLE="$1"
		;;

	 	--echo)
			 ECHO_BACK=true
	 	;;

		--alter)
			DO_ALTER=true
			shift
			__TABLE="$1"
		;;

		--rename)
			DO_ALTER=true
			DO_ALTER_NAME=true
			shift
			__TABLE="$1"
		;;

		--transfer)
			DO_ALTER=true
			DO_TRANSFER=true
			shift
			__TABLE="$1"
		;;

		--to)
			shift
			RENAME_TO="$1"
		;;

		# --from () is much simpler to read...and more natural than alter...
		--adding)
			DO_ALTER=true
			shift
			COLUMN_TO_ADD="$1"
		;;

		--removing)
			DO_ALTER=true
			shift
			COLUMN_TO_REMOVE="$1"
		;;

		--drop)
			DROP_TABLE=true
		;;

		# Things like transactions and other complexity will go here.
		--raw)
		;;

		# [ ADMIN ] END

		# [ SYSTEM ] 
	 	-v|--verbose)
			 VERBOSE=true
	 	 ;;

	 	-h|--help)
		 	 $__EXIT__ 0
	 	 ;;
		# [ SYSTEM ] END

		--) break;;

		-*)
			printf "Unknown argument received: $1\n";
			$__EXIT__ 1
		;;

		*) break;;
	esac
	shift
done
# [ OPTS ] END


# [ CODE ]
# Set table properly.
[ ! -z "$TABLE" ] && __TABLE="$TABLE"

# [ ADMIN ]
# get a column listing 
[ ! -z $DO_GET_COLUMNS ] && {
	[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1

	# Anywhere a __TABLE is present, check the first chars and make
	# sure they're not flags.
	parse_schemata --of $__TABLE --columns	
}


# get a datatype listing 
[ ! -z $DO_GET_DATATYPES ] && {
	[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
	#$__SQLITE__ $DB ".schema ${__TABLE}"
	parse_schemata --of $__TABLE --datatypes
}


# Get entire schemata.
[ ! -z $DO_GET_SCHEMATA ] && {
	[ -z "${__TABLE}" ] && echo "No table to operate on!" && $__EXIT__ 1
	$__SQLITE__ $DB ".schema ${__TABLE}"
}

###########################################################
# WARNING: This code is unfinished.
# Please check buildlib/alter-tmp.sh for the block
# that belongs here.
###########################################################


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

# [ EXTENSIONS ]
# test 
[ ! -z $DO_VARDUMP ]	&& load_from_db_columns "$QUERY_ARG"
# [ EXTENSIONS ] END

# Skip unset.
# Plumbing
#unset __SQLITE__
#unset __TABLE # --destroy-handle can kill both of these...

# Unset all flags.
unset DO_ALTER
unset DO_ALTER_NAME
unset DO_GET_COLUMNS
unset DO_GET_DATATYPES
unset DO_GET_SCHEMATA
unset DO_SHOW_TABLES_AND_COLUMNS
unset DO_SHOW_TABLES

#... 
unset RENAME_TO
unset COLUMN_TO_ADD
unset COLUMN_TO_REMOVE
unset DROP_TABLE

# General
unset ECHO_BACK
unset VERBOSE
unset THROW_RAW 
unset RAW_STMT

# [ CODE ] END
