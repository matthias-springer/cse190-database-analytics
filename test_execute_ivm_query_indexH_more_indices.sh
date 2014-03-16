#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema/base_tables.sql > /dev/null

echo "Creating IV tables"
time psql -U postgres -f schema/incremental_view.sql > /dev/null
psql -U postgres -f schema/incremental_view_indexH_query.sql > /dev/null

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

