# Generation note.
[ ! -z $VERBOSE ] && 
	printf "Generating library...\n"
}

# Load whatever db-minishell library we've asked for...
[ ! -z "$WITH_THIS" ] && DBM="$WITH_THIS" || {
	tmp_file -n DBM
	$BUILD -b -n $CALLNAME > $DBM
}


# Generate markers again for testing...


# Generate a bunch of tests dynamically
# id
# instance_name
# srv_path
# dev_path
# date_created
# version
# last_version
# user_owner
# description
tmp_file -n RUN_TESTS


# build the library and run it...
# or just skip through this...
printf "DB=$DB"
printf "TABLE=$TABLE"

# select statements
printf "[ SELECT ]"
# Should see all
printf "$CALLNAME --select '*'"
printf "$CALLNAME --select-all" 

# Should only get a certain row...
printf "$CALLNAME --distinct 'instance_name,user_owner' --where " 

# Only 10
printf "$CALLNAME --limit 10" 

# only 10, but start at id 60
printf "$CALLNAME --limit 10 --offset 60" 
#printf "$CALLNAME --having 10" 
printf "$CALLNAME --order-by instance_name" 
printf "$CALLNAME --having 10" 
printf "$CALLNAME --where 10" 
printf "$CALLNAME --where 10 --or 2" 
printf "$CALLNAME --id 10" 
printf "$CALLNAME --having 10" 
printf "[ SELECT ] END"


# Do some other stuff...
printf "[ SERIALIZATION ] "
printf "[ SERIALIZATION ] END"

# Do some other stuff...
printf "$CALLNAME --select-all" 
printf "$CALLNAME --select-all" 
printf "$CALLNAME --select-all" 
