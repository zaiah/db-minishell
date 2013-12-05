for __MY_LIB__ in $(ls $BINDIR/minilib/*)
do
	[[ "$(basename $__MY_LIB__)" == "__.sh" ]] && continue
	source $__MY_LIB__
done
