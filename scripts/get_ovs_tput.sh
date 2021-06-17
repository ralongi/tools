#!/bin/bash

# script to gather results from OVS manual scripts

target_dir="."
if [[ $# -gt 0 ]]; then target_dir=$1; fi
log_file=$target_dir/ovs_results.log
rm -f $log_file
file_list=$(ls $target_dir/mylog*.sum)
for i in $file_list; do
	avg=$(grep / $i | awk -F / '{ print $2 }' | tr -d " ")
	echo "Results from file: $i"
	sed -n 1,3p $i
	echo "The average is: $avg Mbps"
	echo "**********************************************************************"
done >> $log_file
