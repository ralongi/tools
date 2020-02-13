#!/bin/bash

get_if_driver_info()
{
	back_to_back=${back_to_back:-"no"}
	if [[ -e /tmp/iface_driver_list.txt ]]; then rm -f /tmp/iface_driver_list.txt; fi
	local mgmt_iface=$(ip route | awk '/default/{match($0,"dev ([^ ]+)",M); print M[1]; exit}')
	local iface_list=$(find /sys/class/net/ -type l | awk -F'/' '!/lo|sit|usb|ib/{print $5}' | sort -u | egrep -v 'ovs|virbr|vnet|gre|int' | egrep -v "$mgmt_iface")
	for i in $iface_list; do ip link set dev $i up; done
	
	if [[ $back_to_back == "yes" ]]; then
		echo "Attempting to ping remote machine to make sure peer NIC in b2b connection is available (times out after 10 minutes)..."
		if i_am_client; then
			timeout 10m bash -c "until ping -c3 $SERVERS; do sleep 10; done"
		else
			timeout 10m bash -c "until ping -c3 $CLIENTS; do sleep 10; done"
		fi
		sleep 30
	else
		echo "Sleeping 30 seconds to allow all driver types to set link up..."
		sleep 30
		echo -e
	fi
	
	echo -e "Here is the current status for all interfaces on host $(hostname):"
	echo -e
	ip l l
	echo -e
	echo "This is the interface information for host "$(hostname):
	echo -e
	echo "The management interface is: $mgmt_iface"
	echo -e
	for i in $iface_list; do
		echo "Interface: "$i, "Driver: $(ethtool -i $i | grep driver | awk '{ print $2 }')", "Speed: $(ethtool $i | grep Speed | awk '{print $2}' | tr -d '[a-z A-Z /]') Mbps" >> /tmp/iface_driver_list.txt; done
	echo -e "Total interfaces currently available for test:"
	echo -e
	cat /tmp/iface_driver_list.txt | grep -v '!'
	one_g=$(grep -w 1000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	two_pt_five_g=$(grep -w 2500 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	five_g=$(grep -w 5000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	ten_g=$(grep -w 10000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	twenty_five_g=$(grep -w 25000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	forty_g=$(grep -w 40000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	fifty_g=$(grep -w 50000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	one_hundred_g=$(grep -w 100000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	two_hundred_g=$(grep -w 200000 /tmp/iface_driver_list.txt | awk '{print $2 " (" $4 ")"}' | tr -d ",")
	
	echo -e
	if [[ -z "$one_g" ]]; then 
		echo -e "1G interfaces currently available for test: NONE"
	else
		echo -e "1G interfaces currently available for test: "
		echo "$one_g"
	fi
	echo -e	
	if [[ -z "$two_pt_five_g" ]]; then 
		echo -e "2.5G interfaces currently available for test: NONE"
	else
		echo -e "2.5G interfaces currently available for test: "
		echo "$two_pt_five_g"
	fi
	echo -e	
	if [[ -z "$five_g" ]]; then 
		echo -e "5G interfaces currently available for test: NONE"
	else
		echo -e "5G interfaces currently available for test: "
		echo "$five_g"
	fi
	echo -e	
	if [[ -z "$ten_g" ]]; then 
		echo -e "10G interfaces currently available for test: NONE"
	else
		echo -e "10G interfaces currently available for test: "
		echo "$ten_g"
	fi
	echo -e	
	if [[ -z "$twenty_five_g" ]]; then 
		echo -e "25G interfaces currently available for test: NONE"
	else
		echo -e "25G interfaces currently available for test: "
		echo "$twenty_five_g"
	fi
	echo -e
	if [[ -z "$forty_g" ]]; then 
		echo -e "40G interfaces currently available for test: NONE"
	else
		echo -e "40G interfaces currently available for test: "
		echo "$forty_g"
	fi
	echo -e
	if [[ -z "$fifty_g" ]]; then 
		echo -e "50G interfaces currently available for test: NONE"
	else
		echo -e "50G interfaces currently available for test: "
		echo "$fifty_g"
	fi
	echo -e
	if [[ -z "$one_hundred_g" ]]; then 
		echo -e "100G interfaces currently available for test: NONE"
	else
		echo -e "100G interfaces currently available for test: "
		echo "$one_hundred_g"
	fi
	echo -e	
	if [[ -z "$two_hundred_g" ]]; then 
		echo -e "200G interfaces currently available for test: NONE"
	else
		echo -e "200G interfaces currently available for test: "
		echo "$two_hundred_g"
	fi
	echo -e
	echo -e "Interfaces unavailable for test due to no detected link or port speed: "
	cat /tmp/iface_driver_list.txt | grep '!'
	echo -e
}

get_if_driver_info
