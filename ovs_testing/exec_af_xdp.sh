#!/bin/bash

# af_xdp

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
NIC_NUM=2
TESTS_TO_RUN=${TESTS_TO_RUN:-"all_tests"}

pushd ~/git/my_fork/kernel/networking/ebpf_xdp/af_xdp

if [[ $driver == "ice" ]]; then
	server="netqe51.knqe.eng.rdu2.dc.redhat.com"
	client="netqe52.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="i40e"
	card_info="(ICE)"
elif [[ $driver == "i40e" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="i40e"
	client_driver="ice"
	card_info="(I40E)"
elif [[ $driver == "ixgbe" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ixgbe"
	client_driver="sfc"
	card_info="(IXGBE)"
elif [[ $driver == "sfc" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="sfc"
	client_driver="ixgbe"
	card_info="(SFC)"
elif [[ $driver == "cx5" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:1019"
	client_pciid="15b3:101d"
	#pciid_info="--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}""
	card_info="(CX5)"
elif [[ $driver == "cx6dx" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:101d"
	client_pciid="15b3:1019"
	#pciid_info='--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}"'
	card_info="(CX6 DX)"
elif [[ $driver == "cx3" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx4_en"
	client_driver="mlx5_core"
	card_info="(CX3)"
elif [[ $driver == "enic" ]]; then
	server="netqe26.knqe.eng.rdu2.dc.redhat.com"
	client="netqe22.knqe.eng.rdu2.dc.redhat.com"
	server_driver="enic"
	client_driver="bnxt_en"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="(ENIC)"	
elif [[ $driver == "qede" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="qede"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
	card_info="(QEDE)"
elif [[ $driver == "bnxt_en" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="bnxt_en"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="(BNXT_EN)"
fi

if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then
	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/af_xdp | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag  --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=NAY=yes --param=NIC_NUM=2 --param=SKIP_CASE="$SKIP_CASE" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=TEST_CONFIG=$TEST_CONFIG --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --param=XDP_LOAD_MODE="native" --param=XDP_TEST_FRAMEWORK=beakerlib --wb "(Server/DUT: $server, Client: $client), AF_XDP, $COMPOSE, networking/ebpf_xdp/af_xdp, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver $brew_build $special_info $card_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
# standard test run
	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/af_xdp | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag  --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --ks-meta=method=http --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=NAY=yes --param=NIC_NUM=2 --param=SKIP_CASE="$SKIP_CASE" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=TEST_CONFIG=$TEST_CONFIG --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --param=XDP_LOAD_MODE="native" --param=XDP_TEST_FRAMEWORK=beakerlib --wb "(Server/DUT: $server, Client: $client), AF_XDP, $COMPOSE, networking/ebpf_xdp/af_xdp, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver $card_info $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
# cki or brew
#	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/af_xdp | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --B "repo:cki-artifacts,https://artifacts.internal.cki-project.org/arr-cki-prod-internal-artifacts/internal-artifacts/1536128177/publish_x86_64/8321745178/artifacts/repo/5.14.0-527.5432_1536127707.el9.x86_64/" --ks-meta=method=http --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=NAY=yes --param=NIC_NUM=2 --param=SKIP_CASE="$SKIP_CASE" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=TEST_CONFIG=$TEST_CONFIG --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --param=XDP_LOAD_MODE="native" --param=XDP_TEST_FRAMEWORK=beakerlib --wb "(Server/DUT: $server, Client: $client), AF_XDP, $COMPOSE, networking/ebpf_xdp/af_xdp, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver $card_info $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"



fi

popd
