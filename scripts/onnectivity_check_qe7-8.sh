#!/bin/bash
set -x


host=$(hostname)
if [[ $host == "netqe7.knqe.lab.eng.bos.redhat.com" ]]; then
        ip4addr="192.168.100.7"
        ip4addr_peer="192.168.100.8"
else
        ip4addr="192.168.100.8"
        ip4addr_peer="192.168.100.7"
fi

result_file="/tmp/connectivity_check.log"
rm -f $result_file

iface_list="em1 em2 p1p1 p1p2 p2p1 p3p1 p3p2 p5p1 p5p2 p6p1 p6p2 p7p1 p7p2"

for i in $iface_list; do
		ip n flush all
        ip link set dev $i up
        ip addr flush dev $i
        ip addr add dev $i $ip4addr/24
        sleep 10
        ping -c3 $ip4addr_peer
        if [[ $? -ne 0 ]]; then echo "$i ping failed" >> $result_file; ip add | grep -A3 $i >> $result_file; echo "**************" >> $result_file; fi
        sleep 2
        ip addr flush dev $i
done

