#!/bin/bash -
#-----------------------------------------------------#
# eval_flags
#
# Expands flags for commonly used programs based on 
# verbosity settings.
#-----------------------------------------------------#
eval_flags() {
	if [ ! -z $VERBOSE ]
	then
		MV_FLAGS="-v"
		CP_FLAGS="-v"
		LN_FLAGS="-sv"
		MKDIR_FLAGS="-pv"
		GZCREATE_FLAGS="czvf"
		BZ2CREATE_FLAGS="cjvf"
		UNGZ_FLAGS="xzvf"
		UNBZ2_FLAGS="xjvf"
		SCP_FLAGS="-v"
		RM_FLAGS="-rfv"
	else
		MV_FLAGS=
		CP_FLAGS=
		LN_FLAGS="-s"
		MKDIR_FLAGS="-p"
		GZCREATE_FLAGS="czf"
		BZ2CREATE_FLAGS="cjf"
		UNGZ_FLAGS="xzf"
		UNBZ2_FLAGS="xjf"
		SCP_FLAGS=
		RM_FLAGS="-rf"
	fi
}
