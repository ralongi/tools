#!/bin/bash

# ovs_qos

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
#pushd ~/git/kernel/networking/openvswitch/ovs_qos
pushd ~/temp
server="netqe3.knqe.lab.eng.bos.redhat.com"
client="netqe2.knqe.lab.eng.bos.redhat.com"
server_driver="i40e"
client_driver="ice"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
OVS_TOPO=${OVS_TOPO:-"ovs_all"}
#VM_IMAGE=rhel7.9.qcow2 # use RHEL-7 VM image to avoid ovs_qos_linux_htb test failure

lstest ~/git/kernel/networking/openvswitch/ovs_qos | runtest $COMPOSE --product=$product --retention-tag=$retention_tag --arch=x86_64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=mh-NIC_DRIVER=$server_driver,$client_driver --param=OVS_TOPO=$OVS_TOPO --param=SELINUX=$SELINUX --param=NAY=yes --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

rm -f *.xml
popd
