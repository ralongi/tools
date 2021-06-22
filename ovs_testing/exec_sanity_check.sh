#!/bin/bash

# sanity_check

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/sanity_check
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut="netqe9.knqe.lab.eng.bos.redhat.com"
NIC_DRIVER=${NIC_DRIVER:-"ixgbe"}

lstest | runtest $COMPOSE --machine=$dut --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=yes --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/sanity_check, Driver: $NIC_DRIVER"
	
popd
