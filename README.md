# db_minishell

A library for parsing through SQLite3 databases with Bash.

# Usage

# Files

- db-minishell.sh
	Wraps the command line interface for quicker development.

- library.sh
	An embeddable library, omitting `usage` function and unnecessary options.  
	Also allows one to just include the library in a program.


x -d | database <arg>       
x -s | select <arg>         
x     select-all           
x     distinct <arg>       
x     limit <arg>          
     offset <arg>         
     having <arg>         
     order-by [asc|desc]  
-b | between <arg>       
                        
-f | from <arg>           
-w | where <arg>           Supply a
-o | or <arg>              Supply an
-z | id <arg>             
-sa| show-as <arg>        


Administrative Functions:
-c | columns              
-dt| datatypes            
     schemata             
     of <arg>             
     tables               
     set-id <colname>     
     vardump              


Update Functions:
-i | insert <arg>         
-t | into <arg>           
     insert-from-mem      
-u | update <arg>         
-e | set <arg>            
-r | delete               
-x | remove-where <arg>   


General Options:
     librarify            
     libname <name>       
     install <dir>        


# To do / Good Ideas
Move this to a transaction based system for speed.  Only one invocation needed and close the program when totally done.
