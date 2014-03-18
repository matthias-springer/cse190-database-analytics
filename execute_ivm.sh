#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema/base_tables.sql > /dev/null

echo "Creating IV tables"
time psql -U postgres -f schema/incremental_view.sql > /dev/null

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
time psql -U postgres -f query/gen_query1_ivm.sql > query1_ivm_result.txt

echo "Run query 2"
time psql -U postgres -f query/gen_query2_ivm.sql > query2_ivm_result.txt


echo "MIX"
echo "Creating schema"
time psql -U postgres -f schema/base_tables.sql > /dev/null

echo "Creating IV tables"
time psql -U postgres -f schema/incremental_view.sql > /dev/null

echo "Inserting mix"
time psql -U postgres -f data/gen_mix.sql > /dev/null


echo "Run query 1"
time psql -U postgres -f data/f_mix_ivm_query_1.sql > query1_mix_ivm_result.txt

echo "Run query 2"
time psql -U postgres -f data/f_mix_ivm_query_2.sql > query2_mix_ivm_result.txt