#!/bin/bash
. /home/ralongi/scripts/bash_functions

set -x
set -e

#Create variables to be used with functions
LOCAL4=192.168.88.100/24
LOCAL6=2014::1/64
REMOTE4=192.168.88.200/24
REMOTE6=2014::2/64
IFACE=p2p1
CON_NAME=static-p2p1
MTU=1500
NETSERVER_IP4=$(echo $REMOTE4 | awk -F / '{ print $1 }')
NETSERVER_IP6=$(echo $REMOTE6 | awk -F / '{ print $1 }')


#Configure IP addresses, MTU and start netserver
nmcli_con_del $CON_NAME
nmcli_cfg_ip $CON_NAME $IFACE $REMOTE4 $REMOTE6
nmcli_cfg_mtu $MTU $CON_NAME
nmcli_con_up $CON_NAME
netserver4 $NETSERVER_IP4 || :
sleep 2
netserver6 $NETSERVER_IP6 || :
