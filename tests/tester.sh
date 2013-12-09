#!/bin/bash -
# List of tests for db_minishell
DB="mytest.db"
TABLE="tests"
DBM="dbm --database $DB --into $TABLE"

# How long is this string?
# printf "Within write string: "
# printf "%s" "null,'zaiah','/home/ancollins/dsoro','/home/ancollins/johnnybob',$(date +%s),'1.01','1.00','ancollins','The big brown fox jumps over the lazy dog'" | wc -c 

# No special characters.
# $DBM --insert "null|'zaiah'|'/home/ancollins/dsoro'|'/home/ancollins/johnnybob'|$(date +%s)|'1.01'|'1.00'|'ancollins'|'The big brown fox jumps over the lazy dog'" --echo

# No quotes. 
# $DBM --insert "null|zaiah|/home/ancollins/dsoro|/home/ancollins/johnnybob|$(date +%s)|1.01|1.00|ancollins|The big brown fox jumps over the lazy dog" --echo

# Blanks
#$DBM --insert "null||/home/ancollins/dsoro|/home/ancollins/johnnybob||1.01|1.00|ancollins|The big brown fox jumps over the lazy dog." 

# Die on blanks
#$DBM --insert "null||/home/ancollins/dsoro|/home/ancollins/johnnybob||1.01|1.00|ancollins|The big brown fox jumps over the lazy dog." --none-blank

# White space [ \s ]
$DBM --insert "null|za iah| /home/ancollins/dsoro   |/home/ancollins/johnnybob |jo|   1.01|1.00|ancollins|Flocka flame. " --echo

# Tabs (still not working...)
# $DBM --insert "null|za iah|	/home/ancollins/dsoro|/home/ancollins/johnnybob	|	jo|1.01|1.00|ancollins|Flocka flame. " --echo

# Special characters [ ' ]
# $DBM --insert "null|zaiah|/home/ancollins/dsoro|/home/ancollins/johnnybob|jo|1.01|1.00|ancollins|Don't you play with me crackface! I've got something for you... don't be playing 23j42k12#%%!2321adbE#" 

# Special characters [ \ $ ! ]
# $DBM --insert "null|zaiah|/home/ancollins/dsoro|/home/ancollins/johnnybob|jo|1.01|1.00|ancollins|Don't you play with me crackface! I've got something for you... don't be playing 23j42k12#%%!2321adbE\$#" 

# HTML-Encode?
#$DBM --html-encode --insert "null,zaiah,/home/ancollins/dsoro,/home/ancollins/johnnybob,1.01,1.00,ancollins,The big brown fox jumps over the lazy dog" 

# Check the result.
# $DBM --select-all --limit 1 --order-by id desc

# A rollback option would save TONS of time...
