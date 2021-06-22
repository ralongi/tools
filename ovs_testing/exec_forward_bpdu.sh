#!/bin/bash

# forward-bpdu

dbg_flag="set -x"
pushd ~/git/kernel/networking/openvswitch/forward-bpdu
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe20.knqe.lab.eng.bos.redhat.com"
server_driver="i40e"
client_driver="i40e"
NIC_TX="3c:fd:fe:ad:82:11,3c:fd:fe:ad:82:44"
NIC_RX="3c:fd:fe:ad:82:10,3c:fd:fe:ad:82:45"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

#server="netqe6.knqe.lab.eng.bos.redhat.com"
#client="netqe5.knqe.lab.eng.bos.redhat.com"
#server_driver="ixgbe"
#client_driver="ixgbe"
#NIC_TX="a0:36:9f:4f:1e:aa,a0:36:9f:08:2b:c4"
#NIC_RX="a0:36:9f:4f:1e:a8,a0:36:9f:08:2b:c6"

lstest | runtest $COMPOSE  --arch=x86_64 --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=NAY=yes --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_TX=$NIC_TX --param=mh-NIC_RX=$NIC_RX --cmd="yum install -y policycoreutils-python; yum -y install $RPM_OVS_SELINUX_EXTRA_POLICY" --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/forward-bpdu, Client driver: $client_driver, Server driver: $server_driver"
	
popd
