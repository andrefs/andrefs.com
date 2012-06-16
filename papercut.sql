CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(255) DEFAULT NULL,
  login VARCHAR(255) NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE roles (
  user_id INTEGER NOT NULL references users(id),
  rolename VARCHAR(255) NOT NULL,
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
