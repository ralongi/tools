#!/bin/bash

# memory_leak_soak

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/memory_leak_soak
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut=${dut:-"wsfd-advnetlab34.anl.lab.eng.bos.redhat.com"}
trex_server=${trex_server:-"wsfd-advnetlab33.anl.lab.eng.bos.redhat.com"}
NIC_DRIVER=${NIC_DRIVER:-"i40e"}
OVS_TOPO=${OVS_TOPO:-""}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

# Full test
#lstest | runtest $COMPOSE --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVS=$RPM_OVN_COMMON --param=RPM_OVS=$RPM_OVN_CENTRAL --param=RPM_OVS=$RPM_OVN_HOST  --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"

# All tests, short duration
#lstest | runtest $COMPOSE --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVS=$RPM_OVN_COMMON --param=RPM_OVS=$RPM_OVN_CENTRAL --param=RPM_OVS=$RPM_OVN_HOST --param=traffic_runtime=1000 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"

# 1K flow tests only, short duration (sanity check)
lstest | runtest $COMPOSE --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVS=$RPM_OVN_COMMON --param=RPM_OVS=$RPM_OVN_CENTRAL --param=RPM_OVS=$RPM_OVN_HOST --param=traffic_runtime=1000 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=skip_5k_flows=yes --param=skip_10k_flows=yes --param=skip_25k_flows=yes --param=skip_100k_flows=yes --param=skip_1m_flows=yes --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER"

popd
