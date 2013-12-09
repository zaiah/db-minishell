#------------------------------------------------------
# genlibs.sh 
# 
# Generate a few different types of libraries for 
# testing.
#-----------------------------------------------------#
T=tests
BUILD="./ms-build.sh"

# Everything
$BUILD -b > $T/dbm-complete.sh

# No dependencies
$BUILD -b --omit "dependencies" > $T/dbm-no-deps.sh

# No comments or license
$BUILD -b --omit "license,comments" > $T/dbm-no-extraneous.sh

# Invoke db_minishell by calling `my_namespace` in whatever script.
$BUILD -b -n my_namespace > $T/dbm-alt-namespace.sh

# Compile only the orm and redirect to a particular file.
$BUILD --orm -n dbm --at $T/dbm-orm.sh  
