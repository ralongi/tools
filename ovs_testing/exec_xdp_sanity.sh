#!/bin/bash

# xdp_sanity

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG
XDP_LOAD_MODE=${XDP_LOAD_MODE:-"native"}
XDP_TEST_FRAMEWORK=${XDP_TEST_FRAMEWORK:-"beakerlib"}
SYSTYPE=${SYSTYPE:-"machine"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

#pushd ~/git/kernel/networking/ebpf_xdp/sanity

if [[ $driver == "ice" ]]; then
	server="netqe51.knqe.eng.rdu2.dc.redhat.com"
	client="netqe52.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="i40e"
	card_info="ICE"
elif [[ $driver == "i40e" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="i40e"
	client_driver="ice"
	card_info="I40E"
elif [[ $driver == "ixgbe" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ixgbe"
	client_driver="sfc"
	card_info="IXGBE"
elif [[ $driver == "sfc" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="sfc"
	client_driver="ixgbe"
	card_info="SFC"
elif [[ $driver == "cx5" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:1019"
	client_pciid="15b3:101d"
	card_info="CX5"
	pciid_info="--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}""
	if [[ -z $special_info ]]; then	special_info="(CX5)"; fi
elif [[ $driver == "cx6dx" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:101d"
	client_pciid="15b3:1019"
	card_info="CX6 DX"
	pciid_info='--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}"'
	if [[ -z $special_info ]]; then	special_info="(CX6 DX)"; fi
elif [[ $driver == "cx3" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx4_en"
	client_driver="mlx5_core"
	card_info="CX3"
elif [[ $driver == "nfp" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="nfp"
	client_driver="i40e"
	card_info="NFP"	
elif [[ $driver == "qede" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="qede"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
	card_info="QEDE"
elif [[ $driver == "bnxt_en" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="bnxt_en"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="BNXT_EN"
elif [[ $driver == "enic" ]]; then
	server="netqe26.knqe.eng.rdu2.dc.redhat.com"
	client="netqe22.knqe.eng.rdu2.dc.redhat.com"
	server_driver="enic"
	client_driver="bnxt_en"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="ENIC"
elif [[ $driver == "atlantic" ]]; then
	server="dell-per750-26.rhts.eng.pek2.redhat.com"
	client="dell-per740-48.rhts.eng.pek2.redhat.com"
	server_driver="atlantic"
	client_driver="atlantic"
	card_info="ATLANTIC"
	SYSTYPE="prototype"
fi

#driver_list="ixgbe i40e ice sfc cx5 cx6dx nfp qede enic bnxt_en"

if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then
	lstest ~/git/kernel/networking/ebpf_xdp/sanity | runtest $COMPOSE -crashsize=640M --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=DBG_FLAG="$DBG_FLAG" --param=SKIP_CASE="$SKIP_CASE" --param=NAY=yes --param=NIC_NUM=2 --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $(echo "$pciid_info") --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --param=XDP_LOAD_MODE="$XDP_LOAD_MODE" --param=XDP_TEST_FRAMEWORK="$XDP_TEST_FRAMEWORK" --wb "(Server/DUT: $server, Client: $client), XDP Sanity test, $COMPOSE, networking/ebpf_xdp/sanity, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
	lstest ~/git/kernel/networking/ebpf_xdp/sanity | runtest $COMPOSE --crashsize=640M --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=DBG_FLAG="$DBG_FLAG" --param=SKIP_CASE="$SKIP_CASE" --param=NAY=yes --param=NIC_NUM=2 --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $(echo "$pciid_info") --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --param=XDP_LOAD_MODE="$XDP_LOAD_MODE" --param=XDP_TEST_FRAMEWORK="$XDP_TEST_FRAMEWORK" --wb "(Server/DUT: $server, Client: $client), XDP Sanity test, $COMPOSE, networking/ebpf_xdp/sanity, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 1> /dev/null
