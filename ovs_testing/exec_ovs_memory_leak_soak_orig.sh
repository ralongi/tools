#!/bin/bash

# memory_leak_soak

dbg_flag="set -x"
pushd ~/git/kernel/networking/openvswitch/memory_leak_soak
fdp_release=$FDP_RELEASE
dut="wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"
NIC_DRIVER=${NIC_DRIVER:-"i40e"}

# OVS 2.9, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS29_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.11, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.12, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS212_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-7
compose=$RHEL7_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL7
image_name=$RHEL7_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"

#lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.11, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS211_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

#lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# OVS 2.13, RHEL-8
compose=$RHEL8_COMPOSE
RPM_OVS=$RPM_OVS213_RHEL8
RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
image_name=$RHEL8_VM_IMAGE
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
rhos_test_version="14"
ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"

lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

#lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=720 --param=mem_check_interval=30s --param=num_mem_checks=24 --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
popd
