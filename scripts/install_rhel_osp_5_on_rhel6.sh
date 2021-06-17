#!/bin/bash

# script to install RHEL OSP 5.0 on RHEL6

default_iface=$(ip route | awk '/default/ {print $5}')

# set variable to default interface on local host
ipaddr1=$(ip a | grep $default_iface | grep inet | awk '{ print $2'} | awk -F "/" '{ print $1 }')

# set variable(s) for remote interfaces
ipaddr2="10.19.15.33"

### the wget commands below must be run on all nodes ###
wget -O /etc/yum.repos.d/RH6-RHOS-5.0.repo http://download.lab.bos.redhat.com/rel-eng/OpenStack/5.0-RHEL-6/latest/RH6-RHOS-5.0.repo
wget -O /etc/yum.repos.d/external-RH6-RHOS-5.0.repo http://download.lab.bos.redhat.com/rel-eng/OpenStack/5.0-RHEL-6/latest/external-RH6-RHOS-5.0.repo
###

# the packstack related commands below only need to be run on the controller node ?

# install packstack package
pushd /home; yum -y install */packstack

# generate packstack answer file
packstack --gen-answer-file=packstack.ans

# back up packstack.ans file
/bin/cp -f packstack.ans packstack_orig.ans

# make necessary edits to packstack.ans file
awk '{if ($1 ~ /^CONFIG_COMPUTE_HOSTS='$ipaddr1'/) print $0",'$ipaddr2'"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=vxlan/) print $0",gre"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan/) print $0",gre"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_ML2_VLAN_RANGES=/) print $0"1:1000"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_OVS_VLAN_RANGES=/) print $0"physnet1:1:1000,physnet2:1:1000,physnet3:1:1000,physnet4:1:1000"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=/) print $0"physnet1:br-link1,physnet2:br-link2,physnet3:br-link3,physnet4:br-link4"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '{if ($1 ~ /^CONFIG_NEUTRON_OVS_TUNNEL_RANGES=/) print $0"1:1000"; else print $0}' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '/CONFIG_PROVISION_DEMO=y/ { sub(/y/, "n") }; { print }' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans
awk '/CONFIG_HORIZON_SSL=n/ { sub(/n/, "y") }; { print }' packstack.ans > packstack.tmp; mv -f packstack.tmp packstack.ans

# run packstack to install OSP
packstack --answer-file=packstack.ans

### verify that installation completed succesfully
