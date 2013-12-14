xxx() {
	LIBPROGRAM=""
	_usage() {
	   STATUS="${1:-0}"
	   echo "Usage: ./$LIBPROGRAM
		[ -  ]
	
	-r | --recompile              desc
	-w | --with <arg>             desc
	-w | --without <arg>          desc
	-v | --version                desc
	-s | --single-file            desc
	-v | --verbose                Be verbose in output.
	-h | --help                   Show this help and quit.
	"
	   exit $STATUS
	}
	
	
	[ -z "$#" ] && printf "Nothing to do\n" > /dev/stderr && _usage 1
}
