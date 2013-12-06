#------------------------------------------------------
# genlibs.sh 
# 
# Generate a few different types of libraries for 
# testing.
#-----------------------------------------------------#
T=tests
BUILD=".$BUILD"

# Everything
$BUILD -b > dbm-complete.sh

# No dependencies
$BUILD -b --omit "dependencies" > dbm-no-deps.sh

# No comments or license
$BUILD -b --omit "license,comments" > dbm-no-extraneous.sh

# Invoke db_minishell by calling `my_namespace` in whatever script.
$BUILD -b -n my_namespace > dbm-alt-namespace.sh

# Compile only the orm and redirect to a particular file.
$BUILD --orm -n dbm --at dbm-orm.sh  
