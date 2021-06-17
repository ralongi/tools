#!/bin/bash

br_name=$1
br_phys_port=$2
br_int_port_name=$3
br_port_ip=$4

#create the display usage to be presented to the user
display_usage(){
	echo -e "\nUsage: \n$0 [bridge name] [bridge physical port] [bridge internal port name] [bridge port IP address with CIDR]"
	echo -e "Example: \n$0 ovsbr0 p6p1 int0 192.168.100.100/24"
	}

#if less than 3 arguments are supplied by the user, display usage
if [ $# -lt 3 ]
then
	display_usage
	exit 1
fi

#check whether user has supplied -h or --help or help or -?.  if yes, display usage
if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" ]]
then
        display_usage
        exit 0
fi

ovs-vsctl del-br $1
ovs-vsctl add-br $1
ovs-vsctl add-port $1 $2
ovs-vsctl add-port $1 $3 -- set interface $3 type=internal
ifconfig $3 $4
