#!/bin/bash

# XDP regression test suite

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG

pushd ~/git/kernel/networking/ebpf_xdp/sanity

if [[ $driver == "ice" ]]; then
	server="netqe2.knqe.lab.eng.bos.redhat.com"
	client="netqe3.knqe.lab.eng.bos.redhat.com"
	server_driver="ice"
	client_driver="i40e"
elif [[ $driver == "i40e" ]]; then
	server="netqe3.knqe.lab.eng.bos.redhat.com"
	client="netqe2.knqe.lab.eng.bos.redhat.com"
	server_driver="i40e"
	client_driver="ice"
elif [[ $driver == "ixgbe" ]]; then
	server="netqe1.knqe.lab.eng.bos.redhat.com"
	client="netqe4.knqe.lab.eng.bos.redhat.com"
	server_driver="ixgbe"
	client_driver="sfc"
elif [[ $driver == "sfc" ]]; then
	server="netqe4.knqe.lab.eng.bos.redhat.com"
	client="netqe1.knqe.lab.eng.bos.redhat.com"
	server_driver="sfc"
	client_driver="ixgbe"
elif [[ $driver == "cx5" ]]; then
	server="netqe4.knqe.lab.eng.bos.redhat.com"
	client="netqe1.knqe.lab.eng.bos.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:1019"
	client_pciid="15b3:101d"
	#pciid_info="--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}""
	special_info="(CX5)"
elif [[ $driver == "cx6dx" ]]; then
	server="netqe1.knqe.lab.eng.bos.redhat.com"
	client="netqe4.knqe.lab.eng.bos.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:101d"
	client_pciid="15b3:1019"
	#pciid_info='--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}"'
	special_info="(CX6 DX)"
elif [[ $driver == "cx3" ]]; then
	server="netqe4.knqe.lab.eng.bos.redhat.com"
	client="netqe1.knqe.lab.eng.bos.redhat.com"
	server_driver="mlx4_en"
	client_driver="mlx5_core"
	special_info="(CX3)"
elif [[ $driver == "nfp" ]]; then
	server="netqe3.knqe.lab.eng.bos.redhat.com"
	client="netqe2.knqe.lab.eng.bos.redhat.com"
	server_driver="nfp"
	client_driver="i40e"	
elif [[ $driver == "qede" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="qede"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
elif [[ $driver == "bnxt_en" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="bnxt_en"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
fi

NAY=yes
NIC_NUM=2
XDP_LOAD_MODE="native"
XDP_TEST_FRAMEWORK="beakerlib"
mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}"

~/github/tools/ovs_testing/exec_xdp_sanity.sh $driver $COMPOSE
~/github/tools/ovs_testing/exec_xdp_tools.sh $driver $COMPOSE
~/github/tools/ovs_testing/exec_af_xdp.sh $driver $COMPOSE

