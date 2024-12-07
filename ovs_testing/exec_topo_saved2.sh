#!/bin/bash

# topo
# note that Server machine info is listed first, Client second

dbg_flag="set -x"
pushd ~/git/my_fork/kernel/networking/tools/runtest-network --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fdp_release=$FDP_RELEASE
driver=$1
if [[ $# -lt 1 ]]; then
	echo "Please enter the driver name"
	echo "Example: $0 ixgbe"
	exit 0
fi

if [[ "$driver" == "mlx5_core" ]] && [[ "$use_hpe_synergy" == "no" ]]; then
	NAY="no"
	PVT="yes"
else
	NAY="yes"
	PVT="no"
fi

### ixgbe tests without Netscout
if [[ "$driver" == "ixgbe" ]]; then
	server="netqe21.knqe.lab.eng.bos.redhat.com"
	client="netqe44.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ixgbe"
	client_driver="ixgbe"
fi

### i40e with Netscout
if [[ "$driver" == "i40e" ]]; then
	server="netqe21.knqe.lab.eng.bos.redhat.com"
	client="netqe44.knqe.eng.rdu2.dc.redhat.com"
	netscout_switch="bos_3903"
	netscout_pair1="netqe20_p5p1 netqe21_p5p1"
	netscout_pair2="netqe20_p5p2 netqe21_p5p2"
#	netscout_pair1="netqe20_p5p1 ex4500_p0"
#	netscout_pair2="netqe20_p5p2 ex4500_p1"
#	netscout_pair3="netqe21_p5p1 ex4500_p2"
#	netscout_pair4="netqe21_p5p2 ex4500_p3"
	server_driver="i40e"
	client_driver="i40e"
fi

### qede with Netscout, no bonding tests
if [[ "$driver" == "qede" ]]; then
	if [[ "$use_hpe_synergy" != "yes" ]]; then
		server="netqe10.knqe.lab.eng.bos.redhat.com"
		client="netqe9.knqe.lab.eng.bos.redhat.com"
		netscout_switch="bos_3200"
		netscout_pair1="netqe9_p7p1 netqe10_p4p1"
		netscout_pair2="netqe9_p7p2 netqe10_p4p2"
		server_driver="bnxt_en"
		client_driver="qede"
	else
		### HPE Synergy 4820C
		server="hpe-netqe-syn480g10-05.knqe.lab.eng.bos.redhat.com"
		client="hpe-netqe-syn480g10-06.knqe.lab.eng.bos.redhat.com"
		server_driver="qede"
		client_driver="qede"
	fi	
fi

### bnxt_en with Netscout, no bonding tests
if [[ "$driver" == "bnxt_en" ]]; then
	server="netqe29.knqe.eng.rdu2.dc.redhat.com"
	client="netqe10.knqe.lab.eng.bos.redhat.com"
	netscout_switch="bos_3200"
	netscout_pair1="netqe29_p3p1 netqe10_p4p1"
	netscout_pair2="netqe29_p3p2 netqe10_p4p2"
	server_driver="qede"
	client_driver="bnxt_en"
fi

### mlx5_core (CX5) with Netscout, no bonding tests
if [[ "$driver" == "mlx5_core" ]]; then
	if [[ "$use_hpe_synergy" != "yes" ]]; then
		server="netqe24.knqe.eng.rdu2.dc.redhat.com"
		client="netqe25.knqe.eng.rdu2.dc.redhat.com"
		netscout_switch="bos_3200"
		netscout_pair1="netqe24_p4p1 netqe25_p5p1"
		netscout_pair2="netqe24_p4p2 netqe25_p5p2"
		server_driver="mlx5_core"
		client_driver="mlx5_core"
	else
		### HPE Synergy 6410C
		server="hpe-netqe-syn480g10-05.knqe.lab.eng.bos.redhat.com"
		client="hpe-netqe-syn480g10-06.knqe.lab.eng.bos.redhat.com"
		server_driver="mlx5_core"
		client_driver="mlx5_core"
	fi	
fi

### Cisco enic with Netscout, no bonding tests
if [[ "$driver" == "enic" ]]; then
	server="netqe44.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	netscout_switch="bos_3903"
	netscout_pair1="netqe20_p5p1 netqe26_enp9s0"
	netscout_pair2="netqe20_p5p2 netqe26_enp10s0"
	server_driver="i40e"
	client_driver="enic"
fi

### nfp with Netscout, no bonding tests
#if [[ "$driver" == "nfp" ]]; then
	#server="netqe27.knqe.lab.eng.bos.redhat.com"
	#client="netqe12.knqe.lab.eng.bos.redhat.com"
	#netscout_switch="bos_3200"
	#netscout_pair1="netqe27_p5p1 netqe12_enp132s0np0"
	#netscout_pair2="netqe27_p5p2 netqe12_enp132s0np1"	
#	server="netqe9.knqe.lab.eng.bos.redhat.com"
#	client="netqe12.knqe.lab.eng.bos.redhat.com"
#	netscout_switch="bos_3200"
#	netscout_pair1="netqe9_p4p1 netqe12_enp129s0np0"
#	netscout_pair2="netqe9_p4p2 netqe12_enp129s0np1"	
#	server_driver="i40e"
#	client_driver="nfp"
#fi

### HPE Synergy 4820C
#server="hpe-netqe-syn480g10-05.knqe.lab.eng.bos.redhat.com"
#client="hpe-netqe-syn480g10-06.knqe.lab.eng.bos.redhat.com"
#server_driver="qede"
#client_driver="qede"
#######

### HPE Synergy 6820C
#server="hpe-netqe-syn480g10-08.knqe.lab.eng.bos.redhat.com"
#client="hpe-netqe-syn480g10-03.knqe.lab.eng.bos.redhat.com"
#server_driver="mlx5_core"
#client_driver="qede"
#######

### HPE Synergy 6410C
#server="hpe-netqe-syn480g10-05.knqe.lab.eng.bos.redhat.com"
#client="hpe-netqe-syn480g10-06.knqe.lab.eng.bos.redhat.com"
#server_driver="mlx5_core"
#client_driver="mlx5_core"
#######

### HPE Synergy 4610C
#server="hpe-netqe-syn480g10-02.knqe.lab.eng.bos.redhat.com"
#client="hpe-netqe-syn480g10-03.knqe.lab.eng.bos.redhat.com"
#server_driver="i40e"
#client_driver="i40e"
#######

### ice tests without Netscout
if [[ "$driver" == "ice" ]]; then
	server="wsfd-advnetlab11.anl.eng.rdu2.dc.redhat.com"
	client="wsfd-advnetlab10.anl.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="ice"
fi

if [[ "$skip_rhel7_ovs29" != "yes" ]]; then
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"

#	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=NAY=$NAY --param=PVT=$PVT --param=nic_test=p4p1,p5p1 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
 	
	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX5 on netqe24/25
	
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=mh-nic_test=p6p1,p6p1 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2"--param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX5 on netqe24/25
	
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=mh-nic_test=p6p1,p6p1 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX5)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then	
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
			
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	#load special kernel, one test only
	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine -B kernel-4.18.0-234.el8 --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=OVS_TOPO="ovs_test_vm_vxlan_tos" --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX5 on netqe24/25
	#server="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=mh-nic_test=enp130s0f0,enp5s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX5)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

	# CX6 RHEL-8 specific
	#server="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
			
	# standard job		
	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

	# load specific kernel job
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --machine=$server,$client -B kernel-4.18.0-259.el8 --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX5 on netqe24/25
	#server="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=mh-nic_test=enp130s0f0,enp5s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX5)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX6 RHEL-8 specific
	#server="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# ICE E810 RHEL-8 specific
	#server="wsfd-advnetlab11.anl.eng.rdu2.dc.redhat.com"
	#client="wsfd-advnetlab10.anl.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=mh-nic_test=ens2f0,ens1f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (ICE E810)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

if [[ "$skip_rhel9_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-9
	compose=$RHEL9_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL9
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	ks_meta="{harness='restraint-rhts beakerlib beakerlib-redhat'}"
	OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
	selinux_enable=no
			
	# standard job		
	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

	# load specific kernel job
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --machine=$server,$client -B kernel-4.18.0-259.el8 --systype=machine,machine  --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX5 on netqe24/25
	#server="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=no --param=PVT=yes --param=mh-nic_test=enp130s0f0,enp5s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX5)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# CX6 RHEL-8 specific
	#server="netqe25.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe24.knqe.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	# ICE E810 RHEL-8 specific
	#server="wsfd-advnetlab11.anl.eng.rdu2.dc.redhat.com"
	#client="wsfd-advnetlab10.anl.eng.rdu2.dc.redhat.com"
	#cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=selinux_enable=$selinux_enable --param=NAY=no --param=PVT=yes --param=mh-nic_test=ens2f0,ens1f0 --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (ICE E810)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 2>/dev/null
