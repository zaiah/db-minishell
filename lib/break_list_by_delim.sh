#!/bin/bash -
#-----------------------------------------------------#
# break_list_by_delim
#
# Creates an array based on a string containing delimiters.
#-----------------------------------------------------#
break_list_by_delim() {
	mylist=(`printf $1 | sed "s/${DELIM}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}