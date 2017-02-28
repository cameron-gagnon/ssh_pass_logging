#!/bin/bash

# create the initial group
groupadd -g 2000 honeypot


# list of some default usernames to add
declare -a USERS=("admin" "support" "cs" "php" "rustserver" "postgres" "test" "master" "mother" "arkserver" "nexus" "jun" "csgoserver" "pma" "dbsql" "mc" "minecraft" "chiba")

for user in "${USERS[@]}";
do
    ./honeypot_user.sh $user
done
