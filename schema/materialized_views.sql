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


--- QUERY 2
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


--CREATE OR REPLACE FUNCTION f_refresh_mv_nrv()
--RETURNS trigger
--AS
--$f_refresh_mv_nrv$
--	BEGIN
--		REFRESH MATERIALIZED VIEW mv_nrv;
--		RETURN NEW;
--	END;
--$f_refresh_mv_nrv$
--LANGUAGE plpgsql;

--CREATE TRIGGER refresh_mv_nrv
--AFTER INSERT ON viewed
--FOR EACH ROW EXECUTE PROCEDURE f_refresh_mv_nrv();

SELECT nation AS n, ratio AS r, reader AS v
FROM mv_nrv
WHERE reader = 123;		--question: should reader be the ID the name (varchar)?