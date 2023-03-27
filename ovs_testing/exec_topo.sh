#!/bin/bash

# topo
# note that Server machine info is listed first, Client second

# set VM image to rhel8.4.qcow2 when running RHEL-9 compose due to problems installing netperf on RHEL-9 guest
if [[ $(echo $COMPOSE | grep RHEL-9) ]]; then VM_IMAGE="rhel8.4.qcow2"; fi

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
ovs_rpm_stream_ver=$(echo $ovs_rpm_name | awk -F "-" '{print $1}' | sed 's/openvswitch//g' | tr -d .)
pushd ~/temp
driver=$1
mlx_card_type=$(echo $2 | tr '[:lower:]' '[:upper:]')

if [[ $driver == "ixgbe" ]] || [[ $driver == "mlx5_core" ]]; then
	export GUEST_TYPE="vm"
fi

OVS_TOPO=${OVS_TOPO:-"ovs_all"}
#if [[ "$*" == *"cpu"* ]]; then
#	export OVS_TOPO="ovs_test_ns_enable_nomlockall_CPUAffinity_test"
#fi

compose_version=$(echo $COMPOSE | awk -F "-" '{print $2}' | awk -F "." '{print $1}')

extra_packages="--param=rpm_driverctl=$RPM_DRIVERCTL --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST"

GUEST_TYPE=${GUEST_TYPE:-"all"}

