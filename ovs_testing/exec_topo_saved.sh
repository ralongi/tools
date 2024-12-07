#!/bin/bash

# topo
# note that Server machine info is listed first, Client second

netscout_cable()
{
	rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
	local port1=$(echo $1 | tr '[:lower:]' '[:upper:]')
	local port2=$(echo $2 | tr '[:lower:]' '[:upper:]')
	# possible netscout switches: bos_3200  bos_3903  nay_3200  nay_3901
	# set this in runtest.sh as necessary --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	netscout_switch=${netscout_switch:-"bos_3903"}
	
	if [[ "$rhel_version" -eq 8 ]]; then
		pushd /home/NetScout/
		rm -f settings.cfg
		wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
		sleep 2
		python3 /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
		popd 2>/dev/null
	elif [[ "$rhel_version" -eq 7 ]]; then	
		scl enable rh-python34 - << EOF
			pushd /home/NetScout/
			rm -f settings.cfg
			wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
			sleep 2
			python /home/ralongi/github/NetScout/NSConnect.py --connect $port1 $port2
			popd 2>/dev/null
EOF
	fi
}

netscout_show_connections()
{
        rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')
        # possible netscout switches: bos_3200  bos_3903  nay_3200  nay_3901
        # set this in runtest.sh as necessary --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
        netscout_switch=$1
        if [[ $# -lt 1 ]]; then netscout_switch="bos_3903"; fi
        
        echo "Checking connections on Netscout switch $netscout_switch..."
        
        if [[ "$rhel_version" -eq 8 ]]; then
                pushd /home/NetScout/
                rm -f settings.cfg
                wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
                sleep 2
                python3 /home/ralongi/github/NetScout/NSConnect.py --showconnections
                popd 2>/dev/null
        elif [[ "$rhel_version" -eq 7 ]]; then  
                scl enable rh-python34 - << EOF
                        pushd /home/NetScout/
                        rm -f settings.cfg
                        wget -O ./settings.cfg http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/NSConn/"$netscout_switch".cfg
                        sleep 2
                        python /home/ralongi/github/NetScout/NSConnect.py --showconnections
                        popd 2>/dev/null
EOF
        fi
}


dbg_flag="set -x"
pushd ~/git/my_fork/kernel/networking/tools/runtest-network --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fdp_release=$FDP_RELEASE
driver=$1
if [[ $# -lt 1 ]]; then
	echo "Please enter the driver name"
	echo "Example: $0 ixgbe"
	exit 0
fi

if [[ "$driver" == "ixgbe" ]]; then 
	use_netscout="no"
elif [[ "$use_hpe_synergy" == "yes" ]]; then
	use_netscout="no"
else
	use_netscout="yes"
fi

skip_ovs29=${skip_ovs29:-"no"}
skip_ovs211=${skip_ovs211:-"no"}
skip_ovs212=${skip_ovs212:-"no"}
skip_ovs213=${skip_ovs213:-"no"}
use_hpe_synergy=${use_hpe_synergy:-"no"}

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
	netscout_cable $netscout_pair1
	netscout_cable $netscout_pair2
#	netscout_cable $netscout_pair3
#	netscout_cable $netscout_pair4
	
	# OVS 2.9, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS29_RHEL7
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	rhos_test_version="14"
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
		netscout_cable $netscout_pair1
		netscout_cable $netscout_pair2
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
	netscout_cable $netscout_pair1
	netscout_cable $netscout_pair2
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
#		netscout_cable $netscout_pair1
#		netscout_cable $netscout_pair2
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
	netscout_cable $netscout_pair1
	netscout_cable $netscout_pair2
fi

### nfp with Netscout, no bonding tests
if [[ "$driver" == "nfp" ]]; then
	#server="netqe27.knqe.lab.eng.bos.redhat.com"
	#client="netqe12.knqe.lab.eng.bos.redhat.com"
	#netscout_switch="bos_3200"
	#netscout_pair1="netqe27_p5p1 netqe12_enp132s0np0"
	#netscout_pair2="netqe27_p5p2 netqe12_enp132s0np1"	
	server="netqe9.knqe.lab.eng.bos.redhat.com"
	client="netqe12.knqe.lab.eng.bos.redhat.com"
	netscout_switch="bos_3200"
	netscout_pair1="netqe9_p4p1 netqe12_enp129s0np0"
	netscout_pair2="netqe9_p4p2 netqe12_enp129s0np1"	
	server_driver="i40e"
	client_driver="nfp"
	netscout_cable $netscout_pair1
	netscout_cable $netscout_pair2
fi

### HPE Synergy 4820C
#server="hpe-netqe-syn480g10-05.knqe.lab.eng.bos.redhat.com"
#client="hpe-netqe-syn480g10-06.knqe.lab.eng.bos.redhat.com"
#server_driver="qede"
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

if [[ "$use_netscout" == "yes" ]]; then
echo "Here are the current Netscout connections on $netscout_switch:"
echo -e
netscout_show_connections $netscout_switch

	if [[ $skip_ovs29 != "yes" ]]; then
		# OVS 2.9, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS29_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"
		
if [[ "$driver" == "mlx5_core" ]] && [[ "$use_hpe_synergy" == "no" ]]; then
	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=netscout_pair3="$netscout_pair3" --param=netscout_pair4="$netscout_pair4" --param=NAY=$NAY --param=PVT=$PVT --param=nic_test=p4p1,p5p1 --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else 	
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=netscout_pair3="$netscout_pair3" --param=netscout_pair4="$netscout_pair4" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

	if [[ $skip_ovs211 != "yes" ]]; then
		# OVS 2.11, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS211_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=netscout_pair3="$netscout_pair3" --param=netscout_pair4="$netscout_pair4" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi

	if [[ $skip_ovs213 != "yes" ]]; then
		# OVS 2.13, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS213_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=netscout_pair3="$netscout_pair3" --param=netscout_pair4="$netscout_pair4" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
		
	if [[ $skip_ovs211 != "yes" ]]; then
		# OVS 2.11, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS211_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
		
	if [[ $skip_ovs213 != "yes" ]]; then
		# OVS 2.13, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS213_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
			
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# CX6 RHEL-8 specific
#	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
	
	if [[ $skip_ovs214 != "yes" ]]; then
		# OVS 2.14, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS215_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
			
		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# CX6 RHEL-8 specific
#	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
		
else

	if [[ $skip_ovs29 != "yes" ]]; then	
		# OVS 2.9, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS29_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp ovs_test_gre_ipv6 ovs_test_gre1_ipv6 ovs_test_gre_flow_ipv6 ovs_test_vlan_gre_ipv6 ovs_test_vlan_gre1_ipv6 ovs_test_vm_gre_ipv6 ovs_test_vm_gre1_ipv6 ovs_test_vm_gre_flow_ipv6 ovs_test_vm_vlan_gre_ipv6 ovs_test_vm_vlan_gre1_ipv6"
	
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi

	if [[ $skip_ovs211 != "yes" ]]; then
		# OVS 2.11, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS211_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
		
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi

	if [[ $skip_ovs213 != "yes" ]]; then
		# OVS 2.13, RHEL-7
		compose=$RHEL7_COMPOSE
		RPM_OVS=$RPM_OVS213_RHEL7
		image_name=$RHEL7_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
		rhos_test_version="14"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"

#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=netscout_switch="$netscout_switch" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=netscout_pair3="$netscout_pair3" --param=netscout_pair4="$netscout_pair4" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=rhos_test_version=$rhos_test_version --param=RPM_CONTAINER_SELINUX_POLICY=$RPM_CONTAINER_SELINUX_POLICY --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
		
	if [[ $skip_ovs211 != "yes" ]]; then
		# OVS 2.11, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS211_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
		
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
	
	if [[ $skip_ovs213 != "yes" ]]; then
		# OVS 2.13, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS213_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		rhos_test_version="14"
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
		
#		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# CX6 RHEL-8 specific
#	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
	
	if [[ $skip_ovs214 != "yes" ]]; then
		# OVS 2.14, RHEL-8
		compose=$RHEL8_COMPOSE
		RPM_OVS=$RPM_OVS215_RHEL8
		image_name=$RHEL8_VM_IMAGE
		ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
		ks_meta="harness='restraint-rhts beakerlib beakerlib-redhat'"
		OVS_SKIP_TESTS="ovs_test_bond_active_backup ovs_test_bond_set_active_slave ovs_test_bond_lacp_active ovs_test_bond_lacp_passive ovs_test_bond_balance_slb ovs_test_bond_balance_tcp"
			
		cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# CX6 RHEL-8 specific
#	cat ovs.list | egrep "openvswitch/topo" | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=NAY=no --param=PVT=yes --param=nic_test=enp4s0f0 --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6)" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	fi
	
fi

popd 2>/dev/null
