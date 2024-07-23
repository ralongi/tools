#!/bin/bash

# memory_leak_soak

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/memory_leak_soak
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
dut=${dut:-"wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"}
#SERVERS=$dut
#CLIENTS="null"
ROLE="STANDALONE"

trex_server=${trex_server:-"wsfd-advnetlab33.anl.eng.rdu2.dc.redhat.com"}
NIC_DRIVER=${NIC_DRIVER:-"i40e"}
OVS_TOPO=${OVS_TOPO:-""}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
skip_dpdk_tests=${skip_dpdk_tests:-"yes"}
skip_kernel_tests=${skip_kernel_tests:-"no"}
compose_minor_ver=$(echo $COMPOSE | awk -F "-" '{print $2}' | awk -F "." '{print $1"."$2}')
image_name=${image_name:-"rhel"$compose_minor_ver".qcow2"}
gen_valgrind_suppressions=${gen_valgrind_suppressions:-"yes"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

# Full test
#lstest | runtest $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$dut --systype=machine --param=ROLE=$ROLE --param=dbg_flag="set -x" --param=skip_kernel_tests=$skip_kernel_tests --param=skip_dpdk_tests=$skip_dpdk_tests --param=image_name=$image_name --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=RPM_OVN_CENTRAL=$RPM_OVN_CENTRAL --param=RPM_OVN_HOST=$RPM_OVN_HOST --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --param=gen_valgrind_suppressions=$gen_valgrind_suppressions --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# Full test but skip DPDK
#lstest | runtest $COMPOSE --machine=$dut --systype=machine --param=ROLE=$ROLE --param=dbg_flag="set -x" --param=skip_kernel_tests=$skip_kernel_tests --param=skip_dpdk_tests=$skip_dpdk_tests --param=image_name=$image_name --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=RPM_OVN_CENTRAL=$RPM_OVN_CENTRAL --param=RPM_OVN_HOST=$RPM_OVN_HOST --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --param=gen_valgrind_suppressions=$gen_valgrind_suppressions --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# All tests, short duration
lstest | runtest $COMPOSE --machine=$dut --systype=machine --param=ROLE=$ROLE --param=dbg_flag="set -x" --param=skip_kernel_tests=$skip_kernel_tests --param=skip_dpdk_tests=$skip_dpdk_tests --param=image_name=$image_name --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=RPM_OVN_CENTRAL=$RPM_OVN_CENTRAL --param=RPM_OVN_HOST=$RPM_OVN_HOST --param=traffic_runtime=1000 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --param=gen_valgrind_suppressions=$gen_valgrind_suppressions --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

# 1K flow tests only, short duration (sanity check)
#lstest | runtest $COMPOSE --machine=$dut --systype=machine --param=ROLE=$ROLE --param=dbg_flag="set -x" --param=skip_kernel_tests=$skip_kernel_tests --param=skip_dpdk_tests=$skip_dpdk_tests --param=image_name=$image_name --param=SELINUX=$SELINUX --param=OVS_TOPO=$OVS_TOPO --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=RPM_OVN_CENTRAL=$RPM_OVN_CENTRAL --param=RPM_OVN_HOST=$RPM_OVN_HOST --param=traffic_runtime=1000 --param=mem_check_interval=30s --param=num_mem_checks=24 --param=skip_5k_flows=yes --param=skip_10k_flows=yes --param=skip_25k_flows=yes --param=skip_100k_flows=yes --param=skip_1m_flows=yes --param=fdp_release_dir=$fdp_release_dir --param=trex_server=$trex_server --param=gen_valgrind_suppressions=$gen_valgrind_suppressions --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/memory_leak_soak, Driver: $NIC_DRIVER $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

popd
