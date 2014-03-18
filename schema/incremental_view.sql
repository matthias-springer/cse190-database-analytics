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

CREATE OR REPLACE FUNCTION f_insert_view() 
RETURNS trigger 
AS 
$f_insert_view$
	DECLARE
		num_posts_nation		INTEGER;
		view_nation				VARCHAR(255);
		num_posts				INTEGER;
		author_index			INTEGER;
	BEGIN
		-- Query 1
		author_index := (SELECT posts.author FROM posts WHERE posts.id = NEW.post);
		
		IF EXISTS (SELECT * FROM ivm_arv WHERE reader = NEW.reader AND author = author_index) THEN
			UPDATE ivm_arv
				SET numerator = numerator + 1
				WHERE reader = NEW.reader AND author = author_index;
		ELSE
			num_posts := (SELECT COUNT(*) FROM posts WHERE author = author_index);
			INSERT INTO ivm_arv
				VALUES (author_index, NEW.reader, 1, num_posts);
		END IF;
		
		-- Query 2
		IF EXISTS (SELECT * FROM ivm_nrv, posts, members WHERE ivm_nrv.reader = NEW.reader AND ivm_nrv.nation = members.nation AND members.id = posts.author AND new.post = posts.id) THEN
			UPDATE ivm_nrv
				SET numerator = numerator + 1
				FROM posts, members
				WHERE reader = NEW.reader AND ivm_nrv.nation = members.nation AND members.id = posts.author AND NEW.post = posts.id;
		ELSE
			view_nation := (SELECT nation FROM members, posts WHERE posts.author = members.id AND posts.id = NEW.post);
			num_posts_nation := (SELECT COUNT(*) FROM members, posts, friends WHERE members.id = friends.x AND friends.y = NEW.reader AND posts.author = members.id AND members.nation = view_nation);
			
			INSERT INTO ivm_nrv
				VALUES (view_nation, NEW.reader, 1, num_posts_nation);
		END IF;
			
		RETURN NEW;
	END;
$f_insert_view$
LANGUAGE plpgsql;

CREATE TRIGGER insert_view 
AFTER INSERT ON viewed
FOR EACH ROW
EXECUTE PROCEDURE f_insert_view();


CREATE OR REPLACE FUNCTION f_insert_friends()
RETURNS trigger
AS
$f_insert_friends$
	DECLARE
		num_posts 			INTEGER;
		num_posts_nation 	INTEGER;
		friend_nation 		VARCHAR(255);
	BEGIN
		-- TODO: try creating materialized view for number of posts per member; tried it, makes it slower
		-- Query 1
		
		num_posts := (SELECT COUNT(*) FROM posts WHERE author = NEW.x);
		
		--IF num_posts > 0 THEN
		--	INSERT INTO ivm_arv 
		--		VALUES (NEW.x, NEW.y, 0, num_posts);
		--END IF;
		
		
		-- Query 2
		friend_nation := (SELECT nation FROM members WHERE id = NEW.x);
		
		IF EXISTS (SELECT * FROM ivm_nrv WHERE nation = friend_nation AND reader = NEW.y) THEN
			UPDATE ivm_nrv
				SET denominator = denominator + num_posts
				WHERE nation = friend_nation AND reader = NEW.y;
		END IF;
		
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
	DECLARE
		author_nation			VARCHAR(255);
		friend_id				INTEGER;
	BEGIN
--		IF EXISTS (SELECT * FROM ivm_arv WHERE author = NEW.author) THEN
			UPDATE ivm_arv
				SET denominator = denominator + 1
				WHERE author = NEW.author;
--		ELSE
--			INSERT INTO ivm_arv
--				(SELECT NEW.author, friends.y, 0, 1 FROM friends WHERE friends.x = NEW.author);
--		END IF;
		
		
		-- Query 2
		author_nation = (SELECT nation FROM members WHERE NEW.author = members.id);
		
		FOR friend_id IN (SELECT members.id FROM members, friends WHERE members.id = friends.x AND friends.y = NEW.author)
		LOOP
			IF EXISTS (SELECT * FROM ivm_nrv WHERE nation = author_nation AND reader = friend_id) THEN
				UPDATE ivm_nrv
					SET denominator = denominator + 1
					WHERE nation = author_nation AND reader = friend_id;
			END IF;
		END LOOP;
		
		RETURN NEW;
	END;
$f_insert_posts$
LANGUAGE plpgsql;

CREATE TRIGGER insert_posts
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE PROCEDURE f_insert_posts();