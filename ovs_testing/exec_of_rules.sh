#!/bin/bash

# of_rules

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
#pushd ~/git/my_fork/kernel/networking/openvswitch/of_rules
server="netqe51.knqe.eng.rdu2.dc.redhat.com"
client="netqe52.knqe.eng.rdu2.dc.redhat.com"
server_driver="ice"
client_driver="i40e"
#NIC_TX="b4:96:91:a0:3f:7e,40:a6:b7:2f:b9:21"
#NIC_RX="b4:96:91:a0:3f:7f,40:a6:b7:2f:b9:20"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
image_mode=${image_mode:-"no"}
NAY="${NAY:-"no"}"
PVT="${PVT:-"no"}"
GET_NIC_WITH_MAC="${GET_NIC_WITH_MAC:-"yes"}"
NIC_NUM=2

server="wsfd-advnetlab35.anl.eng.rdu2.dc.redhat.com"
client="wsfd-advnetlab36.anl.eng.rdu2.dc.redhat.com"
server_driver="mlx5_core"
client_driver="i40e"
SERVER_NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad"
CLIENT_NIC_MAC_STRING="3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11"

pushd ~

if [[ $image_mode == "yes" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad","3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11" --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --bootc=$COMPOSE,frompkg --packages="iproute2 bridge-utils grubby sshpass iperf3 gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq python3-scapy" --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info \`Image Mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
elif [[ $image_mode == "no" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad","3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11" --param=NIC_NUM=$NIC_NUM --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 2>/dev/null
