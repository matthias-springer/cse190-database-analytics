import random
import string

max_topics = 1000
max_posts  = 5000
max_members = 1000

for i in xrange(max_posts):
	title = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	text = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(50))
	author = str(random.randint(0, max_members - 1))
	topic = str(random.randint(0, max_members - 1))

	print("INSERT INTO posts VALUES (" + str(i) + ", " + author + ", '" + title + "', '" + text + "', " + topic + ", TIMESTAMP '2011-05-16 15:36:38');")
