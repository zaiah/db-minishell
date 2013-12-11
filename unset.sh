# Quick script to clean up and find unique values.

# Notice the range, and file, and extremely long requirements which MIGHT be served just as well through an `eval`
sed -n 145,377p db-minishell.sh | \
	sed 's/^[ \t]//g' | \
	grep -v -- '--' | \
	grep -v shift | \
	grep -v EXIT | \
	grep -v ';;' | \
	grep -v 'printf' | \
	grep -v '#' | \
	grep -v 'if' | \
	grep -v 'else' | \
	grep -v 'then' | \
	grep -v 'fi' | \
	grep -v 'case' | \
	grep -v 'do' | \
	grep -v '}' | \
	grep -v -- '-*)' | \
	grep -v -- '-z' | \
	sed 's/[ \t]//g' | \
	sed 's/$[ \t]//g' | \
	sort | uniq -u | tr -s ' ' | \
	sed 's/=.*//g' | \
	sed 's/^/unset /'



		 

