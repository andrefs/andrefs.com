create table users (
	id integer primary key autoincrement,
	name varchar(255) default null,
	login varchar(255) not null,
	password text not null
);

create table roles (
	user_id integer not null references users(id),
	rolename varchar(255) not null,
	primary key (user_id, rolename)
);

-- create table if not exists author (
--   id integer primary key autoincrement not null,
--   name string not null,
--   username string not null,
--   password string not null
-- );

create table if not exists posts (
	id integer primary key autoincrement,
	title string not null,
	text string not null,
	author integer references users(id)
);
