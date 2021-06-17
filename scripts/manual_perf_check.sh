#!/bin/bash

rhel_version=$(cut -f1 -d. /etc/redhat-release | sed 's/[^0-9]//g')

if [[ ! $(which git) ]]; then
	echo "Installing Git and cloning repo..."
	yum -y install git
	mkdir /mnt/git_repo
	cd /mnt/git_repo && git clone git://pkgs.devel.redhat.com/tests/kernel
fi

yum -y install openssl

. /mnt/git_repo/kernel/networking/impairment/install.sh || exit 1
. /mnt/git_repo/kernel/networking/openvswitch/perf_check/lib_perf_check.sh || exit 1
. /mnt/git_repo/kernel/networking/openvswitch/lib_config.sh || exit 1

iface=$1
cfg=$2
ovsbr="ovsbr0"
intport="intport0"
vxlan_tun="vxlan1"
gre_tun="gre1"
geneve_tun="geneve1"
mtu="1500"
vxlan_mtu=$(($mtu-58))
gre_mtu=$(($mtu-50))
vlan_id="10"
vm_list="g1"

host=$(hostname)
if [[ $host == "netqe8.knqe.lab.eng.bos.redhat.com" ]]; then
        ip4addr="192.168.1.8"
        ip6addr="2017::8"
        ip4addr_peer="192.168.1.7"
        ip6addr_peer="2017::7"
        intport_ip4="192.168.100.8"
        intport_ip6="2016::8"
        pvt_netperf_install
        pkill netserver; sleep 2; netserver
elif [[ $host == "netqe7.knqe.lab.eng.bos.redhat.com" ]]; then
        ip4addr="192.168.1.7"
        ip6addr="2017::7"
        ip4addr_peer="192.168.1.8"
        ip6addr_peer="2017::8"
        intport_ip4="192.168.100.7"
        intport_ip6="2016::7"
        pvt_netperf_install
fi

pvt_install_expect
pvt_ovs_install
pvt_virt_install

if [[ $(which ovs-vsctl) ]]; then 
	ovs-vsctl list bridge | grep name | awk '{system("ovs-vsctl --if-exist del-br "$3)}'
fi

flush-ip-addresses
use_vm="yes"
if [[ $use_vm == "yes" ]]; then
	ovs-vsctl --if-exists del-br $ovsbr && ovs-vsctl add-br $ovsbr 
	for i in $vm_list; do
		virsh list --all | grep $i
		if [[ $? -ne 0 ]]; then create-vm $i $rhel_minor_version_actual $ovsbr; fi
	done
fi

# Examples of $cfg below are ovs_vxlan_cfg, ovs_geneve_vlan_cfg, etc.
$cfg
