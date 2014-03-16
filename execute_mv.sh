#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema/base_tables.sql > /dev/null

echo "Creating IV tables"
time psql -U postgres -f schema/materialized_views.sql > /dev/null

echo "Creating members"
time psql -U postgres -f data/gen_members.sql > /dev/null

echo "Creating friends"
time psql -U postgres -f data/gen_friends.sql > /dev/null

echo "Creating topics"
time psql -U postgres -f data/gen_topics.sql > /dev/null

echo "Creating posts"
time psql -U postgres -f data/gen_posts.sql > /dev/null

echo "Create views"
time psql -U postgres -f data/gen_views.sql > /dev/null

echo "Run query 1"
time psql -U postgres -f query/gen_query1_mv.sql > query1_mv_result.txt
