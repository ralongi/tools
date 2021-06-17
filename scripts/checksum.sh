#!/bin/bash

SIZE=$1
FILE="/tmp/"$SIZE"MBFile"
DEST=$2

#create the display usage to be presented to the user
display_usage(){
        echo -e "\nUsage: \n$0 [size of file (in MB) to be transferred] [destination]"
        echo -e "Example: \n$0 50 root@host1.company.com"
        }

#if less than 2 arguments are supplied by the user, display usage

if [ $# -lt 2 ]
then
        display_usage
        exit 0
fi

#check whether user has supplied -h or --help or help or -?.  if yes, display usage
if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" ]]
then
        display_usage
        exit 0
fi

dd if=/dev/urandom of=$FILE bs=1M count=$SIZE

scp $FILE $DEST:$FILE

LOCAL_CKSUM=$(cksum $FILE | awk '{ print $1 }')
REMOTE_CKSUM=$(ssh $DEST cksum $FILE | awk '{ print $1 }')

echo -e "The checksum on the local file is: "" $LOCAL_CKSUM.\n"
echo -e "The checksum on the remote file is: $REMOTE_CKSUM.\n"
