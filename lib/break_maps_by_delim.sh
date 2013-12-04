#!/bin/bash -
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