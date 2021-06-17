#!/bin/bash

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
#RHEL_VER=${RHEL_VER:-""}
RHEL_VER_MAJOR=$(echo $RHEL_VER | awk -F "." '{print $1}')

# Script to execute all of my ovs tests

source ~/git/kernel/networking/openvswitch/common/package_list.sh

use_hpe_synergy=${use_hpe_synergy:-"no"}

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

netscout_cable()
{
	rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	local port1=$(echo $1 | tr '[:lower:]' '[:upper:]')
	local port2=$(echo $2 | tr '[:lower:]' '[:upper:]')
	# possible netscout switches: bos_3200  bos_3903  nay_3200  nay_3901
	# set this in runtest.sh as necessary
	netscout_switch=${netscout_switch:-"bos_3903"}
	
	if [[ "$rhel_version" -eq 8 ]]; then
		pushd /home/NetScout/
		rm -f settings.cfg
		wget -O ./settings.cfg http://netqe-infra01.knqe.lab.eng.bos.redhat.com/NSConn/"$netscout_switch".cfg
		sleep 2
		python3 /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
		popd
	elif [[ "$rhel_version" -eq 7 ]]; then	
		scl enable rh-python34 - << EOF
			pushd /home/NetScout/
			rm -f settings.cfg
			wget -O ./settings.cfg http://netqe-infra01.knqe.lab.eng.bos.redhat.com/NSConn/"$netscout_switch".cfg
			sleep 2
			python /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
			popd
EOF
	fi
}

# RHEL composes

/home/ralongi/inf_ralongi/scripts/get_beaker_compose_id.sh $RHEL_VER && export COMPOSE=$(/home/ralongi/gvar/bin/gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $COMPOSE"

# Netperf package
export SRC_NETPERF="http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/tools/netperf-20210121.tar.bz2"

# VM image names
export VM_IMAGE="rhelRHEL_VER_VALUE.qcow2"

# OVS packages

export RPM_OVS=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHELRHEL_VER_MAJOR_VALUE

# SELinux packages
export RPM_OVS_SELINUX_EXTRA_POLICY=$OVS_SELINUX_FDP_RELEASE_VALUE_RHELRHEL_VER_MAJOR_VALUE

#DPDK packages

export RPM_DPDK_RHEL7=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-18.11.8-1.el7_8.x86_64.rpm
export RPM_DPDK_TOOLS_RHEL7=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-tools-18.11.8-1.el7_8.x86_64.rpm

if [[ $(echo $COMPOSE | grep RHEL-8.2) ]]; then
	export RPM_DPDK_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-19.11-5.el8_2.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-tools-19.11-5.el8_2.x86_64.rpm
elif [[ $(echo $COMPOSE | grep RHEL-8.3) ]]; then
	export RPM_DPDK_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-19.11.3-1.el8.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-tools-19.11.3-1.el8.x86_64.rpm
elif [[ $(echo $COMPOSE | grep RHEL-8.4) ]]; then
	export RPM_DPDK_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-20.11-3.el8.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-tools-20.11-3.el8.x86_64.rpm
elif [[ $(echo $COMPOSE | grep RHEL-9) ]]; then
	export RPM_DPDK_RHEL9=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/20.11/2.el9/x86_64/dpdk-20.11-2.el9.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL9=http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/20.11/2.el9/x86_64/dpdk-tools-20.11-2.el9.x86_64.rpm
fi

# For rpm_dpdk variable used by openvswitch/perf tests
export rpm_dpdk=$RPM_DPDK_RHELRHEL_VER_MAJOR_VALUE
export rpm_dpdk_tools=$RPM_DPDK_TOOLS_RHELRHEL_VER_MAJOR_VALUE

# QEMU packages
export QEMU_KVM_RHEV_RHEL7=http://download-node-02.eng.bos.redhat.com/brewroot/packages/qemu-kvm-rhev/2.12.0/48.el7_9.2/x86_64/qemu-kvm-rhev-2.12.0-48.el7_9.2.x86_64.rpm

# OVN packages
export RPM_OVN=$OVNFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHELRHEL_VER_MAJOR_VALUE 

export BONDING_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

export GRE_IPV6_TESTS="ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"

#pushd /home/ralongi/Documents/ovs_testing
#pushd /home/ralongi/global_docs/ovs_testing
pushd /home/ralongi/inf_ralongi/Documents/ovs_testing

###############################################################################
# USE rhel8.3 VM IMAGE for mcast_snoop tests for now to avoid problems with IPv6 tests
export VM_IMAGE=rhel8.3.qcow2
#./exec_mcast_snoop.sh
export VM_IMAGE="rhelRHEL_VER_VALUE.qcow2"
###############################################################################
#./exec_ovs_qos.sh
#./exec_forward_bpdu.sh
#./exec_of_rules.sh
#./exec_power_cycle_crash.sh
#./exec_topo.sh ixgbe
#./exec_topo.sh i40e
#./exec_topo.sh enic
#./exec_topo.sh mlx5_core cx5
#./exec_topo.sh mlx5_core cx6
#./exec_topo.sh qede
#./exec_topo.sh bnxt_en
#./exec_topo.sh nfp
#./exec_topo.sh ice
#./exec_sanity_check.sh

#./exec_ovs_memory_leak_soak.sh
#./exec_ovn_memory_leak_soak.sh

###############################################################################
# set VM_IMAGE value to full URL for per_ci test
# may need to create proper image for westford or point to bj image
export VM_IMAGE=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/vms/OVS/rhelRHEL_VER_VALUE.qcow2
#./exec_perf_ci.sh cx5
#./exec_perf_ci.sh cx6
export VM_IMAGE="rhelRHEL_VER_VALUE.qcow2"
###############################################################################

# Conntrack firewall rules Jiying Qiu (not related to driver)
# openvswitch/conntrack2 and openvswitch/conntrack_dpdk
#./exec_conntrack2.sh
#./exec_conntrack_dpdk.sh

# Stateful traffic Xena (by speed)
# openvswitch/conntrack3/ct_kernel and openvswitch/conntrack3/ct_userspace
# Google sheet: https://docs.google.com/spreadsheets/d/1cPG1ovmrCo1RhAMGVfK9SgKIEtj7yocjYP_CDvLUfYY/edit?usp=sharing
#./exec_ct_kernel.sh
#./exec_ct_userspace.sh

# ovs-dpdk-conntrack
# Google sheet: https://docs.google.com/spreadsheets/d/17MKqKpCmVV93dhCawgD-xxAm3aQweV5yszb82A-L-Kk/edit?usp=sharing
# search for "disable emc" and then "enable emc" in taskout.log file
#./exec_ovs_dpdk_conntrack.sh

# ovs-kernel-conntrack
# Google sheet: https://docs.google.com/spreadsheets/d/1qku7ViuVgAwWXobQjekv1JxNvfQ4rgjCOBX0NTeda9o/edit?usp=sharing
# search for "disable emc" and then "enable emc" in taskout.log file
#./exec_ovs_kernel_conntrack.sh

# ovs-dpdk-latency
# Google sheet: https://docs.google.com/spreadsheets/d/11BqpCkXoUXTVH4s0uMGZ4ieBOZzUNjbYS9E-3CxYIpI/edit?usp=sharing
# search for "Flows:" in taskout.log file
#./exec_ovs_dpdk_latency.sh

# xena_conntrack/xena_dpdk
#./exec_xena_dpdk.sh

### need to add upgrade tests
### need to add vm_100

popd
