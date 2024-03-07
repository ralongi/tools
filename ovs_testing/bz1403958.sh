#!/bin/bash

ovsbr="ovsbr0"

red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

check_result()
{
	if [[ $? -eq 0 ]]; then
		echo "Test: ${green} PASSED${reset}"
	else
		echo "Test: ${red} FAILED${reset}"
	fi
}
bridge_list=$(ovs-vsctl show | grep Bridge | awk '{print $2}' | tr -d '"')
for i in $bridge_list; do ovs-vsctl del-br $i; done
pkill ovs
systemctl stop openvswitch
pgrep ovs-vswitchd
check_result
pgrep ovsdb-server
check_result
rpm -e openvswitch

rpm -ivh http://download.devel.redhat.com/brewroot/packages/openvswitch/2.5.0/14.git20160727.el7fdp/x86_64/openvswitch-2.5.0-14.git20160727.el7fdp.x86_64.rpm
systemctl enable openvswitch.service
systemctl restart openvswitch.service
sleep 3
pgrep ovs-vswitchd && check_result
pgrep ovsdb-server && check_result
ovs-vsctl add-br $ovsbr && check_result
ovs-vsctl show | grep $ovsbr && check_result

rpm -Uvh http://download.devel.redhat.com/brewroot/packages/openvswitch/2.5.0/22.git20160727.el7fdp/x86_64/openvswitch-2.5.0-22.git20160727.el7fdp.x86_64.rpm
sleep 3
pgrep ovs-vswitchd
check_result
pgrep ovsdb-server
check_result
systemctl restart openvswitch.service
sleep 3
pgrep ovs-vswitchd
check_result
pgrep ovsdb-server
check_result
ovs-vsctl show | grep $ovsbr
check_result

