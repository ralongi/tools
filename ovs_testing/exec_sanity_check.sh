#!/bin/bash

# sanity_check

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/sanity_check
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut="netqe40.knqe.lab.eng.bos.redhat.com"
NIC_DRIVER=${NIC_DRIVER:-"ixgbe"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

lstest | runtest $COMPOSE --machine=$dut -c 1 $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="set -x" --param=xena_chassis_module=5 --param=netscout_pair1="NETQE9_SLOT3PORT0 XENA_M5P0"  --param=netscout_pair1="NETQE9_SLOT3PORT1 XENA_M5P1" --param=SELINUX=$SELINUX --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=no --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/sanity_check, Driver: $NIC_DRIVER $brew_build $special_info"
	
popd
