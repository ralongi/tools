#!/bin/bash

# mcast_snoop

echo "COMPOSE is: $COMPOSE"

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/tools/runtest-network
fdp_release=$FDP_RELEASE
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe20.knqe.lab.eng.bos.redhat.com"
server_driver="i40e"
client_driver="i40e"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
VM_IMAGE=rhel8.3.qcow2 # USE rhel8.3 VM IMAGE for now to avoid problems with ipv6 tests

cat ovs.list | egrep "openvswitch/mcast_snoop" | runtest $COMPOSE --machine=$server,$client --systype=machine,machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=NAY=yes --param=PVT=no --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver"

popd
