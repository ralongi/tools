#!/bin/bash

# ovs_qos

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/ovs_qos
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe44.knqe.lab.eng.bos.redhat.com"
server_driver="i40e"
client_driver="i40e"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
VM_IMAGE=rhel7.9.qcow2 # use RHEL-7 VM image to avoid ovs_qos_linux_htb test failure

lstest | runtest $COMPOSE --arch=x86_64 --machine=$server,$client --systype=machine,machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=NAY=yes --param=image_name=$VM_IMAGE --param=SRC_NETPERF=$SRC_NETPERF --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_qos, Client driver: $client_driver, Server driver: $server_driver $brew_build $special_info"

popd
