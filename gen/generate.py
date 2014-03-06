import random
import string
max_members = 1001

f_members = open("gen_members.sql", "w")

nation = ["United States", "Germany", "France", "Japan", "China", "South Korea", "Mexico", "Canada", "Spain", "Italy", "Belgium", "Poland", "Greece", "Russia"]

for i in xrange(max_members):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_members.write("INSERT INTO members VALUES (" + str(i) + ", '" + name + "', '" + random.choice(nation) + "', to_date('1963-09-01', 'YYYY-MM-DD'), TIMESTAMP '2011-05-16 15:36:38');\n")
	
f_members.close()


f_friends = open("gen_friends.sql", "w")
connections = 5000
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


f_topics = open("gen_topics.sql", "w")
max_topics = 1000

for i in xrange(max_topics):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	f_topics.write("INSERT INTO topics VALUES (" + str(i) + ", '" + name + "');\n")

f_topics.close()


f_posts = open("gen_posts.sql", "w")
max_posts  = 5000
posts = []

for i in xrange(max_posts):
	title = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	text = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(50))
	author = str(random.randint(0, max_members - 1))
	topic = str(random.randint(0, max_topics - 1))
	posts.append(int(author))
	
	f_posts.write("INSERT INTO posts VALUES (" + str(i) + ", " + author + ", '" + title + "', '" + text + "', " + topic + ", TIMESTAMP '2011-05-16 15:36:38');\n")


f_views = open("gen_views.sql", "w")
max_views = 7500
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
