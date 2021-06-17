#!/bin/bash

# script to kick off OVS tests 

# First update and check in kernel/networking/openvswitch/common/package_list.sh
# Confirm that the target tests to be run are uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_my_ovs_tests_template.sh
# Confirm that the correct test is uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_topo.sh, exec_ovs_memory_leak_soak.sh

# requires user input for FDP relase, RHEL version and FDP stream
# example syntax: run_ovs_tests.sh 21e 8.4 2.13

display_usage()
{
	echo "This script will kick off OVS tests based on parameters provided."
	echo "Usage: $0 <FDP Release> <RHEL Version> <FDP Stream>"
	echo "Example: $0 21e 8.4 2.13"
	exit 0
}

if [[ $# -lt 3 ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]]	|| [[ $1 = "-?" ]]; then
	display_usage
fi

export FDP_RELEASE=${FDP_RELEASE:-"$1"}
export FDP_RELEASE=$(echo $FDP_RELEASE | tr '[:lower:]' '[:upper:]')

export RHEL_VER=${RHEL_VER:-"$2"}
export RHEL_VER_MAJOR=$(echo $RHEL_VER | awk -F "." '{print $1}')

export FDP_STREAM=${FDP_STREAM:-"$3"}
export FDP_STREAM=$(echo $FDP_STREAM | tr -d '.')

pushd ~/inf_ralongi/Documents/ovs_testing
/bin/cp -f exec_my_ovs_tests_template.sh exec_my_ovs_tests.sh
sed -i "s/FDP_RELEASE_VALUE/$FDP_RELEASE/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_VALUE/$RHEL_VER/g" exec_my_ovs_tests.sh
sed -i "s/FDP_STREAM_VALUE/$FDP_STREAM/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_MAJOR_VALUE/$RHEL_VER_MAJOR/g" exec_my_ovs_tests.sh

./exec_my_ovs_tests.sh

popd


