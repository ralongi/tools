#!/bin/bash

# ovs-kernel-conntrack

dbg_flag="set -x"
testdir="/home/ralongi/git/my_fork/kernel/networking/ovs-dpdk/ovs-kernel-conntrack"
pushd $testdir
fdp_release=$FDP_RELEASE
server="dell-per730-51.rhts.eng.pek2.redhat.com"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
RPM_DPDK=$RPM_DPDK_RHEL7
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7
QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=7.7

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server --systype=machine  --param=dbg_flag="set -x" --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.12, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL7
RPM_DPDK=$RPM_DPDK_RHEL7
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7
QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=7.7

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server --systype=machine  --param=dbg_flag="set -x" --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL7
RPM_DPDK=$RPM_DPDK_RHEL7
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7
QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=7.7

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server --systype=machine  --param=dbg_flag="set -x" --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.11, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=8.1
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose --machine=$server --systype=machine  --param=dbg_flag="set -x"  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --ks-meta "$ks_meta" --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.12, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=8.1
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose --machine=$server --systype=machine  --param=dbg_flag="set -x"  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --ks-meta "$ks_meta" --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8_1911
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8_1911
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
image_name=8.1
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose --machine=$server --systype=machine  --param=dbg_flag="set -x"  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --ks-meta "$ks_meta" --param=QCOW_LOC=China --param=DPDK_URL=$RPM_DPDK --param=DPDK_TOOL_URL=$RPM_DPDK_TOOLS --param=xena_port1=XENA_M7P0 --param=xena_port2=XENA_M7P1 --param=GUEST_DPDK_VERSION=18-11 --param=NetScout_nic1=dell51_p4p1 --param=NetScout_nic2=dell51_p4p2 --param=NIC1_NAME=p4p1 --param=NIC2_NAME=p4p2 --param=xena_module=7 --param=GUEST_IMG=$image_name --param=OVS_URL=$RPM_OVS --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}')" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
popd
