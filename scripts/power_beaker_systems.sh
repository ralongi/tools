#!/bin/bash

# script to manipulate power on beaker systems

action=$1
system_list=$2

if [[ $# -eq 2 ]]; then
	system_list=$2
else
	system_list=$(bkr system-list --mine)
fi

for system in $system_list; do bkr system-power --action $action $system; done
