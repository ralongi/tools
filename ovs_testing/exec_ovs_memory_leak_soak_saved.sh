#!/bin/bash

# memory_leak_soak

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/memory_leak_soak
fdp_release=$FDP_RELEASE
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut="wsfd-advnetlab34.anl.lab.eng.bos.redhat.com"
NIC_DRIVER=${NIC_DRIVER:-"i40e"}

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
	OVS_TOPO=${OVS_TOPO:-""}	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
	OVS_TOPO=${OVS_TOPO:-""}	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
	OVS_TOPO=${OVS_TOPO:-""}	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_TOPO=${OVS_TOPO:-""}

	lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=10800 --param=mem_check_interval=1h --param=num_mem_checks=3 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_TOPO=${OVS_TOPO:-""}

	# Full test
	lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
	
	# All tests, short duration
#	lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=900 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_TOPO=${OVS_TOPO:-""}

	# Full test
	lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-9
	compose=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL9
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	selinux_enable=no
	OVS_TOPO=${OVS_TOPO:-""}

	# Full test
	lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=OVS_TOPO=$OVS_TOPO --param=selinux_enable=$selinux_enable --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
fi

# All tests, short duration
#lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=900 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"

# 1K flow tests only, short duration (sanity check)
#lstest | runtest $compose --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=traffic_runtime=900 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=skip_5k_flows=yes --param=skip_10k_flows=yes --param=skip_25k_flows=yes --param=skip_100k_flows=yes --param=skip_1m_flows=yes --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"
	
popd
