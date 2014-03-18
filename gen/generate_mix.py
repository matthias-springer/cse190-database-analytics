import random
import string

global max_members
global max_topics
global max_posts

max_members = 0
max_topics = 0
max_posts  = 0

f_mix = open("../data/gen_mix.sql", "w")
f_mix_none_query_1 = open("../data/f_mix_none_query_1.sql", "w")
f_mix_ivm_query_1 = open("../data/f_mix_ivm_query_1.sql", "w")
f_mix_none_query_2 = open("../data/f_mix_none_query_2.sql", "w")
f_mix_ivm_query_2 = open("../data/f_mix_ivm_query_2.sql", "w")

nation = ["United States", "Germany", "France", "Japan", "China", "South Korea", "Mexico", "Canada", "Spain", "Italy", "Belgium", "Poland", "Greece", "Russia"]
friends = [[False for x in xrange(5000)] for x in xrange(5000)]
posts = []
views = []

def gen_member():
	global max_members
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_mix.write("INSERT INTO members VALUES (" + str(max_members) + ", '" + name + "', '" + random.choice(nation) + "', to_date('1963-09-01', 'YYYY-MM-DD'), TIMESTAMP '2011-05-16 15:36:38');\n")
	max_members += 1

def gen_friend():
	if max_members < 10: return
	
	i = random.randint(0, max_members-1)
	j = random.randint(0, max_members-1)
	
	if i != j and not friends[i][j]:
		friends[i][j] = friends[j][i] = True
		
		f_mix.write("INSERT INTO friends VALUES (" + str(j) + ", " + str(i) + ", TIMESTAMP '2011-05-16 15:36:38');\n")
		f_mix.write("INSERT INTO friends VALUES (" + str(i) + ", " + str(j) + ", TIMESTAMP '2011-05-16 15:36:38');\n")

def gen_topic():
	global max_topics
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_mix.write("INSERT INTO topics VALUES (" + str(max_topics) + ", '" + name + "');\n")
	max_topics += 1

def gen_post():
	global max_posts
	
	if max_members < 10 or max_topics < 2: return
	
	title = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	text = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(50))
	author = str(random.randint(0, max_members - 1))
	topic = str(random.randint(0, max_topics - 1))
	posts.append(int(author))
	
	f_mix.write("INSERT INTO posts VALUES (" + str(max_posts) + ", " + author + ", '" + title + "', '" + text + "', " + topic + ", TIMESTAMP '2011-05-16 15:36:38');\n")
	max_posts += 1

def gen_view():
	if max_members < 10 or max_posts < 10: return
	
	success = False
	
	while not success:
		post = random.randint(0, max_posts - 1)
		member = random.randint(0, max_members - 1)
		
		if friends[posts[post]][member] and not (member, post) in views:
			f_mix.write("INSERT INTO viewed VALUES (" + str(member) + ", " + str(post) + ");\n")
			views.append((member, post))
			success = True
		
def gen_query():
	reader = random.randint(0, max_members - 1)
	f_mix_ivm_query_1.write("SELECT author AS a, numerator * 1.0 / denominator AS v, reader AS r FROM ivm_arv WHERE reader = " + str(reader) + ";\n")
	f_mix_none_query_1.write("""SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.author as a, numerator.reader as r
FROM (SELECT posts.author AS author, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed
		WHERE posts.id = viewed.post AND viewed.reader = """ + str(reader) + """
		GROUP BY posts.author, viewed.reader) AS numerator,
	(SELECT posts.author AS author, COUNT(*) AS cnt
		FROM posts
		GROUP BY posts.author) AS denominator
WHERE numerator.author = denominator.author;\n""")
	f_mix_none_query_2.write("""SELECT (1.0 * numerator.cnt / denominator.cnt) AS v, numerator.nation as n, numerator.reader as r
FROM (SELECT members.nation AS nation, viewed.reader AS reader, COUNT(*) AS cnt
		FROM posts, viewed, members
		WHERE posts.id = viewed.post AND viewed.reader = """ + str(reader) + """ AND members.id = posts.author
		GROUP BY members.nation, viewed.reader) AS numerator,
	(SELECT members.nation AS nation, COUNT(*) AS cnt
		FROM posts, members, friends
		WHERE posts.author = members.id AND friends.x = """ + str(reader) + """ AND friends.y = members.id
		GROUP BY members.nation) AS denominator
WHERE numerator.nation = denominator.nation;""")
	f_mix_ivm_query_2.write("SELECT nation AS n, numerator * 1.0 / denominator AS v, reader AS r FROM ivm_nrv WHERE reader = " + str(reader) + ";\n")


max_members = 0
for i in xrange(25000):
	rand = random.random()
	
	if rand   < 0.1:
		gen_member()
	elif rand < 0.3:
		gen_friend()
	elif rand < 0.35:
		gen_topic()
	elif rand < 0.6:
		gen_post()
	else:
		gen_view()
		
	if i % 100 == 0 :
		print(i)
		
f_mix.close()

for i in xrange(10000):
	gen_query()
	
	if i % 100 == 0:
		print(i)
		
f_mix_none_query_2.close()
f_mix_none_query_1.close()
f_mix_ivm_query_2.close()
f_mix_ivm_query_1.close()


