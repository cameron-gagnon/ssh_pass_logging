#!/bin/bash

# input to this script: the user to be created

if [[ -n "$1" ]]
then
    if [[ ${#1} -gt 32 ]];
    then
        echo "Username too long: $1"
        exit
    fi
    ERROR_DATA=$( { useradd -c "honeypot user" -d /home/honeypot -g 2000 -m -o -s /bin/false -u 2000 "$1"; } 2>&1 )
    ret_code=$?
    if [[ $ret_code = 6 ]];
    then
        echo "Create the honeypot group with:"
        echo -e "\t 'groupadd -g 2000 honeypot'"
    elif [[ $ret_code = 0 ]];
    then
        echo "Successfully created user: $1"
    elif [[ $ret_code != 9 ]];
    then
        echo "ERROR OCCURRED: $ERROR_DATA"
    fi
else
    echo "Example use of script:"
    echo -e "\t./honeypot_user admin"
fi
