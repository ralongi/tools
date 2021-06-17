#!/bin/bash

iface="p4p1"
vid="10"
br="br0"
ip4="192.168.111.4"
ip4_peer="192.168.111.2"

set_mtu()
{
	local target=$1
	local mtu=$2
	ip link set dev $target mtu $mtu
}

# bridge over vlan over nic, run netperf -H $remote_ip -L $local_ip -l 60 over bridge interface
bridge_vlan_nic_setup()
{
	# set up config
	ip link set dev $iface up
	ip link add link $iface name $iface.$vid type vlan id $vid
	ip link set dev $iface.$vid up
	brctl addbr $br
	ip link set dev $br up
	brctl addif $br $iface.$vid
	ip address add dev $br $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $iface.$vid mtu $mtu
	ip link set dev $br mtu $mtu
}

bridge_vlan_nic_cleanup()
{
	# clean up config
	ip addr flush dev $br
	ip link set dev $iface down
	ip link set dev $iface.$vid down
	ip link del dev $iface.$vid
	ip link set dev $br down
	brctl delbr $br
}

# vlan over bridge over nic, run netperf -H $remote_ip -L $local_ip -l 60 over vlan interface
vlan_bridge_nic_setup()
{
	# set up config
	ip link set dev $iface up
	brctl addbr $br
	ip link set dev $br up
	ip link add link $br name $br.$vid type vlan id $vid
	ip link set dev $br.$vid up
	ip address add dev $br.$vid $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $br.$vid mtu $mtu
	ip link set dev $br mtu $mtu
}

vlan_bridge_cleanup()
{
	# clean up config
	ip addr flush dev $br.$vid
	ip link set dev $iface down
	ip link del dev $br.$vid
	ip link set dev $br down
	brctl delbr $br
}

# vlan over nic, run netperf -H $remote_ip -L $local_ip -l 60 over vlan interface
vlan_nic_setup()
{
	# set up config
	ip link set dev $iface up
	ip link add link $iface name $iface.$vid vlan id $vid
	ip link set dev $iface.$vid up
	ip address add dev $iface.$vid $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $iface.$vid mtu $mtu
}

vlan_nic_cleanup()
{
	# clean up config
	ip addr flush dev $br.$vid
	ip link set dev $iface down
	ip link set dev $iface.$vid down
	ip link del dev $iface.$vid
	ip link set dev $br down
	brctl delbr $br
}

# bridge over nic, netperf -H $remote_ip -L $local_ip -l 60 over bridge interface
bridge_nic_setup()
{
	# set up config
	ip link set dev $iface up
	brctl addbr $br
	ip link set dev $br up
	brctl addif $br $iface
	ip address add dev $br $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $br mtu $mtu
}

bridge_nic_cleanup()
{
	# clean up config
	ip addr flush dev $br
	ip link set dev $iface down
	ip link set dev $br down
	brctl delbr $br
}

