#!/bin/bash
# Script to report the latest compose ID and associated kernel for the major RHEL version provided by the user

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

rhel_ver=$1
if [[ $# -lt 1 ]]; then
	echo "Please provide a valid major RHEL version."
	echo "Usage $0 <Major RHEL version>"
	echo  "Example: $0 7"
	exit 0
fi
 # get RHEL info
base_dir="/net/ntap-bos-c01-eng01-nfs01a.storage.bos.redhat.com/devops_engineering_nfs/devarchive/redhat/rel-eng"
ls "$base_dir"/latest-RHEL-"$rhel_ver"/compose/Server/x86_64/os/Packages/kernel* | awk -F "/" '{print $14}' > /tmp/results.txt
kernel=$(head -n1 /tmp/results.txt)
compose_id=$(cat "$base_dir"/latest-RHEL-"$rhel_ver"/COMPOSE_ID)

# get RHEL-ALT info
ls "$base_dir"/latest-RHEL-ALT-"$rhel_ver"/compose/Server/x86_64/os/Packages/kernel* | awk -F "/" '{print $14}' > /tmp/results.txt
alt_kernel=$(head -n1 /tmp/results.txt)
alt_compose_id=$(cat "$base_dir"/latest-RHEL-ALT-"$rhel_ver"/COMPOSE_ID)

echo ""
echo "RHEL info:"
echo "The latest RHEL $rhel_ver compose ID is: $compose_id"
echo "The associated kernel is: $kernel"

echo ""
echo "RHEL ALT info:"
echo "The latest RHEL-ALT $rhel_ver compose ID is: $alt_compose_id"
echo "The associated kernel is: $alt_kernel"
echo ""
