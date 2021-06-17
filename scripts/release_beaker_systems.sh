#!/bin/bash

# script to release beaker systems

. /home/ralongi/.bashrc > /dev/null

system_list=$1

if [[ $# -eq 2 ]]; then
    if [[ $(fqdn $system_list) ]]; then
            system_list=$(fqdn $system_list)
    else
            system_list=$2
    fi
else
	system_list=$(bkr system-list --mine)
fi

for system in $system_list; do bkr system-release $system; done
