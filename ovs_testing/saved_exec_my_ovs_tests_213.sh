#!/bin/bash

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
		wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
		sleep 2
		python3 /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
		popd
	elif [[ "$rhel_version" -eq 7 ]]; then	
		scl enable rh-python34 - << EOF
			pushd /home/NetScout/
			rm -f settings.cfg
			wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
			sleep 2
			python /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
			popd
EOF
	fi
}

# Script to execute all of my ovs tests

# RHEL composes
export RHEL7_COMPOSE="RHEL-7.7-updates-20200128.0"
export RHEL8_COMPOSE="RHEL-8.1.0-20191015.0"

#export RHEL7_COMPOSE="RHEL-7.8-20200116.0"
#export RHEL8_COMPOSE="RHEL-8.2.0-20191219.0"

# FDP Release
export FDP_RELEASE="FDP 20.B"

# 2.9
export RPM_OVS29_RHEL7=http://download.devel.redhat.com/brewroot/packages/openvswitch/2.9.0/125.el7fdp/x86_64/openvswitch-2.9.0-125.el7fdp.x86_64.rpm

# 2.11 (RHEL 7)
export RPM_OVS211_RHEL7=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/47.el7fdp/x86_64/openvswitch2.11-2.11.0-47.el7fdp.x86_64.rpm

# 2.11 (RHEL8)
export RPM_OVS211_RHEL8=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/47.el8fdp/x86_64/openvswitch2.11-2.11.0-47.el8fdp.x86_64.rpm

# 2.12 (RHEL7)
export RPM_OVS212_RHEL7=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.12/2.12.0/21.el7fdp/x86_64/openvswitch2.12-2.12.0-21.el7fdp.x86_64.rpm

# 2.12 (RHEL8)
export RPM_OVS212_RHEL8=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.12/2.12.0/21.el8fdp/x86_64/openvswitch2.12-2.12.0-21.el8fdp.x86_64.rpm

# 2.13 (RHEL7)
export RPM_OVS213_RHEL7=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/0.20200121git2a4f006.el7fdp/x86_64/openvswitch2.13-2.13.0-0.20200121git2a4f006.el7fdp.x86_64.rpm

export RPM_OVS212_RHEL7=$RPM_OVS213_RHEL7

# 2.13 (RHEL8)
export RPM_OVS213_RHEL8=http://download.eng.bos.redhat.com/brewroot/packages/openvswitch2.13/2.13.0/0.20200121git2a4f006.el8fdp/x86_64/openvswitch2.13-2.13.0-0.20200121git2a4f006.el8fdp.x86_64.rpm

export RPM_OVS212_RHEL8=$RPM_OVS213_RHEL8

export RPM_CONTAINER_SELINUX_POLICY=http://download.devel.redhat.com/brewroot/packages/container-selinux/2.77/1.el7_6/noarch/container-selinux-2.77-1.el7_6.noarch.rpm

export RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7=http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/15.el7fdp/noarch/openvswitch-selinux-extra-policy-1.0-15.el7fdp.noarch.rpm

export RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8=http://download.devel.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/19.el8fdp/noarch/openvswitch-selinux-extra-policy-1.0-19.el8fdp.noarch.rpm

export RPM_DPDK_RHEL7=http://download.devel.redhat.com/brewroot/packages/dpdk/18.11.2/1.el7/x86_64/dpdk-18.11.2-1.el7.x86_64.rpm

export RPM_DPDK_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11/1.el8/x86_64/dpdk-19.11-1.el8.x86_64.rpm

export RPM_DPDK_TOOLS_RHEL7=http://download.devel.redhat.com/brewroot/packages/dpdk/18.11.2/1.el7/x86_64/dpdk-tools-18.11.2-1.el7.x86_64.rpm

export RPM_DPDK_TOOLS_RHEL8=http://download.devel.redhat.com/brewroot/packages/dpdk/19.11/1.el8/x86_64/dpdk-tools-19.11-1.el8.x86_64.rpm

export QEMU_KVM_RHEV_RHEL7=http://download.devel.redhat.com/brewroot/packages/qemu-kvm-rhev/2.12.0/43.el7/x86_64/qemu-kvm-rhev-2.12.0-43.el7.x86_64.rpm

export BONDING_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

export GRE_IPV6_TESTS="ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"

if [[ $(echo $RHEL7_COMPOSE | grep "RHEL-7.7") ]]; then
	export OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"
else
	export OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
fi

pushd /home/ralongi/Documents/ovs_testing

./exec_mcast_snoop.sh
./exec_ovs_qos.sh
./exec_forward_bpdu.sh
./exec_of_rules.sh
./exec_topo.sh ixgbe
#./exec_topo.sh enic
./exec_topo.sh i40e
#./exec_topo.sh mlx5_core
#./exec_topo.sh qede
#./exec_topo.sh bnxt_en
#./exec_topo.sh nfp

./exec_power_cycle_crash.sh

# Conntrack firewall rules Jiying Qiu (not related to driver)
# openvswitch/conntrack2 and openvswitch/contrack_dpdk
./exec_conntrack2.sh
./exec_conntrack_dpdk.sh

# Stateful traffic Xena (by speed)
# openvswitch/conntrack3/ct_kernel and openvswitch/conntrack3/ct_userspace
# Google sheet: https://docs.google.com/spreadsheets/d/1cPG1ovmrCo1RhAMGVfK9SgKIEtj7yocjYP_CDvLUfYY/edit?usp=sharing
./exec_ct_kernel.sh
./exec_ct_userspace.sh

# ovs-dpdk-conntrack
# Google sheet: https://docs.google.com/spreadsheets/d/17MKqKpCmVV93dhCawgD-xxAm3aQweV5yszb82A-L-Kk/edit?usp=sharing
# search for "disable emc" and then "enable emc" in taskout.log file
./exec_ovs_dpdk_conntrack.sh

# ovs-kernel-conntrack
# Google sheet: https://docs.google.com/spreadsheets/d/1qku7ViuVgAwWXobQjekv1JxNvfQ4rgjCOBX0NTeda9o/edit?usp=sharing
# search for "disable emc" and then "enable emc" in taskout.log file
./exec_ovs_kernel_conntrack.sh

# ovs-dpdk-latency
# Google sheet: https://docs.google.com/spreadsheets/d/11BqpCkXoUXTVH4s0uMGZ4ieBOZzUNjbYS9E-3CxYIpI/edit?usp=sharing
# search for "Flows:" in taskout.log file
./exec_ovs_dpdk_latency.sh

# xena_conntrack/xena_dpdk
./exec_xena_dpdk.sh

# need to add upgrade tests
# need to add vm_100

popd
