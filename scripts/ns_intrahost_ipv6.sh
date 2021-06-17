#!/bin/bash

ip netns add myns
ip netns exec myns ip link set lo up
ip link add veth0 type veth peer name veth1
ip link set netns myns dev veth1
ip netns exec myns ifconfig veth1 inet6 add 2222::1/64 up

## If running netserver and netperf in IPv6
#ip netns exec myns netserver -6
#ip netns exec rick netperf -6 -H 2222::1
