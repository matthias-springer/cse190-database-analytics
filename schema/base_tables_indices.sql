--SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.author as a, numerator.reader as r
--FROM (SELECT posts.author AS author, viewed.reader AS reader, COUNT(*) AS cnt
--		FROM posts, viewed
--		WHERE posts.id = viewed.post AND viewed.reader = 664
--		GROUP BY posts.author, viewed.reader) AS numerator,
--	(SELECT posts.author AS author, COUNT(*) AS cnt
--		FROM posts
--		GROUP BY posts.author) AS denominator
--WHERE numerator.author = denominator.author;

--SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.nation as n, numerator.reader as r
--FROM (SELECT members.nation AS nation, viewed.reader AS reader, COUNT(*) AS cnt
--		FROM posts, viewed, members
--		WHERE posts.id = viewed.post AND viewed.reader = 504 AND members.id = posts.author
--		GROUP BY members.nation, viewed.reader) AS numerator,
--	(SELECT members.nation AS nation, COUNT(*) AS cnt
--		FROM posts, members, friends
--		WHERE posts.author = members.id AND friends.x = 504 AND friends.y = members.id
--		GROUP BY members.nation) AS denominator
--WHERE numerator.nation = denominator.nation;

CREATE INDEX ON posts using hash (id);	-- faster than btree
--CREATE INDEX ON viewed using btree (post, reader);
CREATE INDEX ON viewed using hash (post);	-- faster than btree and dual btree
CREATE INDEX ON viewed using hash (reader);	-- faster than btree and dual btree
CREATE INDEX ON posts using btree (author);	-- faster than hash
CREATE INDEX ON members using hash (nation);
CREATE INDEX ON members using hash (id);
CREATE INDEX ON friends using hash (x);
