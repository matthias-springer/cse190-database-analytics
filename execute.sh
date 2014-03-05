#!/bin/bash
echo "Creating schema"
time psql -U postgres -f schema.sql

echo "Creating members"
time psql -U postgres -f gen_members.sql

echo "Creating friends"
time psql -U postgres -f gen_friends.sql

