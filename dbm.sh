#!/bin/bash -
# [ LICENSE ] 
#-----------------------------------------------------#
# dbms-orm
#
# A shell tool for ORM functionality.
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
PROGRAM="dbm"

# References to $SELF
[ -z $DO_LIBRARIFY ] && {
	BINDIR="$(dirname "$(readlink -f $0)")"
	SELF="$(readlink -f $0)"
	source $BINDIR/lib/__.sh
	source $BINDIR/minilib/__.sh
}


# usage() - Show usage message and die with $STATUS
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ - ]

-d | --database <arg>        Choose a database to work with. 
     --table <arg>           Set table <arg> as the active table. 
-s | --select <arg>          Select <arg> columns from a table. 
     --select-all            Select all columns from a table. 
     --distinct <arg>        Select distinct rows from a table. 
-l | --limit <arg>           Limit result set.
     --offset <arg>          Use an offset when using the limit.
-g | --group-by <arg>        Group results by <arg>
-h | --having <arg>          When using --group-by, select rows having <arg> 
     --order-by [asc|desc]   Order the rows.
-b | --between <arg>         Use the BETWEEN clause.
                             (<arg> should follow format: <col>=<min>-<max>)
-w | --where <arg>           Supply a WHERE clause to tune result set. 
-o | --or <arg>              Supply an OR clause to tune result set. 
-z | --id <arg>              Retrieve only an id.
-a | --show-as <arg>         Choose a serialization type.
                             ( line, html, col are acceptable choices )
-i | --insert <arg>          Commit records in <arg> to database. 
-t | --into <arg>            Choose a table to insert into when using --insert.
     --insert-from-mem       Craft and commit statement from variables within
                             a script.
-u | --update <arg>          If \$__TABLE not set, set this to choose a
                             table to use in an UPDATE statement.
-e | --set <arg>             Set <column> = <value>
-r | --remove                Delete entry or entries depending on clause. 
     --delete                Non SQL-compliant synonym for --delete
     --echo                  Echo back.
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

		# [ ORM ] 
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

		-l|--limit)
			DO_SEND_QUERY=true
			shift
			__LIM="$1"
		;;
		-h|--having)
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

		-g|--group-by)
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

		--insert-from-mem)
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
			DO_SEND_QUERY=true
			DO_UPDATE=true
			shift
			if [[ "$1" =~ "|" ]]
			then
				[ -z $DO_LIBRARIFY ] && \
					printf "This argument can't have a pipe character (|)."
				$__EXIT__ 1
			fi
			[ -z "$SET" ] && SET="$1" || SET="$SET|$1"
		;;

		-r|--delete|--remove)
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

		-a|--show-as)
			shift
			SERIALIZATION_TYPE="$1"
		;;
		# [ ORM ] END

		# [ EXTENSIONS ]
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
	 	--echo)
			ECHO_BACK=true
	 	 ;;
		# [ EXTENSIONS ] END

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


# [ SYSTEM ]
# Install
[ ! -z $DO_INSTALL ] && {
	[ -z "$INSTALL_DIR" ] && printf "No install dir specified!" && $__EXIT__ 1	
	installation --do --this "db-minishell" --to $INSTALL_DIR
}
# [ SYSTEM ] END

# [ EXTENSIONS ]
# test 
[ ! -z $DO_VARDUMP ]	&& load_from_db_columns "$QUERY_ARG"
# [ EXTENSIONS ] END

# Send a query onto the db.
# [ ORM ]
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
				printf "%s" "$__SQLITE__ $DB " > /dev/stderr
				printf "%s" "\"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\"\n" > /dev/stderr
				eval "echo \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\"" > /dev/stderr
			}

			# Insert the records loaded.
			eval "$__SQLITE__ $DB \"INSERT INTO ${__TABLE} VALUES ( $__INSTR__ )\""

		# Allow the ability to craft a more standard INSERT own.
		else
		#		typical_insert	
			# Find each of the markers.
			WRITE=$(chop --this "$WRITE" --delimiter '|' | sed 's/|/,/g')

			# Echo back if asked.
			[ ! -z $ECHO_BACK ] && {
				printf "%s\n" "$__SQLITE__ $DB \"INSERT INTO ${__TABLE} VALUES ( $(printf "%s" "$WRITE" | sed 's/|/,/g' ) )\"" > /dev/stderr
			}

			# Insert a new row.
			$__SQLITE__ $DB "INSERT INTO ${__TABLE} VALUES ( $WRITE )" > /dev/stderr
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
			(
				printf "%s" "$__SQLITE__ $DB $SR_TYPE" 
				printf "%s" "'${SELECT_DISTINCT:-SELECT} $SELECT FROM ${__TABLE}${STMT}'"
				printf "\n"
			) > /dev/stderr
		}

		# Select all the records asked for.
		$__SQLITE__ $DB \
			$SR_TYPE \
			"${SELECT_DISTINCT:-SELECT} $SELECT FROM ${__TABLE}${STMT}"
	}	

	# select only id
	# Select all the records asked for.
	[ ! -z $DO_ID ] && {
		# Echo back if asked.
		[ ! -z $ECHO_BACK ] && {
			printf "%s" $__SQLITE__ $DB "SELECT ${ID_IDENTIFIER:-id} FROM ${__TABLE}${STMT}" > /dev/stderr
		}

		# Do a select.
		$__SQLITE__ $DB "SELECT ${ID_IDENTIFIER:-id} FROM ${__TABLE}${STMT}"
	}

	# update	
	[ ! -z $DO_UPDATE ] && {
		# Compound your SET statements, 
		# same rules apply as in regular statment
		assemble_set

		# Return query first if asked.
		[ ! -z $ECHO_BACK ] && {
			(
				printf -- "%s" "$__SQLITE__ $DB "
				printf "UPDATE ${__TABLE} SET ${ST_TM}${STMT}"
				printf "\n"
			) > /dev/stderr
		}

		# Run the query.
		$__SQLITE__ $DB "UPDATE ${__TABLE} SET ${ST_TM}${STMT}"
	}
	
	# remove
	[ ! -z $DO_REMOVE ] && {
		$__SQLITE__ $DB "DELETE FROM ${__TABLE}${STMT}"
	}
fi 
# [ ORM ] END
# [ CODE ] END
