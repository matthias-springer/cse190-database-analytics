import random
import string
max_members = 1001

nation = ["United States", "Germany", "France", "Japan", "China", "South Korea", "Mexico", "Canada", "Spain", "Italy", "Belgium", "Poland", "Greece", "Russia"]

for i in xrange(max_members):
	name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
	print("INSERT INTO members VALUES (" + str(i) + ", '" + name + "', '" + random.choice(nation) + "', to_date('1963-09-01', 'YYYY-MM-DD'), TIMESTAMP '2011-05-16 15:36:38');")