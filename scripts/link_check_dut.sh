#!/bin/bash

# To be run on target system/DUT
# Usage: nohup link_check_dut.sh &

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
iface1=${iface1:-"ens1f0"}
iface2=${iface2:-"ens1f1"}
sleep_time=${sleep_time:-30m}

rm -f /tmp/no_link.txt

while [ 1 ]; do
	sleep $sleep_time
    if [[ $(ip link show $iface1 | grep 'NO-CARRIER') ]] || [[ $(ip link show $iface2 | grep 'NO-CARRIER') ]]; then
		echo "No link" > /tmp/no_link.txt
		break
    fi
done
exit 0
