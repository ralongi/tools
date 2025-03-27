#!/bin/bash

# mcast_snoop

echo "COMPOSE is: $COMPOSE"

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
pushd ~/temp
fdp_release=$FDP_RELEASE
server="netqe51.knqe.eng.rdu2.dc.redhat.com"
client="netqe52.knqe.eng.rdu2.dc.redhat.com"
server_driver="ice"
client_driver="i40e"
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
#VM_IMAGE=rhel8.3.qcow2 # USE rhel8.3 VM IMAGE for now to avoid problems with ipv6 tests

cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/mcast_snoop" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --machine=$server,$client $(echo "$brew_build_cmd") --systype=machine,machine $(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=NAY=yes --param=PVT=no --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver  $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# image mode

#cat ~/git/my_fork/kernel/networking/tools/runtest-network/ovs.list | egrep "openvswitch/mcast_snoop" | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --cmd-and-reboot="grubby --args=crashkernel=640M --update-kernel=ALL" --machine=$server,$client $(echo "$brew_build_cmd") --systype=machine,machine $(echo "$zstream_repo_list") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=NAY=yes --param=PVT=no --param=image_name=$VM_IMAGE --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=mh-NIC_DRIVER=$server_driver,$client_driver --bootc=latest-10.0  --packages="grubby sshpass iperf3 virt-viewer virt-install libvirt-daemon virt-manager libvirt qemu-kvm libguestfs guestfs-tools gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq" --nrestraint --wb "(Server: $server, Client: $client), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/mcast_snoop, Client driver: $client_driver, Server driver: $server_driver  $special_info \`image mode\`" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

rm -f ~/git/my_fork/kernel/networking/tools/runtest-network/job*.xml --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

popd 2>/dev/null
