#!/bin/bash

# mcast_snoop

dbg_flag="set -x"
pushd ~/git/kernel/networking/tools/runtest-network --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fdp_release=$FDP_RELEASE
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe44.knqe.eng.rdu2.dc.redhat.com"
server_driver="i40e"
client_driver="i40e"

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"	

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-9
	compose=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	image_name=$RHEL8_VM_IMAGE #use rhel8.3 vm image for now to avoid problems with ipv6 tests
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	SELINUX=no

	cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=NAY=yes --param=PVT=no --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi
	
popd

