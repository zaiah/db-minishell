#!/bin/bash

# Run a test... for is.
# source extract_real_match.sh
source is.sh

STRING="A big ass string"
STRINGS='A big ass string'
INTEGER="11"
ARRAY=( x y z h "bighead" )
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

is --what "STRING"

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
