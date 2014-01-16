# db-minishell

A command-line tool and library for parsing through SQLite3 databases via the command-line.


# Files

- dbms-orm.sh
	Contains just functions necessary for grabbing and manipulating the data within some database.

- dbms-admin.sh
	Contains functions necessary for administrative tasks, such as creating tables, altering tables, getting the schema of a database, etc.

- ms-build.sh
	Builds a library out of this minishell.

- ms-test.sh
	Builds some tests for minishell.


- library.sh
	An embeddable library, omitting `usage` function and unnecessary options.  
	Also allows one to just include the library in a program.


# Why

I'm sure I'm not alone in thinking that invoking:
<pre>
sqlite3 "some-db"
sqlite> select * from tony where x=y;
sqlite> delete xid from tony where category='big paper' and color='green';
</pre>
is not the greatest way to go about developing an application for the database.   While there are plenty of pretty decent scripts out there that handle stuff like this (even some going so far as to be built into your IDE), there aren't really a whole lot out there right now that solve this rather simple problem from your command line.

The hope is to see this thing get embedded into simple scripts when needed, maybe making Bash or some other shell variant a little more useful for your system administration needs.


# To do / Good Ideas
- Move this to a transaction based system for speed.  Only one invocation needed and close the program when totally done.

- What if I want to do mass updates?  Besides looped invocation (slow as hell) how can I generate a GIANT statement?

- Man pages and better documentation are on the way.
