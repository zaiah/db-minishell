#!/bin/bash -
#-----------------------------------------------------#
# break_maps_by_delim
#
# Creates a key to value pair based on a string containing delimiters.
#-----------------------------------------------------#
break_maps_by_delim() {
	local m=(`printf "$1" | sed "s/=/ /g"`)
	echo "${m[@]}"			# Return the list all ghetto-style.
}
