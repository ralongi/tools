#!/bin/bash

# conntrack2

dbg_flag="set -x"
pushd ~/git/my_fork/kernel/networking/openvswitch/conntrack2
fdp_release=$FDP_RELEASE
server="dell-per730-25.rhts.eng.pek2.redhat.com"
client="dell-per730-26.rhts.eng.pek2.redhat.com"
server_driver="ixgbe"
client_driver="ixgbe"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
image_name="rhel7.7.qcow2"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK_RHEL7 --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7 --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/conntrack2, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

popd
