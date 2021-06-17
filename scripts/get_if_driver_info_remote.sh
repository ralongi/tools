#!/bin/bash

# Script to log into target host and gather iface and driver info

target=$1

timeout 5s bash -c "until ping -c3 $target; do sleep 1s; done"
if [[ $? -ne 0 ]]; then
	echo "$target is not reachable.  Exiting test..."
	exit
fi

#cat /home/inf_ralongi/scripts/new_get_if_driver_info.sh | ssh root@$target 'bash -'
cat ./get_if_driver_info.sh | ssh root@$target 'bash -'

