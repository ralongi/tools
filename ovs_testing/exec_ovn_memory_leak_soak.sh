#!/bin/bash

# OVN memory_leak_soak

dbg_flag=${dbg_flag:-"set +x"}
$dbg_flag
pushd ~/git/kernel/networking/openvswitch/ovn/soak_test
echo "CWD is: $(pwd)"
fdp_release=$FDP_RELEASE
NIC_DRIVER=${NIC_DRIVER:-"i40e"}
export loop_round=100
server="netqe21.knqe.lab.eng.bos.redhat.com"
client="netqe44.knqe.lab.eng.bos.redhat.com"
#netscout_pair1="netqe20_p5p1 netqe21_p5p1"
#netscout_pair2="netqe20_p5p2 netqe21_p5p2"
#netscout_cable $netscout_pair1
#netscout_cable $netscout_pair2
#netscout_show_connections bos_3903

IMG_GUEST=${IMG_GUEST:-"http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/vms/OVS/${image_name}"}
SRC_NETPERF=${SRC_NETPERF:-"http://netqe-infra01.knqe.lab.eng.bos.redhat.com/share/tools/netperf-20160222.tar.bz2"}

if [[ "$skip_rhel7_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL7
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7
	RPM_OVN_COMMON=$RPM_OVN_211_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	
	#QEMU_KVM_RHEV=$QEMU_KVM_RHEV_RHEL7

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"
fi


if [[ "$skip_rhel7_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-7
	compose=$RHEL7_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL7
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL7
	RPM_OVN_COMMON=$RPM_OVN_213_RHEL7
	image_name=$RHEL7_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	lstest | runtest $compose  --variant=server --arch=x86_64 --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs211" != "yes" ]]; then
	# OVS 2.11, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS211_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	RPM_OVN_COMMON=$RPM_OVN_211_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs213" != "yes" ]]; then
	# OVS 2.13, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS213_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	RPM_OVN_COMMON=$RPM_COMMON_OVN213_RHEL8
	RPM_OVN_CENTRAL=$RPM_CENTRAL_OVN213_RHEL8
	RPM_OVN_HOST=$RPM_HOST_OVN213_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	#lstest | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"

	lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"
fi

if [[ "$skip_rhel8_ovs215" != "yes" ]]; then
	# OVS 2.15, RHEL-8
	compose=$RHEL8_COMPOSE
	RPM_OVS=$RPM_OVS215_RHEL8
	RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY_RHEL8
	RPM_OVN_COMMON=$RPM_COMMON_OVN2021_RHEL8
	RPM_OVN_CENTRAL=$RPM_CENTRAL_OVN2021_RHEL8
	RPM_OVN_HOST=$RPM_HOST_OVN2021_RHEL8
	image_name=$RHEL8_VM_IMAGE
	ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')	

	#lstest | runtest $compose  --repo "http://download.devel.redhat.com/nightly/latest-BUILDROOT-8-RHEL-8/compose/Buildroot/x86_64/os" --variant=BaseOS --arch=x86_64 --ks-meta "$ks_meta" --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"

	lstest | runtest $compose  --variant=BaseOS --arch=x86_64 --machine=$server,$client --systype=machine  --param=dbg_flag="set -x" --param=NAY=yes --param=NIC_DRIVER=$NIC_DRIVER --param=NIC_NUM=2 --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --param=RPM_OVN_COMMON=$RPM_OVN_COMMON --param=loop_round=$loop_round --wb "$fdp_release, $ovs_rpm_name, $compose, openvswitch/ovn/soak_test, Driver: $NIC_DRIVER"
fi
	
popd
