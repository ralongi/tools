#!/bin/bash

distro=$1
base_dir="/home/ralongi/kernel/networking/openvswitch"

# Tests
runtest $distro $base_dir/upgrade_systemd_check/ -- --variant=Server --param=start_ovs_ver="2.5.0.14" --param=target_upgrade_ver="2.5.0.23"

runtest $distro $base_dir/ovs_systemd/ -- --variant=Server --param=dbg_flag="set -x" --param=selinux_enable="no" --param=vm_version="7.3" --param=openvswitch_rpm="http://download.devel.redhat.com/brewroot/packages/openvswitch/2.6.1/3.git20161206.el7fdb/x86_64/openvswitch-2.6.1-3.git20161206.el7fdb.x86_64.rpm"
