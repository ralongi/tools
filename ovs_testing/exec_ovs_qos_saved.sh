#!/bin/bash

# ovs_qos

dbg_flag="set -x"
pushd ~/git/kernel/networking/openvswitch/ovs_qos
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe44.knqe.lab.eng.bos.redhat.com"
server_driver="i40e"
client_driver="i40e"

lstest | runtest $COMPOSE --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	image_name=$RHEL7_VM_IMAGE # use RHEL-7 VM image since RHEL-8 VM image results in failures for linux_htb test
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	image_name=$RHEL7_VM_IMAGE # use RHEL-7 VM image since RHEL-8 VM image results in failures for linux_htb test
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	image_name=$RHEL7_VM_IMAGE # use RHEL-7 VM image since RHEL-8 VM image results in failures for linux_htb test
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"

	lstest | runtest $compose --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-9
	compose=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	image_name=$RHEL7_VM_IMAGE # use RHEL-7 VM image since RHEL-8 VM image results in failures for linux_htb test
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	SELINUX=no

	lstest | runtest $compose --ks-meta "$ks_meta" --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=NAY=yes --param=PVT=no --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver"
fi
	
popd
