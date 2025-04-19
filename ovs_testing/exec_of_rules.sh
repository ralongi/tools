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
NIC_NUM=2
COMPOSE_VER=$(echo $COMPOSE | awk -F 'RHEL-' '{print $2}' | awk -F '.' '{print $1}')
GIT_HOME=~/git/my_fork
NAY=${NAY:-"yes"}
arch=${arch:-"x86_64"}
image_mode=${image_mode:-"no"}

pushd ~

if [[ $image_mode == "yes" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=NAY=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --bootc=$COMPOSE,frompkg --packages="iproute2 bridge-utils grubby sshpass iperf3 gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq python3-scapy" --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info \`Image Mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
elif [[ $image_mode == "no" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/of_rules | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=NAY=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/of_rules, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
fi

popd 2>/dev/null
