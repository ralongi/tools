#!/bin/bash

# ovs_upgrade

pushd ~/temp

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
LEAPP_UPGRADE=${LEAPP_UPGRADE:-"no"}
#leapp_upgrade_repo=${leapp_upgrade_repo:-"http://file.emea.redhat.com/~mreznik/tmp/leapp_upgrade_repositories.repo"}
dut=${dut:-"wsfd-advnetlab34.anl.eng.rdu2.dc.redhat.com"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

RHEL_VER_MAJOR=$(echo $COMPOSE | awk -F "-" '{print $2}' | awk -F "." '{print $1}')
RPM_LIST=$(grep -w $(basename $RPM_OVS | awk -F "-" '{print $1}') ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump|selinux')

LATEST_RPM_OVS=$(echo $RPM_LIST | awk '{print $NF}' | awk -F "=" '{print $NF}')
RPM_OVS_VER=$(basename $RPM_OVS | awk -F ".el" '{print $1}' | awk -F "-" '{print $NF}')
LATEST_RPM_OVS_VER=$(basename $LATEST_RPM_OVS | awk -F ".el" '{print $1}' | awk -F "-" '{print $NF}')

if [[ -z $STARTING_RPM_OVS ]]; then
	if [[ $(basename $LATEST_RPM_OVS) == $RPM_OVS ]]; then
		STARTING_RPM_OVS=$(echo $RPM_LIST | awk {'print $(NF-1)}' | awk -F "=" '{print $NF}')
	elif [[ $LATEST_RPM_OVS_VER -lt $RPM_OVS_VER ]]; then
		STARTING_RPM_OVS=$LATEST_RPM_OVS
	fi
fi

STARTING_STREAM=$(grep $STARTING_RPM_OVS ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | awk -F "_" '{print $2}')

if [[ -z $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY ]]; then
	STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$(grep $STARTING_STREAM ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep -i selinux | grep RHEL$RHEL_VER_MAJOR | awk -F "=" '{print $NF}')
fi

if [[ -z $OVS_LATEST_STREAM_PKG ]]; then
	OVS_LATEST_STREAM_PKG=$(grep OVS ~/git/my_fork/kernel/networking/openvswitch/common/package_list.sh | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump|selinux' | tail -n1 | awk -F "=" '{print $NF}')
fi

FDP_STREAM=$(basename $RPM_OVS | awk -F "-" '{print $1}' | sed s/openvswitch//g )

lstest ~/git/my_fork/kernel/networking/openvswitch/ovs_upgrade | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE  --arch=x86_64 --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=FDP_STREAM=$FDP_STREAM --param=NAY=yes --param=STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$STARTING_RPM_OVS_SELINUX_EXTRA_POLICY --param=STARTING_RPM_OVS=$STARTING_RPM_OVS --param=OVS_LATEST_STREAM_PKG=$OVS_LATEST_STREAM_PKG --param=RPM_OVS=$RPM_OVS --param=LEAPP_UPGRADE=$LEAPP_UPGRADE --wb "($dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_upgrade, LEAPP UPGRADE: $LEAPP_UPGRADE $brew_build $special_info" --append-task="/kernel/networking/openvswitch/crash_check {dbg_flag=set -x}"

rm -f *.xml	
popd 2>/dev/null
