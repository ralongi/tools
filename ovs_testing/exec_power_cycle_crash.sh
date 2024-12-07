#!/bin/bash

# power_cycle_crash

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
dut=${dut:-"wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

pushd ~/temp

lstest ~/git/my_fork/kernel/networking/openvswitch/power_cycle_crash/set_config | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --product=$product --retention-tag=$retention_tag --ks-post "$(cat ~/temp/rhts_power.sh)" --arch=x86_64 --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=ROLE="STANDALONE" --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM --param=NAY=yes --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Standalone: $dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/power_cycle_crash $brew_build $special_info" --append-task="/distribution/utils/power-cycle" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x}" --append-task="/distribution/crashes/crash-sysrq-c" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x}"

popd 2>/dev/null
