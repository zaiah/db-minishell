#!/bin/bash -
#-----------------------------------------------------#
# is_element_present_in
#
# Return true or false if an element is found in an array.
#-----------------------------------------------------#
is_this_in () {
	# Catch arguments.
	if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Improper arguments supplied to is_element_present_in()"
		echo "You've made an error in coding!"
		exit 1
	fi

	# Catch arguments.
	ARR="$(eval 'echo ${'$1'[@]}')"
	VS_ELE="$2"
	STAT=

	# Compare each element.
	for ELE in ${ARR[@]}
	do
		[ $ELE == $VS_ELE ] && STAT="true" && break 
	done

	# Return a status.
	[ -z $STAT ] && STAT="false"
	echo $STAT
}
