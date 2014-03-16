DROP SCHEMA PUBLIC CASCADE;
CREATE SCHEMA PUBLIC;

CREATE TABLE members (
	id			integer PRIMARY KEY,
	name		varchar(255),
	nation		varchar(255),
	birthday	date,
	created		timestamp
);

CREATE TABLE topics (
	id			integer PRIMARY KEY,
	name		varchar(255)
);

CREATE TABLE posts (
	id			integer PRIMARY KEY,		-- not explicitly stated in the text, use SERIAL?
	author		integer references members(id),
	title		varchar(255),
	text		varchar(255),
	topic		integer references topics(id),
	created		timestamp
);

-- friend relationship is symmetric
CREATE TABLE friends (
	x			integer references members(id),
	y			integer references members(id),
	created		timestamp
);

CREATE TABLE viewed (						-- had to change table name from "view" to "viewed"
	reader		integer references members(id),
	post		integer references posts(id)
);
