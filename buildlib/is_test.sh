#!/bin/bash


# Run a test... for is.
# source extract_real_match.sh
source is.sh

STRING="A big ass string"
STRINGS='A big ass string'
INTEGER="11"
ARRAY=( "x" "y" "z" "h" "bighead" )
declare -A AARRAY
AARRAY["girl"]="She's a nice lookin girl."
AARRAY["boy"]="He's a nice lookin boy"
AARRAY["man"]="She's a nice lookin man. (?)"
AARRAY["woman"]="She's a nice lookin woman"

function fboogy( ) {
	echo 'jim'
	echo 'peace'
	local STRING="flocka"
}

function wboogy () {
	echo 'jim'
	echo 'peace'
}

# Some tests of extract_real_match
#	printf "hcc" | extract_real_match
#	declare | extract_real_match --find "STRING="


#is --what "" # Return empty or null...

# Dumps the entire thing.
# Need whatever I wrote to find function names... grep doesn't cut it...
# declare | grep 'STRING='  	# This will be trouble...
# declare | grep 'STRINGS'  	# This will be trouble...
# declare | grep 'INTEGER' 
# declare | grep 'ARRAY'	 	# Search for first =(
# declare | grep 'fboogy'  	# Notice that no matter where parens are, we're good

# Why grep doesn't work...
# Same name (STRING vs. STRINGS)

ETC="your mom"
EMPTYNESS=""
POUND=11
THE_INTEGER="11"
APOUND=11a
GPOUND=111283947132894789132748913274890132470891234
ARR=( mega tryon )
JUI=
declare -a ARRTWO

# Turn on diagnostics.
#shopt -s expand_aliases 
#alias is="is --diagnostic"
printf "\n%s\n" 'is --what "ETC":'
is --what "ETC"				# string

printf "\n%s\n" 'is --what "wboogy":'
is --what "wboogy"			# function

printf "\n%s\n" 'is --what "ARR":'
is --what "ARR"			   # array

printf "\n%s\n" 'is --what "ARRTWO":'
is --what "ARRTWO"			# array 

printf "\n%s\n" 'is --what "POUND":'
is --what "POUND"				# integer 

printf "\n%s\n" 'is --what "APOUND":'
is --what "APOUND"			# string 

printf "\n%s\n" 'is --what "GPOUND":'
is --what "GPOUND"			# integer (an extremely long one)

printf "\n%s\n" 'is --what "THE_INTEGER":'
is --what "THE_INTEGER"		# integer (within strings) 

printf "\n%s\n" 'is --what "EMPTYNESS":'
is --what "EMPTYNESS"		# empty 

printf "\n%s\n" 'is --what "UNDEFINED":'
is --what "UNDEFINED"		# undefined (as it is nowhere within this code) 

# This must be tested for because it can EASILY occur.
printf "\n%s\n" 'is --what "$JUI":  # (a var named $JUI with nothing)'
is --what "$JUI"				# nil 


# declare | grep THE_INTEGER
