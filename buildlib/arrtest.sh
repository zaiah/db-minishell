# source and whatnot...
source arr.sh

usage() {
	STATUS="$1"
	echo "
	-m|--manual         Run tests on manually created arrays.
	-p|--push-and-pop   Run push and pops on arr.sh created arrays.
	-d|--destroy        Run tests that will destroy an array.
	"
	exit $STATUS
}

[ -z "$BASH_ARGV" ] && printf "Nothing to do\n" > /dev/stderr && usage 1

while [ $# -gt 0 ]
do
	case "$1" in
		-m|--manual)
			MANUAL=true
		;;
		-p|--push-and-pop)
			PP=true
		;;
		-d|--destroy)
			DE=true
		;;
	esac
	shift
done

function op() {
	printf "%s\n" "Output of: $1" 
}

function ti() {
	printf "%s" "Value of $1:                     " | head -c 40 
	printf "%s\n" "[ $2 ]" 
}

[ ! -z $MANUAL ] && {
	# Make a fresh array.
	declare -a JOLLY_BEANS

	# Nothing will show...
	echo '# nothing should show'
	op 'echo ${JOLLY_BEANS[@]}'
	echo ${JOLLY_BEANS[@]}

	# Return the number of elements
	echo '# likewise zero should show' 
	op "arr --elements --within JOLLY_BEANS"
	arr --elements --within JOLLY_BEANS

	# Add array elements
	JOLLY_BEANS[0]="megadeth"
	JOLLY_BEANS[1]="willis"

	# Let's do it again...
	echo '# We just added two elements manually.'
	op "arr --elements --within JOLLY_BEANS"
	arr --elements --within JOLLY_BEANS

	# Manual results...
	echo "# Show the array"
	op "echo ${JOLLY_BEANS[@]}"
	echo ${JOLLY_BEANS[@]}
}


[ ! -z $PP ] && {
	# Non manual
	echo "# Show the array (via arr.sh)"
	op "arr --reveal --within JOLLY_BEANS"
	arr --reveal --within JOLLY_BEANS

	# That basic stuff seems to work.
	# Let's do it all again...
	declare -a SUPER_DETH
	echo "Make a new array called SUPER_DETH"
	op "arr --elements --within SUPER_DETH"
	arr --elements --within SUPER_DETH 

	# Push some stuff to it.
	echo 'Push stuff via: arr --push "one" --to SUPER_DETH'
	arr --push "one" --to "SUPER_DETH"
	echo 'And something else for the hell of it: arr --push "two" --to SUPER_DETH'
	arr --push "two" --to "SUPER_DETH"

	# Show us...
	op 'arr --elements --within SUPER_DETH'
	arr --elements --within SUPER_DETH 

	# Show more...
	op 'arr --reveal --within SUPER_DETH'
	arr --reveal --within SUPER_DETH 
	#JOLLY_BEANS[15]="xxx"
	#echo '# handle sparseness'
	#echo ${JOLLY_BEANS[@]}		# two elements should show
}
