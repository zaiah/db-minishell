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
#		echo ${cbTERM:$__CHAR__:1} 
		[[ ${cbTERM:$__CHAR__:1} == $cbDELIM ]] && cbARR[${#cbARR[@]}]=$__CHAR__
	done

	# Last element is always entire string.
	# cbARR[${#cbARR[@]}]="${#cbTERM}"
	THESE=(0 ${cbARR[@]})

	#  
	for cbE in `seq 0 $(( ${#THESE[@]} - 1 ))`
	do
		SCS=${THESE[$cbE]}
		SCE=${THESE[$(( $cbE + 1 ))]}

		[ -z $SCE ] && SCE="${#cbTERM}"
		[ $SCS -ne 0 ] && SCS=$(( $SCS + 1 ))

		cbL=$(( $SCE - $SCS ))
		cbW="$(printf "%s\n" "${cbTERM:$SCS:$cbL}")"

	# Check for null first.
	[[ "$cbW" == "NULL" ]] || [[ "$cbW" == "null" ]] && {
		[ -z "$cbSTR" ] && cbSTR="${cbTERM}" || cbSTR="${cbSTR}${cbDELIM}${cbTERM:$SCS:$cbL}"
		continue	
	}	
		

	# Encapsulate. (Not necessary for some engines)
	if [[ ${cbW:0:1} == [a-z] ]] || \
		[[ ${cbW:0:1} == '!' ]] || \
		[[ ${cbW:0:1} == '@' ]] || \
		[[ ${cbW:0:1} == '#' ]] || \
		[[ ${cbW:0:1} == '$' ]] || \
		[[ ${cbW:0:1} == '%' ]] || \
		[[ ${cbW:0:1} == '^' ]] || \
		[[ ${cbW:0:1} == '&' ]] || \
		[[ ${cbW:0:1} == '*' ]] || \
		[[ ${cbW:0:1} == '(' ]] || \
		[[ ${cbW:0:1} == ')' ]] || \
		[[ ${cbW:0:1} == '+' ]] || \
		[[ ${cbW:0:1} == '/' ]] || \
		[[ ${cbW:0:1} == '\' ]] || \
		[[ ${cbW:0:1} == '.' ]] || \
		[[ ${cbW:0:1} == '-' ]] 
		then
			[ -z "$cbSTR" ] && cbSTR="'${cbTERM}'" || cbSTR="${cbSTR}${cbDELIM}'${cbTERM:$SCS:$cbL}'"
		else
			[ -z "$cbSTR" ] && cbSTR="${cbTERM}" || cbSTR="${cbSTR}${cbDELIM}${cbTERM:$SCS:$cbL}"
		fi
	done	

	printf "%s" $cbSTR | sed 's/|/\n/g' 
exit
	# Unset a bunch of crap...
	unset __CHAR__
	unset cbARR
	unset cbTERM
	unset cbDELIM 
	unset THESE
	unset cbSTR
}
