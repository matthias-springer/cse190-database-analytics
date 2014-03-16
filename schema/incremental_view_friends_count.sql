-- TODO: do not insert tuples with ratio 0 (check if that one is faster)

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

CREATE TABLE ivm_posts_by_author (
	author		integer,
	counter		integer
);

CREATE INDEX ON ivm_posts_by_author using hash (author);

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

--CREATE INDEX ON posts (id);
--CREATE INDEX ON members (id);

CREATE TRIGGER insert_view 
AFTER INSERT ON viewed
FOR EACH ROW
EXECUTE PROCEDURE f_insert_view();


CREATE OR REPLACE FUNCTION f_insert_friends()
RETURNS trigger
AS
$f_insert_friends$
	DECLARE
		num_posts INTEGER;
	BEGIN
		-- TODO: try creating materialized view for number of posts per member
		num_posts := (SELECT counter FROM ivm_posts_by_author WHERE author = NEW.x); --(SELECT COUNT(*) FROM posts WHERE author = NEW.x);
		
		IF num_posts > 0 THEN
			INSERT INTO ivm_arv 
				VALUES (NEW.x, NEW.y, 0, num_posts);
		END IF;
		
		--INSERT INTO ivm_arv	-- causes duplicates
		--	VALUES (NEW.y, NEW.x, 0, (SELECT COUNT(*) FROM posts WHERE author = NEW.y));
			
		RETURN NEW;
	END;
$f_insert_friends$
LANGUAGE plpgsql;

CREATE TRIGGER insert_friends
AFTER INSERT ON friends
FOR EACH ROW
EXECUTE PROCEDURE f_insert_friends();


CREATE OR REPLACE FUNCTION f_insert_members()
RETURNS trigger
AS
$f_insert_members$
	BEGIN
		INSERT INTO ivm_posts_by_author 
			VALUES (NEW.id, 0);
			
		RETURN NEW;
	END;
$f_insert_members$
LANGUAGE plpgsql;

CREATE TRIGGER insert_members
AFTER INSERT ON members
FOR EACH ROW
EXECUTE PROCEDURE f_insert_members();


CREATE OR REPLACE FUNCTION f_insert_posts()
RETURNS trigger
AS
$f_insert_posts$
	BEGIN
		IF EXISTS (SELECT * FROM ivm_arv WHERE author = NEW.author) THEN
			UPDATE ivm_arv
				SET denominator = denominator + 1
				WHERE author = NEW.author;
		ELSE
			INSERT INTO ivm_arv
				(SELECT NEW.author, friends.y, 0, 1 FROM friends WHERE friends.x = NEW.author);
		END IF;
		
		UPDATE ivm_posts_by_author
			SET counter = counter + 1
			WHERE author = NEW.author;
			
		RETURN NEW;
	END;
$f_insert_posts$
LANGUAGE plpgsql;

CREATE TRIGGER insert_posts
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE PROCEDURE f_insert_posts();