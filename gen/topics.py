import random
import string

max_topics = 1000

for i in xrange(max_topics):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	print("INSERT INTO topics VALUES (" + str(i) + ", '" + name + "');")
