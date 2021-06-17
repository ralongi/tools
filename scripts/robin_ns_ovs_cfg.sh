#!/bin/bash

# Create an OVS
ovs-vsctl add-br ovsbr0
ovs-vsctl add-port ovsbr0 enp7s0f0

# Create a name space
ip netns add myns
ip netns exec myns ip link set lo up

# Create veth pair, and assign it to the name space
ip link add veth0 type veth peer name veth1
ip link set netns myns dev veth1
ip netns exec myns ifconfig veth1 192.168.99.100/24

# Add veth0 to OVS
ovs-vsctl add-port ovsbr0 veth0 tag=10
