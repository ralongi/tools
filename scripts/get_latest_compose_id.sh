#!/bin/bash
# Script to report the latest compose ID and associated kernel for the major RHEL version provided by the user

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

rhel_minor_ver=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide a valid mijor RHEL version."
	echo "Usage $0 <Mijor RHEL version>"
	echo  "Example: $0 7.6"
	exit 0
fi

latest_compose_id=$(curl -s https://beaker.engineering.redhat.com/distrotrees/?simplesearch=rhel-$rhel_minor_ver | grep '/distros/view' | grep -v '.n' | head -n1 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')

echo ""
echo "The latest RHEL $rhel_minor_ver compose available in beaker is: $latest_compose_id"
echo ""

