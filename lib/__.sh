#!/bin/bash
BASHUTIL_LIBS=(
	'lib/break_list_by_delim.sh' # 059619afaf95f737eb844ce92e470ce5
	'lib/break_maps_by_delim.sh' # a4ddc2e9ba4a81dec71d2397fed440fd
	'lib/installation.sh' # 11d0b8ac6b071103da869ad54cac3e43
	'lib/tmp_file.sh' # 9eda50a97c7b97a3976d6412a0c973fa
)

for __MY_LIB__ in ${BASHUTIL_LIBS[@]}
do
	source "$BINDIR/$__MY_LIB__"
done

