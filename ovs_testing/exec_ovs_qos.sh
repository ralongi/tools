#!/bin/bash

# ovs_qos

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
#pushd ~/git/my_fork/kernel/networking/openvswitch/ovs_qos
pushd ~/temp
server="netqe52.knqe.eng.rdu2.dc.redhat.com"
client="netqe51.knqe.eng.rdu2.dc.redhat.com"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
image_mode=${image_mode:-"no"}
NAY="${NAY:-"no"}"
PVT="${PVT:-"no"}"
GET_NIC_WITH_MAC="${GET_NIC_WITH_MAC:-"yes"}"

server="wsfd-advnetlab36.anl.eng.rdu2.dc.redhat.com"
client="wsfd-advnetlab35.anl.eng.rdu2.dc.redhat.com"
server_driver="i40e"
client_driver="mlx5_core"
SERVER_NIC_MAC_STRING="3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11" # XXV710 i40e
CLIENT_NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad" # CX6-LX mlx5_core

if [[ $image_mode == "yes" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/ovs_qos | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=OVS_TOPO=$OVS_TOPO --param=SELINUX=$SELINUX --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11","10:70:fd:5d:76:ac 10:70:fd:5d:76:ad" --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS -bootc=$COMPOSE,frompkg --packages="iproute2 bridge-utils grubby sshpass iperf3 gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq python3-scapy" --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info \`Image Mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
	lstest ~/git/my_fork/kernel/networking/openvswitch/ovs_qos | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=OVS_TOPO=$OVS_TOPO --param=SELINUX=$SELINUX --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11","10:70:fd:5d:76:ac 10:70:fd:5d:76:ad" --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

rm -f *.xml
popd 2>/dev/null
