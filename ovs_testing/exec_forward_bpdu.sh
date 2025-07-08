#!/bin/bash

# forward_bpdu

echo "COMPOSE is: $COMPOSE"

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
pushd ~/temp
fdp_release=$FDP_RELEASE
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
#server="netqe51.knqe.eng.rdu2.dc.redhat.com"
#client="netqe52.knqe.eng.rdu2.dc.redhat.com"
#server_driver="ice"
#client_driver="i40e"
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

pushd ~/temp

if [[ $image_mode == "yes" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/forward_bpdu | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --product=$product --retention-tag=$retention_tag --machine=$server,$client $(echo "$brew_build_cmd") --systype=machine,machine $(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX -param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING=$SERVER_NIC_MAC_STRING,$CLIENT_NIC_MAC_STRING --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --bootc=$COMPOSE --packages="grubby sshpass iperf3 virt-viewer virt-install libvirt-daemon virt-manager libvirt qemu-kvm libguestfs guestfs-tools gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq" --nrestraint --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/forward_bpdu, Client driver: $client_driver, Server driver: $server_driver  $special_info \`image mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
else
	lstest ~/git/my_fork/kernel/networking/openvswitch/forward_bpdu | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --product=$product --retention-tag=$retention_tag --machine=$server,$client $(echo "$brew_build_cmd") --systype=machine,machine $(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad","3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11" --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/forward_bpdu, Client driver: $client_driver, Server driver: $server_driver  $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 2>/dev/null
