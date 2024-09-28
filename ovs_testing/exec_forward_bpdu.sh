#!/bin/bash

# forward_bpdu

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
#pushd ~/git/my_fork/kernel/networking/openvswitch/forward_bpdu
pushd ~/temp
server="netqe51.knqe.eng.rdu2.dc.redhat.com"
client="netqe52.knqe.eng.rdu2.dc.redhat.com"
server_driver="ice"
client_driver="i40e"
#NIC_TX="b4:96:91:a0:3f:7e,40:a6:b7:2f:b9:21"
#NIC_RX="b4:96:91:a0:3f:7f,40:a6:b7:2f:b9:20"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
NIC_NUM=2

#server="netqe6.knqe.lab.eng.bos.redhat.com"
#client="netqe5.knqe.lab.eng.bos.redhat.com"
#server_driver="ixgbe"
#client_driver="ixgbe"
#NIC_TX="a0:36:9f:4f:1e:aa,a0:36:9f:08:2b:c4"
#NIC_RX="a0:36:9f:4f:1e:a8,a0:36:9f:08:2b:c6"

#lstest ~/git/my_fork/kernel/networking/openvswitch/forward_bpdu| runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=NAY=yes --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_TX=$NIC_TX --param=mh-NIC_RX=$NIC_RX --cmd="yum install -y policycoreutils-python; yum -y install $RPM_OVS_SELINUX_EXTRA_POLICY" --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/forward_bpdu, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

lstest ~/git/my_fork/kernel/networking/openvswitch/forward_bpdu| runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine --param=dbg_flag="$dbg_flag" --param=NAY=yes --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=NIC_NUM=$NIC_NUM --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/forward_bpdu, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
popd
