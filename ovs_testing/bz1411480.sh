#!/bin/bash

ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

# vxlan with udpcsum option enabled

ovs-vsctl add-br br0 -- set Bridge br0 protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-vsctl add-br br-underlay -- set Bridge br-underlay protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-ofctl add-flow br-underlay "actions=normal"

ip netns add at_ns0
ip netns exec at_ns0 sysctl -w net.netfilter.nf_conntrack_helper=0

echo "priority=1,action=drop"                                      > flows.txt
echo "priority=10,arp,action=normal"                              >> flows.txt
echo "priority=100,in_port=1,icmp,action=ct(commit,zone=9),LOCAL" >> flows.txt
echo "priority=100,in_port=LOCAL,icmp,action=ct(table=1,zone=9)"  >> flows.txt
echo "table=1,in_port=LOCAL,ct_state=+trk+est,icmp,action=1"      >> flows.txt

ovs-ofctl --bundle add-flows br0 flows.txt

ip link add p0 type veth peer name ovs-p0
ip link set p0 netns at_ns0
ip link set dev ovs-p0 up
ovs-vsctl add-port br-underlay ovs-p0 -- set interface ovs-p0 external-ids:iface-id="p0"
ip netns exec at_ns0 ip addr add "172.31.1.1/24" dev p0
ip netns exec at_ns0 ip link set dev p0 up

ip addr add dev br-underlay "172.31.1.100/24"
ip link set dev br-underlay up

ovs-vsctl add-port br0 at_vxlan0 -- set int at_vxlan0 type=vxlan options:remote_ip=172.31.1.1
ip addr add dev br0 10.1.1.100/24
ip link set dev br0 up
ip link set dev br0 mtu 1450

ip netns exec at_ns0 ip link add dev at_vxlan1 type vxlan remote 172.31.1.100 id 0 dstport 4789 udpcsum
ip netns exec at_ns0 ip addr add dev at_vxlan1 10.1.1.1/24
ip netns exec at_ns0 ip link set dev at_vxlan1 mtu 1450 up

# First, check the underlay
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 172.31.1.100

# Okay, now check the overlay with different packet sizes
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 1600 -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 3200 -q -c 3 -i 0.3 -w 2 10.1.1.100

# Cleanup
ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

# vxlan with udpcsum option disabled

ovs-vsctl add-br br0 -- set Bridge br0 protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-vsctl add-br br-underlay -- set Bridge br-underlay protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-ofctl add-flow br-underlay "actions=normal"

ip netns add at_ns0
ip netns exec at_ns0 sysctl -w net.netfilter.nf_conntrack_helper=0

echo "priority=1,action=drop"                                      > flows.txt
echo "priority=10,arp,action=normal"                              >> flows.txt
echo "priority=100,in_port=1,icmp,action=ct(commit,zone=9),LOCAL" >> flows.txt
echo "priority=100,in_port=LOCAL,icmp,action=ct(table=1,zone=9)"  >> flows.txt
echo "table=1,in_port=LOCAL,ct_state=+trk+est,icmp,action=1"      >> flows.txt

ovs-ofctl --bundle add-flows br0 flows.txt

ip link add p0 type veth peer name ovs-p0
ip link set p0 netns at_ns0
ip link set dev ovs-p0 up
ovs-vsctl add-port br-underlay ovs-p0 -- set interface ovs-p0 external-ids:iface-id="p0"
ip netns exec at_ns0 ip addr add "172.31.1.1/24" dev p0
ip netns exec at_ns0 ip link set dev p0 up

ip addr add dev br-underlay "172.31.1.100/24"
ip link set dev br-underlay up

ovs-vsctl add-port br0 at_vxlan0 -- set int at_vxlan0 type=vxlan options:remote_ip=172.31.1.1
ip addr add dev br0 10.1.1.100/24
ip link set dev br0 up
ip link set dev br0 mtu 1450

ip netns exec at_ns0 ip link add dev at_vxlan1 type vxlan remote 172.31.1.100 id 0 dstport 4789
ip netns exec at_ns0 ip addr add dev at_vxlan1 10.1.1.1/24
ip netns exec at_ns0 ip link set dev at_vxlan1 mtu 1450 up

# First, check the underlay
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 172.31.1.100

# Okay, now check the overlay with different packet sizes
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 1600 -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 3200 -q -c 3 -i 0.3 -w 2 10.1.1.100

# Cleanup
ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

##########################################################################

# geneve with udpcsum option enabled

ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

