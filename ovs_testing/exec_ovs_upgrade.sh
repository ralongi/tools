#!/bin/bash

# ovs_upgrade

dbg_flag="set -x"

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
	export STARTING_FDP_RELEASE=$(decr_string $FDP_RELEASE)
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
	export OVS_LATEST_STREAM_PKG=$(tail ~/git/kernel/networking/openvswitch/common/package_list.sh | grep OVS | grep RHEL"$COMPOSE_VER" | tail -1 | awk -F "=" '{print$2}')
fi

pushd ~/git/kernel/networking/openvswitch/ovs_upgrade
dut=${dut:-"netqe9.knqe.lab.eng.bos.redhat.com"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')

lstest | runtest $COMPOSE  --arch=x86_64 --machine=$dut --systype=machine  --param=dbg_flag="set -x" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM --param=NAY=yes --param=STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$STARTING_RPM_OVS_SELINUX_EXTRA_POLICY --param=STARTING_RPM_OVS=$STARTING_RPM_OVS --param=OVS_LATEST_STREAM_PKG=$OVS_LATEST_STREAM_PKG --param=RPM_OVS=$RPM_OVS --wb "FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/ovs_upgrade"
	
popd
