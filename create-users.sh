#!/bin/sh

# Description: Creates Linux and Samba users from a CSV file
#
# The source users file should contain:
#     one user per line
#     username, password, group and comment fields
#     all the four fields separated by a TAB char
#
# Author: Fabio Agostinho Boris
#         github.com/fabioboris
#
# Creation: 2013-01-25 


# function that checks if a command exists
CheckCommand() {
    if [ -z `which $1` ]; then
        echo "Command '$1' not found."
        exit 1
    fi
}

# function that checks if a file exists
CheckFile() {
    if [ ! -f $1 ]; then
        echo "File '$1' not found."
        exit 1
    fi
}


# check if openssl command exists
CheckCommand openssl

# check if mkpasswd command exists
CheckCommand mkpasswd

# get file name
if [ -z "$1" ]; then
    echo "Enter the file name:"
    read FILE
else
    FILE=$1
fi

# check if file exists
CheckFile $FILE

# backup the "internal field separator"
OLDIFS=$IFS
IFS="   " # a literal tab char


# loop through file lines reading the fields
while read USER PASSWORD GROUP COMMENT 
do
    # generate random 8 chars salt
    SALT=`openssl rand -base64 6`

    # generate sha512 shadow password hash
    HASH=`mkpasswd -m sha-512 -S $SALT -s $PASSWORD`

    # add system user
    useradd -p $HASH -g $GROUP -c "$COMMENT" -m $USER

    # add samba user
    (echo $PASSWORD; echo $PASSWORD) |smbpasswd -a -s $USER
done < $FILE


# restore IFS
IFS=$OLDIFS
