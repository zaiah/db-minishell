#-----------------------------------------------------#
# cbchar
#
# Chop a string based on character and it's subsequent
# positions.
# 
# This is a very strange function...
#-----------------------------------------------------#
chop() {
	# String of magic death....
	declare -a cbARR

	# Loop
	while [ $# -gt 0 ]
	do
		case "$1" in
			-t|--this)
				shift
				cbTERM="$1"
			;;
			-d|--delimiter)
				shift
				cbDELIM="$1"
			;;
		esac
		shift
	done

	# Find matches and save.
	for __CHAR__ in `seq 0 ${#cbTERM}`
	do
		# Characters.
		# echo ${cbTERM:$__CHAR__:1} 
		[[ ${cbTERM:$__CHAR__:1} == $cbDELIM ]] && cbARR[${#cbARR[@]}]=$__CHAR__
	done

	# Last element is always entire string.
	# cbARR[${#cbARR[@]}]="${#cbTERM}"
	THESE=(0 ${cbARR[@]})

	# Loop through each element in range. 
	for cbE in `seq 0 $(( ${#THESE[@]} - 1 ))`
	do
		SCS=${THESE[$cbE]}
		SCE=${THESE[$(( $cbE + 1 ))]}

		[ -z $SCE ] && SCE="${#cbTERM}"
		[ $SCS -ne 0 ] && SCS=$(( $SCS + 1 ))

		cbL=$(( $SCE - $SCS ))
		cbW="$(printf "${cbTERM:$SCS:$cbL}")"


		# Iterate through characters forward and backward searching for white space.
		# How to start multiple threads?
		# Check the first and last for a space.
		if [[ ${cbW:0:1} == ' ' ]] || \
			[[ ${cbW:$(( ${#cbW} - 1 )):1} == ' ' ]] || \
		 	[[ ${cbW:0:1} == '	' ]] || \
			[[ ${cbW:$(( ${#cbW} - 1 )):1} == '	' ]]
		then
			echo "In $cbW" > /dev/stderr
			echo Length: ${#cbW} > /dev/stderr

			# Track how many spaces are found.
			# Forward	
			cbFF=0	
			for cbSS in `seq 0 ${#cbW}`
			do
			if [[ ! ${cbW:$cbSS:1} == ' ' ]] && [[ ! ${cbw:$cbSS:1} == $'\t' ]]
			then
				break
			else	
				cbFF=$(( $cbFF + 1 ))
			fi	
			done
			unset cbSS

			# Backward...
			cbRR=${#cbW}
			for cbSS in `seq ${#cbW} -1 0`
			do
				if [[ ! ${cbW:$(( $cbSS - 1 )):1} == ' ' ]] && [[ ! ${cbW:$(( $cbSS - 1 )):1} == '	' ]]
				then
					break 
				else	
					cbRR=$(( $cbRR - 1 ))
				fi	
			done

			# Reallocate
			cbW="${cbW:$cbFF:$(( $cbRR - $cbFF ))}"
			unset cbFF
			unset cbRR
#( 
#echo "'$cbW'"
#echo ${#cbW}
#echo "'${cbW:0:${#cbW}}'" 
#) > /dev/stderr
		fi

		# Check for null first.
		[[ "$cbW" == "NULL" ]] || [[ "$cbW" == "null" ]] && {
			[ -z "$cbSTR" ] && cbSTR="${cbW}" || cbSTR="${cbSTR}${cbDELIM}${cbTERM:$SCS:$cbL}"
			continue	
		}	
		
		# Encapsulate. (Not necessary for some engines)
		# Check if the value is already wrapped between quotes.
		if [[ ${cbW:0:1} == "'" ]] 
		then
			CLL=$(( ${#cbW} - 1 ))
			[[ ${cbW:$CLL:1} == "'" ]] && {
				[ -z "$cbSTR" ] && cbSTR="${cbW}" || cbSTR="${cbSTR}${cbDELIM}${cbW}"
			}

		# If not then we can make our short checks first.
		# Notice that the checks go from shortest time to longest to calculate.
		elif [[ ${cbW:0:1} == [a-z] ]] || \
		  [[ ${cbW:0:1} == '/' ]] || \
		  [[ "${cbW}" =~ '.' ]] || \
		  [[ "${cbW}" =~ '!' ]] || \
		  [[ "${cbW}" =~ '@' ]] || \
		  [[ "${cbW}" =~ '#' ]] || \
		  [[ "${cbW}" =~ '$' ]] || \
		  [[ "${cbW}" =~ '%' ]] || \
		  [[ "${cbW}" =~ '^' ]] || \
		  [[ "${cbW}" =~ '&' ]] || \
		  [[ "${cbW}" =~ '*' ]] || \
		  [[ "${cbW}" =~ '(' ]] || \
		  [[ "${cbW}" =~ ')' ]] || \
		  [[ "${cbW}" =~ '+' ]] || \
		  [[ "${cbW}" =~ '/' ]] || \
		  [[ "${cbW}" =~ '\' ]] || \
		  [[ "${cbW}" =~ '-' ]] 
		then
			[ -z "$cbSTR" ] && cbSTR="'${cbW}'" || cbSTR="${cbSTR}${cbDELIM}'${cbW}'"

		# If the value is the delimiter, then it's likely that the value is blank.
		# Which is fine in some cases...

		# Finally catch numbers.
		else
			[ -z "$cbSTR" ] && cbSTR="${cbW}" || cbSTR="${cbSTR}${cbDELIM}${cbW}"
		fi
		#printf "\nMy string: %s" "$cbSTR"
	done	

	# Return the strings.
	#	/usr/bin/printf "%s" $cbSTR | sed 's/|/\n/g' 
	printf "%s" "$cbSTR" #| sed 's/|/\n/g' 

	# Unset a bunch of crap...
	unset __CHAR__
	unset cbARR
	unset cbTERM
	unset cbDELIM 
	unset THESE
	unset cbSTR
}
