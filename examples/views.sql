/******************************************************
* user_profiles 
* 
* All the information needed for a proper user
* profile.
******************************************************/

CREATE VIEW view_user_profile AS
	SELECT 
		media.thumb,	-- comment... 
		media.media, 
		users.username,
		users.age,
		users.fname,
		users.lname,
		users.video,
		users.dateAdded,
		users.home_city,
		users.home_state,
		users.current_city,
		users.current_state
	FROM media
	JOIN users ON media.xid=users.video;


/******************************************************
* view_total_user
* 
*
******************************************************/

CREATE VIEW view_total_user AS
	SELECT
		media.thumb,
		media.media,
		users.username,
		users.age,
		users.fname,
		users.lname,
		users.video,
		users.dateAdded,
		users.college,
		users.highschool
	FROM media
		JOIN users ON media.xid=users.video;
