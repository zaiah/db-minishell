#-----------------------------------------------------#
# pick_off() 
#
# Generate a temporary file and "pick off" the ranges
# needed.
#-----------------------------------------------------#
pick_off() {
	MARKER="$1"   # From outside...
	
	# Process needed options by extracting from temporary file.
	tmp_file -n DD
	parse_range -f "$MARKER" -t "$MARKER END" -w $FILE > $DD

	# Debug
	[ ! -z "$2" ] && cp -v $DD $2

	# Only take needed options and actions from the code.
	# Check UNPARSE above for more details.
	for EACH_MKR in ${UNPARSE[@]}
	do
		# Define the marker.
		MKR="${!EACH_MKR}"

		# Remove the portions not asked for.
		parse_range -f "$MKR" -t "$MKR END" -w $DD --include-range --delete
	done
	unset MKR

	# Get rid of any leftover library markers.
	for EACH_MKR in ${MKR_ALL[@]}
	do
		# Define the marker.
		MKR="${!EACH_MKR}"
		[ ! -z "$(grep --fixed --line-number "$MKR" $DD | head -n 1 )" ] && {
			MKR_RNG=( $(grep --fixed --line-number "$MKR" $DD | awk -F ':' '{ print $1 }') )
			for EE in ${MKR_RNG[@]}
			do
				sed -i ${EE}d $DD #>> /dev/stderr
			done
			unset MKR_RNG
		}
	done
	unset MKR

	# Put all these options into the library file.
	cat $DD | sed 's/^/\t/g'

	# Get rid of the temporary file.
	tmp_file -l
}
