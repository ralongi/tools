#!/bin/bash

# topo
# note that Server machine info is listed first, Client second

# set VM image to rhel8.4.qcow2 when running RHEL-9 compose due to problems installing netperf on RHEL-9 guest
#if [[ $(echo $COMPOSE | grep RHEL-9) ]]; then VM_IMAGE="rhel8.4.qcow2"; fi

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag

COMPOSE_VER=$(echo $COMPOSE | awk -F '-' '{print $2}')
if [[ $ovs_env == "ovs-dpdk" ]]; then
    ver_comp_result_file=version_compare_result.txt
    rpmdev-vercmp $COMPOSE_VER 8.8.0
    echo $? | tee $ver_comp_result_file
    # set VM image to rhel8.6.qcow2 when running RHEL-8 compose -ge 8.8 due to https://issues.redhat.com/browse/RHEL-7165
    # only affects RHEL-8, ovs-dpdk with guest running RHEL-8.8 and higher 
    if [[ $(echo $COMPOSE_VER | awk -F "." '{print $1}') -eq 8 ]]; then
        if [[ $(cat $ver_comp_result_file) -eq 0 ]] || [[ $(cat $ver_comp_result_file) -eq 11 ]]; then
            VM_IMAGE="rhel8.6.qcow2"
        fi
    fi
    # use 8.6 VM image with RHEL-9.2 due to https://bugzilla.redhat.com/show_bug.cgi?id=2184976
    if [[ $COMPOSE_VER == "9.2.0" ]]; then
        VM_IMAGE="rhel8.6.qcow2"
    fi
    rm -f $ver_comp_result_file
