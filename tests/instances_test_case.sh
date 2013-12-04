# TESTS
INSTANCE='jericurl'
SRV_PATH='/home/bob/jericurl'
DEV_PATH='/home/bob/jericurl'
DATECREATED='23894723947329'
VERSION="1.00"
LAST_VERSION="1.01"
USER_OWNER="zaiah"
DESCRIPTION='Button up, bro.'


/usr/bin/sqlite3 mytest.db < echo "CREATE TABLE items (
	id integer primary key autoincrement,
	srv_path text,
	dev_path text,
	date_created integer,
	version text,
	last_version text,
	user_owner text,
	description text
);" 
