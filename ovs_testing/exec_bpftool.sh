#!/bin/bash

# bpftool

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG
SYSTYPE=${SYSTYPE:-"machine"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
NIC_NUM=2
TESTS_TO_RUN=${TESTS_TO_RUN:-"all_tests"}

# Example brew_build_cmd (note back slashes to escape $basesearch variable)
#export brew_build_cmd="--B repo:cki-artifacts,https://s3.upshift.redhat.com/DH-PROD-CKI/internal/1063880898/\$basearch/5.14.0-383.3337_1063880735.el9.\$basearch"

#export brew_build_cmd="--B repo:cki-artifacts,https://artifacts.internal.cki-project.org/arr-cki-prod-internal-artifacts/internal-artifacts/1361255010/publish_x86_64/7269536670/artifacts/repo/5.14.0-284.73.1.1834_1361254984.el9_2.x86_64/"



pushd ~/temp

if [[ $driver == "ice" ]]; then
	server="netqe51.knqe.eng.rdu2.dc.redhat.com"
	client="netqe52.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="i40e"
	card_info="ICE"
elif [[ $driver == "igc" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="igc"
	client_driver="igc"
	card_info="IGC"
	NIC_NUM=1
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
	#pciid_info="--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}""
	#if [[ -z $special_info ]]; then	special_info="(CX5)"; fi
elif [[ $driver == "cx6dx" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:101d"
	client_pciid="15b3:1019"
	card_info="CX6 DX"
	#pciid_info='--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}"'
	#if [[ -z $special_info ]]; then	special_info="(CX6 DX)"; fi
elif [[ $driver == "cx3" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx4_en"
	client_driver="mlx5_core"
	card_info="(CX3)"
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
elif [[ $driver == "ionic" ]]; then
	server="dell-per740-11.knqe.eng.rdu2.dc.redhat.com"
	client="dell-per740-05.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ionic"
	client_driver="mlx5_core"
	card_info="IONIC"
	SYSTYPE="prototype"
fi

# Temporarily add commands similar to below to runtest string to install packages downloaded to infra01

# --cmd-and-reboot 'dnf -y install wget; wget -O /etc/yum.repos.d/infra01-server.repo http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/infra01-server.repo; dnf -y install kernel-5.14.0-427.18.1.el9_4' 

# --cmd-and-reboot 'dnf -y install wget; wget -O /etc/yum.repos.d/infra01-server.repo http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/infra01-server.repo; dnf -y install bpftool-4.18.0-553.7.1.el8_10 kernel-4.18.0-553.7.1.el8_10'

# with Netscout
if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then
	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/bpftool | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE -B "repo:cki-artifacts,https://artifacts.internal.cki-project.org/arr-cki-prod-internal-artifacts/internal-artifacts/1461974769/publish_x86_64/7876818432/artifacts/repo/5.14.0-503.6.1.2487_1461974618.el9_5.x86_64/" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds") --param=DBG_FLAG="$DBG_FLAG" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --wb "(Server/DUT: $server, Client: $client), bpftool test, $COMPOSE, networking/ebpf_xdp/bpftool, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
# normal run, no netscout
	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/bpftool | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=DBG_FLAG="$DBG_FLAG" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --wb "(Server/DUT: $server, Client: $client), bpftool test, $COMPOSE, networking/ebpf_xdp/bpftool, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# RT kernel
#	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/bpftool | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE -B 'rtk' --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=DBG_FLAG="$DBG_FLAG" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --wb "(Server/DUT: $server, Client: $client), bpftool test, $COMPOSE, networking/ebpf_xdp/bpftool, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# cki artifacts
#	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/bpftool | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE -B "repo:cki-artifacts,https://artifacts.internal.cki-project.org/arr-cki-prod-internal-artifacts/internal-artifacts/1499066194/publish_x86_64/8104340271/artifacts/repo/5.14.0-427.41.1.2640_1499066031.el9_4.x86_64/" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --wb "(Server/DUT: $server, Client: $client), bpftool test, $COMPOSE, networking/ebpf_xdp/bpftool, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# infra01 packages
#	lstest ~/git/my_fork/kernel/networking/ebpf_xdp/bpftool | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL; dnf -y install wget; wget -O /etc/yum.repos.d/infra01-server.repo http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/infra01-server.repo; dnf -y install	bpftool-7.3.0-427.32.1.2216_1415671754.el9_4 kernel-5.14.0-427.32.1.2216_1415671754.el9_4 kernel-modules-internal-5.14.0-427.32.1.2216_1415671754.el9_4 kernel-selftests-internal-5.14.0-427.32.1.2216_1415671754.el9_4" --product=$product --retention-tag=$retention_tag --arch=x86_64 --topo=multiHost.1.1 --machine=$server,$client --systype=$SYSTYPE,$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=DBG_FLAG="$DBG_FLAG" --param=TESTS_TO_RUN="$TESTS_TO_RUN" --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER="${server_driver}","${client_driver}" $pciid_info --param=mh-TEST_DRIVER="${server_driver}","${client_driver}" --wb "(Server/DUT: $server, Client: $client), bpftool test, $COMPOSE, networking/ebpf_xdp/bpftool, Client driver: $client_driver, Server driver: $server_driver, Driver under test: $server_driver ($card_info) $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

fi

# Example of reservesys
#--insert-task="/distribution/reservesys {RESERVETIME=86400}" 

popd