fi

ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
ovs_rpm_stream_ver=$(echo $ovs_rpm_name | awk -F "-" '{print $1}' | sed 's/openvswitch//g' | tr -d .)
if [[ $(echo $ovs_rpm_stream_ver | wc -c) -lt 4 ]]; then ovs_rpm_stream_ver=$(echo $ovs_rpm_stream_ver"0"); fi
pushd ~/temp
driver=$1
mlx_card_type=$(echo $2 | tr '[:lower:]' '[:upper:]')
OVS_TOPO=${OVS_TOPO:-"ovs_all"}
GUEST_TYPE=${GUEST_TYPE:-"all"}
mlx_card_model=${mlx_card_model:-"DX"}
use_hpe_synergy=${use_hpe_synergy:-"no"}
HOST_TESTS_ONLY=${HOST_TESTS_ONLY:-"no"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

if [[ "$driver" == *"arm"* ]]; then
	export GUEST_TYPE="container"
fi

#if [[ "$*" == *"cpu"* ]]; then
#	export OVS_TOPO="ovs_test_ns_enable_nomlockall_CPUAffinity_test"
#fi

compose_version=$(echo $COMPOSE | awk -F "-" '{print $2}' | awk -F "." '{print $1}')

extra_packages="--param=rpm_driverctl=$RPM_DRIVERCTL --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST"

if [[ $# -lt 1 ]]; then
	echo "Please enter the driver name"
	echo "Example: $0 ixgbe"
	exit 0
fi

# Can either add ovs-dpdk as third argument to ./exec_topo.sh or export ovs_env="ovs-dpdk" in terminal window
if [[ "$*" == *"ovs_env="* ]]; then
	export ovs_env=$(echo "$*" | awk -F 'ovs_env=' '{print $NF}')
fi

# set VM image to rhel8.6.qcow2 when ovs_env=ovs-dpdk until fix for https://bugzilla.redhat.com/show_bug.cgi?id=2184976 is merged
#if [[ $ovs_env == "ovs-dpdk" ]]; then VM_IMAGE=rhel8.6.qcow2; fi

if [[ $(echo $mlx_card_type | grep -i cx6) ]]; then
	if [[ "$*" == *"dx"* ]] ||  [[ "$*" == *"DX"* ]]; then
		export mlx_card_model="DX"
	elif [[ "$*" == *"lx"* ]] ||  [[ "$*" == *"LX"* ]]; then
		export mlx_card_model="LX"
	fi
fi

mlx_card_model=$(echo $mlx_card_model | tr '[:lower:]' '[:upper:]')

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

if [[ "$driver" == *"mlx5_core"* ]] || [[ "$driver" == *"ixgbe"* ]]; then
	OVS_SKIP_TESTS+=" ovs_test_container_vlan"
fi

### ixgbe tests without Netscout
if [[ "$driver" == "ixgbe" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="ixgbe"
fi

### i40e without Netscout
if [[ "$driver" == "i40e" ]]; then
	server="netqe51.knqe.eng.rdu2.dc.redhat.com"
	client="netqe52.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="i40e"
fi

# Standard topo run
if [[ "$driver" == "ixgbe" ]] || [[ "$driver" == "i40e" ]]; then
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi
	
# ICE E810 (RHEL-8.4 and higher)
### ice tests with Netscout
if [[ "$driver" == "ice" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	NAY=yes
	PVT=no
	server_driver="i40e"
	client_driver="ice"
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
# mlx5_core CX5
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX5" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	#server_pciid="15b3:101d" #CX6
	#client_pciid="15b3:1017" #CX5
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --ks-meta "!grubport=0x02f8" --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver` (CX5), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
# mlx5_core CX6
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX6" ]]; then
	if [[ $mlx_card_model == "DX" ]]; then
		server="netqe53.knqe.eng.rdu2.dc.redhat.com"
		client="netqe50.knqe.eng.rdu2.dc.redhat.com"
		server_driver="mlx5_core"
		client_driver="mlx5_core"
		NAY="yes"
		PVT="no"
	fi
	if [[ $mlx_card_model == "LX" ]]; then
		server="wsfd-advnetlab36.anl.eng.rdu2.dc.redhat.com"
		client="wsfd-advnetlab35.anl.eng.rdu2.dc.redhat.com"
		server_driver="i40e"
		client_driver="mlx5_core"
		NAY="no"
		PVT="yes"
		if [[ $compose_version -gt 8 ]]; then
			server_nic_test="ens1f0"
			client_nic_test="ens3f0np0"
		else
			server_nic_test="ens1f0"
			client_nic_test="ens3f0"
		fi
	fi
	#server_pciid="15b3:1017" #CX5
	#client_pciid="15b3:101d" #CX6 DX
	#client_pciid="15b3:101f" #CX6 LX
	#CX6 LX wsfd-advnetlab35 client nic -gt rhel8: ens3f0np0, ens3f1np1
	#CX6 LX wsfd-advnetlab35 client nic -le rhel8: ens3f0, ens3f1
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --ks-meta "!grubport=0x02f8" --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver ($mlx_card_type, $mlx_card_model)`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "CX7" ]]; then
	server="wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"
	client="wsfd-advnetlab33.anl.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	NAY="yes"
	PVT="no"
	client_pciid="15b3:1021"
	server_pciid="15b3:1019"
	#if [[ $compose_version -gt 8 ]]; then
	#	server_nic_test="enp202s0f1np1"
	#	client_nic_test="enp23s0f1np1"
	#else
	#	server_nic_test="ens8f0"
	#	client_nic_test="ens4f0"
	#fi
	
	# ethtool -s $nic_test speed 100000 duplex full autoneg off
	# ethtool -s $nic_test speed 100000 duplex full autoneg off
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=mh-nic_test=$server_nic_test,$client_nic_test --param=mh-netqe-nic-pciid=$server_pciid,$client_pciid --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver` ($mlx_card_type, $mlx_card_model), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
# mlx5_core BF2
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "BF2" ]]; then
	server="netqe29.knqe.eng.rdu2.dc.redhat.com"
	client="netqe30.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="i40e"
	client_driver="mlx5_core"
	netscout_pair1="netqe29_p3p1 netqe30_p7p1"
	netscout_pair2="netqe29_p3p2 netqe30_p7p2"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="ens3f0"
		client_nic_test="ens7f0np0"
	else
		server_nic_test="ens3f0"
		client_nic_test="ens7f0"
	fi
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver ($mlx_card_type, $mlx_card_model)`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	
# mlx5_core BF3
elif [[ "$driver" == "mlx5_core" ]] && [[ "$mlx_card_type" == "BF3" ]]; then
	server="netqe27.knqe.eng.rdu2.dc.redhat.com"
	client="netqe28.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp130s0f0np0"
		client_nic_test="ens1f0np0"
	else
		server_nic_test="ens3f0"
		client_nic_test="ens7f0"
	fi
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine  $(echo "$zstream_repo_list") --Brew=$brew_target --param=mh-nic_test=$server_nic_test,$client_nic_test --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver ($mlx_card_type, $mlx_card_model)`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
# if no mlx_card_type value, default to mlx5_core CX6
elif [[ "$driver" == "mlx5_core" ]] && [[ -z "$mlx_card_type" ]]; then
	mlx_card_type="CX6"
	server="netqe25.knqe.eng.rdu2.dc.redhat.com"
	client="netqe24.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp4s0f0np0"
		client_nic_test="enp4s0f0np0"
	else
		server_nic_test="enp4s0f0"
		client_nic_test="enp4s0f0"
	fi
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver` (CX6), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
### ARM aarch64 tests with Netscout
elif [[ "$driver" == "mlx5_core_arm" ]]; then
	#server="ampere-mtsnow-01.knqe.eng.rdu2.dc.redhat.com"
	#client="ampere-mtsnow-02.knqe.eng.rdu2.dc.redhat.com"
	#server_driver="mlx5_core"
	#client_driver="mlx5_core"
	mlx_card_type="CX7"
	client="netqe49.knqe.eng.rdu2.dc.redhat.com" # ARM system
	#client="netqe47.knqe.eng.rdu2.dc.redhat.com"
	#client="netqe48.knqe.eng.rdu2.dc.redhat.com"
	server="netqe24.knqe.eng.rdu2.dc.redhat.com" #x86_64 system
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	#server_pciid="15b3:1021" #CX7
	#server_pciid="15b3:101d" #CX6-DX
	#client_pciid="8086:1592" #E810
	export RPM_OVS_AARCH64=$(echo $RPM_OVS | sed 's/x86_64/aarch64/g')
	export RPM_OVS_TCPDUMP_PYTHON_AARCH64=$(echo $RPM_OVS_TCPDUMP_PYTHON | sed 's/x86_64/aarch64/g')
	#export RPM_OVS_TCPDUMP_TEST_AARCH64=$(echo $RPM_OVS_TCPDUMP_TEST | sed 's/x86_64/aarch64/g')	
	export ovs_rpm_name=$(echo $RPM_OVS_AARCH64 | awk -F "/" '{print $NF}')
	netscout_pair1="NETQE24_P4P1 NETQE49_CX7_P5P1" # netqe24 CX5 to netqe49 CX7 ARM
	netscout_pair2="NETQE24_P4P2 NETQE49_CX7_P5P2" # netqe24 CX5 to netqe49 CX7
	GUEST_TYPE="container"
	NAY=no
	PVT=yes
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp130s0f0np0"
		client_nic_test="enP2p2s0f0np0"
	else
		server_nic_test="ens4f0"
		client_nic_test="enP2p2s0f0"
	fi
	#server_nic_test="eno2"
	#client_nic_test="eno2"
	#zstream_repo_list_aarch64=$(echo $zstream_repo_list | sed 's/x86_64/aarch64/g') 
	# Below code is to avoid problem with RHEL-8.6 not installing if z stream repos are specified in the beaker job recipe (at least with mixed arch jobs)
	#if [[ $(echo $COMPOSE | grep 'RHEL-8.6') ]]; then
	#	export zstream_repo_list=""
	#	export zstream_repo_list_aarch64=""
	#fi
	
	if [[ $ovs_env == "ovs-dpdk" ]]; then
	    cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=aarch64 --machine=$server,$client --systype=machine,machine --Brew=$brew_target $(echo "$zstream_repo_list") $(echo "$zstream_repo_list_aarch64") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=mh-netqe-nic-pciid=$server_pciid,$client_pciid --param=HOST_TESTS_ONLY=yes --param=ovs_env=$ovs_env --param=image_name=$VM_IMAGE --param=SELINUX=$SELINUX --param=GUEST_TYPE=container --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS_AARCH64 --param=RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON_AARCH64 --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --param=rpm_driverctl=$RPM_DRIVERCTL --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver ($mlx_card_type)`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	else
	    cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64,aarch64 --machine=$server,$client --systype=machine,machine --Brew=$brew_target $(echo "$zstream_repo_list") $(echo "$zstream_repo_list_aarch64") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=mh-netqe-nic-pciid=$server_pciid,$client_pciid --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=image_name=$VM_IMAGE --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=mh-RPM_OVS=$RPM_OVS,$RPM_OVS_AARCH64 --param=mh-RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON,$RPM_OVS_TCPDUMP_PYTHON_AARCH64 --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --param=rpm_driverctl=$RPM_DRIVERCTL --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver ($mlx_card_type)`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"  --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	fi
	
	#cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --dryrun --prettyxml $COMPOSE  --arch=aarch64 --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine --Brew=$brew_target $(echo "$zstream_repo_list"),$(echo "$zstream_repo_list_aarch64") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=mh-RPM_OVS=$RPM_OVS,$RPM_OVS_AARCH64 --param=mh-RPM_OVS_TCPDUMP_PYTHON=$RPM_OVS_TCPDUMP_PYTHON,$RPM_OVS_TCPDUMP_PYTHON_AARCH64 --param=RPM_OVS_TCPDUMP_TEST=$RPM_OVS_TCPDUMP_TEST --param=rpm_driverctl=$RPM_DRIVERCTL --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
	#job_xml_file=$(ls -t ~/temp/job*.xml | head -n1)
		
	#remove_lines=$(grep -A21 -n '<distro_arch op="=" value="x86_64"' $job_xml_file | grep repo | grep aarch64 | awk '{print $1}' | tr -d '-')
	#start_line=$(echo $remove_lines | awk '{print $1}')
	#end_line=$(echo $remove_lines | awk '{print $NF}')
	#sed -i "${start_line},${end_line}d" $job_xml_file
	
	#remove_lines=$(grep -A21 -n '<distro_arch op="=" value="aarch64"' $job_xml_file | grep repo | grep x86_64 | awk '{print $1}' | tr -d '-')
	#start_line=$(echo $remove_lines | awk '{print $1}')
	#end_line=$(echo $remove_lines | awk '{print $NF}')
	#sed -i "${start_line},${end_line}d" $job_xml_file
	
	#bkr job-submit $job_xml_file

	#cat ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE  --arch=x86_64,aarch64 --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list"),$(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=mh-RPM_OVS=$RPM_OVS,$RPM_OVS_AARCH64 --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
### Cisco enic
elif [[ "$driver" == "enic" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="i40e"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P6P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P6P2"
	server_nic_test="enp3s0f0"
	client_nic_test="enp9s0"
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=yes --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	
elif [[ "$driver" == "qede" ]]; then
	server="netqe26.knqe.eng.rdu2.dc.redhat.com"
	client="netqe22.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="enic"
	client_driver="qede"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
	server_nic_test="enp9s0"
	client_nic_test="enp5s0f0"
	HOST_TESTS_ONLY="yes"
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=yes --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	
elif [[ "$driver" == "bnxt_en" ]]; then
	server="netqe26.knqe.eng.rdu2.dc.redhat.com"
	client="netqe22.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="enic"
	client_driver="bnxt_en"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"	
	server_nic_test="enp9s0"
	client_nic_test="enp130s0f0np0"
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=yes --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"

# Intel ice E810 STS card	
elif [[ "$driver" == "sts" ]]; then
	server="netqe18.knqe.lab.eng.bos.redhat.com"
	client="netqe29.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="i40e"
	client_driver="ice"
	#netscout_pair1="NETQE29_STS2_1 NETQE22_P6P1"
	#netscout_pair2="NETQE29_STS2_2 NETQE22_P6P2"
	server_nic_test="ens1f0"
	client_nic_test="ens8f0"
	special_info="Intel E810 STS2 NIC"	
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	
# Intel i40e X710 T4L card	
elif [[ "$driver" == "t4l" ]]; then
	server=${server:-"wsfd-netdev73.ntdv.lab.eng.bos.redhat.com"}
	client=${client:-"wsfd-netdev71.ntdv.lab.eng.bos.redhat.com"}
	NAY="yes"
	PVT="no"
	server_driver=${server_driver:-"i40e"}
	client_driver=${server_driver:-"i40e"}
	#server_nic_test="enp3s0f0"
	#client_nic_test="enp4s0f0"
	special_info=${special_info:-"Intel X710 T4L NIC"}
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
# Intel ice E810 Empire Flats card	
elif [[ "$driver" == "empire" ]]; then
	server="netqe25.knqe.eng.rdu2.dc.redhat.com"
	client="netqe40.knqe.eng.rdu2.dc.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="mlx5_core"
	client_driver="ice"
	netscout_pair1="NETQE25_P5P1 NETQE40_P0P1"
	netscout_pair2="NETQE25_P5P2 NETQE40_P0P2"
	client_nic_test="eno3"
	special_info="Intel E810 Empire Flats NIC"
	
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="enp6s0f0np0"
	else
		server_nic_test="enp6s0f0"
	fi
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
	
# Broadcom BMC57504 tests	
elif [[ "$driver" == "bmc57504" ]]; then
	server="wsfd-advnetlab151.anl.lab.eng.bos.redhat.com"
	client="wsfd-advnetlab154.anl.lab.eng.bos.redhat.com"
	NAY="no"
	PVT="yes"
	server_driver="mlx5_core"
	client_driver="bnxt_en"
	client_nic_test="ens5f0np0"
	if [[ $compose_version -gt 8 ]]; then
		server_nic_test="ens4f0np0"
	else
		server_nic_test="ens4f0"
	fi
	special_info="Broadcom BMC57504 NIC https://issues.redhat.com/browse/FDPQE-450"	
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# HPE Synergy 6820C qede
elif [[ "$driver" == "6820c" ]]; then
	server="hpe-netqe-syn480g10-02.knqe.eng.rdu2.dc.redhat.com"
	client="hpe-netqe-syn480g10-01.knqe.eng.rdu2.dc.redhat.com"
	server_driver="i40e"
	client_driver="qede"
	NAY=no
	PVT=yes
	client_nic_test="ens1f0"
	server_nic_test="ens1f0"
	
	cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") --Brew=$brew_target --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=HOST_TESTS_ONLY=$HOST_TESTS_ONLY --param=ovs_env=$ovs_env --param=SELINUX=$SELINUX --param=GUEST_TYPE=$GUEST_TYPE --param=NAY=$NAY --param=PVT=$PVT --param=mh-nic_test=$server_nic_test,$client_nic_test --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver` (6820C), ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

# load specific kernel job
#brew_build=http://download.eng.bos.redhat.com/brewroot/work/tasks/3943/49363943/

# To obtain the info for the brew build:
# - go to original task ID provided (in Jira, etc.)
# - click on buildArch src.rpm for the target arch under Descendants
# - right click kernel rpm link: http://download.eng.bos.redhat.com/brewroot/work/tasks/4549/37664549/kernel-4.18.0-315.el8.bz1944818v1.x86_64.rpm
# - for above kernel, BUILDID value is: 49363943
# OR use link with runtest: -B 49363943 or --Brew=49363943

#	cat ovs.list | egrep "openvswitch/topo" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$server,$client -B $brew_build --systype=machine,machine  --param=dbg_flag="$dbg_flag" --param=OVS_TOPO=$OVS_TOPO --param=selinux_enable=$selinux_enable --param=NAY=$NAY --param=GUEST_TYPE=$GUEST_TYPE --param=PVT=$PVT --param=image_name=$image_name --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8 --param=RPM_OVS=$RPM_OVS $(echo $extra_packages) --param=OVS_SKIP_CLEANUP_ENV=yes --param=OVS_SKIP="$OVS_SKIP_TESTS" --param=netscout_pair1="$netscout_pair1" --param=netscout_pair2="$netscout_pair2" --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/topo, Client driver: $client_driver, Server driver: $server_driver, `Driver under test: $client_driver`, ovs_env: $ovs_env, OVS_TOPO: $OVS_TOPO $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

rm -f ~/git/my_fork/kernel/networking/tools/runtest-network/job*.xml
popd
