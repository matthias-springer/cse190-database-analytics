import random

max_friends = 1000
connections = 5000

friends = [[False for x in xrange(max_friends)] for x in xrange(max_friends)]
cnt_friends = 0

while cnt_friends < connections:
	i = random.randint(0, max_friends-1)
	j = random.randint(0, max_friends-1)
	
	if i != j and not friends[i][j]:
		friends[i][j] = friends[j][i] = True
		cnt_friends = cnt_friends + 1
		
		print("INSERT INTO friends VALUES (" + str(j) + ", " + str(i) + ", TIMESTAMP '2011-05-16 15:36:38');")
		print("INSERT INTO friends VALUES (" + str(i) + ", " + str(j) + ", TIMESTAMP '2011-05-16 15:36:38');")
