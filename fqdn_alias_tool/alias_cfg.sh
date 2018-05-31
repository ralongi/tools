#!/bin/bash

#Populate the /etc/host.aliases file
# must be run as root
rm -f /etc/host.aliases
touch /etc/host.aliases && chmod 755 /etc/host.aliases

IFS=$'\n'

for line in $(cat ./host_list.txt); do
	if [[ ! $(grep $line /etc/host.aliases) ]]; then
		echo $line >> /etc/host.aliases
	fi
done

#Add entry to /etc/profile
if [[ ! $(grep 'export HOSTALIASES=/etc/host.aliases' /etc/profile) ]]; then
	echo "export HOSTALIASES=/etc/host.aliases" >> /etc/profile
fi

#Source /etc/profile to activate the changes
. /etc/profile

