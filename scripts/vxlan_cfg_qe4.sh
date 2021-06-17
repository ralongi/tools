#!/bin/bash

# settings used for setup
iface=$1
if [ $# -ne 1 ]; then
	echo "Usage: $0 <interface> (Example: $0 p7p1)"
	exit 1
fi
ovsbr="myovs"
vxlan_tun="vxlan1"
mtu=1500
vxlan_mtu=$(($mtu-58))
ip4addr=192.168.120.4
ip4addr_peer=192.168.120.2
intport=inport0
intport_ip4=192.168.220.4
intport_ip4_peer=192.168.220.2
tnl_offload=$(ethtool -k $iface | grep tx-udp_tnl-segmentation | awk '{ print $2 }')
nic_driver=$(ethtool -i $iface | awk '/driver:/{print $2}')

# function to gather basic interface information
get_current_link_cfg()
{
    ip a | grep -A4 $iface
    echo -e
	ip a | grep $intport; if [[ $? == 0 ]]; then ip a | grep -A4 $intport; fi
    echo -e
    ip r
    echo -e
    ip -6 r
    echo -e
    ovs-vsctl show
    echo -e
}

# commands to configure ovs and vxlan
ip addr flush dev $iface
ip addr flush dev $intport
ovs-vsctl --if-exists del-br $ovsbr
ovs-vsctl add-br $ovsbr
ip link set dev $ovsbr up
ovs-vsctl add-port $ovsbr $vxlan_tun -- set interface $vxlan_tun type=vxlan options:remote_ip=$ip4addr_peer
ovs-vsctl add-port $ovsbr $intport -- set interface $intport type=internal
ip addr add $ip4addr/24 dev $iface
ip link set dev $iface mtu $mtu
ip link set dev $intport mtu $vxlan_mtu || true
ip link set dev $iface up
ip link set dev $intport up
ip addr add $intport_ip4/24 dev $intport
sleep 10

# get current settings for $iface under test
get_current_link_cfg

# check the current setting for VxLAN offload using ethtool -k
echo "VxLAN offoad is currently set to: $tnl_offload."

# check dmesg for vxlan messages
dmesg | grep -i $nic_driver
dmesg | grep -i vxlan

# gather information for $iface using ethtool
ethtool $iface
ethtool -i $iface
ethtool -k $iface

# clear IP config 
#ip addr flush dev $iface
#ip add flush dev $intport

