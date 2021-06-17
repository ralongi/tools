#!/bin/bash

#target_file=${target_file:-"/var/lib/libvirt/images/master.qcow2"}
target_file=$1
if [ $# -lt 1 ]; then
	target_file="/var/lib/libvirt/images/master.qcow2"
fi
expected_file_size=1724186624

if [ ! $(ls $target_file) ]; then
	echo "$target_file does not exist.  Exiting..."
	exit 0
fi

check_file_size()
{
	current_file_size=$(ls -alt $target_file | awk '{print $5}')
	echo "Current file size of $target_file is: $current_file_size"
}

echo "Monitoring file size of $target_file..."

SECONDS=0
check_file_size
while [ "$current_file_size" != "$expected_file_size" ]; do
	echo "Sleeping 30 seconds..."
	sleep 30
	check_file_size
done

time_to_execute=$SECONDS

echo "Time taken to achieve expected file size of $expected_file_size: $time_to_execute seconds"


