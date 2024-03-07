#!/bin/bash

# iproute2_load_xdp

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

compose_version=$(echo $COMPOSE | awk -F "-" '{print $2}' | awk -F "." '{print $1}')
if [[ $compose_version -ge 9 ]]; then
    echo "IPROUTE2_LOAD_XDP TEST IS NOT SUPPORTED ON RHEL-9 AND HIGHER.  EXITING..."
    exit 0
fi

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG

XDP_LOAD_MODE=${XDP_LOAD_MODE:-"native"}
XDP_TEST_FRAMEWORK=${XDP_TEST_FRAMEWORK:-"beakerlib"}

pushd ~/git/kernel/networking/ebpf_xdp/iproute2_load_xdp

if [[ $driver == "ice" ]]; then
	dut="netqe2.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="ice"
	TEST_DRIVER=$NIC_DRIVER
elif [[ $driver == "i40e" ]]; then
	#dut="netqe3.knqe.lab.eng.bos.redhat.com"
	dut="netqe40.knqe.eng.rdu2.dc.redhat.com"
	NIC_DRIVER="i40e"
	TEST_DRIVER=$NIC_DRIVER
elif [[ $driver == "ixgbe" ]]; then
	dut="netqe1.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="ixgbe"
	TEST_DRIVER=$NIC_DRIVER
elif [[ $driver == "sfc" ]]; then
	dut="netqe4.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="sfc"
	TEST_DRIVER=$NIC_DRIVER
elif [[ $driver == "cx5" ]]; then
	dut="netqe4.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="mlx5_core"
	TEST_DRIVER=$NIC_DRIVER
	dut_pciid="15b3:1019"
	#pciid_info='--param=netqe-nic-pciid="$dut_pciid"'
	special_info="(CX5)"
elif [[ $driver == "cx6dx" ]]; then
	dut="netqe1.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="mlx5_core"
	TEST_DRIVER=$NIC_DRIVER
	dut_pciid="15b3:101d"
	#pciid_info='--param=netqe-nic-pciid="$dut_pciid"'
	special_info="(CX6 DX)"
elif [[ $driver == "cx3" ]]; then
	dut="netqe4.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="mlx4_en"
	TEST_DRIVER=$NIC_DRIVER
	special_info="(CX3)"
elif [[ $driver == "nfp" ]]; then
	dut="netqe3.knqe.lab.eng.bos.redhat.com"
	NIC_DRIVER="nfp"
	TEST_DRIVER=$NIC_DRIVER	
elif [[ $driver == "qede" ]]; then
	dut="netqe22.knqe.eng.rdu2.dc.redhat.com"
	NIC_DRIVER="qede"
	TEST_DRIVER=$NIC_DRIVER
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
	# if using netqe41 for qede test, need to connect qede card via netscout to get link:
	#netscout_pair1="NETQE30_P2P1 NETQE41_P3P1"
	#netscout_pair2="NETQE30_P2P2 NETQE41_P3P2"
elif [[ $driver == "bnxt_en" ]]; then
	dut="netqe22.knqe.eng.rdu2.dc.redhat.com"
	NIC_DRIVER="bnxt_en"
	TEST_DRIVER=$NIC_DRIVER
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
fi

if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then
	lstest | runtest $COMPOSE --arch=x86_64 --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=XDP_LOAD_MODE="$XDP_LOAD_MODE" --param=XDP_TEST_FRAMEWORK="$XDP_TEST_FRAMEWORK" --param=NAY=yes --param=NIC_NUM=2 --param=NIC_DRIVER="$NIC_DRIVER" --param=TEST_DRIVER="$TEST_DRIVER" $pciid_info --wb "(DUT: $dut), iproute2 xdp_load test, XDP Load Mode: $XDP_LOAD_MODE,$COMPOSE, networking/ebpf_xdp/iproute2_load_xdp, Driver under test: $NIC_DRIVER $brew_build $special_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
	lstest | runtest $COMPOSE --arch=x86_64 --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG"  --param=XDP_LOAD_MODE="$XDP_LOAD_MODE" --param=XDP_TEST_FRAMEWORK="$XDP_TEST_FRAMEWORK" --param=NAY=yes --param=NIC_NUM=2 --param=NIC_DRIVER="$NIC_DRIVER" --param=TEST_DRIVER="$TEST_DRIVER" $pciid_info --wb "(DUT: $dut), iproute2 xdp_load test, XDP Load Mode: $XDP_LOAD_MODE, $COMPOSE, networking/ebpf_xdp/iproute2_load_xdp, Driver under test: $NIC_DRIVER $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd
