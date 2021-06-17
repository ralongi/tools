#!/bin/bash

iface="p2p1"
vid="10"
br="br0"
ip4="192.168.111.2"
ip4_peer="192.168.111.4"

set_mtu()
{
	local target=$1
	local mtu=$2
	ip link set dev $target mtu $mtu
}

# bridge over vlan over nic, run netperf -H $remote_ip -L $local_ip -l 60 over bridge interface
bridge_vlan_nic()
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
	sleep 5

	# run netperf
	netperf -H $ip4_peer -L $ip4 -l 60 -t TCP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t UDP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t SCTP_STREAM
	sleep 5

	# clean up config
	ip addr flush dev $br
	ip link set dev $iface down
	ip link del dev $iface.$vid
	ip link set dev $br down
	brctl delbr $br
}

# vlan over bridge over nic, run netperf -H $remote_ip -L $local_ip -l 60 over vlan interface
vlan_bridge_nic()
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
	sleep 5

	# run netperf
	netperf -H $ip4_peer -L $ip4 -l 60 -t TCP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t UDP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t SCTP_STREAM
	sleep 5

	# clean up config
	ip addr flush dev $br.$vid
	ip link set dev $iface down
	ip link del dev $br.$vid
	ip link set dev $br down
	brctl delbr $br
}

# vlan over nic, run netperf -H $remote_ip -L $local_ip -l 60 over vlan interface
vlan_nic()
{
	# set up config
	ip link set dev $iface up
	ip link add link $iface name $iface.$vid vlan id $vid
	ip link set dev $iface.$vid up
	ip address add dev $iface.$vid $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $iface.$vid mtu $mtu
	sleep 5

	# clean up config
	ip addr flush dev $br.$vid
	ip link set dev $iface down
	ip link set dev $iface.$vid down
	ip link del dev $iface.$vid
	ip link set dev $br down
	brctl delbr $br
}


# bridge over nic, netperf -H $remote_ip -L $local_ip -l 60 over bridge interface
bridge_nic()
{
	# set up config
	ip link set dev $iface up
	brctl addbr $br
	ip link set dev $br up
	brctl addif $br $iface
	ip address add dev $br $ip4/24
	ip link set dev $iface mtu $mtu
	ip link set dev $br mtu $mtu
	sleep 5

	# run netperf
	netperf -H $ip4_peer -L $ip4 -l 60 -t TCP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t UDP_STREAM
	sleep 5
	netperf -H $ip4_peer -L $ip4 -l 60 -t SCTP_STREAM
	sleep 5

	# clean up config
	ip addr flush dev $br
	ip link set dev $iface down
	ip link set dev $br down
	brctl delbr $br
}

# tests

# set MTU to 1500
mtu=1500

# run tests
for i in {1..10}; do bridge_vlan_nic; done
for i in {1..10}; do vlan_bridge_nic; done
for i in {1..10}; do vlan_nic; done
for i in {1..10}; do bridge_nic; done

# change mtu to 9000
mtu=9000

# run tests
for i in {1..10}; do bridge_vlan_nic; done
for i in {1..10}; do vlan_bridge_nic; done
for i in {1..10}; do vlan_nic; done
for i in {1..10}; do bridge_nic; done

