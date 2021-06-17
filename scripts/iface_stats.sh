#!/bin/bash
#set -x

iface=$1
if [[ $# -lt 1 ]]; then iface="p5p1"; fi


tx1=$(ifconfig | grep -A7 $iface | grep "TX bytes" | awk '{print $6}' | awk -F ":" '{print $2}')
rx1=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com ifconfig | grep -A7 $iface | grep "RX bytes" | awk '{print $2}' | awk -F ":" '{print $2}')

. ~/.bashrc &>/dev/null
ovs-perf

tx2=$(ifconfig | grep -A7 $iface | grep "TX bytes" | awk '{print $6}' | awk -F ":" '{print $2}')

rx2=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com ifconfig | grep -A7 $iface | grep "RX bytes" | awk '{print $2}' | awk -F ":" '{print $2}')

tx_bytes=$(($tx2 - $tx1))
rx_bytes=$(($rx2 - $rx1))

result=$(($tx_bytes - $rx_bytes))
pct=$(echo "scale=0; $result*100/$tx_bytes" | bc)

echo "Total bytes transmitted from local interface $iface: $tx_bytes"
echo "Total bytes received on remote interface $iface: $rx_bytes"
echo "Total bytes lost: $result"
echo "Byte loss percentage: $pct%"

if [[ $result -gt 0 ]]; then
        echo "$result bytes were dropped!"
else
        echo "Nothing was dropped"
fi

