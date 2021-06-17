#!/bin/bash

# get list of interfaces and drivers and save it to a file

get_iface_driver()
{
	iface_list=$(ip l l | grep BROADCAST | awk -F ":" '{ print $2 }')
	drivers=$(for i in $iface_list; do ethtool -i $i | grep driver | awk '{ print $2 }'; done)

	echo $iface_list
	echo $drivers
}

get_iface_driver > file.tmp


# get the number of columns/records per line

records=$(awk 'FNR == 1 { print NF }' file.tmp)