if [[ $# -lt 1 ]]; then
	echo "Please enter the driver name"
	echo "Example: $0 ixgbe"
	exit 0
fi

# Can either add ovs-dpdk as third argument to ./exec_topo.sh or export ovs_env="ovs-dpdk" in terminal window
if [[ "$*" == *"ovs_env="* ]]; then
	export ovs_env=$(echo "$*" | awk -F 'ovs_env=' '{print $NF}')
fi

if [[ -z "$ovs_env" ]]; then
	export ovs_env="kernel"
fi

# For now, run both kernel and ovs-dpdk tests
# export ovs_env="all"

if [[ "$driver" == "mlx5_core" ]] && [[ "$use_hpe_synergy" == "no" ]]; then
	NAY="no"
	PVT="yes"
else
	NAY="yes"
	PVT="no"
fi

if [[ $ovs_rpm_stream_ver -lt 216 ]]; then
	OVS_SKIP_TESTS=$BONDING_CPU_TESTS
else
	OVS_SKIP_TESTS=$BONDING_TESTS
fi

### ixgbe tests without Netscout
if [[ "$driver" == "ixgbe" ]]; then
	server="netqe21.knqe.lab.eng.bos.redhat.com"
	client="netqe44.knqe.lab.eng.bos.redhat.com"
	server_driver="ixgbe"
	client_driver="ixgbe"
fi

### i40e with Netscout
if [[ "$driver" == "i40e" ]]; then
	server="netqe21.knqe.lab.eng.bos.redhat.com"
	client="netqe44.knqe.lab.eng.bos.redhat.com"
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
	server="netqe29.knqe.lab.eng.bos.redhat.com"
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
		server="netqe24.knqe.lab.eng.bos.redhat.com"
		client="netqe25.knqe.lab.eng.bos.redhat.com"
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
	server="netqe44.knqe.lab.eng.bos.redhat.com"
	client="netqe26.knqe.lab.eng.bos.redhat.com"
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

# Standard topo run
if [[ "$driver" != "ice" ]] && [[ "$driver" != "mlx5_core" ]] && [[ "$driver" != "arm" ]]; then
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"
	
# ICE E810 (RHEL-8.4 and higher)
### ice tests with Netscout
elif [[ "$driver" == "ice" ]]; then
	#server="wsfd-advnetlab11.anl.lab.eng.bos.redhat.com"
	#client="wsfd-advnetlab10.anl.lab.eng.bos.redhat.com"
	#NAY=no
	#PVT=yes
	#server_driver=mlx5_core
	#server_nic_test=ens2f0
	#client_nic_test=ens1f0
	server="netqe40.knqe.lab.eng.bos.redhat.com"
	client="netqe44.knqe.lab.eng.bos.redhat.com"
	NAY=yes
	PVT=no
	server_driver="qede"
	client_driver="ice"
	netscout_pair1="NETQE40_P7P1 NETQE44-E810-1"
	netscout_pair2="NETQE40_P7P2 NETQE44-E810-2"
	
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"
	
# mlx5_core CX5
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX5" ]]; then
	server="netqe24.knqe.lab.eng.bos.redhat.com"
	client="netqe25.knqe.lab.eng.bos.redhat.com"
	NAY="no"
	PVT="yes"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp4s0f0np0"
		client_nic_test="enp4s0f0np0"
	else
		server_nic_test="enp4s0f0"
		client_nic_test="enp4s0f0"
	fi
	#server_pciid="15b3:101d" #CX6
	#client_pciid="15b3:1017" #CX5
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --ks-meta "!grubport=0x02f8" --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX5), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"
# mlx5_core CX6
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX6" ]]; then
	server="netqe25.knqe.lab.eng.bos.redhat.com"
	client="netqe24.knqe.lab.eng.bos.redhat.com"
	NAY="no"
	PVT="yes"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp4s0f0np0"
		client_nic_test="enp4s0f0np0"
	else
		server_nic_test="enp4s0f0"
		client_nic_test="enp4s0f0"
	fi
	#server_pciid="15b3:1017" #CX5
	#client_pciid="15b3:101d" #CX6
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --ks-meta "!grubport=0x02f8" --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver ($mlx_card_type), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"		
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX7" ]]; then
	server="dell-per750-12.rhts.eng.pek2.redhat.com"
	client="dell-per750-11.rhts.eng.pek2.redhat.com"
	NAY="no"
	PVT="yes"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp202s0f1np1"
		client_nic_test="enp23s0f1np1"
	else
		server_nic_test="ens7f1"
		client_nic_test="ens2f1"
	fi
	# ethtool -s $server_nic_test speed 100000 duplex full autoneg off
	# ethtool -s $client_nic_test speed 100000 duplex full autoneg off
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --machine=$server,$client --systype=prototype,prototype  $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver ($mlx_card_type), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"	
# if no mlx_card_type value, default to mlx5_core CX6
elif [[ "$driver" == "mlx5_core" ]] && [[ -z "$mlx_card_type" ]]; then
	mlx_card_type="CX6"
	server="netqe25.knqe.lab.eng.bos.redhat.com"
	client="netqe24.knqe.lab.eng.bos.redhat.com"
	NAY="no"
	PVT="yes"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp4s0f0np0"
		client_nic_test="enp4s0f0np0"
	else
		server_nic_test="enp4s0f0"
		client_nic_test="enp4s0f0"
	fi
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver (CX6), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"
### ARM aarch64 tests without Netscout
elif [[ "$driver" == "arm" ]]; then
	server="netqe-arm10-x86.arm.eng.rdu2.redhat.com"
	client="dev-010.arm.eng.rdu2.redhat.com"
	#server="netqe-arm11-x86.arm.eng.rdu2.redhat.com"
	#client="dev-011.arm.eng.rdu2.redhat.com"
	#server_driver="ixgbe"
	#client_driver="ixgbe"
	server_driver="tg3"
	client_driver="igb"
	GUEST_TYPE="container"
	export RPM_OVS_AARCH64=$(echo $RPM_OVS | sed 's/x86_64/aarch64/g')
	export RPM_OVS_TCPDUMP_PYTHON_AARCH64=$(echo $RPM_OVS_TCPDUMP_PYTHON | sed 's/x86_64/aarch64/g')
	#export RPM_OVS_TCPDUMP_TEST_AARCH64=$(echo $RPM_OVS_TCPDUMP_TEST | sed 's/x86_64/aarch64/g')	
	export ovs_rpm_name=$(echo $RPM_OVS_AARCH64 | awk -F "/" '{print $NF}')
	#NAY=yes
	#PVT=no
	NAY=no
	PVT=yes
	server_nic_test="eno2"
	client_nic_test="eno2"
	zstream_repo_list_aarch64=$(echo $zstream_repo_list | sed 's/x86_64/aarch64/g') 
	# Below code is to avoid problem with RHEL-8.6 not installing if z stream repos are specified in the beaker job recipe (at least with mixed arch jobs)
	if [[ $(echo $COMPOSE | grep 'RHEL-8.6') ]]; then
		export zstream_repo_list=""
		export zstream_repo_list_aarch64=""
	fi
	
	cat ~/git/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --dryrun --prettyxml $COMPOSE  --arch=x86_64,aarch64 --machine=$server,$client --systype=machine,machine $(echo "$brew_build_cmd") $(echo "$zstream_repo_list"),$(echo "$zstream_repo_list_aarch64") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=mh-RPM_OVS=$RPM_OVS,$RPM_OVS_AARCH64 --param=mh-RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON,$RPM_OVS_TCPDUMP_PYTHON_AARCH64 --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --param=rpm_driverctl=$RPM_DRIVERCTL --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"
	
	job_xml_file=$(ls -t ~/temp/job*.xml | head -n1)
		
	remove_lines=$(grep -A21 -n '<distro_arch op="=" value="x86_64"' $job_xml_file | grep repo | grep aarch64 | awk '{print $1}' | tr -d '-')
	start_line=$(echo $remove_lines | awk '{print $1}')
	end_line=$(echo $remove_lines | awk '{print $NF}')
	sed -i "${start_line},${end_line}d" $job_xml_file
	
	remove_lines=$(grep -A21 -n '<distro_arch op="=" value="aarch64"' $job_xml_file | grep repo | grep x86_64 | awk '{print $1}' | tr -d '-')
	start_line=$(echo $remove_lines | awk '{print $1}')
	end_line=$(echo $remove_lines | awk '{print $NF}')
	sed -i "${start_line},${end_line}d" $job_xml_file
	
	bkr job-submit $job_xml_file

	#cat ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --arch=x86_64,aarch64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list"),$(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=mh-RPM_OVS=$RPM_OVS,$RPM_OVS_AARCH64 --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"

fi

# load specific kernel job
#brew_build=http://download.eng.bos.redhat.com/brewroot/work/tasks/3943/49363943/

# To obtain the info for the brew build:
# - go to original task ID provided (in Jira, etc.)
# - click on buildArch src.rpm for the target arch under Descendants
# - right click kernel rpm link: http://download.eng.bos.redhat.com/brewroot/work/tasks/4549/37664549/kernel-4.18.0-315.el8.bz1944818v1.x86_64.rpm
# - for above kernel, BUILDID value is: 49363943
# OR use link with runtest: -B 49363943 or --Brew=49363943

#	cat ovs.list | egrep "openvswitch/topo" | runtest $COMPOSE  --machine=$server,$client -B $brew_build --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=selinux_enable=$selinux_enable --param=NAY=$NAY --param=GUEST_TYPE=$GUEST_TYPE --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $client_driver, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info"

rm -f ~/git/kernel/networking/tools/runtest-network/job*.xml
popd
