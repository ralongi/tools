#!/bin/bash

# Usage: nohup ping_check.sh $target_ip &

target_ip=$1
sleep_time=${sleep_time:-30s}

while [ 1 ]; do
	sleep $sleep_time
	ping -c1 $target_ip
	if [[ $? -eq 0 ]]; then
		notify-send -u critical -t 0 Test "$target_ip is now UP"
		break
	fi
done
exit 0
