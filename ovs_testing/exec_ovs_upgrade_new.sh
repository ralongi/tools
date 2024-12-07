#!/bin/bash

# ovs_upgrade

pushd ~/temp

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
LEAPP_UPGRADE=${LEAPP_UPGRADE:-"no"}
#leapp_upgrade_repo=${leapp_upgrade_repo:-"http://file.emea.redhat.com/~mreznik/tmp/leapp_upgrade_repositories.repo"}

get_starting_packages()
{
    starting_stream=$(grep OVS$FDP_STREAM2 /home/ralongi/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'p
ython|tcpdump' | tail -n2 | head -n1 | awk -F "_" '{print $2}')
    
    export STARTING_RPM_OVS=$(grep "$starting_stream" /home/ralongi/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep OVS$FDP_STREAM2 | grep 
RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump' | awk -F "=" '{print $2}')
    export STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$(grep "$starting_stream" package_list.sh | grep -i
 selinux | grep RHEL$RHEL_VER_MAJOR)

    echo "STARTING_RPM_OVS: $STARTING_RPM_OVS"
    echo "STARTING_RPM_OVS_SELINUX_EXTRA_POLICY: $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY"
}

get_starting_packages

dut=${dut:-"netqe21.knqe.lab.eng.bos.redhat.com"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

lstest ~/git/my_fork/kernel/networking/openvswitch/ovs_upgrade | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE  --arch=x86_64 --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM --param=NAY=yes --param=STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$STARTING_RPM_OVS_SELINUX_EXTRA_POLICY --param=STARTING_RPM_OVS=$STARTING_RPM_OVS --param=OVS_LATEST_STREAM_PKG=$OVS_LATEST_STREAM_PKG --param=RPM_OVS=$RPM_OVS --param=LEAPP_UPGRADE=$LEAPP_UPGRADE --wb "($dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_upgrade, LEAPP UPGRADE: $LEAPP_UPGRADE $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

rm -f *.xml	
popd 2>/dev/null
