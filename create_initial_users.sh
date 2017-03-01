#!/bin/bash

# create the initial group
groupadd -g 2000 honeypot 2> /dev/null


# list of some default usernames to add
while IFS='' read -r user || [[ -n "$user" ]];
do
    ./honeypot_user.sh "$user"
done < "usernames.txt"
