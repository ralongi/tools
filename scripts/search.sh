#!/bin/bash

# script that greps for string provided in static list of locations referenced in $dir_list below
$dbg_flag
search_string=$1

display_usage()
{
    echo "This tool will recursively grep for the string provided (case insensitive) only in the static list of directories referenced as dir_list in $0"
    echo "Please provide a string to be searched ($0 <string>)."
    echo "Example: $0 rhel_version="
    exit 0
}

if [[ -z $search_string ]] || [[ $1 == "-h" ]]; then
    display_usage
fi

dir_list='/home/ralongi/git/my_fork/kernel/networking/openvswitch/common /home/ralongi/git/my_fork/kernel/networking/openvswitch/mcast_snoop /home/ralongi/git/my_fork/kernel/networking/openvswitch/topo /home/ralongi/git/my_fork/kernel/networking/openvswitch/sanity_check /home/ralongi/git/my_fork/kernel/networking/openvswitch/forward_bpdu /home/ralongi/git/my_fork/kernel/networking/openvswitch/ovs_upgrade /home/ralongi/git/my_fork/kernel/networking/openvswitch/ovs_qos /home/ralongi/git/my_fork/kernel/networking/openvswitch/memory_leak_soak /home/ralongi/git/my_fork/kernel/networking/openvswitch/of_rules /home/ralongi/git/my_fork/kernel/networking/openvswitch/power_cycle_crash/set_config /home/ralongi/git/my_fork/kernel/networking/openvswitch/power_cycle_crash/check_config /home/ralongi/github/tools/ovs_testing /home/ralongi/git/my_fork/kernel/networking/common'

rm -f ~/temp/search_results.txt

for i in $dir_list; do
    echo "" >> ~/temp/search_results.txt
    echo "Directory being searched: $i" >> ~/temp/search_results.txt
    echo "" >> ~/temp/search_results.txt
    grep -Ri $search_string "$i"/* >> ~/temp/search_results.txt
    echo "" >> ~/temp/search_results.txt
done

more ~/temp/search_results.txt
rm -f ~/temp/search_results.txt
