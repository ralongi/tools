#!/bin/bash

# Endurance

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

#TREX_COMPOSE=${TREX_COMPOSE:-"RHEL-8.4.0-updates-20231107.24"}
echo "DUT/SERVER COMPOSE is: $COMPOSE"
echo "TREX/CLIENT COMPOSE is: $TREX_COMPOSE"

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/perf
task="~/git/kernel/networking/openvswitch/perf"
rhel_minor_ver=$(echo $COMPOSE | awk -F - '{print $2}' | sed 's/.0//g')
rhel_major_ver=$(echo $COMPOSE | awk -F - '{print $2}' | awk -F . '{print $1}') 
card_type=$(echo $1 | tr '[:upper:]' '[:lower:]')
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
image="http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/vms/OVS/rhel$rhel_minor_ver.qcow2"
trex_url="http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/tools/v3.03.tar.gz"
trafficgen_url="http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/tools/trafficgen-20210903.tgz"
arch=${arch:-"x86_64"}

# strip any spaces from $COMPOSE value
COMPOSE=$(echo $COMPOSE | tr -d " ")

# Change format of $FDP_RELEASE due to change in Guan's code to upload db
FDP_RELEASE=$(echo ${FDP_RELEASE:0:2}.${FDP_RELEASE:2:2})
#####FDP_RELEASE="'$FDP_RELEASE'"

# card types: cx5, cx6dx, cx6lx, bf2

if [[ $card_type == "cx5" ]]; then
	nic_test="mlx5_100g_cx5"
	card_info="100G CX5"
	SERVER="netqe25.knqe.eng.rdu2.dc.redhat.com"
	CLIENT="netqe24.knqe.eng.rdu2.dc.redhat.com"
	netscout_pair1="NETQE24_P4P1 NETQE25_P5P1"
	netscout_pair2="NETQE24_P4P2 NETQE25_P5P2"
	#SERVER="netqe4.knqe.lab.eng.bos.redhat.com"
	#CLIENT="netqe1.knqe.lab.eng.bos.redhat.com"
	if [[ $(echo $COMPOSE | grep 'RHEL-9') ]]; then
		test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx5_netqe25_netqe24_rhel9_endurance
		#test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx5_netqe4_netqe1_rhel9_endurance
	elif [[ $(echo $COMPOSE | grep 'RHEL-8') ]]; then
		test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx5_netqe25_netqe24_rhel8_endurance
		#test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx5_netqe4_netqe1_rhel8_endurance
	fi
elif [[ $card_type == "cx6dx" ]]; then
	nic_test="mlx5_100g_cx6dx"
	card_info="100G CX6 DX"
	SERVER=netqe24.knqe.eng.rdu2.dc.redhat.com
	CLIENT=netqe25.knqe.eng.rdu2.dc.redhat.com
	#SERVER="netqe1.knqe.lab.eng.bos.redhat.com"
	#CLIENT="netqe4.knqe.lab.eng.bos.redhat.com"
	if [[ $(echo $COMPOSE | grep 'RHEL-9') ]]; then
		test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx6dx_netqe24_netqe25_rhel9_endurance
		#test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx6dx_netqe1_netqe4_rhel9_endurance
	elif [[ $(echo $COMPOSE | grep 'RHEL-8') ]]; then
		test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx6dx_netqe24_netqe25_rhel8_endurance
		#test_env=http://netqe-infra01.knqe.eng.rdu2.dc.redhat.com/share/ralongi/mlx5_100g_cx6dx_netqe1_netqe4_rhel8_endurance
	fi
elif [[ $card_type == "cx6lx" ]]; then
	nic_test="mlx5_25g_cx6lx"
	card_info="25G CX6 LX"
	SERVER="wsfd-advnetlab35.anl.eng.rdu2.dc.redhat.com"
	CLIENT="wsfd-advnetlab36.anl.eng.rdu2.dc.redhat.com"
	if [[ $(echo $COMPOSE | grep 'RHEL-9') ]]; then
		test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_25g_cx6lx_anl35_anl36_rhel9_endurance
	elif [[ $(echo $COMPOSE | grep 'RHEL-8') ]]; then
		test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_25g_cx6lx_anl35_anl36_rhel8_endurance
	fi
elif [[ $card_type == "bf2" ]]; then
	nic_test="mlx5_25g_bf2"
	card_info="25G BF2"
	SERVER="netqe30.knqe.eng.rdu2.dc.redhat.com"
	CLIENT="netqe29.knqe.eng.rdu2.dc.redhat.com"
	netscout_pair1="netqe29_p3p1 netqe30_p7p1"
	netscout_pair2="netqe29_p3p2 netqe30_p7p2"
	if [[ $(echo $COMPOSE | grep 'RHEL-9') ]]; then
		test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_25g_bf2_netqe30_netqe29_rhel9_endurance
	elif [[ $(echo $COMPOSE | grep 'RHEL-8') ]]; then
		test_env=http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/ralongi/mlx5_25g_bf2_netqe30_netqe29_rhel8_endurance
	fi
fi

if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then
    runtest \
    --product=cpe:/o:redhat:enterprise_linux \
    --retention-tag=active+1 \
    --distro=$COMPOSE \
    --family=RedHatEnterpriseLinux$rhel_major_ver \
    --variant=BaseOS \
    --arch=$arch \
    --servers=1 \
    --clients=1 \
    --systype=machine \
    --machine="$SERVER,$CLIENT" \
    --kernel-options-post="pci=realloc intel_iommu=on" \
    --task="/kernel/networking/openvswitch/perf" \
    --param=test_env=$test_env \
    --param=nic_test=$nic_test \
    --param=trex_url=$trex_url \
    --param=trafficgen_url=$trafficgen_url \
    --param=image=$image \
    --param=rpm_openvswitch_selinux_extra_policy=$RPM_OVS_SELINUX \
    --param=rpm_ovs=$RPM_OVS \
    --param=fdp_release=$FDP_RELEASE \
    --wb="(Server/DUT: $SERVER, Client/Trex: $CLIENT) FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/perf Endurance ($card_info)" \
    --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"
else
    runtest \
    --product=cpe:/o:redhat:enterprise_linux \
    --retention-tag=active+1 \
    --distro=$COMPOSE \
    --family=RedHatEnterpriseLinux$rhel_major_ver \
    --variant=BaseOS \
    --arch=$arch \
    --servers=1 \
    --clients=1 \
    --systype=machine \
    --machine="$SERVER,$CLIENT" \
    --kernel-options-post="pci=realloc intel_iommu=on" \
    --task="/kernel/networking/openvswitch/perf" \
    --param=test_env=$test_env \
    --param=nic_test=$nic_test \
    --param=trex_url=$trex_url \
    --param=trafficgen_url=$trafficgen_url \
    --param=image=$image \
    --param=rpm_openvswitch_selinux_extra_policy=$RPM_OVS_SELINUX \
    --param=rpm_ovs=$RPM_OVS \
    --param=fdp_release=$FDP_RELEASE \
    --wb="(Server/DUT: $SERVER, Client/Trex: $CLIENT) FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/perf Endurance ($card_info)"    
fi

popd
