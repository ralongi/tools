#!/bin/bash

# script to kick off OVS tests 

# First update and check in kernel/networking/openvswitch/common/package_list.sh
# Confirm that the target tests to be run are uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_my_ovs_tests_template.sh
# Confirm that the correct test is uncommented in /home/ralongi/inf_ralongi/Documents/ovs_testing/exec_topo.sh, exec_ovs_memory_leak_soak.sh

# requires user input for FDP relase, RHEL version and FDP stream
# example syntax: run_ovs_tests.sh 21e 8.4 2.13

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag

display_usage()
{
	echo "This script will kick off OVS tests based on parameters provided."
	echo "Usage: $0 <FDP Release> <RHEL Version> <FDP Stream>"
	echo "Example: $0 21e 8.4 2.13"
	echo "To use a specific compose (versus using latest), first execute 'export COMPOSE=<COMPOSE_ID>' in terminal window"
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
export FDP_STREAM2=$(echo $FDP_STREAM | tr -d '.')
if [[ $FDP_STREAM2 -gt 213 ]]; then
	YEAR=$(grep -i ovn /home/ralongi/git/kernel/networking/openvswitch/common/package_list.sh | grep $FDP_RELEASE | awk -F "_" '{print $3}' | grep -v 213 | tail -n1)
fi

pushd /home/ralongi/github/tools/ovs_testing
/bin/cp -f exec_my_ovs_tests_template.sh exec_my_ovs_tests.sh
sed -i "s/FDP_RELEASE_VALUE/$FDP_RELEASE/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_VALUE/$RHEL_VER/g" exec_my_ovs_tests.sh
sed -i "s/FDP_STREAM_VALUE/$FDP_STREAM2/g" exec_my_ovs_tests.sh
sed -i "s/YEAR_VALUE/$YEAR/g" exec_my_ovs_tests.sh
sed -i "s/RHEL_VER_MAJOR_VALUE/$RHEL_VER_MAJOR/g" exec_my_ovs_tests.sh

# new code
tests=$(grep "OVS-$FDP_STREAM-RHEL-$RHEL_VER_MAJOR-Tests" ~/github/tools/scripts/fdp_errata_list.txt | awk -F ":" '{print $NF}')

for i in $tests; do
	if [[ $i == *"mcast_snoop"* ]]; then
		sed -i '/exec_mcast_snoop.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_qos"* ]]; then
		sed -i '/exec_ovs_qos.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"forward_bpdu"* ]]; then
		sed -i '/exec_forward_bpdu.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"of_rules"* ]]; then
		sed -i '/exec_of_rules.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"power_cycle_crash"* ]]; then
		sed -i '/exec_power_cycle_crash.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_upgrade"* ]]; then
		sed -i '/exec_ovs_upgrade.sh/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_ixgbe"* ]]; then
		sed -i '/exec_topo.sh ixgbe/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_i40e"* ]]; then
		sed -i '/exec_topo.sh i40e/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_arm"* ]]; then
		sed -i '/exec_topo.sh arm/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_mlx5_core_cx5"* ]]; then
		sed -i '/exec_topo.sh mlx5_core cx5/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"topo_mlx5_core_cx6"* ]]; then
		sed -i '/exec_topo.sh mlx5_core cx6/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"endurance_cx6"* ]]; then
		sed -i '/exec_endurance.sh cx6/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"perf_ci_cx6"* ]]; then
		sed -i '/exec_perf_ci.sh cx6/s/^#//g' exec_my_ovs_tests.sh
	elif [[ $i == *"ovs_memory_leak_soak_i40e"* ]]; then
		/bin/cp -f exec_ovs_memory_leak_soak_template.sh exec_ovs_memory_leak_soak.sh
		sed -i '/exec_ovs_memory_leak_soak.sh/s/^#//g' exec_my_ovs_tests.sh
		sed -i 's/dut:-""/dut:-"wsfd-advnetlab34.anl.lab.eng.bos.redhat.com"/g' exec_ovs_memory_leak_soak.sh
		sed -i 's/NIC_DRIVER:-""/NIC_DRIVER:-"i40e"/g' exec_ovs_memory_leak_soak.sh
	elif [[ $i == *"ovs_memory_leak_soak_mlx5_core"* ]]; then
		/bin/cp -f exec_ovs_memory_leak_soak_template.sh exec_ovs_memory_leak_soak.sh
		sed -i '/exec_ovs_memory_leak_soak.sh/s/^#//g' exec_my_ovs_tests.sh
		sed -i 's/dut:-""/dut:-"wsfd-advnetlab33.anl.lab.eng.bos.redhat.com"/g' exec_ovs_memory_leak_soak.sh
		sed -i 's/NIC_DRIVER:-""/NIC_DRIVER:-"mlx5_core"/g' exec_ovs_memory_leak_soak.sh
	fi
done

./exec_my_ovs_tests.sh

popd


