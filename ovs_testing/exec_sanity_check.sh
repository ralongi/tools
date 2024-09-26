#!/bin/bash

# sanity_check

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
pushd ~/git/my_fork/kernel/networking/openvswitch/sanity_check
fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
#dut=${dut:-"netqe21.knqe.lab.eng.bos.redhat.com"}
dut=${dut:-"netqe32.knqe.eng.rdu2.dc.redhat.com"}
NIC_DRIVER=${NIC_DRIVER:-"i40e"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
netscout_pair1=${netscout_pair1:-"NETQE32_P3P1 XENA_M5P0"}
netscout_pair2=${netscout_pair2:-"NETQE32_P3P2 XENA_M5P1"}
skip_traffic_tests=${skip_traffic_tests:-"no"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
COMPOSE_VER_MINOR=$(echo $COMPOSE | awk -F "-" '{print $2}' | sed s/.0//g)
if [[ -z $image_name ]]; then
	image_name="rhel$COMPOSE_VER_MINOR.qcow2"
fi

# netqe31
#pushd ~/git/my_fork/kernel/networking/openvswitch/sanity_check
#FDP_RELEASE=23F
#fdp_release_dir=$(echo $FDP_RELEASE | tr -d [" ".])
#dut="netqe31.knqe.lab.eng.bos.redhat.com"
#COMPOSE=RHEL-9.2.0-updates-20230809.16
#RPM_OVS_SELINUX_EXTRA_POLICY=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch-selinux-extra-policy/1.0/34.el9fdp/noarch/openvswitch-selinux-extra-policy-1.0-34.el9fdp.noarch.rpm
#RPM_OVS=http://download.hosts.prod.psi.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/35.el9fdp/x86_64/openvswitch3.1-3.1.0-35.el9fdp.x86_64.rpm
#ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
#netscout_pair1="NETQE31_E810_5_P1 XENA_25_M9P0"
#netscout_pair2="NETQE31_E810_5_P2 XENA_25_M9P1"

# netqe31
#lstest | runtest $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$dut -c 1 -param=dbg_flag="set -x" --param=xena_chassis_module=9 --param=NAY=yes --param=NIC_DRIVER=ice --param=ROLE="STANDALONE" --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=fdp_release_dir=$fdp_release_dir --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/sanity_check, Driver: $NIC_DRIVER" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"

lstest | runtest $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$dut --topo=singlehost $(echo "$repo_cmd") $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") -param=dbg_flag="set -x" --param=xena_chassis_module=5 --param=NAY=yes --param=NIC_DRIVER=i40e --param=ROLE="STANDALONE" --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=skip_traffic_tests=$skip_traffic_tests --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "($dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/sanity_check, Driver: $NIC_DRIVER $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"

#lstest | runtest $COMPOSE --product=$product --retention-tag=$retention_tag --machine=$dut -c 1 $(echo "$repo_cmd") $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="set -x" --param=xena_chassis_module=5 --param=netscout_pair1="NETQE9_SLOT3PORT0 XENA_M5P0"  --param=netscout_pair2="NETQE9_SLOT3PORT1 XENA_M5P1" --param=SELINUX=$SELINUX --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=ROLE="STANDALONE" --param=image_name=$image_name --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_DPDK=$RPM_DPDK --param=RPM_DPDK_TOOLS=$RPM_DPDK_TOOLS --param=skip_traffic_tests=no --param=skip_cleanup_env=yes --param=skip_openvswitch_restart_test=no --param=fdp_release_dir=$fdp_release_dir --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/sanity_check, Driver: $NIC_DRIVER $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"
	
popd
