#!/bin/bash

# input to this script: the user to be created

if [[ -n "$1" ]]
then
    useradd -c "honeypot user" -d /home/honeypot -g 2000 -m -o -s /bin/false -u 2000 $1 2> /dev/null
    if [[ $? = 6 ]];
    then
        echo "Create the honeypot group with:"
        echo -e "\t 'groupadd -g 2000 honeypot'"
    fi
else
    echo "Example use of script:"
    echo -e "\t./honeypot_user admin"
fi
