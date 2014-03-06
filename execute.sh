#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema.sql

echo "Creating members"
time psql -U postgres -f gen_members.sql

echo "Creating friends"
time psql -U postgres -f gen_friends.sql

echo "Creating topics"
time psql -U postgres -f gen_topics.sql

echo "Creating posts"
time psql -U postgres -f gen_posts.sql

echo "Create views"
time psql -U postgres -f gen_views.sql