ovs-vsctl add-br br0 -- set Bridge br0 protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-vsctl add-br br-underlay -- set Bridge br-underlay protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-ofctl add-flow br-underlay "actions=normal"

ip netns add at_ns0
ip netns exec at_ns0 sysctl -w net.netfilter.nf_conntrack_helper=0

echo "priority=1,action=drop"                                      > flows.txt
echo "priority=10,arp,action=normal"                              >> flows.txt
echo "priority=100,in_port=1,icmp,action=ct(commit,zone=9),LOCAL" >> flows.txt
echo "priority=100,in_port=LOCAL,icmp,action=ct(table=1,zone=9)"  >> flows.txt
echo "table=1,in_port=LOCAL,ct_state=+trk+est,icmp,action=1"      >> flows.txt

ovs-ofctl --bundle add-flows br0 flows.txt

ip link add p0 type veth peer name ovs-p0
ip link set p0 netns at_ns0
ip link set dev ovs-p0 up
ovs-vsctl add-port br-underlay ovs-p0 -- set interface ovs-p0 external-ids:iface-id="p0"
ip netns exec at_ns0 ip addr add "172.31.1.1/24" dev p0
ip netns exec at_ns0 ip link set dev p0 up

ip addr add dev br-underlay "172.31.1.100/24"
ip link set dev br-underlay up

ovs-vsctl add-port br0 at_geneve0 -- set int at_geneve0 type=geneve options:remote_ip=172.31.1.1
ip addr add dev br0 10.1.1.100/24
ip link set dev br0 up
ip link set dev br0 mtu 1450

ip netns exec at_ns0 ip link add dev at_geneve1 type geneve remote 172.31.1.100 id 0 dstport 6081 udpcsum
ip netns exec at_ns0 ip addr add dev at_geneve1 10.1.1.1/24
ip netns exec at_ns0 ip link set dev at_geneve1 mtu 1450 up

# First, check the underlay
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 172.31.1.100

# Okay, now check the overlay with different packet sizes
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 1600 -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 3200 -q -c 3 -i 0.3 -w 2 10.1.1.100

# Cleanup
ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

# geneve with udpcsum option disabled

ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay

ovs-vsctl add-br br0 -- set Bridge br0 protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-vsctl add-br br-underlay -- set Bridge br-underlay protocols=OpenFlow10,OpenFlow11,OpenFlow12,OpenFlow13,OpenFlow14 fail-mode=secure
ovs-ofctl add-flow br-underlay "actions=normal"

ip netns add at_ns0
ip netns exec at_ns0 sysctl -w net.netfilter.nf_conntrack_helper=0

echo "priority=1,action=drop"                                      > flows.txt
echo "priority=10,arp,action=normal"                              >> flows.txt
echo "priority=100,in_port=1,icmp,action=ct(commit,zone=9),LOCAL" >> flows.txt
echo "priority=100,in_port=LOCAL,icmp,action=ct(table=1,zone=9)"  >> flows.txt
echo "table=1,in_port=LOCAL,ct_state=+trk+est,icmp,action=1"      >> flows.txt

ovs-ofctl --bundle add-flows br0 flows.txt

ip link add p0 type veth peer name ovs-p0
ip link set p0 netns at_ns0
ip link set dev ovs-p0 up
ovs-vsctl add-port br-underlay ovs-p0 -- set interface ovs-p0 external-ids:iface-id="p0"
ip netns exec at_ns0 ip addr add "172.31.1.1/24" dev p0
ip netns exec at_ns0 ip link set dev p0 up

ip addr add dev br-underlay "172.31.1.100/24"
ip link set dev br-underlay up

ovs-vsctl add-port br0 at_geneve0 -- set int at_geneve0 type=geneve options:remote_ip=172.31.1.1
ip addr add dev br0 10.1.1.100/24
ip link set dev br0 up
ip link set dev br0 mtu 1450

ip netns exec at_ns0 ip link add dev at_geneve1 type geneve remote 172.31.1.100 id 0 dstport 6081
ip netns exec at_ns0 ip addr add dev at_geneve1 10.1.1.1/24
ip netns exec at_ns0 ip link set dev at_geneve1 mtu 1450 up

# First, check the underlay
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 172.31.1.100

# Okay, now check the overlay with different packet sizes
ip netns exec at_ns0 ping -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 1600 -q -c 3 -i 0.3 -w 2 10.1.1.100

ip netns exec at_ns0 ping -s 3200 -q -c 3 -i 0.3 -w 2 10.1.1.100

# Cleanup
ip netns del at_ns0
ovs-vsctl del-br br0
ovs-vsctl del-br br-underlay


