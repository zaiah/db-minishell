#!/bin/bash
__BULIBSRC__="$(dirname $(readlink -f $0))/lib"

# Hold library names and checksums.
BASHUTIL_LIBS=(
	"arrayify.sh" # None
	"break_list_by_delim.sh" # 059619afaf95f737eb844ce92e470ce5
	"break_maps_by_delim.sh" # a4ddc2e9ba4a81dec71d2397fed440fd
	"is_element_present_in.sh" # 4a85d469af74c76c14f199c287ee989e
	"eval_flags.sh" # 4d2b5aae266d3478cfa28660762894f2
	"installation.sh" # 11d0b8ac6b071103da869ad54cac3e43
	"tmp_file.sh" # 9eda50a97c7b97a3976d6412a0c973fa
)

# Load each library.
for __MY_LIB__ in ${BASHUTIL_LIBS[@]}
do
	source "$__BULIBSRC__/$__MY_LIB__"
done
