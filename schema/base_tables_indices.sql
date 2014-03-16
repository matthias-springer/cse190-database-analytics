--SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.author as a, numerator.reader as r
--FROM (SELECT posts.author AS author, viewed.reader AS reader, COUNT(*) AS cnt
--		FROM posts, viewed
--		WHERE posts.id = viewed.post AND viewed.reader = 664
--		GROUP BY posts.author, viewed.reader) AS numerator,
--	(SELECT posts.author AS author, COUNT(*) AS cnt
--		FROM posts
--		GROUP BY posts.author) AS denominator
--WHERE numerator.author = denominator.author;

CREATE INDEX ON posts using hash (id);	-- faster than btree
--CREATE INDEX ON viewed using btree (post, reader);
CREATE INDEX ON viewed using hash (post);	-- faster than btree and dual btree
CREATE INDEX ON viewed using hash (reader);	-- faster than btree and dual btree
CREATE INDEX ON posts using btree (author);	-- faster than hash
