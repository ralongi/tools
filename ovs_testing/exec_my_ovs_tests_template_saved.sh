#!/bin/bash

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

# Script to execute all of my ovs tests

skip_rhel7_ovs29=${skip_ovs29:-"no"}
skip_rhel7_ovs211=${skip_ovs211:-"no"}
skip_rhel8_ovs211=${skip_ovs211:-"no"}
skip_rhel7_ovs213=${skip_ovs213:-"no"}
skip_rhel8_ovs213=${skip_ovs213:-"no"}
skip_rhel8_ovs215=${skip_ovs213:-"no"}

# Set above variables in ./exec_tests_variables.sh to determine which jobs should run
#source ./exec_tests_variables.sh
source ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh

use_hpe_synergy=${use_hpe_synergy:-"no"}

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

netscout_cable()
{
	RHEL_VERsion=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	local port1=$(echo $1 | tr '[:lower:]' '[:upper:]')
	local port2=$(echo $2 | tr '[:lower:]' '[:upper:]')
	# possible netscout switches: bos_3200  bos_3903  nay_3200  nay_3901
	# set this in runtest.sh as necessary --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	netscout_switch=${netscout_switch:-"bos_3903"}
	
	if [[ "$RHEL_VERsion" -eq 8 ]]; then
		pushd /home/NetScout/
		rm -f settings.cfg
		wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
		sleep 2
		python3 /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
		popd 2>/dev/null
	elif [[ "$RHEL_VERsion" -eq 7 ]]; then	
		scl enable rh-python34 - << EOF
			pushd /home/NetScout/
			rm -f settings.cfg
			wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
			sleep 2
			python /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
			popd 2>/dev/null
EOF
	fi
}

# RHEL composes

# RHEL-7.9
if [[ $RHEL_VER == 7.9 ]]; then
	gc 7.9 &&  RHEL7_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL7_COMPOSE"
fi

# RHEL-8.2
if [[ $RHEL_VER == 8.2 ]]; then
	gc 8.2 && RHEL8_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL8_COMPOSE"
fi

# RHEL-8.3
if [[ $RHEL_VER == 8.3 ]]; then
	gc 8.3 && RHEL8_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL8_COMPOSE"
fi

# RHEL-8.4
if [[ $RHEL_VER == 8.4 ]]; then
	gc 8.4 && RHEL8_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL8_COMPOSE"
fi

# RHEL-8.5
if [[ $RHEL_VER == 8.5 ]]; then
	gc 8.5 && RHEL8_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL8_COMPOSE"
fi

# RHEL-9.0
if [[ $RHEL_VER == 9.0 ]]; then
	gc 9.0 && RHEL9_COMPOSE=$(gvar $latest_compose_id | awk -F "=" '{print $NF}') && echo "Using compose: $RHEL9_COMPOSE"
fi

# FDP Release
export FDP_RELEASE="FDP FDP_RELEASE_VALUE"
export fdp_release=$(echo $FDP_RELEASE | awk '{print $NF }')
#export FDP_RELEASE="RHEL-9.0 Testing"

# Netperf package
SRC_NETPERF="http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/tools/netperf-20210121.tar.bz2"

# VM image names
export VM_IMAGE="rhelREL_VER_VALUE.qcow2"

# OVS packages
# 2.9
export RPM_OVS29_RHEL7=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL7

# 2.11 (RHEL 7)
export RPM_OVS211_RHEL7=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL7

# 2.11 (RHEL8)
export RPM_OVS211_RHEL8=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL8

# 2.13 (RHEL7)
export RPM_OVS213_RHEL7=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL7

# 2.13 (RHEL8)
export RPM_OVS213_RHEL8=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL8

# 2.15 (RHEL8)
export RPM_OVS215_RHEL8=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL8

# 2.15 (RHEL9)
export RPM_OVS215_RHEL9=$OVSFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL9

# SELinux packages
export RPM_CONTAINER_SELINUX_POLICY=http://download.devel.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm

export RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7=$OVS_SELINUX_FDP_RELEASE_VALUE_RHEL7

export RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8=$OVS_SELINUX_FDP_RELEASE_VALUE_RHEL8

export RPM_OVS_SELINUX_EXTRA_POLICY_RHEL9=$OVS_SELINUX_FDP_RELEASE_VALUE_RHEL8

#DPDK packages

export RPM_DPDK_RHEL7=http://download.devel.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-18.11.8-1.el7_8.x86_64.rpm
export RPM_DPDK_TOOLS_RHEL7=http://download.devel.redhat.com/brewroot/packages/dpdk/18.11.8/1.el7_8/x86_64/dpdk-tools-18.11.8-1.el7_8.x86_64.rpm

if [[ $(echo $RHEL8_COMPOSE | grep RHEL-8.2) ]]; then
	export RPM_DPDK_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-19.11-5.el8_2.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11/5.el8_2/x86_64/dpdk-tools-19.11-5.el8_2.x86_64.rpm
elif [[ $(echo $RHEL8_COMPOSE | grep RHEL-8.3) ]]; then
	export RPM_DPDK_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-19.11.3-1.el8.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11.3/1.el8/x86_64/dpdk-tools-19.11.3-1.el8.x86_64.rpm
elif [[ $(echo $RHEL8_COMPOSE | grep RHEL-8.4) ]]; then
	export RPM_DPDK_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-20.11-3.el8.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/20.11/3.el8/x86_64/dpdk-tools-20.11-3.el8.x86_64.rpm
elif [[ $(echo $RHEL8_COMPOSE | grep RHEL-9) ]]; then
	export RPM_DPDK_RHEL9=http://download.devel.redhat.com/brewroot/packages/dpdk/20.11/2.el9/x86_64/dpdk-20.11-2.el9.x86_64.rpm
	export RPM_DPDK_TOOLS_RHEL9=http://download.devel.redhat.com/brewroot/packages/dpdk/20.11/2.el9/x86_64/dpdk-tools-20.11-2.el9.x86_64.rpm
fi

# QEMU packages
export QEMU_KVM_RHEV_RHEL7=http://download.devel.redhat.com/brewroot/packages/qemu-kvm-rhev/2.12.0/48.el7_9.2/x86_64/qemu-kvm-rhev-2.12.0-48.el7_9.2.x86_64.rpm

# OVN packages
export RPM_OVNFDP_STREAM_VALUE_RHEL7=$OVNFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL7 
export RPM_OVNFDP_STREAM_VALUE_RHEL8=$OVNFDP_STREAM_VALUE_FDP_RELEASE_VALUE_RHEL8

export BONDING_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

export GRE_IPV6_TESTS="ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"

#pushd /home/ralongi/Documents/ovs_testing
#pushd /home/ralongi/global_docs/ovs_testing
pushd /home/ralongi/inf_ralongi/Documents/ovs_testing

./exec_mcast_snoop.sh
#./exec_ovs_qos.sh
#./exec_forward_bpdu.sh
#./exec_of_rules.sh
#./exec_power_cycle_crash.sh
#./exec_topo.sh ixgbe
#./exec_topo.sh i40e
#./exec_topo.sh enic
#./exec_topo.sh mlx5_core
#./exec_topo.sh qede
#./exec_topo.sh bnxt_en
#./exec_topo.sh nfp
#./exec_topo.sh ice
#./exec_sanity_check.sh

#./exec_ovs_memory_leak_soak.sh
#./exec_ovn_memory_leak_soak.sh

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

popd 2>/dev/null
