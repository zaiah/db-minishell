#!/bin/bash
source in_arr.sh

declare -a DOUBLE
DOUBLE[0]="b"
DOUBLE[1]="dsdfsfsadfdasf"
DOUBLE[2]="one"
DOUBLE[3]="3"
DOUBLE[4]="eighty-three"


STAT=$(in_arr --this 15 --index --array DOUBLE)
echo $STAT
