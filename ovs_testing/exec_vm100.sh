#!/bin/bash

# vm100

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
SYSTYPE=${SYSTYPE:-"machine"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
COMPOSE_VER=$(echo $COMPOSE | awk -F 'RHEL-' '{print $2}' | awk -F '.' '{print $1}')
GIT_HOME=~/git/my_fork
arch=${arch:-"x86_64"}
image_mode=${image_mode:-"no"}
CLIENTS=helix93.telcoqe.eng.rdu2.dc.redhat.com
SERVERS=helix94.telcoqe.eng.rdu2.dc.redhat.com
NIC_DRIVER=mlx5_core
VM_IMAGE=rhel9.6.qcow2
NUMBER_OF_GUESTS=100
PVT= no
NAY=no
GET_NIC_WITH_MAC=yes
CLIENTS_NIC_MAC_STRING="9c:63:c0:25:fe:10"  #(for CLIENTS)
SERVERS_NIC_MAC_STRING="5c:25:73:4a:0a:f2"  #(for SERVERS)

pushd ~

if [[ $image_mode == "yes" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/vm100 | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --arch=$arch --topo=multiHost.1.1 --machine=$SERVERS,$CLIENTS --systype=$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=NIC_DRIVER=mlx5_core --param=VM_IMAGE=$VM_IMAGE --param=NUMBER_OF_GUESTS=$NUMBER_OF_GUESTS --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING=$SERVERS_NIC_MAC_STRING,$CLIENTS_NIC_MAC_STRING --bootc=$COMPOSE,frompkg --packages="grubby sshpass iperf3 gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq python3-scapy" --nrestraint --wb "(Server: $SERVERS, Client: $CLIENTS), VM100 test, $COMPOSE, openvswitch/vm100 $special_info \`Image Mode\`" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"	
elif [[ $image_mode == "no" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/vm100 | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --arch=$arch --topo=multiHost.1.1 --machine=$SERVERS,$CLIENTS --systype=$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=dbg_flag="$dbg_flag" --param=NAY=$NAY --param=PVT=$PVT --param=NIC_DRIVER=mlx5_core --param=VM_IMAGE=$VM_IMAGE --param=NUMBER_OF_GUESTS=$NUMBER_OF_GUESTS --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING=$SERVERS_NIC_MAC_STRING,$CLIENTS_NIC_MAC_STRING --nrestraint --wb "(Server: $SERVERS, Client: $CLIENTS), VM100 test, $COMPOSE, openvswitch/vm100 $special_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"	
fi

popd 2>/dev/null
