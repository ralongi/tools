#!/bin/bash

# vm100

dbg_flag=${dbg_flag:-"set -x"}
$dbg_flag
dut="netqe05.knqe.eng.rdu2.dc.redhat.com"
SYSTYPE=${SYSTYPE:-"machine"}
ovs_rpm_name=$(echo $RPM_OVS | awk -F "/" '{print $NF}')
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"
COMPOSE_VER=$(echo $COMPOSE | awk -F 'RHEL-' '{print $2}' | awk -F '.' '{print $1}')
GIT_HOME=~/git/my_fork
NAY=${NAY:-"yes"}
arch=${arch:-"x86_64"}
image_mode=${image_mode:-"no"}

pushd ~

if [[ $image_mode == "yes" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/vm100 | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --arch=$arch --topo=singlehost --machine=$dut --systype=$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=dbg_flag="$dbg_flag" --param=NAY=no --bootc=$COMPOSE,frompkg --packages="grubby sshpass iperf3 gcc gcc-c++ glibc-devel net-tools zlib-devel pciutils lsof tcl tk git wget nano driverctl dpdk dpdk-tools ipv6calc wireshark-cli nmap-ncat dnsmasq python3-scapy" --nrestraint --wb "(DUT: $dut), VM100 test, $COMPOSE, openvswitch/vm100 $special_info \`Image Mode\`" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"	
elif [[ $image_mode == "no" ]]; then
	lstest $GIT_HOME/kernel/networking/openvswitch/vm100 | runtest --fetch-url kernel@https://gitlab.cee.redhat.com/kernel-qe/kernel/-/archive/master/kernel-master.tar.bz2 $COMPOSE --ks-append="rootpw redhat" --product=$product --retention-tag=$retention_tag --arch=$arch --topo=singlehost --machine=$dut --systype=$SYSTYPE $(echo "$zstream_repo_list") $(echo "$brew_build_cmd") $(echo "$cmds_to_run") --param=dbg_flag="$dbg_flag" --param=NAY=no --wb "(DUT: $dut), VM100 test, $COMPOSE, openvswitch/vm100 $special_info" --insert-task="/kernel/networking/openvswitch/netscout_connect_ports {dbg_flag=set -x} {netscout_pair1=$netscout_pair1} {netscout_pair2=$netscout_pair2}"	
fi

popd 2>/dev/null
