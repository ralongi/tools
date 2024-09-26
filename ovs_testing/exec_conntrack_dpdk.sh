#!/bin/bash

# conntrack_dpdk

dbg_flag="set -x"
testdir="/home/ralongi/git/my_fork/kernel/networking/openvswitch/conntrack_dpdk"
pushd $testdir
fdp_release=$FDP_RELEASE
server="dell-per730-26.rhts.eng.pek2.redhat.com"
client="dell-per730-25.rhts.eng.pek2.redhat.com"
server_driver="ixgbe"
client_driver="ixgbe"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
image_name="rhel7.7.qcow2"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel7.7-vsperf-1Q-viommu.qcow2
image_name=rhel7.7.qcow2

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK_RHEL7 --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7 --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.12, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL7
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel7.7-vsperf-1Q-viommu.qcow2
image_name="rhel7.7.qcow2"

lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK_RHEL7 --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7 --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7 --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL7
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel7.7-vsperf-1Q-viommu.qcow2
image_name="rhel7.7.qcow2"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK_RHEL7 --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL7 --param=QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7 --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.11, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel8.1-vsperf-1Q-viommu.qcow2
image_name=rhel8.1.qcow2
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
RPM_OVS_TCPDUMP_PYTHON=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/x86_64/python3-openvswitch2.11-2.11.0-24.el8fdp.x86_64.rpm
RPM_OVS_TCPDUMP_TEST=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/noarch/openvswitch2.11-test-2.11.0-24.el8fdp.noarch.rpm

lstest | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON  --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.12, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel8.1-vsperf-1Q-viommu.qcow2
image_name=rhel8.1.qcow2
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
RPM_OVS_TCPDUMP_PYTHON=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/x86_64/python3-openvswitch2.11-2.11.0-24.el8fdp.x86_64.rpm
RPM_OVS_TCPDUMP_TEST=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/noarch/openvswitch2.11-test-2.11.0-24.el8fdp.noarch.rpm

lstest | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON  --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL8
RPM_DPDK=$RPM_DPDK_RHEL8_1911
RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS_RHEL8_1911
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
#image_name=rhel8.1-vsperf-1Q-viommu.qcow2
image_name=rhel8.1.qcow2
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
RPM_OVS_TCPDUMP_PYTHON=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/x86_64/python3-openvswitch2.11-2.11.0-24.el8fdp.x86_64.rpm
RPM_OVS_TCPDUMP_TEST=http://download.devel.redhat.com/brewroot/packages/openvswitch2.11/2.11.0/24.el8fdp/noarch/openvswitch2.11-test-2.11.0-24.el8fdp.noarch.rpm

lstest | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=NIC_DRIVER=ixgbe --param=image_name=$image_name --param=GUEST_IMAGE=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=OVS_EXTRA=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON  --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --wb "$fdp_release, $ovs_rpm_name, $compose, $(echo $testdir | awk -F 'git' '{print $2}'), Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
popd
