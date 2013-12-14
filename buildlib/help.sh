bol="buildopts --library"
# arr
$bol \
	--short-if \
	--usage \
	-d \
	--summary "Manipulates arrays." \
	--from "@push,@pop,@to,@from,reveal,@destroy,pull-unique,elements,@within" \
	--options \
	--logic \
	-x "to,from,within" \
	--name "arr" > arr.sh

# in_arr
$bol \
	--short-if \
	--usage \
	-d \
	--summary "Peek inside arrays like the nasty man you are." \
	--from "@this,boolean,index,@at" \
	--options \
	--logic \
	-x "this" \
	--name "in_arr" > in_arr.sh

# is
$bol \
	--short-if \
	--usage \
	-d \
	--summary "Check if an element is of particular type." \
	--from "@what,@integer,@string,@array,@temporary,@fifo,@pipe,@device" \
	--options \
	--logic \
	--name "is" > is.sh


# the __.sh file
$bol \
	--short-if \
	--usage \
	-d \
	--from "recompile,@with,@without,version,single-file" > _libupdate_.sh
