#!/bin/bash

# power_cycle_crash

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
dut=${dut:-"netqe05.knqe.eng.rdu2.dc.redhat.com"}
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
if [[ -z $arch ]]; then
	if [[ $dut == "netqe49.knqe.eng.rdu2.dc.redhat.com" ]]; then
		arch="aarch64"
		RPM_OVS=$(echo $RPM_OVS | sed 's/x86_64/aarch64/g')
		image_name="rhel9.4.aarch64.64k.qcow2"
	else
		arch="x86_64"
	fi
fi
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
COMPOSE_VER_MINOR=$(echo $COMPOSE | awk -F "-" '{print $2}' | sed s/.0//g)
if [[ -z $image_name ]]; then
	image_name="rhel$COMPOSE_VER_MINOR.qcow2"
fi

image_mode=${image_mode:-"no"}
NAY="${NAY:-"no"}"
PVT="${PVT:-"no"}"
GET_NIC_WITH_MAC="${GET_NIC_WITH_MAC:-"yes"}"
NIC_NUM=2

pushd ~/temp

if [[ $image_mode == "yes" ]]; then
	lstest ~/git/my_fork/kernel/networking/openvswitch/power_cycle_crash/set_config | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --bootc=$COMPOSE --nrestraint --autopath --kernel-options "crashkernel=640M" --packages="grubby sshpass iperf3 virt-viewer virt-install libvirt-daemon virt-manager libvirt qemu-kvm libguestfs guestfs-tools gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq" --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --ks-post "$(cat ~/temp/rhts_power.sh)" --arch=$arch --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=ROLE="STANDALONE" --param=image_name=$image_name --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM -param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=NIC_MAC_STRING="94:6d:ae:d9:23:f4 94:6d:ae:d9:23:f5" --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Standalone: $dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/power_cycle_crash $brew_build $special_info \`Image Mode\`" --append-task="/distribution/utils/power-cycle" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x} {ROLE=STANDALONE}" --append-task="/kernel/networking/openvswitch/common/misc_tasks/crash_sysrq_c {dbg_flag=set -x}" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x} {ROLE=STANDALONE}"
else
	lstest ~/git/my_fork/kernel/networking/openvswitch/power_cycle_crash/set_config | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --ks-post "$(cat ~/temp/rhts_power.sh)" --arch=$arch --machine=$dut --topo=singleHost --systype=machine $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") --param=ROLE="STANDALONE" --param=image_name=$image_name --param=dbg_flag="$dbg_flag" --param=SELINUX=$SELINUX --param=FDP_STREAM=$FDP_STREAM -param=NAY=$NAY --param=PVT=$PVT --param=GET_NIC_WITH_MAC=$GET_NIC_WITH_MAC --param=NIC_MAC_STRING="94:6d:ae:d9:23:f4 94:6d:ae:d9:23:f5" --param=RPM_OVS_SELINUX_EXTRA_POLICY=$RPM_OVS_SELINUX_EXTRA_POLICY --param=RPM_OVS=$RPM_OVS --wb "(Standalone: $dut), FDP $FDP_RELEASE, $ovs_rpm_name, $COMPOSE, openvswitch/power_cycle_crash $brew_build $special_info \`Package Mode\`" --append-task="/distribution/utils/power-cycle" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x} {ROLE=STANDALONE}" --append-task="/kernel/networking/openvswitch/common/misc_tasks/crash_sysrq_c {dbg_flag=set -x}" --append-task="/kernel/networking/openvswitch/power_cycle_crash/check_config {dbg_flag=set -x} {ROLE=STANDALONE}"
fi

popd 2>/dev/null
