#!/bin/bash

# ovs_upgrade

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
LEAPP_UPGRADE=${LEAPP_UPGRADE:-"no"}
#leapp_upgrade_repo=${leapp_upgrade_repo:-"http://file.emea.redhat.com/~mreznik/tmp/leapp_upgrade_repositories.repo"}

ALPHA=( {A..Z} )
alpha_increment () { echo ${ALPHA[${i:-0}]}; ((i++)) ;}
alpha_decrement () { echo ${ALPHA[${i:-0}]}; ((i--)) ;}

source incr_string.sh
source decr_string.sh

COMPOSE_VER=$(echo $COMPOSE | awk -F"-" '{print $2}' | awk -F "." '{print $1}')
FDP_RELEASE_ALPHA=$(echo $FDP_RELEASE | tr -d {0-9})
FDP_RELEASE_INT=$(echo $FDP_RELEASE | tr -d {A-Z})
if [[ $FDP_RELEASE_ALPHA == "A" ]]; then
	FDP_RELEASE_ALPHA_START="J"
	FDP_RELEASE_INT_START=$((FDP_RELEASE_INT-1))
	export STARTING_FDP_RELEASE="$FDP_RELEASE_INT_START""$FDP_RELEASE_ALPHA_START"
else
	STARTING_FDP_RELEASE=$(decr_string $FDP_RELEASE)
	# add logic in scenario where previous expected release is not present in package_list.sh
	if [[ ! $(grep -i "$STARTING_FDP_RELEASE" ~/git/kernel/networking/openvswitch/common/package_list.sh) ]]; then
		export STARTING_FDP_RELEASE=$(decr_string $STARTING_FDP_RELEASE)
	else
		export STARTING_FDP_RELEASE=$(decr_string $FDP_RELEASE)
	fi	
fi

if [[ -z $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY ]]; then
	STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_VALUE=OVS_SELINUX_"$STARTING_FDP_RELEASE"_RHEL"$COMPOSE_VER"
	export STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$(grep $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY_VALUE ~/git/kernel/networking/openvswitch/common/package_list.sh  | awk -F "=" '{print $2}')
fi

if [[ -z $STARTING_RPM_OVS ]]; then
	FDP_STREAM_VALUE=$(echo $FDP_STREAM | tr -d ".")
	STARTING_RPM_OVS_VALUE=OVS"$FDP_STREAM_VALUE"_"$STARTING_FDP_RELEASE"_RHEL"$COMPOSE_VER"
	export STARTING_RPM_OVS=$(grep $STARTING_RPM_OVS_VALUE ~/git/kernel/networking/openvswitch/common/package_list.sh  | awk -F "=" '{print $2}')
fi

if [[ -z $OVS_LATEST_STREAM_PKG ]]; then
	start_line=$(grep -n "FDP $FDP_RELEASE Packages" ~/git/kernel/networking/openvswitch/common/package_list.sh | awk -F":" '{print $1}')	
	export OVS_LATEST_STREAM_PKG=$(tail -n +$start_line ~/git/kernel/networking/openvswitch/common/package_list.sh | grep OVS | grep RHEL"$COMPOSE_VER" | tail -3 | head -n1 | awk -F "=" '{print$2}')
fi

pushd ~/git/kernel/networking/openvswitch/ovs_upgrade
dut=${dut:-"netqe40.knqe.lab.eng.bos.redhat.com"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

lstest | runtest $COMPOSE  --arch=x86_64 --machine=$dut --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM --param=NAY=yes --param=STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$STARTING_RPM_OVS_SELINUX_EXTRA_POLICY --param=STARTING_RPM_OVS=$STARTING_RPM_OVS --param=OVS_LATEST_STREAM_PKG=$OVS_LATEST_STREAM_PKG --param=RPM_OVS=$RPM_OVS --param=LEAPP_UPGRADE=$LEAPP_UPGRADE --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_upgrade, LEAPP UPGRADE: $LEAPP_UPGRADE $brew_build $special_info"
	
popd
