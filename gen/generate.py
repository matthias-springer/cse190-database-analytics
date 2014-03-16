import random
import string
max_members = 10000

f_members = open("../data/gen_members.sql", "w")

nation = ["United States", "Germany", "France", "Japan", "China", "South Korea", "Mexico", "Canada", "Spain", "Italy", "Belgium", "Poland", "Greece", "Russia"]

for i in xrange(max_members):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_members.write("INSERT INTO members VALUES (" + str(i) + ", '" + name + "', '" + random.choice(nation) + "', to_date('1963-09-01', 'YYYY-MM-DD'), TIMESTAMP '2011-05-16 15:36:38');\n")
	
f_members.close()


f_friends = open("../data/gen_friends.sql", "w")
connections = 10000
friends = [[False for x in xrange(max_members)] for x in xrange(max_members)]
cnt_friends = 0

while cnt_friends < connections:
	i = random.randint(0, max_members-1)
	j = random.randint(0, max_members-1)
	
	if i != j and not friends[i][j]:
		friends[i][j] = friends[j][i] = True
		cnt_friends = cnt_friends + 1
		
		f_friends.write("INSERT INTO friends VALUES (" + str(j) + ", " + str(i) + ", TIMESTAMP '2011-05-16 15:36:38');\n")
		f_friends.write("INSERT INTO friends VALUES (" + str(i) + ", " + str(j) + ", TIMESTAMP '2011-05-16 15:36:38');\n")
		
f_friends.close()


f_topics = open("../data/gen_topics.sql", "w")
max_topics = 15000

for i in xrange(max_topics):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_topics.write("INSERT INTO topics VALUES (" + str(i) + ", '" + name + "');\n")

f_topics.close()


f_posts = open("../data/gen_posts.sql", "w")
max_posts  = 7500
posts = []

for i in xrange(max_posts):
	title = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	text = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(50))
	author = str(random.randint(0, max_members - 1))
	topic = str(random.randint(0, max_topics - 1))
	posts.append(int(author))
	
	f_posts.write("INSERT INTO posts VALUES (" + str(i) + ", " + author + ", '" + title + "', '" + text + "', " + topic + ", TIMESTAMP '2011-05-16 15:36:38');\n")


f_views = open("../data/gen_views.sql", "w")
max_views = 10000
views = []
counter = 0

while counter < max_views:
	post = random.randint(0, max_posts - 1)
	member = random.randint(0, max_members - 1)
	
	if friends[posts[post]][member] and not (member, post) in views:
		print(counter)
		f_views.write("INSERT INTO viewed VALUES (" + str(member) + ", " + str(post) + ");\n")
		views.append((member, post))
		counter += 1
		
f_views.close()


f_query1_none = open("../query/gen_query1_none.sql", "w")
f_query1_mv = open("../query/gen_query1_mv.sql", "w")
f_query1_iv = open("../query/gen_query1_ivm.sql", "w")

f_query2_none = open("../query/gen_query2_none.sql", "w")
f_query2_iv = open("../query/gen_query2_ivm.sql", "w")

max_queries = 10000 #10000

for i in xrange(max_queries):
	reader = random.randint(0, max_members - 1)
	f_query1_iv.write("SELECT author AS a, numerator * 1.0 / denominator AS v, reader AS r FROM ivm_arv WHERE reader = " + str(reader) + ";\n")
	f_query1_mv.write("SELECT author AS a, ration as v, reader AS r FROM mv_arv WHERE reader = " + str(reader) + ";\n")
	f_query1_none.write("""SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.author as a, numerator.reader as r
FROM (SELECT posts.author AS author, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed
		WHERE posts.id = viewed.post AND viewed.reader = """ + str(reader) + """
		GROUP BY posts.author, viewed.reader) AS numerator,
	(SELECT posts.author AS author, COUNT(*) AS cnt
		FROM posts
		GROUP BY posts.author) AS denominator
WHERE numerator.author = denominator.author;\n""")
	f_query2_none.write("""SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.nation as n, numerator.reader as r
FROM (SELECT members.nation AS nation, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed, members
		WHERE posts.id = viewed.post AND viewed.reader = """ + str(reader) + """ AND members.id = posts.author
		GROUP BY members.nation, viewed.reader) AS numerator,
	(SELECT members.nation AS nation, COUNT(*) AS cnt
		FROM posts, members, friends
		WHERE posts.author = members.id AND friends.x = """ + str(reader) + """ AND friends.y = members.id
		GROUP BY members.nation) AS denominator
WHERE numerator.nation = denominator.nation;""")
	f_query2_iv.write("SELECT nation AS n, numerator * 1.0 / denominator AS v, reader AS r FROM ivm_nrv WHERE reader = " + str(reader) + ";\n")

f_query1_iv.close()
f_query1_mv.close()
f_query1_none.close()

f_query2_none.close()
f_query2_iv.close()
