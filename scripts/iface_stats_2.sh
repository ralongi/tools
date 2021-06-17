#!/bin/bash
#set -x

iface1=$1
if [[ $# -eq 2 ]]; then iface2=$2; fi
#if [[ $# -lt 1 ]]; then iface="p5p1"; fi

iface1_tx1=$(cat /sys/class/net/$iface1/statistics/tx_packets)
iface1_rx1=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com cat /sys/class/net/$iface1/statistics/rx_packets)

if [[ $iface2 ]]; then
	iface2_tx1=$(cat /sys/class/net/$iface2/statistics/tx_packets)
	iface2_rx1=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com cat /sys/class/net/$iface2/statistics/rx_packets)
fi

. ~/.bashrc &>/dev/null
#ovs-perf
netperf -H 192.168.100.8 -L 192.168.100.7

iface1_tx2=$(cat /sys/class/net/$iface1/statistics/tx_packets)
iface1_rx2=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com cat /sys/class/net/$iface1/statistics/rx_packets)

if [[ $iface2 ]]; then
	iface2_tx2=$(cat /sys/class/net/$iface2/statistics/tx_packets)
	iface2_rx2=$(ssh root@netqe8.knqe.lab.eng.bos.redhat.com cat /sys/class/net/$iface2/statistics/rx_packets)
fi

iface1_tx_bytes=$(($iface1_tx2 - $iface1_tx1))
iface1_rx_bytes=$(($iface1_rx2 - $iface1_rx1))

if [[ $iface2 ]]; then
	iface2_tx_bytes=$(($iface2_tx2 - $iface2_tx1))
	iface2_rx_bytes=$(($iface2_rx2 - $iface2_rx1))
fi

iface1_result=$(($iface1_tx_bytes - $iface1_rx_bytes))
if [[ $iface2 ]]; then iface2_result=$(($iface2_tx_bytes - $iface2_rx_bytes)); fi
iface1_pct=$(echo "scale=2; $iface1_result*100/$iface1_tx_bytes" | bc)
if [[ $iface2 ]]; then iface2_pct=$(echo "scale=2; $iface2_result*100/$iface2_tx_bytes" | bc); fi

echo "Total bytes transmitted from local interface $iface1: $iface1_tx_bytes"
echo "Total bytes received on remote interface $iface1: $iface1_rx_bytes"
echo ""
if [[ $iface2 ]]; then
	echo "Total bytes transmitted from local interface $iface2: $iface2_tx_bytes"
	echo "Total bytes received on remote interface $iface2: $iface2_rx_bytes"
	echo ""
fi
echo "Total bytes lost on interface $iface1: $iface1_result"
if [[ $iface2 ]]; then echo "Total bytes lost on interface $iface2: $iface2_result"; fi
echo ""
echo "Byte loss percentage on interface $iface1: $iface1_pct%"
if [[ $iface2 ]]; then echo "Byte loss percentage on interface $iface2: $iface2_pct%"; fi
echo ""

if [[ $iface1_result -gt 0 ]]; then
	echo "$iface1_result bytes were dropped on interface $iface1"
else
	echo "Nothing was dropped on interface $iface1"
fi

if [[ $iface2 ]]; then
	if [[ $iface2_result -gt 0 ]]; then
        	echo "$iface2_result bytes were dropped on interface $iface2"
	else
        	echo "Nothing was dropped on interface $iface2"
	fi
fi
