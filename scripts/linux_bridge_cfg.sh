#!/bin/bash

br_con_name=$1
if_name=$2
ipv4_address=$3
slave_con_name=$4
slave_if=$5

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

nmcli con add con-name br0 ifname br0 type bridge ip4 192.168.88.100/24
nmcli con add type bridge-slave con-name br0-slave-1 ifname enp7s0f1 master br0
nmcli con up br0





ovs-vsctl del-br $1
ovs-vsctl add-br $1
ovs-vsctl add-port $1 $2
ovs-vsctl add-port $1 $3 -- set interface $3 type=internal
ifconfig $3 $4

