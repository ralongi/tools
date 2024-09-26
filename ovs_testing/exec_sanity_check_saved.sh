#!/bin/bash

# sanity_check

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
pushd ~/git/my_fork/kernel/networking/openvswitch/sanity_check
fdp_release=$FDP_RELEASE
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut="netqe9.knqe.lab.eng.bos.redhat.com"
NIC_DRIVER=${NIC_DRIVER:-"ixgbe"}

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --machine=$dut --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --machine=$dut --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --machine=$dut --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-9
	compose=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL9
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	selinux_enable=no

	lstest | runtest $compose --machine=$dut --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi
	
popd
