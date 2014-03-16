#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema/base_tables.sql > /dev/null
time psql -U postgres -f schema/base_tables_indices.sql > /dev/null

echo "Creating members"
time psql -U postgres -f test_data/gen_members.sql > /dev/null

echo "Creating friends"
time psql -U postgres -f test_data/gen_friends.sql > /dev/null

echo "Creating topics"
time psql -U postgres -f test_data/gen_topics.sql > /dev/null

echo "Creating posts"
time psql -U postgres -f test_data/gen_posts.sql > /dev/null

echo "Create views"
time psql -U postgres -f test_data/gen_views.sql > /dev/null

