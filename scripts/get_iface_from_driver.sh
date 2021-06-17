#!/bin/bash

driver=$1

mgmt_iface=$(ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}')
iface_list=$(find /sys/class/net/ -type l | awk -F'/' '!/lo|sit|usb|ib/{print $5}' | sort -u | egrep -v 'ovs|virbr|vnet|gre|int' | egrep -v "$mgmt_iface")
rm -f /tmp/$driver"_list.txt"

for i in $iface_list; do
	ethtool -i $i | grep -q $driver
	if [[ $? -eq 0 ]]; then
		echo $i >> /tmp/$driver"_list.txt"
	fi
done

if [[ -s /tmp/$driver"_list.txt" ]]; then
	echo -e "$driver interfaces:\n"
	cat /tmp/$driver"_list.txt"
fi


