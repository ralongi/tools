#!/bin/bash

# of_rules

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
image_mode=${image_mode:-"no"}
NAY="${NAY:-"no"}"
PVT="${PVT:-"no"}"
GET_NIC_WITH_MAC="${GET_NIC_WITH_MAC:-"yes"}"
NIC_NUM=2

if [[ $(echo $COMPOSE | awk -F - '{print $2}' | awk -F '.' '{print $1}') -lt 10 ]]; then
	locate_pkg=mlocate
else
	locate_pkg=plocate
fi

server="001-r760-ee58u02.anl.eng.rdu2.dc.redhat.com"
client="002-r760-ee58u04.anl.eng.rdu2.dc.redhat.com"
server_driver="sfc"
client_driver="i40e"
#SERVER_NIC_MAC_STRING="10:70:fd:5d:76:ac 10:70:fd:5d:76:ad"
#CLIENT_NIC_MAC_STRING="3c:fd:fe:ea:f8:10 3c:fd:fe:ea:f8:11"

pushd ~

if [[ $image_mode == "yes" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --bootc=$COMPOSE --nrestraint --autopath --kernel-options "crashkernel=640M" --packages="virt-viewer,virt-install,libvirt-daemon,virt-manager,libvirt,qemu-kvm,libguestfs,guestfs-tools,gcc,gcc-c++,glibc-devel,net-tools,zlib-devel,pciutils,lsof,tcl,tk,git,wget,nano,driverctl,dpdk,dpdk-tools,ipv6calc,wireshark-cli,nmap-ncat,python3-pip,python3-scapy,rpmdevtools,git,netperf,dnsmasq,$locate_pkg" --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=SERVERS="$server" --param=CLIENTS="$client" --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="00:0f:53:7c:b2:70 00:0f:53:7c:b2:71","3c:fd:fe:ad:86:b4 3c:fd:fe:ad:86:b5" --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=2 --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --bootc=$COMPOSE,frompkg --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info \`of_rules Image Mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
elif [[ $image_mode == "no" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --kernel-options "crashkernel=640M" --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=SERVERS="$server" --param=CLIENTS="$client" --param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=mh-NIC_MAC_STRING="00:0f:53:7c:b2:70 00:0f:53:7c:b2:71","3c:fd:fe:ad:86:b4 3c:fd:fe:ad:86:b5" --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=2 --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info \`of_rules Package Mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 2>/dev/null
