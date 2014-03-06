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

-- assumption: only friends can read posts
-- TRIVIAL SOLUTION
-- QUERY 1
CREATE MATERIALIZED VIEW mv_arv AS (SELECT (1.0 * numerator.cnt / denominator.cnt) AS ratio, numerator.author, numerator.reader
FROM (SELECT posts.author AS author, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed
		WHERE posts.id = viewed.post
		GROUP BY posts.author, viewed.reader) AS numerator,
	(SELECT posts.author AS author, COUNT(*) AS cnt
		FROM posts
		GROUP BY posts.author) AS denominator
WHERE numerator.author = denominator.author);

CREATE INDEX ON mv_arv (reader);


CREATE OR REPLACE FUNCTION f_refresh_mv_arv() 
RETURNS trigger 
AS 
$f_refresh_mv_arv$
	BEGIN
		REFRESH MATERIALIZED VIEW mv_arv;
		RETURN NEW;
	END;
$f_refresh_mv_arv$
LANGUAGE plpgsql;

CREATE TRIGGER refresh_mv_arv 
AFTER INSERT ON viewed
FOR EACH ROW
EXECUTE PROCEDURE f_refresh_mv_arv();

SELECT author AS a, ratio AS r, reader AS v
FROM mv_arv
WHERE reader = 123;

-- QUERY 2
--CREATE MATERIALIZED VIEW mv_nrv AS (SELECT (numerator.cnt / denominator.cnt) AS ratio, numerator.nation, numerator.reader
--FROM (SELECT members.nation AS nation, viewed.reader AS reader, COUNT(*) AS cnt
--		FROM posts, viewed, members
--		WHERE posts.id = viewed.post AND members.id = posts.author
--		GROUP BY members.nation, viewed.reader) AS numerator,
--	(SELECT members.nation AS nation, COUNT(*) AS cnt
--		FROM posts, members
--		WHERE members.id = posts.author
--		GROUP BY members.nation) AS denominator
--WHERE numerator.nation = denominator.nation);	

-- FIXED
CREATE MATERIALIZED VIEW mv_nrv AS (SELECT (1.0 * numerator.cnt / denominator.cnt) AS ratio, numerator.nation, numerator.reader
FROM (SELECT members.nation AS nation, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed, members
		WHERE posts.id = viewed.post AND members.id = posts.author
		GROUP BY members.nation, viewed.reader) AS numerator,
	(SELECT m1.id as member, m2.nation AS nation, COUNT(*) AS cnt
		FROM posts, members m1, members m2, friends
		WHERE m1.id = friends.x AND m2.id = friends.y
		GROUP BY m2.nation, m1.id) AS denominator
WHERE numerator.nation = denominator.nation);


CREATE INDEX ON mv_nrv (reader);

SELECT nation AS n, ratio AS r, reader AS v
FROM mv_nrv
WHERE reader = 123;		--question: should reader be the ID the name (varchar)?


-- IVM TABLES
CREATE TABLE ivm_arv (
	author		integer,
	reader		integer,
	numerator	integer,
	denominator	integer
);

CREATE TABLE ivm_nrv (
	nation		varchar(255),
	reader		integer,
	numerator	integer,
	denominator	integer
);

CREATE OR REPLACE FUNCTION f_insert_view() 
RETURNS trigger 
AS 
$f_insert_view$
	BEGIN
		UPDATE ivm_arv
			SET numerator = numerator + 1
			WHERE reader = NEW.reader AND author = (SELECT posts.author FROM posts WHERE posts.id = NEW.post);
		
		--UPDATE ivm_nrv
		--	SET numerator = numerator + 1
		--	WHERE reader = NEW.reader AND nation = (SELECT members.nation FROM posts, members WHERE posts.id = NEW.post AND members.id = posts.author);
			
		RETURN NEW;
	END;
$f_insert_view$
LANGUAGE plpgsql;

CREATE INDEX ON posts (id);
CREATE INDEX ON members (id);

CREATE TRIGGER insert_view 
AFTER INSERT ON viewed
FOR EACH ROW
EXECUTE PROCEDURE f_insert_view();


CREATE OR REPLACE FUNCTION f_insert_friends()
RETURNS trigger
AS
$f_insert_friends$
	BEGIN
		-- TODO: try creating materialized view for number of posts per member
		INSERT INTO ivm_arv
			VALUES (NEW.x, NEW.y, 0, (SELECT COUNT(*) FROM posts WHERE author = NEW.x));
		INSERT INTO ivm_arv
			VALUES (NEW.y, NEW.x, 0, (SELECT COUNT(*) FROM posts WHERE author = NEW.y));
			
		RETURN NEW;
	END;
$f_insert_friends$
LANGUAGE plpgsql;

CREATE TRIGGER insert_friends
AFTER INSERT ON friends
FOR EACH ROW
EXECUTE PROCEDURE f_insert_friends();


CREATE OR REPLACE FUNCTION f_insert_posts()
RETURNS trigger
AS
$f_insert_posts$
	BEGIN
		UPDATE ivm_arv
			SET denominator = denominator + 1
			WHERE author = NEW.author;
			
		RETURN NEW;
	END;
$f_insert_posts$
LANGUAGE plpgsql;

CREATE TRIGGER insert_posts
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE PROCEDURE f_insert_posts();

--SELECT random() * 99 + 1 FROM generate_series(1,5);


-- WORKLOAD
