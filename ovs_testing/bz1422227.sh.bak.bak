#!/bin/bash

iterations=$1
if [[ $# -lt 1 ]]; then iterations=10000; fi

ovsbr="bz1422227"

systemctl start openvswitch
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr

count=1
while [ $count -le $iterations ]; do
    echo "Iteration: $count"""
	#systemctl reset-failed openvswitch.service && sleep 1 && systemctl restart openvswitch && ovs-vsctl show
	systemctl start openvswitch && ovs-vsctl show
	if [[ $? -ne 0 ]]; thenq
		echo "ERROR MESSAGE ASSERTED!"
		exit 1
	fi
	let count=count+1
done

ovs-vsctl --if-exists del-br $ovsbr
